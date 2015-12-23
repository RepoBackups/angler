#!/sbin/sh
#ramdisk_gov_sed.sh by show-p1984
#Features:
#extracts ramdisk
#finds busbox in /system or sets default location if it cannot be found
#add init.d support if not already supported
#removes governor overrides
#removes min freq overrides
#repacks the ramdisk

mkdir /tmp/ramdisk
cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/
cd /tmp/ramdisk/
gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | cpio -i
cd /

#Don't force encryption
if  grep -qr forceencrypt /tmp/ramdisk/fstab.angler; then
   sed -i "s/forceencrypt/encryptable/" /tmp/ramdisk/fstab.angler
fi

#Disable dm_verity
if  grep -qr verify=/dev/block/platform/msm_sdcc.1/by-name/metadata /tmp/ramdisk/fstab.angler; then
   sed -i "s/\,verify\=\/dev\/block\/platform\/msm_sdcc\.1\/by\-name\/metadata//" /tmp/ramdisk/fstab.angler
fi
rm /tmp/ramdisk/verity_key

ui_print "Install ukm...";
rm -rf /data/UKM/*;
rm -rf /system/etc/init.d/UKM;
rm -rf /system/xbin/uci;
rm -rf /system/addon.d/UKM.sh;
cp -f /tmp/data/* /data;
mkdir /system/addon.d;
set_perm_recursive 0 0 0755 0755 /system/addon.d;
cp -f /tmp/data/UKM/uci /system/xbin/uci;
cp -f /tmp/data/UKM/UKM /system/etc/init.d/UKM;
cp -f /tmp/data/UKM/UKM.sh /system/addon.d/UKM.sh;
set_perm_recursive 0 0 0755 0755 /data/UKM;
set_perm_recursive 0 0 0755 0755 /system/xbin/uci;
set_perm_recursive 0 0 0755 0755 /system/etc/init.d/UKM;
set_perm_recursive 0 0 0755 0755 /system/addon.d/UKM.sh;

rm /tmp/ramdisk/boot.img-ramdisk.gz
rm /tmp/boot.img-ramdisk.gz
cd /tmp/ramdisk/
find . | cpio -o -H newc | gzip > ../boot.img-ramdisk.gz
cd /
rm -rf /tmp/ramdisk

