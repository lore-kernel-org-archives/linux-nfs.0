Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:38290 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803Ab1CWNq3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 09:46:29 -0400
In-Reply-To: <DC2B75F8-382A-4AFB-9286-4A55EAF7609A@oracle.com>
References: <AANLkTimjmdi8sFTTjSPerOVgHQ+pjjwwMvCUX3AJ16At@mail.gmail.com>
	<43F07477-9075-444D-9BBB-368650538EA8@oracle.com>
	<AANLkTinHUQkBvcvh9APVutOqcKOug6CA066kS_O4p4Tq@mail.gmail.com>
	<DC2B75F8-382A-4AFB-9286-4A55EAF7609A@oracle.com>
Date: Wed, 23 Mar 2011 14:46:28 +0100
Message-ID: <AANLkTikWyUbtHbbnSh8NBeP3mT4jDOu5Pbtfw=TwKrwE@mail.gmail.com>
Subject: Re: [bisect] kernel 2.6.38 regression with root nfs mounting
From: Belisko Marek <marek.belisko@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond.Myklebust@netapp.com, broonie@opensource.wolfsonmicro.com,
        bdowning@lavos.net, linux-nfs@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 23, 2011 at 2:44 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Mar 23, 2011, at 2:30 AM, Belisko Marek wrote:
>
>> Added linux-nfs to CC (to keep history) add added log with nfsdebugroot enabled.
>>
>> On Tue, Mar 22, 2011 at 1:34 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>> On Mar 22, 2011, at 3:51 AM, Belisko Marek wrote:
>>>
>>>> After update from 2.6.38-rc8 to 2.6.38 is mounting rootfs over nfs not possible.
>>>> Log:
>>>> VFS: Mounted root (nfs filesystem) on device 0:14.
>>>> Freeing init memory: 132K
>>>> nfs: server 10.146.1.21 not responding, still trying
>>>> nfs: server 10.146.1.21 not responding, still trying
>>>>
>>>> This is never ending. I make short bisect (not too much commits
>>>> between versions)
>>>> and bad commit was reported: 53d4737580535e073963b91ce87d4216e434fab5
>>>>
>>>> NFS: NFSROOT should default to "proto=udp"
>>>>
>>>> I've tested on mini2440 board (DM9000, static IP).
>>>> Is there some missing option or something else to be checked?
>>>
>>> NFSROOT is supposed to work as it did before 2.6.37.
>>>
>>> Enable NFSROOT debugging (see the description of nfsrootdebug in Documentation/filesystems/nfs/nfsroot.txt), try your boot, and then post the contents of your system log to linux-nfs@vger.kernel.org.
>>>
>>> --
>>> Chuck Lever
>>> chuck[dot]lever[at]oracle[dot]com
>>>
>>>
>>>
>>>
>>>
>>
>> Linux version 2.6.38-rc7+ (open-nandra@host) (gcc version 4.5.1
>> (Sourcery G++ Lite 2010.09-50) ) #1 Wed Mar 23 07:23:36 CET 2011
>> CPU: ARM920T [41129200] revision 0 (ARMv4T), cr=c0007177
>> CPU: VIVT data cache, VIVT instruction cache
>> Machine: MINI2440
>> Memory policy: ECC disabled, Data cache writeback
>> CPU S3C2440A (id 0x32440001)
>> S3C24XX Clocks, Copyright 2004 Simtec Electronics
>> S3C244X: core 405.000 MHz, memory 101.250 MHz, peripheral 50.625 MHz
>> CLOCK: Slow mode (1.500 MHz), fast, MPLL on, UPLL on
>> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 16256
>> Kernel command line: console=ttySAC0,115200 noinitrd init=/sbin/init
>> mini2440=1b nfsrootdebug root=/dev/nfs rw
>> nfsroot=10.146.1.21:/home/open-nandra/rootfs
>> ip=10.146.1.199:10.146.1.21::255.20
>> PID hash table entries: 256 (order: -2, 1024 bytes)
>> Dentry cache hash table entries: 8192 (order: 3, 32768 bytes)
>> Inode-cache hash table entries: 4096 (order: 2, 16384 bytes)
>> Memory: 64MB = 64MB total
>> Memory: 60536k/60536k available, 5000k reserved, 0K highmem
>> Virtual kernel memory layout:
>>    vector  : 0xffff0000 - 0xffff1000   (   4 kB)
>>    fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
>>    DMA     : 0xffc00000 - 0xffe00000   (   2 MB)
>>    vmalloc : 0xc4800000 - 0xf6000000   ( 792 MB)
>>    lowmem  : 0xc0000000 - 0xc4000000   (  64 MB)
>>    modules : 0xbf000000 - 0xc0000000   (  16 MB)
>>      .init : 0xc0008000 - 0xc0029000   ( 132 kB)
>>      .text : 0xc0029000 - 0xc03e9bb4   (3843 kB)
>>      .data : 0xc03ea000 - 0xc040e220   ( 145 kB)
>> SLUB: Genslabs=13, HWalign=32, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
>> NR_IRQS:85
>> irq: clearing pending status 02000000
>> irq: clearing subpending status 00000002
>> Console: colour dummy device 80x30
>> console [ttySAC0] enabled
>> Calibrating delay loop... 201.93 BogoMIPS (lpj=504832)
>> pid_max: default: 32768 minimum: 301
>> Mount-cache hash table entries: 512
>> CPU: Testing write buffer coherency: ok
>> gpiochip_add: gpios 288..303 (GPIOK) failed to register
>> gpiochip_add: gpios 320..334 (GPIOL) failed to register
>> gpiochip_add: gpios 352..353 (GPIOM) failed to register
>> NET: Registered protocol family 16
>> MINI2440: Option string mini2440=1b
>> MINI2440: LCD 0:240x320 [1:800x480] 2:1024x768
>> S3C2440: Initialising architecture
>> S3C2440: IRQ Support
>> S3C244X: Clock Support, DVS off
>> bio: create slab <bio-0> at 0
>> usbcore: registered new interface driver usbfs
>> usbcore: registered new interface driver hub
>> usbcore: registered new device driver usb
>> s3c-i2c s3c2440-i2c: slave address 0x10
>> s3c-i2c s3c2440-i2c: bus frequency set to 98 KHz
>> s3c-i2c s3c2440-i2c: i2c-0: S3C I2C adapter
>> Advanced Linux Sound Architecture Driver Version 1.0.23.
>> NET: Registered protocol family 2
>> IP route cache hash table entries: 1024 (order: 0, 4096 bytes)
>> TCP established hash table entries: 2048 (order: 2, 16384 bytes)
>> TCP bind hash table entries: 2048 (order: 1, 8192 bytes)
>> TCP: Hash tables configured (established 2048 bind 2048)
>> TCP reno registered
>> UDP hash table entries: 256 (order: 0, 4096 bytes)
>> UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
>> NET: Registered protocol family 1
>> RPC: Registered udp transport module.
>> RPC: Registered tcp transport module.
>> RPC: Registered tcp NFSv4.1 backchannel transport module.
>> JFFS2 version 2.2. (NAND) �© 2001-2006 Red Hat, Inc.
>> ROMFS MTD (C) 2007 Red Hat, Inc.
>> msgmni has been set to 118
>> io scheduler noop registered
>> io scheduler deadline registered
>> io scheduler cfq registered (default)
>> Console: switching to colour frame buffer device 200x80
>> fb0: s3c2410fb frame buffer device
>> s3c2440-uart.0: ttySAC0 at MMIO 0x50000000 (irq = 70) is a S3C2440
>> s3c2440-uart.1: ttySAC1 at MMIO 0x50004000 (irq = 73) is a S3C2440
>> s3c2440-uart.2: ttySAC2 at MMIO 0x50008000 (irq = 76) is a S3C2440
>> brd: module loaded
>> at24 0-0050: 1024 byte 24c08 EEPROM, writable, 16 bytes/write
>> S3C24XX NAND Driver, (c) 2004 Simtec Electronics
>> s3c24xx-nand s3c2440-nand: Tacls=1, 9ns Twrph0=3 29ns, Twrph1=2 19ns
>> s3c24xx-nand s3c2440-nand: NAND soft ECC
>> NAND device: Manufacturer ID: 0xec, Chip ID: 0xda (Samsung NAND 256MiB
>> 3,3V 8-bit)
>> Creating 4 MTD partitions on "nand":
>> 0x000000000000-0x000000040000 : "u-boot"
>> ftl_cs: FTL header not found.
>> 0x000000040000-0x000000060000 : "u-boot-env"
>> ftl_cs: FTL header not found.
>> 0x000000060000-0x000000560000 : "kernel"
>> ftl_cs: FTL header not found.
>> 0x000000560000-0x000010000000 : "root"
>> ftl_cs: FTL header not found.
>> dm9000 Ethernet Driver, V1.31
>> eth0: dm9000e at c486a300,c486e304 IRQ 51 MAC: 08:08:11:18:12:27 (chip)
>> ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
>> s3c2410-ohci s3c2410-ohci: S3C24XX OHCI
>> s3c2410-ohci s3c2410-ohci: new USB bus registered, assigned bus number 1
>> s3c2410-ohci s3c2410-ohci: irq 42, io mem 0x49000000
>> hub 1-0:1.0: USB hub found
>> hub 1-0:1.0: 2 ports detected
>> usbcore: registered new interface driver libusual
>> s3c2440-usbgadget s3c2440-usbgadget: S3C2440: increasing FIFO to 128 bytes
>> mousedev: PS/2 mouse device common for all mice
>> input: gpio-keys as /devices/platform/gpio-keys/input/input0
>> S3C24XX RTC, (c) 2004,2006 Simtec Electronics
>> s3c-rtc s3c2410-rtc: rtc disabled, re-enabling
>> s3c-rtc s3c2410-rtc: rtc core: registered s3c as rtc0
>> i2c /dev entries driver
>> S3C2410 Watchdog Timer, (c) 2004 Simtec Electronics
>> s3c2410-wdt s3c2410-wdt: watchdog inactive, reset disabled, irq enabled
>> cpuidle: using governor ladder
>> sdhci: Secure Digital Host Controller Interface driver
>> sdhci: Copyright(c) Pierre Ossman
>> s3c-sdi s3c2440-sdi: powered down.
>> s3c-sdi s3c2440-sdi: mmc0 - using pio, sw SDIO IRQ
>> s3c-sdi s3c2440-sdi: running at 0kHz (requested: 0kHz).
>> s3c-sdi s3c2440-sdi: running at 398kHz (requested: 400kHz).
>> s3c-sdi s3c2440-sdi: running at 398kHz (requested: 400kHz).
>> s3c-sdi s3c2440-sdi: running at 398kHz (requested: 400kHz).
>> s3c-sdi s3c2440-sdi: running at 398kHz (requested: 400kHz).
>> s3c-sdi s3c2440-sdi: running at 398kHz (requested: 400kHz).
>> s3c-sdi s3c2440-sdi: running at 398kHz (requested: 400kHz).
>> usbcore: registered new interface driver usbhid
>> usbhid: USB HID core driver
>> ALSA device list:
>>  No soundcards found.
>> TCP cubic registered
>> NET: Registered protocol family 17
>> Registering the dns_resolver key type
>> s3c-rtc s3c2410-rtc: setting system clock to 2011-03-23 06:01:06 UTC
>> (1300860066)
>> s3c-sdi s3c2440-sdi: running at 398kHz (requested: 400kHz).
>> s3c-sdi s3c2440-sdi: running at 16875kHz (requested: 25000kHz).
>> s3c-sdi s3c2440-sdi: running at 16875kHz (requested: 25000kHz).
>> mmc0: new SD card at address b368
>> mmcblk0: mmc0:b368 SD    970 MiB
>> mmcblk0: p1 p2 p3
>> eth0: link down
>> IP-Config: Complete:
>>     device=eth0, addr=10.146.1.199, mask=255.255.255.0, gw=255.255.255.255,
>>     host=mini2440, domain=, nis-domain=(none),
>>     bootserver=10.146.1.21, rootserver=10.146.1.21, rootpath=
>> Root-NFS: nfsroot=/home/open-nandra/rootfs
>> NFS: nfs mount opts='udp,nolock,addr=10.146.1.21'
>> NFS:   parsing nfs mount option 'udp'
>> NFS:   parsing nfs mount option 'nolock'
>> NFS:   parsing nfs mount option 'addr=10.146.1.21'
>> NFS: MNTPATH: '/home/open-nandra/rootfs'
>> NFS: sending MNT request for 10.146.1.21:/home/open-nandra/rootfs
>> eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
>> NFS: received 1 auth flavors
>> NFS:   auth flavor[0]: 1
>> NFS: MNT request succeeded
>> NFS: using auth flavor 1
>> VFS: Mounted root (nfs filesystem) on device 0:14.
>> Freeing init memory: 132K
>> nfs: server 10.146.1.21 not responding, still trying
>> nfs: server 10.146.1.21 not responding, still trying
>>
>> This is behavior for commit 53d4737580535e073963b91ce87d4216e434fab5
>> For commit before it works properly.
>
> What does "rpcinfo -p 10.146.1.21" output look like?  Is NFS over UDP enabled on your server?
 program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  40517  status
    100024    1   tcp  51397  status
    100021    1   udp  44516  nlockmgr
    100021    3   udp  44516  nlockmgr
    100021    4   udp  44516  nlockmgr
    100021    1   tcp  55152  nlockmgr
    100021    3   tcp  55152  nlockmgr
    100021    4   tcp  55152  nlockmgr
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100227    2   tcp   2049
    100227    3   tcp   2049
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100227    2   udp   2049
    100227    3   udp   2049
    100005    1   udp  58278  mountd
    100005    1   tcp  37178  mountd
    100005    2   udp  58278  mountd
    100005    2   tcp  37178  mountd
    100005    3   udp  58278  mountd
    100005    3   tcp  37178  mountd

>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
>

regards,

marek

-- 
as simple and primitive as possible
-------------------------------------------------
Marek Belisko - OPEN-NANDRA
Freelance Developer

Ruska Nova Ves 219 | Presov, 08005 Slovak Republic
Tel: +421 915 052 184
skype: marekwhite
icq: 290551086
web: http://open-nandra.com
