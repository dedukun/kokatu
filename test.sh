#!/bin/sh

#############################################
#======= C O N F I G U R A T I O N S =======#
#############################################

locate_db="/tmp/test_mlocate.db"
kokatu_uncompressed_db="/tmp/test_kokatu.db"
kokatu_compressed_db="/tmp/test_kokatu_compressed.db"

kokatu_binary="./kokatu"

#############################################
#=== A U X I L I A R   F U N C T I O N S ===#
#############################################

_exit_error() {
    printf "\nERROR: %s\n" "$1" >&2
    exit 1
}

_check_command() {
    command -v "$1" >/dev/null || _exit_error "'$1' is not installed"
}

_disable_compression() {
    sed -i 's/compression="Y"/compression=""/' "$kokatu_binary"
}

_enable_compression() {
    sed -i 's/compression=""/compression="Y"/' "$kokatu_binary"
}

_disable_auto_removes() {
    sed -i 's/rm/#rm/' "$kokatu_binary"
}

_enable_auto_removes() {
    sed -i 's/#rm/rm/' "$kokatu_binary"
}

#############################################
#======= T E S T   F U N C T I O N S =======#
#############################################

check_for_commands() {
    printf "\nChecking for commands..."

    _check_command rg
    _check_command fd
    _check_command lz4
    _check_command locate
    _check_command updatedb
    _check_command perf
    _check_command hyperfine

    printf " OK\n"
}

create_databases() {
    printf "\nCreating Databases\n"

    sudo touch "$kokatu_uncompressed_db"
    sudo touch "$kokatu_compressed_db"
    sudo touch "$locate_db"

    printf "  Locate - "
    perf stat sudo updatedb -o "$locate_db" 2>&1 >/dev/null | grep "time elapse" | awk '{print $1}'

    _disable_auto_removes
    _disable_compression

    printf "  Kokatu (no compression) - "
    perf stat sudo $kokatu_binary -d "$kokatu_uncompressed_db" -u 2>&1 >/dev/null | grep "time elapse" | awk '{print $1}'

    _enable_compression

    printf "  Kokatu (compression) - "
    perf stat sudo $kokatu_binary -d "$kokatu_compressed_db" -u 2>&1 >/dev/null | grep "time elapse" | awk '{print $1}'

    _disable_compression
    _enable_auto_removes
}

print_entries_number() {
    printf "\nEntries Number\n"
    printf "  Locate - "
    locate -d "$locate_db" -c -r ".*"

    printf "  Kokatu (no compression) - "
    $kokatu_binary -d "$kokatu_uncompressed_db" -c ".*"

    printf "  Kokatu (compression) - "
    $kokatu_binary -d "$kokatu_compressed_db.lz4" -c ".*"
}

print_db_sizes() {
    printf "\nDatabase Size\n"
    printf "  Locate - "
    du -h "$locate_db" | awk '{print $1}'

    printf "  Kokatu (no compression) - "
    du -h "$kokatu_uncompressed_db" | awk '{print $1}'

    printf "  Kokatu (compression) - "
    du -h "$kokatu_compressed_db.lz4" | awk '{print $1}'
}

performance_test() {
    printf "\nPerformance Test\n"
    hyperfine --warmup 3 "locate -d $locate_db README.md" "$kokatu_binary -d $kokatu_uncompressed_db README.md" "$kokatu_binary -d $kokatu_compressed_db.lz4 README.md"
}

clean_up() {
    printf "\nCleaning Up\n"
    sudo rm "$locate_db"
    sudo rm "$kokatu_uncompressed_db"
    sudo rm "$kokatu_compressed_db"
}

#############################################
#================= M A I N =================#
#############################################

echo "Start Testing"

check_for_commands

create_databases

print_entries_number
print_db_sizes

performance_test

clean_up

printf "\nFinished\n"
