#!/usr/bin/env bash

SWD=$(cd $(dirname $0);echo $PWD)

function get_kitsu_version() {
    if [[ $KITSU_VERSION == "latest" ]]; then
        export KITSU_VERSION=`curl https://api.github.com/repos/cgwire/kitsu/commits | jq -r '.[].commit.message | select(. | test("[0-9]+(\\\\.[0-9]+)+"))?' | grep -m1 ""`
        echo "${GREEN}Set KITSU_VERSION to $KITSU_VERSION"
    fi
}


function get_zou_version(){
    if [[ $ZOU_VERSION == "latest" ]]; then
        export ZOU_VERSION=`curl https://api.github.com/repos/cgwire/zou/commits | jq -r '.[].commit.message | select(. | test("[0-9]+(\\\\.[0-9]+)+"))?' | grep -m1 ""`
        echo "${GREEN}Set ZOU_VERSION to $ZOU_VERSION"
    fi
}

function get_build_dependency() {
    echo "${CYAN}GET $1 build dependencies"
    git clone -b $1 --single-branch --depth 1 https://github.com/TamTahiti/Docker-Kitsu.git $SWD/$1 || :

    if $FORCE && $UPDATE; then
        git -C $SWD/$1 reset --hard || :
    fi
    if $UPDATE; then
        git -C $SWD/$1 pull --rebase || :
    fi
}

function check_dependencies(){
    failed=false
    if [ ! -e "$SWD/kitsu/Dockerfile" ]; then
        echo "${ERROR}Kitsu Dockerfile required"
        failed=true
    fi
    if [ ! -e "$SWD/zou/Dockerfile" ]; then
        echo "${ERROR}Zou Dockerfile required"
        failed=true
    fi
    if $failed; then
        get_build_dependency kitsu
        get_build_dependency zou
    fi
}


function build_images() {
    echo "${MAGENTA}BUILD CONTAINERS"

    check_dependencies

    command -v curl 1>/dev/null || { echo "${ERROR}curl required" && exit 1; }
    command -v jq 1 >/dev/null || { echo "${ERROR}jq required" && exit 1; }

    get_kitsu_version
    get_zou_version
    COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 \
    dc -f docker-compose.yml
}


function compose_up() {
    echo "${YELLOW}START CONTAINERS"
    dc -f docker-compose.yml \
                    up -d
}


function compose_down() {
    echo "${YELLOW}STOP CONTAINERS"
    dc down
}


function init_zou() {
    dbowner=postgres
    dbname=zoudb

    if dc exec db psql -U ${dbowner} ${dbname} -c '' 2>&1; then
        echo "${GREEN}UPGRADE ZOU"
        dc exec zou-app sh /upgrade_zou.sh
    else
        echo "${GREEN}INIT ZOU"
        dc exec db  su - postgres -c "createdb -T template0 -E UTF8 --owner ${dbowner} ${dbname}"
        dc exec zou-app zou reset-search-index
        dc exec zou-app sh /init_zou.sh
    fi
}

# --------------------------------------------------------------
# ---------------------------- ARGS ----------------------------
# --------------------------------------------------------------

source $SWD/common.sh
echo "${BLUE}PARSE ARGS"

DOWN=false
case $1 in
  down)
    DOWN=true
    echo "${CYAN}STOP INSTANCE"
    shift
    ;;
esac

UPDATE=false
FORCE=false
export ENV_FILE=$SWD/.env
for i in "$@"; do
    case $i in
        -e=* | --env=*)
            export ENV_FILE="${i#*=}"
            echo "${CYAN}USE CUSTOM ENV FILE"
            shift
            ;;
        --update)
            UPDATE=true
            echo "${CYAN}UPDATE DEPENDENCIES"
            shift
            ;;
        --force)
            FORCE=true
            echo "${MAGENTA}/!\\ FORCE UPDATE /!\\ "
            shift
            ;;
        -h | --help)
            echo "
    Usage:

        build.sh [subcommand] [options]

    Subcommand:
        down                    Compose Down the stack

    Options:
        -e, --env=ENV_FILE      Set custom env file. If not set ./env is used

        --update            Pull dependencies if clone fails
        --force             Combine with `--update`. Hard reset instead of pull.

        -h, --help              Show this help
                "
            exit 0
        ;;
        *)
            echo "${ERROR}Invalid flag ${i} // Use -h or --help to print help"
            exit 1
        ;;
    esac
done

if $FORCE && ! $UPDATE; then
    echo "${ERROR}Force flag works with 'update' flag only"
    exit 1
fi


# --------------------------------------------------------------
# ---------------------------- MAIN ----------------------------
# --------------------------------------------------------------

source_env ${ENV_FILE}

compose_down

if ! $DOWN ; then
    build_images
    compose_up
    init_zou
fi
