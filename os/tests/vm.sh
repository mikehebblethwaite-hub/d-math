#!/bin/bash
# Delta Hex OS test machine: QEMU + OVMF on its own fresh FAT32 image in os/tests/run/ (never os/esp.img, which is Mike's),
# no display, the serial line and the monitor on sockets. Needs sudo for the loop mount (putting the program on the image).
#   ./vm.sh [program.efi]   (default: builds os/start.delta)
here=$(dirname "$(readlink -f "$0")"); R=$here/run; mkdir -p $R; cd $R
pkill -A -f 'qemu-system-x86_64 -name deltatest' 2>/dev/null; sleep 1
EFI=${1:-}; if [ -z "$EFI" ]; then (cd $here/../.. && lang/delta efi os/start.delta -o $R/test.efi) || exit 1; EFI=$R/test.efi; fi
rm -f esp.img ser.sock mon.sock; dd if=/dev/zero of=esp.img bs=1M count=64 status=none && /usr/sbin/mkfs.vfat -F 32 -n DELTA esp.img >/dev/null
M=$(mktemp -d); sudo mount -o loop,uid=$(id -u) esp.img "$M" && mkdir -p "$M/EFI/BOOT" && cp "$EFI" "$M/EFI/BOOT/BOOTX64.EFI" && sudo umount "$M"; rmdir "$M"
setsid qemu-system-x86_64 -name deltatest -bios /usr/share/ovmf/OVMF.fd -drive format=raw,file=esp.img -m 1024 -net none \
  -device qemu-xhci -device usb-tablet -display none -vga std \
  -serial unix:ser.sock,server,nowait -monitor unix:mon.sock,server,nowait > qemu.log 2>&1 < /dev/null &
