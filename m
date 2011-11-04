Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm4-vm0.bullet.mail.ird.yahoo.com ([77.238.189.211]:32725 "HELO
	nm4-vm0.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932925Ab1KDQ43 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 12:56:29 -0400
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com> <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu> <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com> <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com> <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com> <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com> <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com> <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com> <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com>
Message-ID: <1320425786.67038.YahooMailNeo@web24705.mail.ird.yahoo.com>
Date: Fri, 4 Nov 2011 16:56:26 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> If you boot via tftp, I bet this problem will go away because the network 

> interface will be working by the time the NFSROOT mount is attempted.
> 
> The NFSROOT code assumes that if kernel IP configuration worked, then the NIC is 
> already up.  That is clearly not the case if you boot from your local disk.
> 

This also doesn't work. The kernel doesn't recognize that the eth0 is already up by OpenBoot and tries to do that.
Hence the result is the same as before (see end of my email, please).
---
BTW:
OpenBoot gets the IP configuration for eth0 from a rarp server when I enter "boot net".
As soon as it has the IP (always 6 requests needed), it tries to download the kernel from a tftp server.
After the kernel is downloaded, it's started by OpenBoot with the same kernel line I used before (in silo.conf).
---

> As for a patch: no-one can write a patch unless we understand precisely why the 
> first RPC fails.  I already explained how to add a line or two to 
> fs/nfs/nfsroot.c to give us more information.  If you need a patch to do this, I 
> can send one later today.

So now I'll try to add the lines you've mentioned in an older email...
But if you're faster, I'm also happy about a patch. Because you know better what you want to see...

Regards,
Lukas

PS:
That's the whole OpenBoot and linux-2.6.39.4 kernel log:
---
SPARC Enterprise T5120, No Keyboard
Copyright 2008 Sun Microsystems, Inc.  All rights reserved.
OpenBoot 4.30.0, 32640 MB memory available, Serial #77072834.
Ethernet address 0:14:4f:98:9:c2, Host ID: 849809c2.

{0} ok boot net
Boot device: /pci@0/pci@0/pci@1/pci@0/pci@2/network@0  File and args: root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2 ip=137.226.167.242::137.226.167.225:255.255.255.224:cluster2:eth0:off
1000 Mbps full duplex  Link up
Requesting Internet Address for 0:14:4f:98:9:c2
Requesting Internet Address for 0:14:4f:98:9:c2
Requesting Internet Address for 0:14:4f:98:9:c2
Requesting Internet Address for 0:14:4f:98:9:c2
Requesting Internet Address for 0:14:4f:98:9:c2
Requesting Internet Address for 0:14:4f:98:9:c2
/
[    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 4.30.0 2008/12/11 12:15'
[    0.000000] PROMLIB: Root node compatible: sun4v
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.39.4-razik-2011-11-04 (root@cluster1) (gcc version 4.4.5 (Debian 4.4.5-8) ) #7 SMP Fri Nov 4 17:25:22 CET 2011
[    0.000000] bootconsole [earlyprom0] enabled
[    0.000000] ARCH: SUN4V
[    0.000000] Ethernet address: 00:14:4f:98:09:c2
[    0.000000] Kernel: Using 2 locked TLB entries for main kernel image.
[    0.000000] Remapping the kernel... done.
[    0.000000] OF stdout device is: /virtual-devices@100/console@1
[    0.000000] PROM: Built device tree with 123783 bytes of memory.
[    0.000000] MDESC: Size is 58832 bytes.
[    0.000000] PLATFORM: banner-name [SPARC Enterprise T5120]
[    0.000000] PLATFORM: name [SUNW,SPARC-Enterprise-T5120]
[    0.000000] PLATFORM: hostid [849809c2]
[    0.000000] PLATFORM: serial# [00ab4130]
[    0.000000] PLATFORM: stick-frequency [5458c3a0]
[    0.000000] PLATFORM: mac-address [144f9809c2]
[    0.000000] PLATFORM: watchdog-resolution [1000 ms]
[    0.000000] PLATFORM: watchdog-max-timeout [31536000000 ms]
[    0.000000] PLATFORM: max-cpus [64]
[    0.000000] Top of RAM: 0x7ffb1c000, Total RAM: 0x7f76c2000
[    0.000000] Memory hole size: 132MB
[    0.000000] [0000010000000000-fffff80009000000] page_structs=131072 node=0 entry=0/8192
[    0.000000] [0000010000000000-fffff80009400000] page_structs=131072 node=0 entry=1/8192
[    0.000000] [0000010000800000-fffff80009800000] page_structs=131072 node=0 entry=2/8192
[    0.000000] [0000010000800000-fffff80009c00000] page_structs=131072 node=0 entry=3/8192
[    0.000000] [0000010001000000-fffff8000a000000] page_structs=131072 node=0 entry=4/8192
[    0.000000] [0000010001000000-fffff8000a400000] page_structs=131072 node=0 entry=5/8192
[    0.000000] [0000010001800000-fffff8000a800000] page_structs=131072 node=0 entry=6/8192
[    0.000000] [0000010001800000-fffff8000ac00000] page_structs=131072 node=0 entry=7/8192
[    0.000000] [0000010002000000-fffff8000b000000] page_structs=131072 node=0 entry=8/8192
[    0.000000] [0000010002000000-fffff8000b400000] page_structs=131072 node=0 entry=9/8192
[    0.000000] [0000010002800000-fffff8000b800000] page_structs=131072 node=0 entry=10/8192
[    0.000000] [0000010002800000-fffff8000bc00000] page_structs=131072 node=0 entry=11/8192
[    0.000000] [0000010003000000-fffff8000c000000] page_structs=131072 node=0 entry=12/8192
[    0.000000] [0000010003000000-fffff8000c400000] page_structs=131072 node=0 entry=13/8192
[    0.000000] [0000010003800000-fffff8000c800000] page_structs=131072 node=0 entry=14/8192
[    0.000000] [0000010003800000-fffff8000cc00000] page_structs=131072 node=0 entry=15/8192
[    0.000000] [0000010004000000-fffff8000d000000] page_structs=131072 node=0 entry=16/8192
[    0.000000] [0000010004000000-fffff8000d400000] page_structs=131072 node=0 entry=17/8192
[    0.000000] [0000010004800000-fffff8000d800000] page_structs=131072 node=0 entry=18/8192
[    0.000000] [0000010004800000-fffff8000dc00000] page_structs=131072 node=0 entry=19/8192
[    0.000000] [0000010005000000-fffff8000e000000] page_structs=131072 node=0 entry=20/8192
[    0.000000] [0000010005000000-fffff8000e400000] page_structs=131072 node=0 entry=21/8192
[    0.000000] [0000010005800000-fffff8000e800000] page_structs=131072 node=0 entry=22/8192
[    0.000000] [0000010005800000-fffff8000ec00000] page_structs=131072 node=0 entry=23/8192
[    0.000000] [0000010006000000-fffff8000f000000] page_structs=131072 node=0 entry=24/8192
[    0.000000] [0000010006000000-fffff8000f400000] page_structs=131072 node=0 entry=25/8192
[    0.000000] [0000010006800000-fffff8000f800000] page_structs=131072 node=0 entry=26/8192
[    0.000000] [0000010006800000-fffff8000fc00000] page_structs=131072 node=0 entry=27/8192
[    0.000000] [0000010007000000-fffff80010000000] page_structs=131072 node=0 entry=28/8192
[    0.000000] [0000010007000000-fffff80010400000] page_structs=131072 node=0 entry=29/8192
[    0.000000] [0000010007800000-fffff80010800000] page_structs=131072 node=0 entry=30/8192
[    0.000000] [0000010007800000-fffff80010c00000] page_structs=131072 node=0 entry=31/8192
[    0.000000] [0000010008000000-fffff80011000000] page_structs=131072 node=0 entry=32/8192
[    0.000000] [0000010008000000-fffff80011400000] page_structs=131072 node=0 entry=33/8192
[    0.000000] [0000010008800000-fffff80011800000] page_structs=131072 node=0 entry=34/8192
[    0.000000] [0000010008800000-fffff80011c00000] page_structs=131072 node=0 entry=35/8192
[    0.000000] [0000010009000000-fffff80012000000] page_structs=131072 node=0 entry=36/8192
[    0.000000] [0000010009000000-fffff80012400000] page_structs=131072 node=0 entry=37/8192
[    0.000000] [0000010009800000-fffff80012800000] page_structs=131072 node=0 entry=38/8192
[    0.000000] [0000010009800000-fffff80012c00000] page_structs=131072 node=0 entry=39/8192
[    0.000000] [000001000a000000-fffff80013000000] page_structs=131072 node=0 entry=40/8192
[    0.000000] [000001000a000000-fffff80013400000] page_structs=131072 node=0 entry=41/8192
[    0.000000] [000001000a800000-fffff80013800000] page_structs=131072 node=0 entry=42/8192
[    0.000000] [000001000a800000-fffff80013c00000] page_structs=131072 node=0 entry=43/8192
[    0.000000] [000001000b000000-fffff80014000000] page_structs=131072 node=0 entry=44/8192
[    0.000000] [000001000b000000-fffff80014400000] page_structs=131072 node=0 entry=45/8192
[    0.000000] [000001000b800000-fffff80014800000] page_structs=131072 node=0 entry=46/8192
[    0.000000] [000001000b800000-fffff80014c00000] page_structs=131072 node=0 entry=47/8192
[    0.000000] [000001000c000000-fffff80015000000] page_structs=131072 node=0 entry=48/8192
[    0.000000] [000001000c000000-fffff80015400000] page_structs=131072 node=0 entry=49/8192
[    0.000000] [000001000c800000-fffff80015800000] page_structs=131072 node=0 entry=50/8192
[    0.000000] [000001000c800000-fffff80015c00000] page_structs=131072 node=0 entry=51/8192
[    0.000000] [000001000d000000-fffff80016000000] page_structs=131072 node=0 entry=52/8192
[    0.000000] [000001000d000000-fffff80016400000] page_structs=131072 node=0 entry=53/8192
[    0.000000] [000001000d800000-fffff80016800000] page_structs=131072 node=0 entry=54/8192
[    0.000000] [000001000d800000-fffff80016c00000] page_structs=131072 node=0 entry=55/8192
[    0.000000] [000001000e000000-fffff80017000000] page_structs=131072 node=0 entry=56/8192
[    0.000000] [000001000e000000-fffff80017400000] page_structs=131072 node=0 entry=57/8192
[    0.000000] [000001000e800000-fffff80017800000] page_structs=131072 node=0 entry=58/8192
[    0.000000] [000001000e800000-fffff80017c00000] page_structs=131072 node=0 entry=59/8192
[    0.000000] [000001000f000000-fffff80018000000] page_structs=131072 node=0 entry=60/8192
[    0.000000] [000001000f000000-fffff80018400000] page_structs=131072 node=0 entry=61/8192
[    0.000000] [000001000f800000-fffff80018800000] page_structs=131072 node=0 entry=62/8192
[    0.000000] [000001000f800000-fffff80018c00000] page_structs=131072 node=0 entry=63/8192
[    0.000000] Zone PFN ranges:
[    0.000000]   Normal   0x00004200 -> 0x003ffd8e
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0: 0x00004200 -> 0x003ffd47
[    0.000000]     0: 0x003ffd50 -> 0x003ffd63
[    0.000000]     0: 0x003ffd87 -> 0x003ffd8e
[    0.000000] Booting Linux...
[    0.000000] PERCPU: Embedded 6 pages/cpu @fffff80019000000 s15616 r8192 d25344 u65536
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 4144105
[    0.000000] Kernel command line: root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2 ip=137.226.167.242::137.226.167.225:255.255.255.224:cluster2:eth0:off
[    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 4194304 (order: 12, 33554432 bytes)
[    0.000000] Inode-cache hash table entries: 2097152 (order: 11, 16777216 bytes)
[    0.000000] Memory: 33091488k available (3528k kernel code, 1248k data, 208k init) [fffff80000000000,00000007ffb1c000]
[    0.000000] SLUB: Genslabs=16, HWalign=32, Order=0-3, MinObjects=0, CPUs=64, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  CONFIG_RCU_FANOUT set to non-default value of 32
[    0.000000]  RCU-based detection of stalled CPUs is disabled.
[    0.000000] NR_IRQS:255
[    0.000000] clocksource: mult[5a73e7bb] shift[31]
[    0.000000] clockevent: mult[b5221ba3] shift[31]
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled, bootconsole disabled
[    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 4.30.0 2008/12/11 12:15'
[    0.000000] PROMLIB: Root node compatible: sun4v
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.39.4-razik-2011-11-04 (root@cluster1) (gcc version 4.4.5 (Debian 4.4.5-8) ) #7 SMP Fri Nov 4 17:25:22 CET 2011
[    0.000000] bootconsole [earlyprom0] enabled
[    0.000000] ARCH: SUN4V
[    0.000000] Ethernet address: 00:14:4f:98:09:c2
[    0.000000] Kernel: Using 2 locked TLB entries for main kernel image.
[    0.000000] Remapping the kernel... done.
[    0.000000] OF stdout device is: /virtual-devices@100/console@1
[    0.000000] PROM: Built device tree with 123783 bytes of memory.
[    0.000000] MDESC: Size is 58832 bytes.
[    0.000000] PLATFORM: banner-name [SPARC Enterprise T5120]
[    0.000000] PLATFORM: name [SUNW,SPARC-Enterprise-T5120]
[    0.000000] PLATFORM: hostid [849809c2]
[    0.000000] PLATFORM: serial# [00ab4130]
[    0.000000] PLATFORM: stick-frequency [5458c3a0]
[    0.000000] PLATFORM: mac-address [144f9809c2]
[    0.000000] PLATFORM: watchdog-resolution [1000 ms]
[    0.000000] PLATFORM: watchdog-max-timeout [31536000000 ms]
[    0.000000] PLATFORM: max-cpus [64]
[    0.000000] Top of RAM: 0x7ffb1c000, Total RAM: 0x7f76c2000
[    0.000000] Memory hole size: 132MB
[    0.000000] [0000010000000000-fffff80009000000] page_structs=131072 node=0 entry=0/8192
[    0.000000] [0000010000000000-fffff80009400000] page_structs=131072 node=0 entry=1/8192
[    0.000000] [0000010000800000-fffff80009800000] page_structs=131072 node=0 entry=2/8192
[    0.000000] [0000010000800000-fffff80009c00000] page_structs=131072 node=0 entry=3/8192
[    0.000000] [0000010001000000-fffff8000a000000] page_structs=131072 node=0 entry=4/8192
[    0.000000] [0000010001000000-fffff8000a400000] page_structs=131072 node=0 entry=5/8192
[    0.000000] [0000010001800000-fffff8000a800000] page_structs=131072 node=0 entry=6/8192
[    0.000000] [0000010001800000-fffff8000ac00000] page_structs=131072 node=0 entry=7/8192
[    0.000000] [0000010002000000-fffff8000b000000] page_structs=131072 node=0 entry=8/8192
[    0.000000] [0000010002000000-fffff8000b400000] page_structs=131072 node=0 entry=9/8192
[    0.000000] [0000010002800000-fffff8000b800000] page_structs=131072 node=0 entry=10/8192
[    0.000000] [0000010002800000-fffff8000bc00000] page_structs=131072 node=0 entry=11/8192
[    0.000000] [0000010003000000-fffff8000c000000] page_structs=131072 node=0 entry=12/8192
[    0.000000] [0000010003000000-fffff8000c400000] page_structs=131072 node=0 entry=13/8192
[    0.000000] [0000010003800000-fffff8000c800000] page_structs=131072 node=0 entry=14/8192
[    0.000000] [0000010003800000-fffff8000cc00000] page_structs=131072 node=0 entry=15/8192
[    0.000000] [0000010004000000-fffff8000d000000] page_structs=131072 node=0 entry=16/8192
[    0.000000] [0000010004000000-fffff8000d400000] page_structs=131072 node=0 entry=17/8192
[    0.000000] [0000010004800000-fffff8000d800000] page_structs=131072 node=0 entry=18/8192
[    0.000000] [0000010004800000-fffff8000dc00000] page_structs=131072 node=0 entry=19/8192
[    0.000000] [0000010005000000-fffff8000e000000] page_structs=131072 node=0 entry=20/8192
[    0.000000] [0000010005000000-fffff8000e400000] page_structs=131072 node=0 entry=21/8192
[    0.000000] [0000010005800000-fffff8000e800000] page_structs=131072 node=0 entry=22/8192
[    0.000000] [0000010005800000-fffff8000ec00000] page_structs=131072 node=0 entry=23/8192
[    0.000000] [0000010006000000-fffff8000f000000] page_structs=131072 node=0 entry=24/8192
[    0.000000] [0000010006000000-fffff8000f400000] page_structs=131072 node=0 entry=25/8192
[    0.000000] [0000010006800000-fffff8000f800000] page_structs=131072 node=0 entry=26/8192
[    0.000000] [0000010006800000-fffff8000fc00000] page_structs=131072 node=0 entry=27/8192
[    0.000000] [0000010007000000-fffff80010000000] page_structs=131072 node=0 entry=28/8192
[    0.000000] [0000010007000000-fffff80010400000] page_structs=131072 node=0 entry=29/8192
[    0.000000] [0000010007800000-fffff80010800000] page_structs=131072 node=0 entry=30/8192
[    0.000000] [0000010007800000-fffff80010c00000] page_structs=131072 node=0 entry=31/8192
[    0.000000] [0000010008000000-fffff80011000000] page_structs=131072 node=0 entry=32/8192
[    0.000000] [0000010008000000-fffff80011400000] page_structs=131072 node=0 entry=33/8192
[    0.000000] [0000010008800000-fffff80011800000] page_structs=131072 node=0 entry=34/8192
[    0.000000] [0000010008800000-fffff80011c00000] page_structs=131072 node=0 entry=35/8192
[    0.000000] [0000010009000000-fffff80012000000] page_structs=131072 node=0 entry=36/8192
[    0.000000] [0000010009000000-fffff80012400000] page_structs=131072 node=0 entry=37/8192
[    0.000000] [0000010009800000-fffff80012800000] page_structs=131072 node=0 entry=38/8192
[    0.000000] [0000010009800000-fffff80012c00000] page_structs=131072 node=0 entry=39/8192
[    0.000000] [000001000a000000-fffff80013000000] page_structs=131072 node=0 entry=40/8192
[    0.000000] [000001000a000000-fffff80013400000] page_structs=131072 node=0 entry=41/8192
[    0.000000] [000001000a800000-fffff80013800000] page_structs=131072 node=0 entry=42/8192
[    0.000000] [000001000a800000-fffff80013c00000] page_structs=131072 node=0 entry=43/8192
[    0.000000] [000001000b000000-fffff80014000000] page_structs=131072 node=0 entry=44/8192
[    0.000000] [000001000b000000-fffff80014400000] page_structs=131072 node=0 entry=45/8192
[    0.000000] [000001000b800000-fffff80014800000] page_structs=131072 node=0 entry=46/8192
[    0.000000] [000001000b800000-fffff80014c00000] page_structs=131072 node=0 entry=47/8192
[    0.000000] [000001000c000000-fffff80015000000] page_structs=131072 node=0 entry=48/8192
[    0.000000] [000001000c000000-fffff80015400000] page_structs=131072 node=0 entry=49/8192
[    0.000000] [000001000c800000-fffff80015800000] page_structs=131072 node=0 entry=50/8192
[    0.000000] [000001000c800000-fffff80015c00000] page_structs=131072 node=0 entry=51/8192
[    0.000000] [000001000d000000-fffff80016000000] page_structs=131072 node=0 entry=52/8192
[    0.000000] [000001000d000000-fffff80016400000] page_structs=131072 node=0 entry=53/8192
[    0.000000] [000001000d800000-fffff80016800000] page_structs=131072 node=0 entry=54/8192
[    0.000000] [000001000d800000-fffff80016c00000] page_structs=131072 node=0 entry=55/8192
[    0.000000] [000001000e000000-fffff80017000000] page_structs=131072 node=0 entry=56/8192
[    0.000000] [000001000e000000-fffff80017400000] page_structs=131072 node=0 entry=57/8192
[    0.000000] [000001000e800000-fffff80017800000] page_structs=131072 node=0 entry=58/8192
[    0.000000] [000001000e800000-fffff80017c00000] page_structs=131072 node=0 entry=59/8192
[    0.000000] [000001000f000000-fffff80018000000] page_structs=131072 node=0 entry=60/8192
[    0.000000] [000001000f000000-fffff80018400000] page_structs=131072 node=0 entry=61/8192
[    0.000000] [000001000f800000-fffff80018800000] page_structs=131072 node=0 entry=62/8192
[    0.000000] [000001000f800000-fffff80018c00000] page_structs=131072 node=0 entry=63/8192
[    0.000000] Zone PFN ranges:
[    0.000000]   Normal   0x00004200 -> 0x003ffd8e
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[3] active PFN ranges
[    0.000000]     0: 0x00004200 -> 0x003ffd47
[    0.000000]     0: 0x003ffd50 -> 0x003ffd63
[    0.000000]     0: 0x003ffd87 -> 0x003ffd8e
[    0.000000] Booting Linux...
[    0.000000] PERCPU: Embedded 6 pages/cpu @fffff80019000000 s15616 r8192 d25344 u65536
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 4144105
[    0.000000] Kernel command line: root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2 ip=137.226.167.242::137.226.167.225:255.255.255.224:cluster2:eth0:off
[    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 4194304 (order: 12, 33554432 bytes)
[    0.000000] Inode-cache hash table entries: 2097152 (order: 11, 16777216 bytes)
[    0.000000] Memory: 33091488k available (3528k kernel code, 1248k data, 208k init) [fffff80000000000,00000007ffb1c000]
[    0.000000] SLUB: Genslabs=16, HWalign=32, Order=0-3, MinObjects=0, CPUs=64, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  CONFIG_RCU_FANOUT set to non-default value of 32
[    0.000000]  RCU-based detection of stalled CPUs is disabled.
[    0.000000] NR_IRQS:255
[    0.000000] clocksource: mult[5a73e7bb] shift[31]
[    0.000000] clockevent: mult[b5221ba3] shift[31]
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled, bootconsole disabled
[  509.804744] Calibrating delay using timer specific routine.. 2832.71 BogoMIPS (lpj=5665433)
[  509.804778] pid_max: default: 65536 minimum: 512
[  509.805222] Mount-cache hash table entries: 512
[  509.806382] Initializing cgroup subsys ns
[  509.806402] ns_cgroup deprecated: consider using the 'clone_children' flag without the ns_cgroup.
[  509.806429] Initializing cgroup subsys cpuacct
[  509.806536] Initializing cgroup subsys devices
[  509.806554] Initializing cgroup subsys freezer
[  509.806570] Initializing cgroup subsys net_cls
[  509.806836] Performance events: Supported PMU type is 'niagara2'
[  509.829343] Brought up 64 CPUs
[  509.829440] Testing NMI watchdog ... OK.
[  509.910785] devtmpfs: initialized
[  509.911236] ldc.c:v1.1 (July 22, 2008)
[  509.911508] print_constraints: dummy: 
[  509.911845] NET: Registered protocol family 16
[  509.920950] VIO: Adding device channel-devices
[  509.921027] VIO: Adding device vldc-port-3-0
[  509.921089] VIO: Adding device vldc-port-3-1
[  509.921149] VIO: Adding device vldc-port-3-2
[  509.921209] VIO: Adding device vldc-port-3-3
[  509.921279] VIO: Adding device vldc-port-3-4
[  509.921346] VIO: Adding device vldc-port-3-5
[  509.921415] VIO: Adding device vldc-port-2-0
[  509.921482] VIO: Adding device vldc-port-0-0
[  509.921548] VIO: Adding device vldc-port-0-1
[  509.921615] VIO: Adding device vldc-port-0-2
[  509.921692] VIO: Adding device vldc-port-1-0
[  509.921764] VIO: Adding device vldc-port-3-7
[  509.921836] VIO: Adding device vldc-port-3-8
[  509.921918] VIO: Adding device ds-1
[  509.921981] VIO: Adding device ds-0
[  509.926530] pci_sun4v: Registered hvapi major[1] minor[0]
[  509.926805] /pci@0: SUN4V PCI Bus Module
[  509.926824] /pci@0: On NUMA node -1
[  509.926844] /pci@0: PCI IO[c0f0000000] MEM[c100000000]
[  509.926871] /pci@0: Unable to request IOMMU resource.
[  509.971041] /pci@0: Imported 3 TSB entries from OBP
[  509.972495] /pci@0: MSI Queue first[0] num[36] count[128] devino[0x18]
[  509.972523] /pci@0: MSI first[0] num[256] mask[0xff] width[32]
[  509.972547] /pci@0: MSI addr32[0x7fff0000:0x10000] addr64[0x3ffff0000:0x10000]
[  509.972577] /pci@0: MSI queues at RA [00000007f8180000]
[  509.972600] PCI: Scanning PBM /pci@0
[  509.984309] ds.c:v1.0 (Jul 11, 2007)
[  509.987359] bio: create slab <bio-0> at 0
[  509.987974] vgaarb: loaded
[  509.988772] Switching to clocksource stick
[  509.989440] Switched to NOHz mode on CPU #41
[  509.989554] Switched to NOHz mode on CPU #18
[  509.989580] Switched to NOHz mode on CPU #6
[  509.989616] Switched to NOHz mode on CPU #53
[  509.989626] Switched to NOHz mode on CPU #30
[  509.989759] Switched to NOHz mode on CPU #42
[  509.989885] Switched to NOHz mode on CPU #19
[  509.989911] Switched to NOHz mode on CPU #7
[  509.989962] Switched to NOHz mode on CPU #31
[  509.989971] Switched to NOHz mode on CPU #54
[  509.990097] Switched to NOHz mode on CPU #43
[  509.990216] Switched to NOHz mode on CPU #20
[  509.990226] Switched to NOHz mode on CPU #8
[  509.990306] Switched to NOHz mode on CPU #32
[  509.990327] Switched to NOHz mode on CPU #55
[  509.990444] Switched to NOHz mode on CPU #44
[  509.990541] Switched to NOHz mode on CPU #9
[  509.990557] Switched to NOHz mode on CPU #21
[  509.990651] Switched to NOHz mode on CPU #33
[  509.990671] Switched to NOHz mode on CPU #56
[  509.990789] Switched to NOHz mode on CPU #45
[  509.990876] Switched to NOHz mode on CPU #10
[  509.990893] Switched to NOHz mode on CPU #22
[  509.990985] Switched to NOHz mode on CPU #34
[  509.991023] Switched to NOHz mode on CPU #57
[  509.991136] Switched to NOHz mode on CPU #46
[  509.991207] Switched to NOHz mode on CPU #11
[  509.991239] Switched to NOHz mode on CPU #23
[  509.991340] Switched to NOHz mode on CPU #35
[  509.991367] Switched to NOHz mode on CPU #58
[  509.991485] Switched to NOHz mode on CPU #47
[  509.991536] Switched to NOHz mode on CPU #12
[  509.991577] Switched to NOHz mode on CPU #24
[  509.991675] Switched to NOHz mode on CPU #36
[  509.991736] Switched to NOHz mode on CPU #59
[  509.991835] Switched to NOHz mode on CPU #48
[  509.991853] Switched to NOHz mode on CPU #1
[  509.991863] Switched to NOHz mode on CPU #13
[  509.991917] Switched to NOHz mode on CPU #25
[  509.992033] Switched to NOHz mode on CPU #37
[  509.992083] Switched to NOHz mode on CPU #60
[  509.992188] Switched to NOHz mode on CPU #14
[  509.992198] Switched to NOHz mode on CPU #49
[  509.992254] Switched to NOHz mode on CPU #26
[  509.992263] Switched to NOHz mode on CPU #2
[  509.992369] Switched to NOHz mode on CPU #38
[  509.992435] Switched to NOHz mode on CPU #61
[  509.992527] Switched to NOHz mode on CPU #15
[  509.992546] Switched to NOHz mode on CPU #50
[  509.992579] Switched to NOHz mode on CPU #3
[  509.992645] Switched to NOHz mode on CPU #0
[  509.992655] Switched to NOHz mode on CPU #27
[  509.992699] Switched to NOHz mode on CPU #39
[  509.992787] Switched to NOHz mode on CPU #62
[  509.992870] Switched to NOHz mode on CPU #16
[  509.992893] Switched to NOHz mode on CPU #51
[  509.992916] Switched to NOHz mode on CPU #4
[  509.992933] Switched to NOHz mode on CPU #28
[  509.993055] Switched to NOHz mode on CPU #40
[  509.993180] Switched to NOHz mode on CPU #52
[  509.993190] Switched to NOHz mode on CPU #29
[  509.993199] Switched to NOHz mode on CPU #5
[  509.993208] Switched to NOHz mode on CPU #17
[  509.993218] Switched to NOHz mode on CPU #63
[  509.997364] NET: Registered protocol family 2
[  509.997817] IP route cache hash table entries: 524288 (order: 9, 4194304 bytes)
[  509.999942] TCP established hash table entries: 524288 (order: 10, 8388608 bytes)
[  510.006892] ds-1: Registered pri service.
[  510.009264] ds-1: Registered var-config-backup service.
[  510.025315] TCP bind hash table entries: 65536 (order: 7, 1048576 bytes)
[  510.029037] TCP: Hash tables configured (established 524288 bind 65536)
[  510.029062] TCP reno registered
[  510.029106] UDP hash table entries: 16384 (order: 6, 524288 bytes)
[  510.031128] UDP-Lite hash table entries: 16384 (order: 6, 524288 bytes)
[  510.034532] NET: Registered protocol family 1
[  510.035019] RPC: Registered udp transport module.
[  510.035042] RPC: Registered tcp transport module.
[  510.035063] RPC: Registered tcp NFSv4.1 backchannel transport module.
[  510.036252] audit: initializing netlink socket (disabled)
[  510.036298] type=2000 audit(0.304:1): initialized
[  510.084013] HugeTLB registered 4 MB page size, pre-allocated 0 pages
[  510.092493] VFS: Disk quotas dquot_6.5.2
[  510.092950] Dquot-cache hash table entries: 1024 (order 0, 8192 bytes)
[  510.094145] msgmni has been set to 32768
[  510.095212] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[  510.095245] io scheduler noop registered
[  510.095264] io scheduler deadline registered
[  510.095494] io scheduler cfq registered (default)
[  510.096783] f027ab74: ttyS0 at I/O 0x0 (irq = 17) is a SUN4V HCONS
[  510.155390] console [ttyHV0] enabled
[  510.156988] f028af14: ttyS1 at MMIO 0xfff0ca0000 (irq = 24) is a 16550A
[  510.157601] [drm] Initialized drm 1.1.0 20060810
[  510.158744] e1000e: Intel(R) PRO/1000 Network Driver - 1.3.10-k2
[  510.186832] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[  510.186933] e1000e 0000:08:00.0: Disabling ASPM  L1
[  510.364001] e1000e 0000:08:00.0: eth0: (PCI Express:2.5GB/s:Width x4) 00:14:4f:98:09:c2
[  510.364122] e1000e 0000:08:00.0: eth0: Intel(R) PRO/1000 Network Connection
[  510.364306] e1000e 0000:08:00.0: eth0: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[  510.364444] e1000e 0000:08:00.1: Disabling ASPM  L1
[  510.545790] e1000e 0000:08:00.1: eth1: (PCI Express:2.5GB/s:Width x4) 00:14:4f:98:09:c3
[  510.545910] e1000e 0000:08:00.1: eth1: Intel(R) PRO/1000 Network Connection
[  510.546093] e1000e 0000:08:00.1: eth1: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[  510.546219] e1000e 0000:09:00.0: Disabling ASPM  L1
[  510.724130] e1000e 0000:09:00.0: eth2: (PCI Express:2.5GB/s:Width x4) 00:14:4f:98:09:c4
[  510.724251] e1000e 0000:09:00.0: eth2: Intel(R) PRO/1000 Network Connection
[  510.724434] e1000e 0000:09:00.0: eth2: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[  510.724559] e1000e 0000:09:00.1: Disabling ASPM  L1
[  510.905999] e1000e 0000:09:00.1: eth3: (PCI Express:2.5GB/s:Width x4) 00:14:4f:98:09:c5
[  510.906120] e1000e 0000:09:00.1: eth3: Intel(R) PRO/1000 Network Connection
[  510.906303] e1000e 0000:09:00.1: eth3: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[  510.906988] mousedev: PS/2 mouse device common for all mice
[  510.907998] rtc-sun4v rtc-sun4v: rtc core: registered sun4v as rtc0
[  510.908670] TCP cubic registered
[  510.909540] NET: Registered protocol family 10
[  510.914368] Mobile IPv6
[  510.914442] NET: Registered protocol family 17
[  510.914548] Registering the dns_resolver key type
[  510.915076] registered taskstats version 1
[  510.918076] rtc-sun4v rtc-sun4v: setting system clock to 2011-11-04 16:49:01 UTC (1320425341)
[  511.667422] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  512.689540] IP-Config: Complete:
[  512.689612]      device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=137.226.167.225,
[  512.689815]      host=cluster2, domain=, nis-domain=(none),
[  512.689927]      bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
[  513.772653] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
[  513.792638] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
