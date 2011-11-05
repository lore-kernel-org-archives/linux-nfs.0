Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm15-vm0.bullet.mail.ird.yahoo.com ([77.238.189.216]:46920 "HELO
	nm15-vm0.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751413Ab1KEBws convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 21:52:48 -0400
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com>  <1320353685.18396.119.camel@lade.trondhjem.org>  <20111103211100.GA8393@umich.edu>  <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com>  <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com>  <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com>  <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com>  <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>  <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com>  <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com>  <1320450001.87605.YahooMailNeo@web24706.mail.ird.yahoo.com> <1320455965.2750.9.camel@lade.trondhjem.org>
Message-ID: <1320457963.63089.YahooMailNeo@web24714.mail.ird.yahoo.com>
Date: Sat, 5 Nov 2011 01:52:43 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <1320455965.2750.9.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> So the NFS client is trying to establish contact with the server for a

> period of 35 seconds, and there is no reply... Have you tried using
> wireshark to see if any NFS traffic is arriving at the server from the
> client?

Yes, the server gets no packets from the client between linux 2.6.37 and 3.1.
In linux <= 2.6.36 it also doesn't get packets from client to RPC port 10003 (not even ARP packets) but then the kernel tries 10005. This works (the server gets ARP, then SUNRPC packets and the client can mount NFSROOT).


> Have you tried using the 'mountproto=tcp' option?

Now yes. There were no ARP or SUNRPC packets.
That's the result of linux-3.1 with 'mountproto=tcp':
---
{0} ok boot net root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2,mountproto=tcp ip=137.226.167.242:::255.255.255.224::eth0:off nfsrootdebug
Boot device: /pci@0/pci@0/pci@1/pci@0/pci@2/network@0  File and args: root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2,mountproto=tcp ip=137.226.167.242:::255.255.255.224::eth0:off nfsrootdebug
1000 Mbps full duplex  Link up
Requesting Internet Address for 0:14:4f:98:9:c2
Requesting Internet Address for 0:14:4f:98:9:c2
Requesting Internet Address for 0:14:4f:98:9:c2
Requesting Internet Address for 0:14:4f:98:9:c2
Requesting Internet Address for 0:14:4f:98:9:c2
Requesting Internet Address for 0:14:4f:98:9:c2
|
[    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 4.30.0 2008/12/11 12:15'
[    0.000000] PROMLIB: Root node compatible: sun4v
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.1.0-razik-2011-11-05 (root@cluster1) (gcc version 4.4.5 (Debian 4.4.5-8) ) #3 SMP Sat Nov 5 00:24:24 CET 2011
[    0.000000] bootconsole [earlyprom0] enabled
[    0.000000] ARCH: SUN4V
[    0.000000] Ethernet address: 00:14:4f:98:09:c2
[    0.000000] Kernel: Using 2 locked TLB entries for main kernel image.
[    0.000000] Remapping the kernel... done.
[    0.000000] OF stdout device is: /virtual-devices@100/console@1
[    0.000000] PROM: Built device tree with 123778 bytes of memory.
[    0.000000] MDESC: Size is 58816 bytes.
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
[    0.000000] CPU CAPS: [flush,stbar,swap,muldiv,v9,blkinit,n2,mul32]
[    0.000000] CPU CAPS: [div32,v8plus,popc,vis,vis2,ASIBlkInit]
[    0.000000] PERCPU: Embedded 5 pages/cpu @fffff80019000000 s10816 r8192 d21952 u65536
[    0.000000] SUN4V: Mondo queue sizes [cpu(8192) dev(16384) r(8192) nr(256)]
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 4144105
[    0.000000] Kernel command line: root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2,mountproto=tcp ip=137.226.167.242:::255.255.255.224::eth0:off nfsrootdebug
[    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 4194304 (order: 12, 33554432 bytes)
[    0.000000] Inode-cache hash table entries: 2097152 (order: 11, 16777216 bytes)
[    0.000000] Memory: 33091944k available (3568k kernel code, 1272k data, 216k init) [fffff80000000000,00000007ffb1c000]
[    0.000000] SLUB: Genslabs=16, HWalign=32, Order=0-3, MinObjects=0, CPUs=64, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  CONFIG_RCU_FANOUT set to non-default value of 32
[    0.000000] NR_IRQS:255
[    0.000000] clocksource: mult[b4e7cf] shift[24]
[    0.000000] clockevent: mult[b5221ba3] shift[31]
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled, bootconsole disabled
[    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 4.30.0 2008/12/11 12:15'
[    0.000000] PROMLIB: Root node compatible: sun4v
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.1.0-razik-2011-11-05 (root@cluster1) (gcc version 4.4.5 (Debian 4.4.5-8) ) #3 SMP Sat Nov 5 00:24:24 CET 2011
[    0.000000] bootconsole [earlyprom0] enabled
[    0.000000] ARCH: SUN4V
[    0.000000] Ethernet address: 00:14:4f:98:09:c2
[    0.000000] Kernel: Using 2 locked TLB entries for main kernel image.
[    0.000000] Remapping the kernel... done.
[    0.000000] OF stdout device is: /virtual-devices@100/console@1
[    0.000000] PROM: Built device tree with 123778 bytes of memory.
[    0.000000] MDESC: Size is 58816 bytes.
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
[    0.000000] CPU CAPS: [flush,stbar,swap,muldiv,v9,blkinit,n2,mul32]
[    0.000000] CPU CAPS: [div32,v8plus,popc,vis,vis2,ASIBlkInit]
[    0.000000] PERCPU: Embedded 5 pages/cpu @fffff80019000000 s10816 r8192 d21952 u65536
[    0.000000] SUN4V: Mondo queue sizes [cpu(8192) dev(16384) r(8192) nr(256)]
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 4144105
[    0.000000] Kernel command line: root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2,mountproto=tcp ip=137.226.167.242:::255.255.255.224::eth0:off nfsrootdebug
[    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 4194304 (order: 12, 33554432 bytes)
[    0.000000] Inode-cache hash table entries: 2097152 (order: 11, 16777216 bytes)
[    0.000000] Memory: 33091944k available (3568k kernel code, 1272k data, 216k init) [fffff80000000000,00000007ffb1c000]
[    0.000000] SLUB: Genslabs=16, HWalign=32, Order=0-3, MinObjects=0, CPUs=64, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  CONFIG_RCU_FANOUT set to non-default value of 32
[    0.000000] NR_IRQS:255
[    0.000000] clocksource: mult[b4e7cf] shift[24]
[    0.000000] clockevent: mult[b5221ba3] shift[31]
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled, bootconsole disabled
[  273.822931] Calibrating delay using timer specific routine.. 2832.85 BogoMIPS (lpj=5665715)
[  273.822964] pid_max: default: 65536 minimum: 512
[  273.823429] Mount-cache hash table entries: 512
[  273.824703] Initializing cgroup subsys cpuacct
[  273.824814] Initializing cgroup subsys devices
[  273.824832] Initializing cgroup subsys freezer
[  273.824848] Initializing cgroup subsys net_cls
[  273.825126] Performance events: Supported PMU type is 'niagara2'
[  273.847590] Brought up 64 CPUs
[  273.847649] Testing NMI watchdog ... OK.
[  273.930292] devtmpfs: initialized
[  273.930789] ldc.c:v1.1 (July 22, 2008)
[  273.931092] print_constraints: dummy: 
[  273.931479] NET: Registered protocol family 16
[  273.940690] VIO: Adding device channel-devices
[  273.940767] VIO: Adding device vldc-port-3-0
[  273.940828] VIO: Adding device vldc-port-3-1
[  273.940888] VIO: Adding device vldc-port-3-2
[  273.940958] VIO: Adding device vldc-port-3-3
[  273.941020] VIO: Adding device vldc-port-3-4
[  273.941082] VIO: Adding device vldc-port-3-5
[  273.941144] VIO: Adding device vldc-port-2-0
[  273.941207] VIO: Adding device vldc-port-0-0
[  273.941276] VIO: Adding device vldc-port-0-1
[  273.941344] VIO: Adding device vldc-port-0-2
[  273.941422] VIO: Adding device vldc-port-1-0
[  273.941492] VIO: Adding device vldc-port-3-7
[  273.941565] VIO: Adding device vldc-port-3-8
[  273.941647] VIO: Adding device ds-1
[  273.941711] VIO: Adding device ds-0
[  273.946313] pci_sun4v: Registered hvapi major[1] minor[0]
[  273.946578] /pci@0: SUN4V PCI Bus Module
[  273.946598] /pci@0: On NUMA node -1
[  273.946619] /pci@0: PCI IO[c0f0000000] MEM[c100000000]
[  273.946649] /pci@0: Unable to request IOMMU resource.
[  273.990964] /pci@0: Imported 3 TSB entries from OBP
[  273.992499] /pci@0: MSI Queue first[0] num[36] count[128] devino[0x18]
[  273.992527] /pci@0: MSI first[0] num[256] mask[0xff] width[32]
[  273.992552] /pci@0: MSI addr32[0x7fff0000:0x10000] addr64[0x3ffff0000:0x10000]
[  273.992581] /pci@0: MSI queues at RA [00000007fe580000]
[  273.992605] PCI: Scanning PBM /pci@0
[  274.004444] ds.c:v1.0 (Jul 11, 2007)
[  274.007744] bio: create slab <bio-0> at 0
[  274.008323] vgaarb: loaded
[  274.009098] Switching to clocksource stick
[  274.009749] Switched to NOHz mode on CPU #47
[  274.009801] Switched to NOHz mode on CPU #12
[  274.009829] Switched to NOHz mode on CPU #24
[  274.009923] Switched to NOHz mode on CPU #36
[  274.009968] Switched to NOHz mode on CPU #59
[  274.010093] Switched to NOHz mode on CPU #48
[  274.010106] Switched to NOHz mode on CPU #1
[  274.010131] Switched to NOHz mode on CPU #13
[  274.010170] Switched to NOHz mode on CPU #25
[  274.010282] Switched to NOHz mode on CPU #37
[  274.010316] Switched to NOHz mode on CPU #60
[  274.010449] Switched to NOHz mode on CPU #49
[  274.010463] Switched to NOHz mode on CPU #14
[  274.010510] Switched to NOHz mode on CPU #2
[  274.010519] Switched to NOHz mode on CPU #26
[  274.010624] Switched to NOHz mode on CPU #38
[  274.010669] Switched to NOHz mode on CPU #61
[  274.010830] Switched to NOHz mode on CPU #3
[  274.010838] Switched to NOHz mode on CPU #0
[  274.010848] Switched to NOHz mode on CPU #50
[  274.010857] Switched to NOHz mode on CPU #27
[  274.010967] Switched to NOHz mode on CPU #39
[  274.011024] Switched to NOHz mode on CPU #62
[  274.011124] Switched to NOHz mode on CPU #16
[  274.011133] Switched to NOHz mode on CPU #51
[  274.011157] Switched to NOHz mode on CPU #4
[  274.011178] Switched to NOHz mode on CPU #28
[  274.011307] Switched to NOHz mode on CPU #40
[  274.011375] Switched to NOHz mode on CPU #63
[  274.011465] Switched to NOHz mode on CPU #17
[  274.011476] Switched to NOHz mode on CPU #52
[  274.011492] Switched to NOHz mode on CPU #5
[  274.011526] Switched to NOHz mode on CPU #29
[  274.011656] Switched to NOHz mode on CPU #41
[  274.011796] Switched to NOHz mode on CPU #18
[  274.011827] Switched to NOHz mode on CPU #6
[  274.011847] Switched to NOHz mode on CPU #53
[  274.011864] Switched to NOHz mode on CPU #30
[  274.012006] Switched to NOHz mode on CPU #42
[  274.012126] Switched to NOHz mode on CPU #19
[  274.012155] Switched to NOHz mode on CPU #7
[  274.012205] Switched to NOHz mode on CPU #54
[  274.012215] Switched to NOHz mode on CPU #31
[  274.012355] Switched to NOHz mode on CPU #43
[  274.012457] Switched to NOHz mode on CPU #20
[  274.012466] Switched to NOHz mode on CPU #8
[  274.012554] Switched to NOHz mode on CPU #32
[  274.012563] Switched to NOHz mode on CPU #55
[  274.012692] Switched to NOHz mode on CPU #44
[  274.012786] Switched to NOHz mode on CPU #9
[  274.012806] Switched to NOHz mode on CPU #21
[  274.012891] Switched to NOHz mode on CPU #33
[  274.012902] Switched to NOHz mode on CPU #56
[  274.013039] Switched to NOHz mode on CPU #45
[  274.013126] Switched to NOHz mode on CPU #10
[  274.013139] Switched to NOHz mode on CPU #22
[  274.013226] Switched to NOHz mode on CPU #34
[  274.013248] Switched to NOHz mode on CPU #57
[  274.013491] Switched to NOHz mode on CPU #58
[  274.013500] Switched to NOHz mode on CPU #23
[  274.013510] Switched to NOHz mode on CPU #46
[  274.013519] Switched to NOHz mode on CPU #35
[  274.013531] Switched to NOHz mode on CPU #11
[  274.014829] Switched to NOHz mode on CPU #15
[  274.018228] NET: Registered protocol family 2
[  274.018764] IP route cache hash table entries: 524288 (order: 9, 4194304 bytes)
[  274.020959] TCP established hash table entries: 524288 (order: 10, 8388608 bytes)
[  274.043706] ds-1: Registered pri service.
[  274.046488] TCP bind hash table entries: 65536 (order: 7, 1048576 bytes)
[  274.049897] ds-1: Registered var-config-backup service.
[  274.050231] TCP: Hash tables configured (established 524288 bind 65536)
[  274.050256] TCP reno registered
[  274.050295] UDP hash table entries: 16384 (order: 6, 524288 bytes)
[  274.052307] UDP-Lite hash table entries: 16384 (order: 6, 524288 bytes)
[  274.055271] NET: Registered protocol family 1
[  274.055356] RPC:       creating workqueue rpciod
[  274.055660] RPC:       registering /proc/net/rpc
[  274.055762] svc: Adding svc transport class 'tcp'
[  274.055790] svc: Adding svc transport class 'udp'
[  274.055860] RPC: Registered named UNIX socket transport module.
[  274.055884] RPC: Registered udp transport module.
[  274.055904] RPC: Registered tcp transport module.
[  274.055923] RPC: Registered tcp NFSv4.1 backchannel transport module.
[  274.057280] audit: initializing netlink socket (disabled)
[  274.057327] type=2000 audit(0.304:1): initialized
[  274.763711] HugeTLB registered 4 MB page size, pre-allocated 0 pages
[  274.772451] VFS: Disk quotas dquot_6.5.2
[  274.772895] Dquot-cache hash table entries: 1024 (order 0, 8192 bytes)
[  274.773526] RPC:       creating workqueue nfsiod
[  274.774321] RPC:       registering /proc/net/rpc/nfs
[  274.774375] msgmni has been set to 32768
[  274.775486] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[  274.775520] io scheduler noop registered
[  274.775539] io scheduler deadline registered
[  274.775775] io scheduler cfq registered (default)
[  274.777268] f027ab74: ttyS0 at I/O 0x0 (irq = 17) is a SUN4V HCONS
[  274.840726] console [ttyHV0] enabled
[  274.842372] f028af14: ttyS1 at MMIO 0xfff0ca0000 (irq = 24) is a 16550A
[  274.843094] [drm] Initialized drm 1.1.0 20060810
[  274.844259] e1000e: Intel(R) PRO/1000 Network Driver - 1.4.4-k
[  274.844307] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[  274.844405] e1000e 0000:08:00.0: Disabling ASPM  L1
[  275.024685] e1000e 0000:08:00.0: eth0: (PCI Express:2.5GT/s:Width x4) 00:14:4f:98:09:c2
[  275.024746] e1000e 0000:08:00.0: eth0: Intel(R) PRO/1000 Network Connection
[  275.024873] e1000e 0000:08:00.0: eth0: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[  275.025011] e1000e 0000:08:00.1: Disabling ASPM  L1
[  275.202428] e1000e 0000:08:00.1: eth1: (PCI Express:2.5GT/s:Width x4) 00:14:4f:98:09:c3
[  275.202549] e1000e 0000:08:00.1: eth1: Intel(R) PRO/1000 Network Connection
[  275.202732] e1000e 0000:08:00.1: eth1: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[  275.202858] e1000e 0000:09:00.0: Disabling ASPM  L1
[  275.376782] e1000e 0000:09:00.0: eth2: (PCI Express:2.5GT/s:Width x4) 00:14:4f:98:09:c4
[  275.376902] e1000e 0000:09:00.0: eth2: Intel(R) PRO/1000 Network Connection
[  275.377086] e1000e 0000:09:00.0: eth2: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[  275.377212] e1000e 0000:09:00.1: Disabling ASPM  L1
[  275.554605] e1000e 0000:09:00.1: eth3: (PCI Express:2.5GT/s:Width x4) 00:14:4f:98:09:c5
[  275.554726] e1000e 0000:09:00.1: eth3: Intel(R) PRO/1000 Network Connection
[  275.554909] e1000e 0000:09:00.1: eth3: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[  275.555535] mousedev: PS/2 mouse device common for all mice
[  275.556563] rtc-sun4v rtc-sun4v: rtc core: registered sun4v as rtc0
[  275.557267] TCP cubic registered
[  275.558144] NET: Registered protocol family 10
[  275.560267] Mobile IPv6
[  275.560303] NET: Registered protocol family 17
[  275.560374] Registering the dns_resolver key type
[  275.560844] registered taskstats version 1
[  275.563318] rtc-sun4v rtc-sun4v: setting system clock to 2011-11-05 01:46:43 UTC (1320457603)
[  275.812032] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  277.936740] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
[  277.959073] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  277.980042] IP-Config: Complete:
[  277.980115]      device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=255.255.255.255,
[  277.980317]      host=137.226.167.242, domain=, nis-domain=(none),
[  277.980432]      bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
[  277.980910] Root-NFS: nfsroot=/srv/nfs/cluster2,mountproto=tcp
[  277.981405] NFS: nfs mount opts='vers=2,udp,rsize=4096,wsize=4096,mountproto=tcp,nolock,addr=137.226.167.241'
[  277.981651] NFS:   parsing nfs mount option 'vers=2'
[  277.981739] NFS:   parsing nfs mount option 'udp'
[  277.981803] NFS:   parsing nfs mount option 'rsize=4096'
[  277.981853] NFS:   parsing nfs mount option 'wsize=4096'
[  277.981932] NFS:   parsing nfs mount option 'mountproto=tcp'
[  277.982016] NFS:   parsing nfs mount option 'nolock'
[  277.982062] NFS:   parsing nfs mount option 'addr=137.226.167.241'
[  277.982155] NFS: MNTPATH: '/srv/nfs/cluster2'
[  277.982218] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
[  277.982316] RPC:       set up xprt to 137.226.167.241 (autobind) via tcp
[  277.982394] RPC:       created transport fffff807fdf40800 with 128 slots
[  277.982444] RPC:       creating mount client for 137.226.167.241 (xprt fffff807fdf40800)
[  277.982534] RPC:       creating UNIX authenticator for client fffff807fdf18600
[  277.982627] RPC:       new task initialized, procpid 1
[  277.982700] RPC:       allocated task fffff807fdf10000
[  277.982748] RPC:     1 __rpc_execute flags=0x680
[  277.982813] RPC:     1 call_start mount1 proc NULL (sync)
[  277.982887] RPC:     1 call_reserve (status 0)
[  277.982922] RPC:     1 reserved req fffff807fdf18400 xid 945eb419
[  277.983000] RPC:       wake_up_next(fffff807fdf40978 "xprt_sending")
[  277.983078] RPC:     1 call_reserveresult (status 0)
[  277.983122] RPC:     1 call_refresh (status 0)
[  277.983185] RPC:     1 holding NULL cred 00000000008b8cf0
[  277.983230] RPC:     1 refreshing NULL cred 00000000008b8cf0
[  277.983305] RPC:     1 call_refreshresult (status 0)
[  277.983378] RPC:     1 call_allocate (status 0)
[  277.983413] RPC:     1 allocated buffer of size 96 at fffff807fdf41000
[  277.983490] RPC:     1 call_bind (status 0)
[  277.983525] RPC:     1 rpcb_getport_async(137.226.167.241, 100005, 1, 6)
[  277.983617] RPC:     1 sleep_on(queue "xprt_binding" time 4294893356)
[  277.983696] RPC:     1 added to queue fffff807fdf408c8 "xprt_binding"
[  277.983773] RPC:     1 setting alarm for 60000 ms
[  277.983810] RPC:     1 rpcb_getport_async: trying rpcbind version 2
[  277.983899] RPC:       set up xprt to 137.226.167.241 (port 111) via tcp
[  277.983978] RPC:       created transport fffff807fdf41800 with 128 slots
[  277.984057] RPC:       creating rpcbind client for 137.226.167.241 (xprt fffff807fdf41800)
[  277.984115] RPC:       creating UNIX authenticator for client fffff807fdf18c00
[  277.984202] RPC:       new task initialized, procpid 1
[  277.984274] RPC:       allocated task fffff807fdf100e0
[  277.984355] RPC:       rpc_release_client(fffff807fdf18c00)
[  277.984403] RPC:     1 sync task going to sleep
[  277.984472] RPC:     2 __rpc_execute flags=0x681
[  277.984536] RPC:     2 call_start rpcbind2 proc GETPORT (async)
[  277.984583] RPC:     2 call_reserve (status 0)
[  277.984646] RPC:     2 reserved req fffff807fdf18a00 xid e3ac2074
[  277.984693] RPC:       wake_up_next(fffff807fdf41978 "xprt_sending")
[  277.984771] RPC:     2 call_reserveresult (status 0)
[  277.984814] RPC:     2 call_refresh (status 0)
[  277.984847] RPC:     2 looking up UNIX cred
[  277.984877] RPC:       looking up UNIX cred
[  277.984910] RPC:       allocating UNIX cred for uid 0 gid 0
[  277.984958] RPC:     2 refreshing UNIX cred fffff807fdefc900
[  277.985004] RPC:     2 call_refreshresult (status 0)
[  277.985048] RPC:     2 call_allocate (status 0)
[  277.985082] RPC:     2 allocated buffer of size 416 at fffff807fdf42000
[  277.985130] RPC:     2 call_bind (status 0)
[  277.985163] RPC:     2 call_connect xprt fffff807fdf41800 is not connected
[  277.985213] RPC:     2 xprt_connect xprt fffff807fdf41800 is not connected
[  277.985263] RPC:     2 sleep_on(queue "xprt_pending" time 4294893356)
[  277.985312] RPC:     2 added to queue fffff807fdf41a28 "xprt_pending"
[  277.985358] RPC:     2 setting alarm for 60000 ms
[  277.985393] RPC:       xs_connect scheduled xprt fffff807fdf41800
[  277.985553] RPC:       xs_bind 0.0.0.0:0: ok (0)
[  277.985590] RPC:       worker connecting xprt fffff807fdf41800 via tcp to 137.226.167.241 (port 111)
[  277.985750] RPC:       fffff807fdf41800 connect status 36 connected 0 sock state 2
[  280.989403] RPC:       xs_error_report client fffff807fdf41800...
[  280.989411] RPC:       error 65
[  280.989568] RPC:     2 __rpc_wake_up_task (now 4294894107)
[  280.989670] RPC:     2 disabling timer
[  280.989731] RPC:     2 removed from queue fffff807fdf41a28 "xprt_pending"
[  280.989808] RPC:       __rpc_wake_up_task done
[  280.989843] RPC:       xs_tcp_state_change client fffff807fdf41800...
[  280.989893] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[  280.989968] RPC:       disconnected transport fffff807fdf41800
[  280.990037] RPC:     2 __rpc_execute flags=0x681
[  280.990101] RPC:     2 xprt_connect_status: retrying
[  280.990174] RPC:     2 call_connect_status (status -11)
[  280.990219] RPC:     2 call_transmit (status 0)
[  280.990279] RPC:     2 xprt_prepare_transmit
[  280.990312] RPC:     2 rpc_xdr_encode (status 0)
[  280.990374] RPC:     2 marshaling UNIX cred fffff807fdefc900
[  280.990423] RPC:     2 using AUTH_UNIX cred fffff807fdefc900 to wrap rpc data
[  280.990504] RPC:     2 encoding PMAP_GETPORT call (100005, 1, 6, 0)
[  280.990580] RPC:     2 xprt_transmit(96)
[  280.990620] RPC:       xs_tcp_send_request(96) = -65
[  280.990692] RPC:       sendmsg returned unrecognized error 65
[  280.990768] RPC:       xs_tcp_state_change client fffff807fdf41800...
[  280.990817] RPC:       state 7 conn 0 dead 0 zapped 1 sk_shutdown 3
[  280.990892] RPC:       disconnected transport fffff807fdf41800
[  280.990970] RPC:       wake_up_next(fffff807fdf41978 "xprt_sending")
[  280.991020] RPC:       setting port for xprt fffff807fdf40800 to 0
[  280.991098] RPC:     2 rpcb_getport_done(status -65, port 0)
[  280.991173] RPC:     2 return 0, status -65
[  280.991203] RPC:     2 release task
[  280.991265] RPC:       freeing buffer of size 416 at fffff807fdf42000
[  280.991315] RPC:     2 release request fffff807fdf18a00
[  280.991389] RPC:       wake_up_next(fffff807fdf41ad8 "xprt_backlog")
[  280.991465] RPC:       rpc_release_client(fffff807fdf18c00)
[  280.991539] RPC:       destroying rpcbind client for 137.226.167.241
[  280.991587] RPC:       destroying transport fffff807fdf41800
[  280.991695] RPC:       xs_destroy xprt fffff807fdf41800
[  280.991791] RPC:       xs_close xprt fffff807fdf41800
[  280.991880] RPC:       disconnected transport fffff807fdf41800
[  280.991958] RPC:     2 freeing task
[  280.991989] RPC:     1 __rpc_wake_up_task (now 4294894107)
[  280.992062] RPC:     1 disabling timer
[  280.992094] RPC:     1 removed from queue fffff807fdf408c8 "xprt_binding"
[  280.992174] RPC:       __rpc_wake_up_task done
[  280.992189] RPC:     1 sync task resuming
[  280.992199] RPC:     1 remote rpcbind unreachable: -65
[  280.992208] RPC:     1 return 0, status -65
[  280.992216] RPC:     1 release task
[  280.992227] RPC:       freeing buffer of size 96 at fffff807fdf41000
[  280.992240] RPC:     1 release request fffff807fdf18400
[  280.992250] RPC:       wake_up_next(fffff807fdf40ad8 "xprt_backlog")
[  280.992263] RPC:       rpc_release_client(fffff807fdf18600)
[  280.992273] RPC:     1 freeing task
[  280.992283] RPC:       shutting down mount client for 137.226.167.241
[  280.992292] RPC:       rpc_release_client(fffff807fdf18600)
[  280.992301] RPC:       destroying UNIX authenticator 00000000008b8d78
[  280.992314] RPC:       destroying mount client for 137.226.167.241
[  280.992328] NFS: failed to create MNT RPC client, status=-65
[  280.992339] NFS: unable to mount server 137.226.167.241, error -65
[  280.992373] VFS: Unable to mount root fs via NFS, trying floppy.
[  280.992433] List of all partitions:
[  280.992443] No filesystem could mount root, tried: 
[  280.992458] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(2,0)
[  280.992469] Call Trace:
[  280.992498]  [00000000008c6d18] mount_block_root+0x210/0x228
[  280.992512]  [00000000008c6df4] mount_root+0xc4/0xd4
[  280.992525]  [00000000008c6f80] prepare_namespace+0x17c/0x1c0
[  280.992542]  [00000000008c6250] kernel_init+0x140/0x158
[  280.992562]  [000000000042ac68] kernel_thread+0x30/0x48
[  280.992580]  [0000000000767840] rest_init+0x18/0x74
[  280.992659] Press Stop-A (L1-A) to return to the boot prom
[  280.993582] RPC:       destroying transport fffff807fdf40800
[  280.993715] RPC:       xs_destroy xprt fffff807fdf40800
[  280.993806] RPC:       xs_close xprt fffff807fdf40800
[  280.993881] RPC:       disconnected transport fffff807fdf40800
[  288.549074] eth0: no IPv6 routers present
