From: "lp4u\@inwind\.it" <lp4u@inwind.it>
Subject: kernel panic
Date: Mon, 27 Sep 2004 11:22:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <I4P0P0$FC87B9CC694AB887F0DC180A63B5222F@libero.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CBriB-0004yy-D6
	for nfs@lists.sourceforge.net; Mon, 27 Sep 2004 02:22:23 -0700
Received: from smtp1.libero.it ([193.70.192.51])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CBri9-0000b9-2n
	for nfs@lists.sourceforge.net; Mon, 27 Sep 2004 02:22:23 -0700
Received: from localhost (172.16.1.83) by smtp1.libero.it (7.0.027-DD01)
        id 40C7315F015E3F39 for nfs@lists.sourceforge.net; Mon, 27 Sep 2004 11:22:15 +0200
Received: from libero.it (172.16.1.108) by smtp3.libero.it (7.0.027-DD01)
        id 40D05CC20089662A for nfs@lists.sourceforge.net; Mon, 27 Sep 2004 11:22:12 +0200
To: "NFS NFS" <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi, 
 
I've a s3c2410 board (BAST architecture), I've compilated a kern=
el 2.6.8.1 with patch 2.6.9-rc2 e 
patch 2.6.9-rc2-bk12. But the board d=
on't start with NFS (with kernel 2.4.26, yes). My 
configuration is: =0D
=
 
# 
# Automatically generated make config: don't edit 
# Linux kernel=
 version: 2.6.8.1 
# Mon Sep 27 10:41:24 2004 
# 
CONFIG_ARM=3Dy 
CON=
FIG_MMU=3Dy 
CONFIG_UID16=3Dy 
CONFIG_RWSEM_GENERIC_SPINLOCK=3Dy 
CONF=
IG_GENERIC_IOMAP=3Dy 
 
# 
# Code maturity level options 
# 
CONFIG_=
EXPERIMENTAL=3Dy 
# CONFIG_CLEAN_COMPILE is not set 
CONFIG_BROKEN=3Dy =

CONFIG_BROKEN_ON_SMP=3Dy 
 
# 
# General setup 
# 
CONFIG_LOCALVER=
SION=3D"" 
CONFIG_SWAP=3Dy 
CONFIG_SYSVIPC=3Dy 
# CONFIG_POSIX_MQUEUE =
is not set 
# CONFIG_BSD_PROCESS_ACCT is not set 
CONFIG_SYSCTL=3Dy =0D
=
# CONFIG_AUDIT is not set 
CONFIG_LOG_BUF_SHIFT=3D17 
# CONFIG_HOTPLUG =
is not set 
# CONFIG_IKCONFIG is not set 
# CONFIG_EMBEDDED is not set =

CONFIG_KALLSYMS=3Dy 
# CONFIG_KALLSYMS_ALL is not set 
# CONFIG_KALLS=
YMS_EXTRA_PASS is not set 
CONFIG_FUTEX=3Dy 
CONFIG_EPOLL=3Dy 
CONFIG_=
IOSCHED_NOOP=3Dy 
CONFIG_IOSCHED_AS=3Dy 
CONFIG_IOSCHED_DEADLINE=3Dy =0D
=
CONFIG_IOSCHED_CFQ=3Dy 
CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy 
CONFIG_SHMEM=3D=
y 
# CONFIG_TINY_SHMEM is not set 
 
# 
# Loadable module support =0D
=
# 
CONFIG_MODULES=3Dy 
# CONFIG_MODULE_UNLOAD is not set 
CONFIG_OBSOL=
ETE_MODPARM=3Dy 
# CONFIG_MODVERSIONS is not set 
CONFIG_KMOD=3Dy 
 =0D
=
# 
# System Type 
# 
# CONFIG_ARCH_CLPS7500 is not set 
# CONFIG_ARCH=
_CLPS711X is not set 
# CONFIG_ARCH_CO285 is not set 
# CONFIG_ARCH_EBS=
A110 is not set 
# CONFIG_ARCH_CAMELOT is not set 
# CONFIG_ARCH_FOOTBR=
IDGE is not set 
# CONFIG_ARCH_INTEGRATOR is not set 
# CONFIG_ARCH_IOP=
3XX is not set 
# CONFIG_ARCH_IXP4XX is not set 
# CONFIG_ARCH_IXP2000 =
is not set 
# CONFIG_ARCH_L7200 is not set 
# CONFIG_ARCH_PXA is not se=
t 
# CONFIG_ARCH_RPC is not set 
# CONFIG_ARCH_SA1100 is not set 
CONF=
IG_ARCH_S3C2410=3Dy 
# CONFIG_ARCH_SHARK is not set 
# CONFIG_ARCH_LH7A=
40X is not set 
# CONFIG_ARCH_OMAP is not set 
# CONFIG_ARCH_VERSATILE_=
PB is not set 
# CONFIG_ARCH_IMX is not set 
 
# 
# S3C24XX Implement=
ations 
# 
CONFIG_ARCH_BAST=3Dy 
# CONFIG_ARCH_H1940 is not set 
# CO=
NFIG_ARCH_SMDK2410 is not set 
# CONFIG_MACH_VR1000 is not set 
CONFIG_=
CPU_S3C2410=3Dy 
 
# 
# S3C2410 Setup 
# 
CONFIG_S3C2410_DMA=3Dy =0D
=
# CONFIG_S3C2410_DMA_DEBUG is not set 
 
# 
# Processor Type 
# 
CON=
FIG_CPU_32=3Dy 
CONFIG_CPU_ARM920T=3Dy 
CONFIG_CPU_32v4=3Dy 
CONFIG_CP=
U_ABRT_EV4T=3Dy 
CONFIG_CPU_CACHE_V4WT=3Dy 
CONFIG_CPU_COPY_V4WB=3Dy =0D
=
CONFIG_CPU_TLB_V4WBI=3Dy 
 
# 
# Processor Features 
# 
# CONFIG_ARM=
_THUMB is not set 
# CONFIG_CPU_ICACHE_DISABLE is not set 
# CONFIG_CPU=
_DCACHE_DISABLE is not set 
# CONFIG_CPU_DCACHE_WRITETHROUGH is not set =

 
# 
# General setup 
# 
# CONFIG_ZBOOT_ROM is not set 
CONFIG_ZBO=
OT_ROM_TEXT=3D0x0 
CONFIG_ZBOOT_ROM_BSS=3D0x0 
 
# 
# At least one ma=
th emulation must be selected 
# 
CONFIG_FPE_NWFPE=3Dy 
CONFIG_FPE_NWF=
PE_XP=3Dy 
# CONFIG_FPE_FASTFPE is not set 
CONFIG_BINFMT_ELF=3Dy 
CON=
FIG_BINFMT_AOUT=3Dy 
# CONFIG_BINFMT_MISC is not set 
 
# 
# Generic =
Driver Options 
# 
CONFIG_STANDALONE=3Dy 
CONFIG_PREVENT_FIRMWARE_BUIL=
D=3Dy 
# CONFIG_DEBUG_DRIVER is not set 
# CONFIG_PM is not set 
# CON=
FIG_PREEMPT is not set 
# CONFIG_ARTHUR is not set 
CONFIG_CMDLINE=3D"r=
oot=3D/dev/nfs rw nfsroot=3D143.225.229.44:/board ip=3Ddhcp init/bin/bash=
 
console=3DttySAC0" 
CONFIG_ALIGNMENT_TRAP=3Dy 
 
# 
# Parallel por=
t support 
# 
CONFIG_PARPORT=3Dy 
CONFIG_PARPORT_PC=3Dy 
CONFIG_PARPO=
RT_PC_CML1=3Dy 
CONFIG_PARPORT_PC_FIFO=3Dy 
CONFIG_PARPORT_PC_SUPERIO=3D=
y 
# CONFIG_PARPORT_ARC is not set 
CONFIG_PARPORT_OTHER=3Dy 
CONFIG_P=
ARPORT_1284=3Dy 
 
# 
# Memory Technology Devices (MTD) 
# 
CONFIG_M=
TD=3Dy 
# CONFIG_MTD_DEBUG is not set 
# CONFIG_MTD_PARTITIONS is not s=
et 
# CONFIG_MTD_CONCAT is not set 
 
# 
# User Modules And Translati=
on Layers 
# 
CONFIG_MTD_CHAR=3Dy 
CONFIG_MTD_BLOCK=3Dy 
# CONFIG_FTL=
 is not set 
# CONFIG_NFTL is not set 
# CONFIG_INFTL is not set 
 =0D
=
# 
# RAM/ROM/Flash chip drivers 
# 
CONFIG_MTD_CFI=3Dy 
# CONFIG_MTD_=
JEDECPROBE is not set 
CONFIG_MTD_GEN_PROBE=3Dy 
# CONFIG_MTD_CFI_ADV_O=
PTIONS is not set 
CONFIG_MTD_MAP_BANK_WIDTH_1=3Dy 
CONFIG_MTD_MAP_BANK=
_WIDTH_2=3Dy 
CONFIG_MTD_MAP_BANK_WIDTH_4=3Dy 
# CONFIG_MTD_MAP_BANK_WI=
DTH_8 is not set 
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set 
# CONFIG_M=
TD_MAP_BANK_WIDTH_32 is not set 
CONFIG_MTD_CFI_I1=3Dy 
CONFIG_MTD_CFI_=
I2=3Dy 
# CONFIG_MTD_CFI_I4 is not set 
# CONFIG_MTD_CFI_I8 is not set =

CONFIG_MTD_CFI_INTELEXT=3Dy 
# CONFIG_MTD_CFI_AMDSTD is not set 
# CO=
NFIG_MTD_CFI_STAA is not set 
CONFIG_MTD_CFI_UTIL=3Dy 
# CONFIG_MTD_RAM=
 is not set 
# CONFIG_MTD_ROM is not set 
# CONFIG_MTD_ABSENT is not se=
t 
# CONFIG_MTD_OBSOLETE_CHIPS is not set 
 
# 
# Mapping drivers for=
 chip access 
# 
# CONFIG_MTD_COMPLEX_MAPPINGS is not set 
# CONFIG_MT=
D_PHYSMAP is not set 
# CONFIG_MTD_ARM_INTEGRATOR is not set 
# CONFIG_=
MTD_EDB7312 is not set 
 
# 
# Self-contained MTD device drivers 
# =0D
=
# CONFIG_MTD_SLRAM is not set 
# CONFIG_MTD_PHRAM is not set 
# CONFIG_=
MTD_MTDRAM is not set 
# CONFIG_MTD_BLKMTD is not set 
 
# 
# Disk-On=
-Chip Device Drivers 
# 
# CONFIG_MTD_DOC2000 is not set 
# CONFIG_MTD=
_DOC2001 is not set 
# CONFIG_MTD_DOC2001PLUS is not set 
 
# 
# NAND=
 Flash Device Drivers 
# 
# CONFIG_MTD_NAND is not set 
 
# 
# Plug =
and Play support 
# 
 
# 
# Block devices 
# 
# CONFIG_BLK_DEV_FD i=
s not set 
# CONFIG_PARIDE is not set 
CONFIG_BLK_DEV_LOOP=3Dy 
# CONF=
IG_BLK_DEV_CRYPTOLOOP is not set 
CONFIG_BLK_DEV_NBD=3Dy 
CONFIG_BLK_DE=
V_RAM=3Dy 
CONFIG_BLK_DEV_RAM_SIZE=3D4096 
CONFIG_BLK_DEV_INITRD=3Dy =0D
=
 
# 
# Multi-device support (RAID and LVM) 
# 
# CONFIG_MD is not set=
 
 
# 
# Networking support 
# 
CONFIG_NET=3Dy 
 
# 
# Networking=
 options 
# 
CONFIG_PACKET=3Dy 
CONFIG_PACKET_MMAP=3Dy 
CONFIG_NETLIN=
K_DEV=3Dy 
CONFIG_UNIX=3Dy 
# CONFIG_NET_KEY is not set 
CONFIG_INET=3D=
y 
CONFIG_IP_MULTICAST=3Dy 
# CONFIG_IP_ADVANCED_ROUTER is not set 
CO=
NFIG_IP_PNP=3Dy 
CONFIG_IP_PNP_DHCP=3Dy 
CONFIG_IP_PNP_BOOTP=3Dy 
CONF=
IG_IP_PNP_RARP=3Dy 
# CONFIG_NET_IPIP is not set 
# CONFIG_NET_IPGRE is=
 not set 
# CONFIG_IP_MROUTE is not set 
# CONFIG_ARPD is not set 
# C=
ONFIG_SYN_COOKIES is not set 
# CONFIG_INET_AH is not set 
# CONFIG_INE=
T_ESP is not set 
# CONFIG_INET_IPCOMP is not set 
# CONFIG_INET_TUNNEL=
 is not set 
 
# 
# IP: Virtual Server Configuration 
# 
# CONFIG_IP=
_VS is not set 
# CONFIG_IPV6 is not set 
CONFIG_NETFILTER=3Dy 
CONFIG=
_NETFILTER_DEBUG=3Dy 
 
# 
# IP: Netfilter Configuration 
# 
# CONFI=
G_IP_NF_CONNTRACK is not set 
# CONFIG_IP_NF_QUEUE is not set 
# CONFIG=
_IP_NF_IPTABLES is not set 
# CONFIG_IP_NF_ARPTABLES is not set 
# CONF=
IG_IP_NF_COMPAT_IPCHAINS is not set 
# CONFIG_IP_NF_COMPAT_IPFWADM is no=
t set 
 
# 
# SCTP Configuration (EXPERIMENTAL) 
# 
# CONFIG_IP_SCTP=
 is not set 
# CONFIG_ATM is not set 
# CONFIG_BRIDGE is not set 
# CO=
NFIG_VLAN_8021Q is not set 
# CONFIG_DECNET is not set 
# CONFIG_LLC2 i=
s not set 
# CONFIG_IPX is not set 
# CONFIG_ATALK is not set 
# CONFI=
G_X25 is not set 
# CONFIG_LAPB is not set 
# CONFIG_NET_DIVERT is not =
set 
# CONFIG_ECONET is not set 
# CONFIG_WAN_ROUTER is not set 
# CON=
FIG_NET_HW_FLOWCONTROL is not set 
 
# 
# QoS and/or fair queueing =0D
=
# 
# CONFIG_NET_SCHED is not set 
# CONFIG_NET_CLS_ROUTE is not set =0D
=
 
# 
# Network testing 
# 
# CONFIG_NET_PKTGEN is not set 
# CONFIG_=
NETPOLL is not set 
# CONFIG_NET_POLL_CONTROLLER is not set 
# CONFIG_H=
AMRADIO is not set 
# CONFIG_IRDA is not set 
# CONFIG_BT is not set =0D
=
CONFIG_NETDEVICES=3Dy 
# CONFIG_DUMMY is not set 
# CONFIG_BONDING is n=
ot set 
# CONFIG_EQUALIZER is not set 
# CONFIG_TUN is not set 
# CONF=
IG_ETHERTAP is not set 
 
# 
# Ethernet (10 or 100Mbit) 
# 
CONFIG_N=
ET_ETHERNET=3Dy 
CONFIG_MII=3Dy 
CONFIG_SMC91X=3Dy 
 
# 
# Ethernet =
(1000 Mbit) 
# 
 
# 
# Ethernet (10000 Mbit) 
# 
 
# 
# Token Rin=
g devices 
# 
 
# 
# Wireless LAN (non-hamradio) 
# 
# CONFIG_NET_R=
ADIO is not set 
 
# 
# Wan interfaces 
# 
# CONFIG_WAN is not set =0D
=
# CONFIG_PLIP is not set 
# CONFIG_PPP is not set 
CONFIG_SLIP=3Dy 
CO=
NFIG_SLIP_COMPRESSED=3Dy 
CONFIG_SLIP_SMART=3Dy 
CONFIG_SLIP_MODE_SLIP6=
=3Dy 
# CONFIG_SHAPER is not set 
# CONFIG_NETCONSOLE is not set 
 =0D
=
# 
# ATA/ATAPI/MFM/RLL support 
# 
CONFIG_IDE=3Dy 
CONFIG_BLK_DEV_IDE=
=3Dy 
 
# 
# Please see Documentation/ide.txt for help/info on IDE dri=
ves 
# 
# CONFIG_BLK_DEV_IDE_SATA is not set 
CONFIG_BLK_DEV_IDEDISK=3D=
y 
# CONFIG_IDEDISK_MULTI_MODE is not set 
CONFIG_BLK_DEV_IDECD=3Dy =0D
=
CONFIG_BLK_DEV_IDETAPE=3Dm 
CONFIG_BLK_DEV_IDEFLOPPY=3Dm 
# CONFIG_IDE_=
TASK_IOCTL is not set 
# CONFIG_IDE_TASKFILE_IO is not set 
 
# 
# ID=
E chipset support/bugfixes 
# 
CONFIG_IDE_GENERIC=3Dy 
# CONFIG_IDE_AR=
M is not set 
# CONFIG_BLK_DEV_IDEDMA is not set 
# CONFIG_IDEDMA_AUTO =
is not set 
# CONFIG_BLK_DEV_HD is not set 
 
# 
# SCSI device suppor=
t 
# 
# CONFIG_SCSI is not set 
 
# 
# Fusion MPT device support =0D
=
# 
 
# 
# IEEE 1394 (FireWire) support 
# 
# CONFIG_IEEE1394 is not =
set 
 
# 
# I2O device support 
# 
 
# 
# ISDN subsystem 
# 
# C=
ONFIG_ISDN is not set 
 
# 
# Input device support 
# 
CONFIG_INPUT=3D=
y 
 
# 
# Userland interfaces 
# 
CONFIG_INPUT_MOUSEDEV=3Dy 
CONFIG=
_INPUT_MOUSEDEV_PSAUX=3Dy 
CONFIG_INPUT_MOUSEDEV_SCREEN_X=3D1024 
CONFI=
G_INPUT_MOUSEDEV_SCREEN_Y=3D768 
# CONFIG_INPUT_JOYDEV is not set 
# CO=
NFIG_INPUT_TSDEV is not set 
# CONFIG_INPUT_EVDEV is not set 
# CONFIG_=
INPUT_EVBUG is not set 
 
# 
# Input I/O drivers 
# 
# CONFIG_GAMEPO=
RT is not set 
CONFIG_SOUND_GAMEPORT=3Dy 
CONFIG_SERIO=3Dy 
CONFIG_SER=
IO_SERPORT=3Dy 
# CONFIG_SERIO_CT82C710 is not set 
# CONFIG_SERIO_PARK=
BD is not set 
# CONFIG_SERIO_RAW is not set 
 
# 
# Input Device Dri=
vers 
# 
CONFIG_INPUT_KEYBOARD=3Dy 
# CONFIG_KEYBOARD_ATKBD is not set=
 
# CONFIG_KEYBOARD_SUNKBD is not set 
# CONFIG_KEYBOARD_LKKBD is not s=
et 
# CONFIG_KEYBOARD_XTKBD is not set 
# CONFIG_KEYBOARD_NEWTON is not=
 set 
CONFIG_INPUT_MOUSE=3Dy 
CONFIG_MOUSE_PS2=3Dy 
# CONFIG_MOUSE_SER=
IAL is not set 
# CONFIG_MOUSE_VSXXXAA is not set 
# CONFIG_INPUT_JOYST=
ICK is not set 
# CONFIG_INPUT_TOUCHSCREEN is not set 
# CONFIG_INPUT_M=
ISC is not set 
 
# 
# Character devices 
# 
CONFIG_VT=3Dy 
CONFIG_=
VT_CONSOLE=3Dy 
CONFIG_HW_CONSOLE=3Dy 
CONFIG_SERIAL_NONSTANDARD=3Dy =0D
=
# CONFIG_COMPUTONE is not set 
# CONFIG_ROCKETPORT is not set 
# CONFIG=
_CYCLADES is not set 
# CONFIG_DIGIEPCA is not set 
# CONFIG_DIGI is no=
t set 
# CONFIG_MOXA_INTELLIO is not set 
# CONFIG_MOXA_SMARTIO is not =
set 
# CONFIG_SYNCLINKMP is not set 
# CONFIG_N_HDLC is not set 
# CON=
FIG_RISCOM8 is not set 
# CONFIG_SPECIALIX is not set 
# CONFIG_SX is n=
ot set 
# CONFIG_RIO is not set 
# CONFIG_STALDRV is not set 
 
# =0D
=
# Serial drivers 
# 
CONFIG_SERIAL_8250=3Dy 
CONFIG_SERIAL_8250_CONSOL=
E=3Dy 
CONFIG_SERIAL_8250_NR_UARTS=3D8 
CONFIG_SERIAL_8250_EXTENDED=3Dy=
 
CONFIG_SERIAL_8250_MANY_PORTS=3Dy 
CONFIG_SERIAL_8250_SHARE_IRQ=3Dy =0D
=
# CONFIG_SERIAL_8250_DETECT_IRQ is not set 
# CONFIG_SERIAL_8250_MULTIPO=
RT is not set 
# CONFIG_SERIAL_8250_RSA is not set 
 
# 
# Non-8250 s=
erial port support 
# 
CONFIG_SERIAL_S3C2410=3Dy 
CONFIG_SERIAL_S3C241=
0_CONSOLE=3Dy 
# CONFIG_SERIAL_BAST_SIO is not set 
CONFIG_SERIAL_CORE=3D=
y 
CONFIG_SERIAL_CORE_CONSOLE=3Dy 
CONFIG_UNIX98_PTYS=3Dy 
CONFIG_LEGA=
CY_PTYS=3Dy 
CONFIG_LEGACY_PTY_COUNT=3D256 
CONFIG_PRINTER=3Dy 
# CONF=
IG_LP_CONSOLE is not set 
CONFIG_PPDEV=3Dy 
# CONFIG_TIPAR is not set =0D
=
 
# 
# IPMI 
# 
# CONFIG_IPMI_HANDLER is not set 
 
# 
# Watchdog =
Cards 
# 
# CONFIG_WATCHDOG is not set 
# CONFIG_NVRAM is not set 
CO=
NFIG_RTC=3Dy 
# CONFIG_DTLK is not set 
# CONFIG_R3964 is not set 
 =0D
=
# 
# Ftape, the floppy tape device driver 
# 
# CONFIG_DRM is not set =

# CONFIG_RAW_DRIVER is not set 
 
# 
# I2C support 
# 
CONFIG_I2C=3D=
y 
CONFIG_I2C_CHARDEV=3Dm 
 
# 
# I2C Algorithms 
# 
CONFIG_I2C_ALG=
OBIT=3Dm 
# CONFIG_I2C_ALGOPCF is not set 
# CONFIG_I2C_ALGOPCA is not =
set 
 
# 
# I2C Hardware Bus support 
# 
# CONFIG_I2C_AMD756 is not =
set 
# CONFIG_I2C_AMD8111 is not set 
# CONFIG_I2C_ISA is not set 
# C=
ONFIG_I2C_PARPORT is not set 
# CONFIG_I2C_PARPORT_LIGHT is not set 
# =
CONFIG_SCx200_ACB is not set 
# CONFIG_I2C_PCA_ISA is not set 
 
# =0D
=
# Hardware Sensors Chip support 
# 
CONFIG_I2C_SENSOR=3Dm 
# CONFIG_SE=
NSORS_ADM1021 is not set 
# CONFIG_SENSORS_ADM1025 is not set 
# CONFIG=
_SENSORS_ADM1031 is not set 
# CONFIG_SENSORS_ASB100 is not set 
# CONF=
IG_SENSORS_DS1621 is not set 
# CONFIG_SENSORS_FSCHER is not set 
# CON=
FIG_SENSORS_GL518SM is not set 
# CONFIG_SENSORS_IT87 is not set 
CONFI=
G_SENSORS_LM75=3Dm 
# CONFIG_SENSORS_LM77 is not set 
CONFIG_SENSORS_LM=
78=3Dm 
# CONFIG_SENSORS_LM80 is not set 
# CONFIG_SENSORS_LM83 is not =
set 
CONFIG_SENSORS_LM85=3Dm 
# CONFIG_SENSORS_LM90 is not set 
# CONF=
IG_SENSORS_MAX1619 is not set 
# CONFIG_SENSORS_SMSC47M1 is not set 
# =
CONFIG_SENSORS_W83781D is not set 
# CONFIG_SENSORS_W83L785TS is not set=
 
# CONFIG_SENSORS_W83627HF is not set 
 
# 
# Other I2C Chip support=
 
# 
CONFIG_SENSORS_EEPROM=3Dm 
# CONFIG_SENSORS_PCF8574 is not set =0D
=
# CONFIG_SENSORS_PCF8591 is not set 
# CONFIG_SENSORS_RTC8564 is not set=
 
# CONFIG_I2C_DEBUG_CORE is not set 
# CONFIG_I2C_DEBUG_ALGO is not se=
t 
# CONFIG_I2C_DEBUG_BUS is not set 
# CONFIG_I2C_DEBUG_CHIP is not se=
t 
 
# 
# Multimedia devices 
# 
# CONFIG_VIDEO_DEV is not set 
 =0D
=
# 
# Digital Video Broadcasting Devices 
# 
# CONFIG_DVB is not set =0D
=
 
# 
# File systems 
# 
CONFIG_EXT2_FS=3Dy 
# CONFIG_EXT2_FS_XATTR i=
s not set 
CONFIG_EXT3_FS=3Dy 
CONFIG_EXT3_FS_XATTR=3Dy 
# CONFIG_EXT3=
_FS_POSIX_ACL is not set 
# CONFIG_EXT3_FS_SECURITY is not set 
CONFIG_=
JBD=3Dy 
# CONFIG_JBD_DEBUG is not set 
CONFIG_FS_MBCACHE=3Dy 
# CONFI=
G_REISERFS_FS is not set 
# CONFIG_JFS_FS is not set 
# CONFIG_XFS_FS i=
s not set 
# CONFIG_MINIX_FS is not set 
CONFIG_ROMFS_FS=3Dy 
# CONFIG=
_QUOTA is not set 
# CONFIG_AUTOFS_FS is not set 
# CONFIG_AUTOFS4_FS i=
s not set 
 
# 
# CD-ROM/DVD Filesystems 
# 
# CONFIG_ISO9660_FS is =
not set 
# CONFIG_UDF_FS is not set 
 
# 
# DOS/FAT/NT Filesystems =0D
=
# 
CONFIG_FAT_FS=3Dy 
CONFIG_MSDOS_FS=3Dy 
CONFIG_VFAT_FS=3Dy 
CONFIG=
_FAT_DEFAULT_CODEPAGE=3D437 
CONFIG_FAT_DEFAULT_IOCHARSET=3D"iso8859-1" =

# CONFIG_NTFS_FS is not set 
 
# 
# Pseudo filesystems 
# 
CONFIG_=
PROC_FS=3Dy 
CONFIG_SYSFS=3Dy 
# CONFIG_DEVFS_FS is not set 
# CONFIG_=
DEVPTS_FS_XATTR is not set 
# CONFIG_TMPFS is not set 
# CONFIG_HUGETLB=
FS is not set 
# CONFIG_HUGETLB_PAGE is not set 
CONFIG_RAMFS=3Dy 
 =0D
=
# 
# Miscellaneous filesystems 
# 
# CONFIG_ADFS_FS is not set 
# CON=
FIG_AFFS_FS is not set 
# CONFIG_HFS_FS is not set 
# CONFIG_HFSPLUS_FS=
 is not set 
# CONFIG_BEFS_FS is not set 
# CONFIG_BFS_FS is not set =0D
=
# CONFIG_EFS_FS is not set 
CONFIG_JFFS_FS=3Dy 
CONFIG_JFFS_FS_VERBOSE=3D=
0 
# CONFIG_JFFS_PROC_FS is not set 
CONFIG_JFFS2_FS=3Dy 
CONFIG_JFFS2=
_FS_DEBUG=3D0 
# CONFIG_JFFS2_FS_NAND is not set 
# CONFIG_JFFS2_COMPRE=
SSION_OPTIONS is not set 
CONFIG_JFFS2_ZLIB=3Dy 
CONFIG_JFFS2_RTIME=3Dy=
 
# CONFIG_JFFS2_RUBIN is not set 
# CONFIG_CRAMFS is not set 
# CONFI=
G_VXFS_FS is not set 
# CONFIG_HPFS_FS is not set 
# CONFIG_QNX4FS_FS i=
s not set 
# CONFIG_SYSV_FS is not set 
# CONFIG_UFS_FS is not set 
 =0D
=
# 
# Network File Systems 
# 
CONFIG_NFS_FS=3Dy 
# CONFIG_NFS_V3 is n=
ot set 
# CONFIG_NFS_V4 is not set 
# CONFIG_NFS_DIRECTIO is not set =0D
=
# CONFIG_NFSD is not set 
CONFIG_ROOT_NFS=3Dy 
CONFIG_LOCKD=3Dy 
# CON=
FIG_EXPORTFS is not set 
CONFIG_SUNRPC=3Dy 
# CONFIG_RPCSEC_GSS_KRB5 is=
 not set 
# CONFIG_RPCSEC_GSS_SPKM3 is not set 
# CONFIG_SMB_FS is not =
set 
# CONFIG_CIFS is not set 
# CONFIG_NCP_FS is not set 
# CONFIG_CO=
DA_FS is not set 
# CONFIG_AFS_FS is not set 
 
# 
# Partition Types =

# 
CONFIG_PARTITION_ADVANCED=3Dy 
CONFIG_ACORN_PARTITION=3Dy 
CONFIG=
_ACORN_PARTITION_CUMANA=3Dy 
CONFIG_ACORN_PARTITION_EESOX=3Dy 
CONFIG_A=
CORN_PARTITION_ICS=3Dy 
CONFIG_ACORN_PARTITION_ADFS=3Dy 
CONFIG_ACORN_P=
ARTITION_POWERTEC=3Dy 
CONFIG_ACORN_PARTITION_RISCIX=3Dy 
# CONFIG_OSF_=
PARTITION is not set 
# CONFIG_AMIGA_PARTITION is not set 
# CONFIG_ATA=
RI_PARTITION is not set 
# CONFIG_MAC_PARTITION is not set 
CONFIG_MSDO=
S_PARTITION=3Dy 
CONFIG_BSD_DISKLABEL=3Dy 
# CONFIG_MINIX_SUBPARTITION =
is not set 
CONFIG_SOLARIS_X86_PARTITION=3Dy 
# CONFIG_UNIXWARE_DISKLAB=
EL is not set 
# CONFIG_LDM_PARTITION is not set 
# CONFIG_SGI_PARTITIO=
N is not set 
# CONFIG_ULTRIX_PARTITION is not set 
# CONFIG_SUN_PARTIT=
ION is not set 
# CONFIG_EFI_PARTITION is not set 
 
# 
# Native Lang=
uage Support 
# 
CONFIG_NLS=3Dy 
CONFIG_NLS_DEFAULT=3D"iso8859-1" 
# =
CONFIG_NLS_CODEPAGE_437 is not set 
# CONFIG_NLS_CODEPAGE_737 is not set=
 
# CONFIG_NLS_CODEPAGE_775 is not set 
# CONFIG_NLS_CODEPAGE_850 is no=
t set 
# CONFIG_NLS_CODEPAGE_852 is not set 
# CONFIG_NLS_CODEPAGE_855 =
is not set 
# CONFIG_NLS_CODEPAGE_857 is not set 
# CONFIG_NLS_CODEPAGE=
_860 is not set 
# CONFIG_NLS_CODEPAGE_861 is not set 
# CONFIG_NLS_COD=
EPAGE_862 is not set 
# CONFIG_NLS_CODEPAGE_863 is not set 
# CONFIG_NL=
S_CODEPAGE_864 is not set 
# CONFIG_NLS_CODEPAGE_865 is not set 
# CONF=
IG_NLS_CODEPAGE_866 is not set 
# CONFIG_NLS_CODEPAGE_869 is not set =0D
=
# CONFIG_NLS_CODEPAGE_936 is not set 
# CONFIG_NLS_CODEPAGE_950 is not s=
et 
# CONFIG_NLS_CODEPAGE_932 is not set 
# CONFIG_NLS_CODEPAGE_949 is =
not set 
# CONFIG_NLS_CODEPAGE_874 is not set 
# CONFIG_NLS_ISO8859_8 i=
s not set 
# CONFIG_NLS_CODEPAGE_1250 is not set 
# CONFIG_NLS_CODEPAGE=
_1251 is not set 
# CONFIG_NLS_ASCII is not set 
# CONFIG_NLS_ISO8859_1=
 is not set 
# CONFIG_NLS_ISO8859_2 is not set 
# CONFIG_NLS_ISO8859_3 =
is not set 
# CONFIG_NLS_ISO8859_4 is not set 
# CONFIG_NLS_ISO8859_5 i=
s not set 
# CONFIG_NLS_ISO8859_6 is not set 
# CONFIG_NLS_ISO8859_7 is=
 not set 
# CONFIG_NLS_ISO8859_9 is not set 
# CONFIG_NLS_ISO8859_13 is=
 not set 
# CONFIG_NLS_ISO8859_14 is not set 
# CONFIG_NLS_ISO8859_15 i=
s not set 
# CONFIG_NLS_KOI8_R is not set 
# CONFIG_NLS_KOI8_U is not s=
et 
# CONFIG_NLS_UTF8 is not set 
 
# 
# Profiling support 
# 
# CO=
NFIG_PROFILING is not set 
 
# 
# Graphics support 
# 
CONFIG_FB=3Dy=
 
CONFIG_FB_MODE_HELPERS=3Dy 
# CONFIG_FB_VIRTUAL is not set 
 
# =0D
=
# Console display driver support 
# 
# CONFIG_VGA_CONSOLE is not set =0D
=
CONFIG_DUMMY_CONSOLE=3Dy 
# CONFIG_FRAMEBUFFER_CONSOLE is not set 
 =0D
=
# 
# Logo configuration 
# 
# CONFIG_LOGO is not set 
 
# 
# Sound =

# 
# CONFIG_SOUND is not set 
 
# 
# Misc devices 
# 
 
# 
# US=
B support 
# 
 
# 
# USB Gadget Support 
# 
# CONFIG_USB_GADGET is =
not set 
 
# 
# MMC/SD Card support 
# 
# CONFIG_MMC is not set 
 =0D
=
# 
# Kernel hacking 
# 
CONFIG_DEBUG_KERNEL=3Dy 
# CONFIG_MAGIC_SYSRQ=
 is not set 
# CONFIG_DEBUG_SLAB is not set 
# CONFIG_DEBUG_SPINLOCK is=
 not set 
# CONFIG_DEBUG_BUGVERBOSE is not set 
CONFIG_DEBUG_INFO=3Dy =0D
=
CONFIG_FRAME_POINTER=3Dy 
CONFIG_DEBUG_USER=3Dy 
# CONFIG_DEBUG_WAITQ i=
s not set 
# CONFIG_DEBUG_ERRORS is not set 
CONFIG_DEBUG_LL=3Dy 
# CO=
NFIG_DEBUG_ICEDCC is not set 
CONFIG_DEBUG_S3C2410_PORT=3Dy 
CONFIG_DEB=
UG_S3C2410_UART=3D0 
 
# 
# Security options 
# 
# CONFIG_SECURITY i=
s not set 
 
# 
# Cryptographic options 
# 
# CONFIG_CRYPTO is not s=
et 
 
# 
# Library routines 
# 
# CONFIG_CRC_CCITT is not set 
CONF=
IG_CRC32=3Dy 
# CONFIG_LIBCRC32C is not set 
CONFIG_ZLIB_INFLATE=3Dy =0D
=
CONFIG_ZLIB_DEFLATE=3Dy 
 
 
 
And the boot output is: 
 
Linux ver=
sion 2.6.8.1 (root@sofocle) (gcc version 3.3.2) #2 Mon Sep 27 10:56:48 CE=
ST 2004 
CPU: ARM920Tid(wb) [41129200] revision 0 (ARMv4T) 
CPU: D VIVT=
 write-back cache 
CPU: I cache: 16384 bytes, associativity 64, 32 byte =
lines, 8 sets 
CPU: D cache: 16384 bytes, associativity 64, 32 byte line=
s, 8 sets 
Machine: Simtec-BAST 
Memory policy: ECC disabled, Data cach=
e writeback 
CPU S3C2410 (id 0x32410000) 
machine_initted c001e988,53 =0D
=
S3C2410: core 202.800 MHz, memory 101.400 MHz, peripheral 50.700 MHz 
Bu=
ilt 1 zonelists 
Kernel command line: root=3D/dev/nfs rw nfsroot=3D143.2=
25.229.44:/board ip=3Ddhcp 
console=3DttySAC0 
irq: clearing pending ex=
t status 0003ec00 
irq: clearing subpending status 00000092 
irq: clear=
ing subpending status 00000092 
irq: clearing subpending status 00000092=
 
irq: clearing subpending status 00000092 
PID hash table entries: 512=
 (order: 9, 8192 bytes) 
setup_timer tcon=3D00500000, tcnt ea60, tcfg 00=
000000,00040000 
Console: colour dummy device 80x30 
Dentry cache hash =
table entries: 16384 (order: 4, 65536 bytes) 
Inode-cache hash table ent=
ries: 8192 (order: 3, 32768 bytes) 
Memory: 64MB =3D 64MB total 
Memory=
: 62208KB available (1962K code, 519K data, 100K init) 
Mount-cache hash=
 table entries: 512 (order: 0, 4096 bytes) 
CPU: Testing write buffer co=
herency: ok 
NET: Registered protocol family 16 
S3C2410: Initialising =
architecture 
S3C2410 Clock control, (c) 2004 Simtec Electronics 
S3C24=
10 DMA Driver, (c) 2003-2004 Simtec Electronics 
DMA channel 0 at c48000=
00, irq 33 
DMA channel 1 at c4800040, irq 34 
DMA channel 2 at c480008=
0, irq 35 
DMA channel 3 at c48000c0, irq 36 
NetWinder Floating Point =
Emulator V0.97 (extended precision) 
JFFS version 1.0, (C) 1999, 2000  A=
xis Communications AB 
JFFS2 version 2.2. (C) 2001-2003 Red Hat, Inc. =0D
=
lp: driver loaded but no devices found 
Real Time Clock Driver v1.12 =0D
=
ppdev: user-space parallel port driver 
Serial: 8250/16550 driver $Revis=
ion: 1.90 $ 8 ports, IRQ sharing enabled 
S3C2410X Serial, (c) 2003 Simt=
ec Electronics 
ttySAC0 at MMIO 0x50000000 (irq =3D 70) is a S3C2410 =0D
=
ttySAC1 at MMIO 0x50004000 (irq =3D 73) is a S3C2410 
ttySAC2 at MMIO 0x=
50008000 (irq =3D 76) is a S3C2410 
parport0: PC-style at 0x378 [PCSPP,T=
RISTATE,EPP] 
lp0: using parport0 (polling). 
RAMDISK driver initialize=
d: 16 RAM disks of 4096K size 1024 blocksize 
loop: loaded (max 8 device=
s) 
Using anticipatory io scheduler 
nbd: registered device at major 43=
 
SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=3D256) (6 b=
it encapsulation 
enabled). 
CSLIP: code copyright 1989 Regents of the =
University of California. 
SLIP linefill/keepalive option. 
Uniform Mul=
ti-Platform E-IDE driver Revision: 7.00alpha2 
ide: Assuming 50MHz syste=
m bus speed for PIO modes; override with idebus=3Dxx 
mice: PS/2 mouse d=
evice common for all mice 
NET: Registered protocol family 2 
IP: routi=
ng cache hash table of 512 buckets, 4Kbytes 
TCP: Hash tables configured=
 (established 4096 bind 8192) 
NET: Registered protocol family 1 
NET: =
Registered protocol family 17 
IP-Config: No network devices available. =

Looking up port of RPC 100003/2 on 143.225.229.44 
RPC: sendmsg return=
ed error 101 
portmap: RPC call returned error 101 
Root-NFS: Unable to=
 get nfsd port number from server, using default 
Looking up port of RPC=
 100005/1 on 143.225.229.44 
RPC: sendmsg returned error 101 
portmap: =
RPC call returned error 101 
Root-NFS: Unable to get mountd port number =
from server, using default 
RPC: sendmsg returned error 101 
mount: RPC=
 call returned error 101 
Root-NFS: Server returned error -101 while mou=
nting /board 
VFS: Unable to mount root fs via NFS, trying floppy. 
VFS=
: Cannot open root device "nfs" or unknown-block(2,0) 
Please append a c=
orrect "root=3D" boot option 
Kernel panic - not syncing: VFS: Unable to=
 mount root fs on unknown-block(2,0) 
 
Thanks. 




-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
