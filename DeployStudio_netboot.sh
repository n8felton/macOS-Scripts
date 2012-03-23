#!/bin/sh

###Global Variables ###
SERVER="deploystudio.example.com"
SERVERIP=$(dig $SERVER +short)
SHAREPOINT="NetBootSP0"
IMAGENAME="NetInstall.dmg"
PROTOCOL="nfs"
SIMPLE="false"
NEXTBOOT="--nextonly"
BLESSVER=$(bless -version | cut -d. -f1)

# Turn the volume on so we can hear the "BONGGGGG"
osascript -e 'set volume output volume 100'

# DEBUG
# Turn on verbose booting so that we can see what's going on.
nvram boot-args="-v"

if [ $BLESSVER -lt 76 ]; then 
	#For use with Snow Leopard
	SETNAME="DS-10.6.8.nbi"
	KERNEL="--kernel"
	KERNELFILE="i386/mach.macosx"
else
	#For use with Lion
	SETNAME="DS-10.7.3.nbi"
	KERNEL="--kernelcache"
	KERNELFILE="i386/x86_64/kernelcache"
fi

/usr/sbin/bless --netboot --booter "tftp://${SERVERIP}/NetBoot/${SHAREPOINT}/${SETNAME}/i386/booter" \
	$KERNEL "tftp://${SERVERIP}/NetBoot/${SHAREPOINT}/${SETNAME}/${KERNELFILE}" \
	--options "rp=${PROTOCOL}:${SERVERIP}:/private/tftpboot/NetBoot/${SHAREPOINT}:${SETNAME}/${IMAGENAME}" \
	$NEXTBOOT
	
reboot