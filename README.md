# change-mouse-sens
An interactive bash script for changing the mouse (pointer) sensitivity via xinput

The chief motivation for this script is the lack of sensitivity control for libinput devices in XFCE's mouse configuration tool. Instead of setting the sensitivity manually each time via xinput --set-prop, this script provides an interactive interface with a fine control over sensitivity adjustments. Acceleration control is not implemented.

Make sure to pick the appropriate device, and don't pick a virtual device. The selection options list all the available pointer devices "just in case".

The settings will be reset on reboot. If you wish to make a sensitivity change script that autostarts with your graphical environment, first, use xinput | grep "DEVICENAME", isolate the id number of the device and call xinput --set-prop "IDNUM" 'Coordinate Transformation Matrix' <elements of the matrix>. The very last element is the one that this script changes to adjust the sensitivity, so whatever sensitivity you've found comfortable when playing with the script, change this last element to that. Example:

id=$(xinput | grep "DEVICENAME" | awk -F'id=' '{print $2}' | cut -f1)

xinput --set-prop "$id" 'Coordinate Transformation Matrix' 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, "DESIRED_SENSITIVITY"

Replace DEVICENAME with a name (perhaps partial) of your device and DESIRED_SENSITIVITY with just that.
