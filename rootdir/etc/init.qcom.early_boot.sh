#! /vendor/bin/sh

# Copyright (c) 2012-2013,2016,2018-2020 The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

export PATH=/vendor/bin

baseband=`getprop ro.baseband`
#enable atfwd daemon all targets except sda, apq, qcs
case "$baseband" in
    "apq" | "sda" | "qcs" )
        setprop persist.vendor.radio.atfwd.start false;;
    *)
        setprop persist.vendor.radio.atfwd.start true;;
esac

# check for the type of driver FB or DRM
fb_driver=/sys/class/graphics/fb0
if [ -e "$fb_driver" ]
then
    # check for mdp caps
    file=/sys/class/graphics/fb0/mdp/caps
    if [ -f "$file" ]
    then
        setprop vendor.gralloc.disable_ubwc 1
        cat $file | while read line; do
          case "$line" in
                    *"ubwc"*)
                    setprop vendor.gralloc.enable_fb_ubwc 1
                    setprop vendor.gralloc.disable_ubwc 0
                esac
        done
    fi
fi

boot_reason=`cat /proc/sys/kernel/boot_reason`
reboot_reason=`getprop ro.boot.alarmboot`
if [ "$boot_reason" = "3" ] || [ "$reboot_reason" = "true" ]; then
    setprop ro.vendor.alarm_boot true
else
    setprop ro.vendor.alarm_boot false
fi

# copy GPU frequencies to vendor property
if [ -f /sys/class/kgsl/kgsl-3d0/gpu_available_frequencies ]; then
    gpu_freq=`cat /sys/class/kgsl/kgsl-3d0/gpu_available_frequencies` 2> /dev/null
    setprop vendor.gpu.available_frequencies "$gpu_freq"
fi
