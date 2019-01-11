#!/bin/bash

# Changes the mouse sensitivity via xinput by changing the last
# element of the Coordinate Transformation Matrix of the pointer
# device.

# read char in raw mode
read_char() {
  stty -icanon -echo
  eval "$1=\$(dd bs=1 count=1 2>/dev/null)"
  stty icanon echo
}

# initial device selection
select_device() {
    clear

    DEVS="$(xinput --list --short | grep pointer | \
            cut -d ' ' -f 1 --complement)"

    #print and count the devices
    dev_total=0
    IFS=$'\n'
    for i in $DEVS; do
        ((++dev_total))
        echo "$dev_total. $i"
    done
    unset IFS

    # select the device, for ease of use we use natural numbers for selection
    # instead of letting the user put the device's id as per xinput's output
    printf "\nPlease select the device (1-%s) or press q to quit: " "$dev_total"
    readonly INT_RE='^[0-9]+$' # regexp for matching integers
    c=''
    while 'true'; do
        read_char c

        if [ "$c" = "q" ]; then
            echo "$c"
            exit
        fi

        if [[ $c =~ $INT_RE ]]; then
            if [[ $c -le $dev_total ]]; then
                echo "$c"
                break
            fi
        fi
    done

    # isolate the device's id based on user selection
    j=0
    IFS=$'\n'
    for i in $DEVS; do
        ((++j))
        if ((j == c)); then
            # device's xinput id
            ID="$(echo "$i" | awk -F "=" '{print $2}' | cut -f 1)"
            return
        fi
    done
    unset IFS
}

# internal for sens_loop
print_sens_loop_info() {
    printf "Original sensitivity: %s\n" "$(echo "$DEF_COORMAT" | cut -d ' ' -f9)"
    printf "Current sensitivity: %s\n" "$sens"
    printf "Step: %s\n" "$step"
    printf "\nSensitivity: j/k (higher is slower, lower is faster)\n"
    printf "Step: h/l\n"
    printf "Press S to save the settings and quit\n"
    printf "Press q to quit without saving the settings\n"
}

# change the sensitivity
sens_loop() {
    # requires ID from select_device to be set

    readonly DEF_COORMAT="$(xinput --list-props 10 | grep Coor | cut -f3)"
    step="0.010000"
    while [ "$c" != "S" ] # S will quit while saving the settings
    do
        sens="$(xinput --list-props "$ID" | grep Coor | \
                cut -f 3 | cut -d ' ' -f 9)"

        coor_mat="$(xinput --list-props "$ID" | grep Coor | \
                    cut -f3 | cut -d ' ' -f9 --complement)"

        clear
        print_sens_loop_info

        read_char c
        case "$c" in
        "j") # sens down
            sens="$(echo "$sens $step" | awk '{printf "%f", $1 - $2}')"
            ;;
        "k") # sens up
            sens="$(echo "$sens $step" | awk '{printf "%f", $1 + $2}')"
            ;;
        "h") # step up
            if [ "$(echo "$step > 100" | bc)" = "0" ]; then
                step="$(echo "$step" | awk '{printf "%f", $1 * 10}')"
            fi
            ;;
        "l") # step down
            if [ "$(echo "$step < 0.00001" | bc)" = "0" ]; then
                step="$(echo "$step" | awk '{printf "%f", $1 / 10}')"
            fi
            ;;
        "q") # quit without saving
            xinp_args="xinput --set-prop $ID \
                       'Coordinate Transformation Matrix' $DEF_COORMAT"
            eval "$xinp_args"
            exit
            ;;
        esac

        coor_mat+=" $sens"
        xinp_args="xinput --set-prop $ID \
                   'Coordinate Transformation Matrix' $coor_mat"
        eval "$xinp_args"
    done
}

select_device
sens_loop
