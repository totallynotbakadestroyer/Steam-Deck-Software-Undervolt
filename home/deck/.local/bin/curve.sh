#!/usr/bin/env bash
# LICENSE MIT

VERSION='0.0.1'

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PATH=$PATH:$SCRIPT_DIR

MAGNITUDE_MASK='0xFFFFF'

if ! ryzenadj --help &> /dev/null; then
    echo 'ryzenadj tool not found.'
    exit 1
fi

WITH_CONFIRM=yes

usage() {
    echo "Usage: $(basename $0) [options/settings]"
    echo
    echo 'Options'
    echo '    -y|--yes          Bypass confirm prompt message'
    echo '    -h|--help         Show this help message and exit'
    echo '    -v|--version      Show information about program version'
    echo
    echo 'Settings'
    echo '    -0|--core0 (signed value -100/0/100)   First core value'
    echo '    -1|--core1 (signed value -100/0/100)   Second core value'
    echo '    -2|--core2 (signed value -100/0/100)   Third core value'
    echo '    -3|--core3 (signed value -100/0/100)   Four core value'
    echo
    echo 'Example'
    echo '    This settings will perform undervolt with -30 magnitude by each core:'
    echo "      > $(basename $0) -0 -30 -1 -30 -2 -30 -3 -30"
    echo '      or'
    echo '      > $(basename $0) --core0 -30 --core1 -30 --core2 -30 --core3 -30'
    echo
    version
}

version() {
    echo 'WARNING: Use at your own risk!'
    echo 'This script required ryzenadj tool'
    echo 'By Aleksey Tarasov <deadwenk@gmail.com>'
    echo 'License: MIT'
    echo "Version: $VERSION"
    exit 0
}


validate() {
    if [[ ! $2 =~ ^[+-]?[0-9]+$ ]]; then
        echo "Invalid $1 value: $2. Must be in range -100/100."
        exit 1
    fi
    if [[ $2 -gt 100 ]]; then
        echo "Value in $1 setting must be < than 100. Current value is $2."
        exit 1
    fi
    if [[ $2 -lt -100 ]]; then
        echo "Value in $1 setting must be > than -100. Current value is $2."
        exit 1
    fi
}

apply() {
    for CORE_N in CORE_0 CORE_1 CORE_2 CORE_3; do
        if [ ! -z ${!CORE_N+x} ]; then
            CORE_NUMBER=$(echo ${CORE_N} | tr -d -c 0-9)
            CORE_VALUE=$((${CORE_NUMBER} << 20))
            MAGNITUDE=$((${!CORE_N} & ${MAGNITUDE_MASK}))
            VALUE=$(printf '0x%06X' $((${CORE_VALUE} | ${MAGNITUDE})))
            echo "set ${CORE_N}=${VALUE} (${!CORE_N})"
            ryzenadj --set-coper=${VALUE}
        fi
    done
}

prompt_confirm() {
    while true; do
        read -r -p "${1:-Are you sure? (y/n):} " ANSWER
        case $ANSWER in
            [yY]) echo ; return 1 ;;
            [nN]) return 0 ;;
        esac
    done
}

if [[ $# -eq 0 ]]; then
    usage
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        -[0-4]|--core[0-4])
            CORE_NUMBER=$(echo $1 | tr -d -c 0-9)
            validate $1 $2
            declare CORE_$CORE_NUMBER="$2"
            shift
            shift
            ;;
        -y|--yes)
            WITH_CONFIRM=no
            shift
            ;;
        -h|--help)
            usage
            exit 0
            shift
            ;;
        -v|--version)
            version
            exit 0
            ;;
        -*|--*)
            echo "Unknown option $1"
            usage
            ;;
    esac
done

printf 'Specified core values:\n\n'

for CORE_N in CORE_0 CORE_1 CORE_2 CORE_3; do
    if [ ! -z ${!CORE_N+x} ]; then
        printf "$CORE_N=${!CORE_N}\n"
    fi
done

echo

if [[ $WITH_CONFIRM == 'yes' ]]; then
    prompt_confirm 'This action will apply settings above. Are you sure? (y/n):'
    if [[ $? -eq 0 ]]; then
        echo 'Exiting...'
        exit 0
    fi
fi

apply
