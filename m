Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55077 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751413Ab1KEBTm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 21:19:42 -0400
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Lukas Razik <linux@razik.name>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Fri, 04 Nov 2011 21:19:25 -0400
In-Reply-To: <1320450001.87605.YahooMailNeo@web24706.mail.ird.yahoo.com>
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com>
	 <1320353685.18396.119.camel@lade.trondhjem.org>
	 <20111103211100.GA8393@umich.edu>
	 <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com>
	 <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com>
	 <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com>
	 <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com>
	 <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>
	 <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com>
	 <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com>
	 <1320450001.87605.YahooMailNeo@web24706.mail.ird.yahoo.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320455965.2750.9.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-11-04 at 23:40 +0000, Lukas Razik wrote: 
> > As for a patch: no-one can write a patch unless we understand precisely why the 
> 
> > first RPC fails.  I already explained how to add a line or two to 
> > fs/nfs/nfsroot.c to give us more information.  If you need a patch to do this, I 
> > can send one later today.
> 
> 
> Maybe that's also helpful for you because eth0 seems to be up before NFS tries to mount the NFSROOT.
> BTW: Thanks for forwarding to the right mailing list!
> 
> The debug output (with NFSDBG_ALL and RPCDBG_ALL) of linux-3.1:
> ---
> {0} ok boot net
> Boot device: /pci@0/pci@0/pci@1/pci@0/pci@2/network@0  File and args: root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2 ip=137.226.167.242:::255.255.255.224::eth0:off nfsrootdebug
> 1000 Mbps full duplex  Link up
> Requesting Internet Address for 0:14:4f:98:9:c2
> Requesting Internet Address for 0:14:4f:98:9:c2
> Requesting Internet Address for 0:14:4f:98:9:c2
> Requesting Internet Address for 0:14:4f:98:9:c2
> Requesting Internet Address for 0:14:4f:98:9:c2
> Requesting Internet Address for 0:14:4f:98:9:c2
> [    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 4.30.0 2008/12/11 12:15'
> [    0.000000] PROMLIB: Root node compatible: sun4v
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 3.1.0-razik-2011-11-05 (root@cluster1) (gcc version 4.4.5 (Debian 4.4.5-8) ) #3 SMP Sat Nov 5 00:24:24 CET 2011
> [    0.000000] bootconsole [earlyprom0] enabled
> [    0.000000] ARCH: SUN4V
> [    0.000000] Ethernet address: 00:14:4f:98:09:c2
> [    0.000000] Kernel: Using 2 locked TLB entries for main kernel image.
> [    0.000000] Remapping the kernel... done.
> [    0.000000] OF stdout device is: /virtual-devices@100/console@1
> [    0.000000] PROM: Built device tree with 123763 bytes of memory.
> [    0.000000] MDESC: Size is 58816 bytes.
> [    0.000000] PLATFORM: banner-name [SPARC Enterprise T5120]
> [    0.000000] PLATFORM: name [SUNW,SPARC-Enterprise-T5120]
> [    0.000000] PLATFORM: hostid [849809c2]
> [    0.000000] PLATFORM: serial# [00ab4130]
> [    0.000000] PLATFORM: stick-frequency [5458c3a0]
> [    0.000000] PLATFORM: mac-address [144f9809c2]
> [    0.000000] PLATFORM: watchdog-resolution [1000 ms]
> [    0.000000] PLATFORM: watchdog-max-timeout [31536000000 ms]
> [    0.000000] PLATFORM: max-cpus [64]
> [    0.000000] Top of RAM: 0x7ffb1c000, Total RAM: 0x7f76c2000
> [    0.000000] Memory hole size: 132MB
> [    0.000000] [0000010000000000-fffff80009000000] page_structs=131072 node=0 entry=0/8192
> [    0.000000] [0000010000000000-fffff80009400000] page_structs=131072 node=0 entry=1/8192
> [    0.000000] [0000010000800000-fffff80009800000] page_structs=131072 node=0 entry=2/8192
> [    0.000000] [0000010000800000-fffff80009c00000] page_structs=131072 node=0 entry=3/8192
> [    0.000000] [0000010001000000-fffff8000a000000] page_structs=131072 node=0 entry=4/8192
> [    0.000000] [0000010001000000-fffff8000a400000] page_structs=131072 node=0 entry=5/8192
> [    0.000000] [0000010001800000-fffff8000a800000] page_structs=131072 node=0 entry=6/8192
> [    0.000000] [0000010001800000-fffff8000ac00000] page_structs=131072 node=0 entry=7/8192
> [    0.000000] [0000010002000000-fffff8000b000000] page_structs=131072 node=0 entry=8/8192
> [    0.000000] [0000010002000000-fffff8000b400000] page_structs=131072 node=0 entry=9/8192
> [    0.000000] [0000010002800000-fffff8000b800000] page_structs=131072 node=0 entry=10/8192
> [    0.000000] [0000010002800000-fffff8000bc00000] page_structs=131072 node=0 entry=11/8192
> [    0.000000] [0000010003000000-fffff8000c000000] page_structs=131072 node=0 entry=12/8192
> [    0.000000] [0000010003000000-fffff8000c400000] page_structs=131072 node=0 entry=13/8192
> [    0.000000] [0000010003800000-fffff8000c800000] page_structs=131072 node=0 entry=14/8192
> [    0.000000] [0000010003800000-fffff8000cc00000] page_structs=131072 node=0 entry=15/8192
> [    0.000000] [0000010004000000-fffff8000d000000] page_structs=131072 node=0 entry=16/8192
> [    0.000000] [0000010004000000-fffff8000d400000] page_structs=131072 node=0 entry=17/8192
> [    0.000000] [0000010004800000-fffff8000d800000] page_structs=131072 node=0 entry=18/8192
> [    0.000000] [0000010004800000-fffff8000dc00000] page_structs=131072 node=0 entry=19/8192
> [    0.000000] [0000010005000000-fffff8000e000000] page_structs=131072 node=0 entry=20/8192
> [    0.000000] [0000010005000000-fffff8000e400000] page_structs=131072 node=0 entry=21/8192
> [    0.000000] [0000010005800000-fffff8000e800000] page_structs=131072 node=0 entry=22/8192
> [    0.000000] [0000010005800000-fffff8000ec00000] page_structs=131072 node=0 entry=23/8192
> [    0.000000] [0000010006000000-fffff8000f000000] page_structs=131072 node=0 entry=24/8192
> [    0.000000] [0000010006000000-fffff8000f400000] page_structs=131072 node=0 entry=25/8192
> [    0.000000] [0000010006800000-fffff8000f800000] page_structs=131072 node=0 entry=26/8192
> [    0.000000] [0000010006800000-fffff8000fc00000] page_structs=131072 node=0 entry=27/8192
> [    0.000000] [0000010007000000-fffff80010000000] page_structs=131072 node=0 entry=28/8192
> [    0.000000] [0000010007000000-fffff80010400000] page_structs=131072 node=0 entry=29/8192
> [    0.000000] [0000010007800000-fffff80010800000] page_structs=131072 node=0 entry=30/8192
> [    0.000000] [0000010007800000-fffff80010c00000] page_structs=131072 node=0 entry=31/8192
> [    0.000000] [0000010008000000-fffff80011000000] page_structs=131072 node=0 entry=32/8192
> [    0.000000] [0000010008000000-fffff80011400000] page_structs=131072 node=0 entry=33/8192
> [    0.000000] [0000010008800000-fffff80011800000] page_structs=131072 node=0 entry=34/8192
> [    0.000000] [0000010008800000-fffff80011c00000] page_structs=131072 node=0 entry=35/8192
> [    0.000000] [0000010009000000-fffff80012000000] page_structs=131072 node=0 entry=36/8192
> [    0.000000] [0000010009000000-fffff80012400000] page_structs=131072 node=0 entry=37/8192
> [    0.000000] [0000010009800000-fffff80012800000] page_structs=131072 node=0 entry=38/8192
> [    0.000000] [0000010009800000-fffff80012c00000] page_structs=131072 node=0 entry=39/8192
> [    0.000000] [000001000a000000-fffff80013000000] page_structs=131072 node=0 entry=40/8192
> [    0.000000] [000001000a000000-fffff80013400000] page_structs=131072 node=0 entry=41/8192
> [    0.000000] [000001000a800000-fffff80013800000] page_structs=131072 node=0 entry=42/8192
> [    0.000000] [000001000a800000-fffff80013c00000] page_structs=131072 node=0 entry=43/8192
> [    0.000000] [000001000b000000-fffff80014000000] page_structs=131072 node=0 entry=44/8192
> [    0.000000] [000001000b000000-fffff80014400000] page_structs=131072 node=0 entry=45/8192
> [    0.000000] [000001000b800000-fffff80014800000] page_structs=131072 node=0 entry=46/8192
> [    0.000000] [000001000b800000-fffff80014c00000] page_structs=131072 node=0 entry=47/8192
> [    0.000000] [000001000c000000-fffff80015000000] page_structs=131072 node=0 entry=48/8192
> [    0.000000] [000001000c000000-fffff80015400000] page_structs=131072 node=0 entry=49/8192
> [    0.000000] [000001000c800000-fffff80015800000] page_structs=131072 node=0 entry=50/8192
> [    0.000000] [000001000c800000-fffff80015c00000] page_structs=131072 node=0 entry=51/8192
> [    0.000000] [000001000d000000-fffff80016000000] page_structs=131072 node=0 entry=52/8192
> [    0.000000] [000001000d000000-fffff80016400000] page_structs=131072 node=0 entry=53/8192
> [    0.000000] [000001000d800000-fffff80016800000] page_structs=131072 node=0 entry=54/8192
> [    0.000000] [000001000d800000-fffff80016c00000] page_structs=131072 node=0 entry=55/8192
> [    0.000000] [000001000e000000-fffff80017000000] page_structs=131072 node=0 entry=56/8192
> [    0.000000] [000001000e000000-fffff80017400000] page_structs=131072 node=0 entry=57/8192
> [    0.000000] [000001000e800000-fffff80017800000] page_structs=131072 node=0 entry=58/8192
> [    0.000000] [000001000e800000-fffff80017c00000] page_structs=131072 node=0 entry=59/8192
> [    0.000000] [000001000f000000-fffff80018000000] page_structs=131072 node=0 entry=60/8192
> [    0.000000] [000001000f000000-fffff80018400000] page_structs=131072 node=0 entry=61/8192
> [    0.000000] [000001000f800000-fffff80018800000] page_structs=131072 node=0 entry=62/8192
> [    0.000000] [000001000f800000-fffff80018c00000] page_structs=131072 node=0 entry=63/8192
> [    0.000000] Zone PFN ranges:
> [    0.000000]   Normal   0x00004200 -> 0x003ffd8e
> [    0.000000] Movable zone start PFN for each node
> [    0.000000] early_node_map[3] active PFN ranges
> [    0.000000]     0: 0x00004200 -> 0x003ffd47
> [    0.000000]     0: 0x003ffd50 -> 0x003ffd63
> [    0.000000]     0: 0x003ffd87 -> 0x003ffd8e
> [    0.000000] Booting Linux...
> [    0.000000] CPU CAPS: [flush,stbar,swap,muldiv,v9,blkinit,n2,mul32]
> [    0.000000] CPU CAPS: [div32,v8plus,popc,vis,vis2,ASIBlkInit]
> [    0.000000] PERCPU: Embedded 5 pages/cpu @fffff80019000000 s10816 r8192 d21952 u65536
> [    0.000000] SUN4V: Mondo queue sizes [cpu(8192) dev(16384) r(8192) nr(256)]
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 4144105
> [    0.000000] Kernel command line: root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2 ip=137.226.167.242:::255.255.255.224::eth0:off nfsrootdebug
> [    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
> [    0.000000] Dentry cache hash table entries: 4194304 (order: 12, 33554432 bytes)
> [    0.000000] Inode-cache hash table entries: 2097152 (order: 11, 16777216 bytes)
> [    0.000000] Memory: 33091944k available (3568k kernel code, 1272k data, 216k init) [fffff80000000000,00000007ffb1c000]
> [    0.000000] SLUB: Genslabs=16, HWalign=32, Order=0-3, MinObjects=0, CPUs=64, Nodes=1
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000]  CONFIG_RCU_FANOUT set to non-default value of 32
> [    0.000000] NR_IRQS:255
> [    0.000000] clocksource: mult[b4e7cf] shift[24]
> [    0.000000] clockevent: mult[b5221ba3] shift[31]
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] console [tty0] enabled, bootconsole disabled
> [    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 4.30.0 2008/12/11 12:15'
> [    0.000000] PROMLIB: Root node compatible: sun4v
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 3.1.0-razik-2011-11-05 (root@cluster1) (gcc version 4.4.5 (Debian 4.4.5-8) ) #3 SMP Sat Nov 5 00:24:24 CET 2011
> [    0.000000] bootconsole [earlyprom0] enabled
> [    0.000000] ARCH: SUN4V
> [    0.000000] Ethernet address: 00:14:4f:98:09:c2
> [    0.000000] Kernel: Using 2 locked TLB entries for main kernel image.
> [    0.000000] Remapping the kernel... done.
> [    0.000000] OF stdout device is: /virtual-devices@100/console@1
> [    0.000000] PROM: Built device tree with 123763 bytes of memory.
> [    0.000000] MDESC: Size is 58816 bytes.
> [    0.000000] PLATFORM: banner-name [SPARC Enterprise T5120]
> [    0.000000] PLATFORM: name [SUNW,SPARC-Enterprise-T5120]
> [    0.000000] PLATFORM: hostid [849809c2]
> [    0.000000] PLATFORM: serial# [00ab4130]
> [    0.000000] PLATFORM: stick-frequency [5458c3a0]
> [    0.000000] PLATFORM: mac-address [144f9809c2]
> [    0.000000] PLATFORM: watchdog-resolution [1000 ms]
> [    0.000000] PLATFORM: watchdog-max-timeout [31536000000 ms]
> [    0.000000] PLATFORM: max-cpus [64]
> [    0.000000] Top of RAM: 0x7ffb1c000, Total RAM: 0x7f76c2000
> [    0.000000] Memory hole size: 132MB
> [    0.000000] [0000010000000000-fffff80009000000] page_structs=131072 node=0 entry=0/8192
> [    0.000000] [0000010000000000-fffff80009400000] page_structs=131072 node=0 entry=1/8192
> [    0.000000] [0000010000800000-fffff80009800000] page_structs=131072 node=0 entry=2/8192
> [    0.000000] [0000010000800000-fffff80009c00000] page_structs=131072 node=0 entry=3/8192
> [    0.000000] [0000010001000000-fffff8000a000000] page_structs=131072 node=0 entry=4/8192
> [    0.000000] [0000010001000000-fffff8000a400000] page_structs=131072 node=0 entry=5/8192
> [    0.000000] [0000010001800000-fffff8000a800000] page_structs=131072 node=0 entry=6/8192
> [    0.000000] [0000010001800000-fffff8000ac00000] page_structs=131072 node=0 entry=7/8192
> [    0.000000] [0000010002000000-fffff8000b000000] page_structs=131072 node=0 entry=8/8192
> [    0.000000] [0000010002000000-fffff8000b400000] page_structs=131072 node=0 entry=9/8192
> [    0.000000] [0000010002800000-fffff8000b800000] page_structs=131072 node=0 entry=10/8192
> [    0.000000] [0000010002800000-fffff8000bc00000] page_structs=131072 node=0 entry=11/8192
> [    0.000000] [0000010003000000-fffff8000c000000] page_structs=131072 node=0 entry=12/8192
> [    0.000000] [0000010003000000-fffff8000c400000] page_structs=131072 node=0 entry=13/8192
> [    0.000000] [0000010003800000-fffff8000c800000] page_structs=131072 node=0 entry=14/8192
> [    0.000000] [0000010003800000-fffff8000cc00000] page_structs=131072 node=0 entry=15/8192
> [    0.000000] [0000010004000000-fffff8000d000000] page_structs=131072 node=0 entry=16/8192
> [    0.000000] [0000010004000000-fffff8000d400000] page_structs=131072 node=0 entry=17/8192
> [    0.000000] [0000010004800000-fffff8000d800000] page_structs=131072 node=0 entry=18/8192
> [    0.000000] [0000010004800000-fffff8000dc00000] page_structs=131072 node=0 entry=19/8192
> [    0.000000] [0000010005000000-fffff8000e000000] page_structs=131072 node=0 entry=20/8192
> [    0.000000] [0000010005000000-fffff8000e400000] page_structs=131072 node=0 entry=21/8192
> [    0.000000] [0000010005800000-fffff8000e800000] page_structs=131072 node=0 entry=22/8192
> [    0.000000] [0000010005800000-fffff8000ec00000] page_structs=131072 node=0 entry=23/8192
> [    0.000000] [0000010006000000-fffff8000f000000] page_structs=131072 node=0 entry=24/8192
> [    0.000000] [0000010006000000-fffff8000f400000] page_structs=131072 node=0 entry=25/8192
> [    0.000000] [0000010006800000-fffff8000f800000] page_structs=131072 node=0 entry=26/8192
> [    0.000000] [0000010006800000-fffff8000fc00000] page_structs=131072 node=0 entry=27/8192
> [    0.000000] [0000010007000000-fffff80010000000] page_structs=131072 node=0 entry=28/8192
> [    0.000000] [0000010007000000-fffff80010400000] page_structs=131072 node=0 entry=29/8192
> [    0.000000] [0000010007800000-fffff80010800000] page_structs=131072 node=0 entry=30/8192
> [    0.000000] [0000010007800000-fffff80010c00000] page_structs=131072 node=0 entry=31/8192
> [    0.000000] [0000010008000000-fffff80011000000] page_structs=131072 node=0 entry=32/8192
> [    0.000000] [0000010008000000-fffff80011400000] page_structs=131072 node=0 entry=33/8192
> [    0.000000] [0000010008800000-fffff80011800000] page_structs=131072 node=0 entry=34/8192
> [    0.000000] [0000010008800000-fffff80011c00000] page_structs=131072 node=0 entry=35/8192
> [    0.000000] [0000010009000000-fffff80012000000] page_structs=131072 node=0 entry=36/8192
> [    0.000000] [0000010009000000-fffff80012400000] page_structs=131072 node=0 entry=37/8192
> [    0.000000] [0000010009800000-fffff80012800000] page_structs=131072 node=0 entry=38/8192
> [    0.000000] [0000010009800000-fffff80012c00000] page_structs=131072 node=0 entry=39/8192
> [    0.000000] [000001000a000000-fffff80013000000] page_structs=131072 node=0 entry=40/8192
> [    0.000000] [000001000a000000-fffff80013400000] page_structs=131072 node=0 entry=41/8192
> [    0.000000] [000001000a800000-fffff80013800000] page_structs=131072 node=0 entry=42/8192
> [    0.000000] [000001000a800000-fffff80013c00000] page_structs=131072 node=0 entry=43/8192
> [    0.000000] [000001000b000000-fffff80014000000] page_structs=131072 node=0 entry=44/8192
> [    0.000000] [000001000b000000-fffff80014400000] page_structs=131072 node=0 entry=45/8192
> [    0.000000] [000001000b800000-fffff80014800000] page_structs=131072 node=0 entry=46/8192
> [    0.000000] [000001000b800000-fffff80014c00000] page_structs=131072 node=0 entry=47/8192
> [    0.000000] [000001000c000000-fffff80015000000] page_structs=131072 node=0 entry=48/8192
> [    0.000000] [000001000c000000-fffff80015400000] page_structs=131072 node=0 entry=49/8192
> [    0.000000] [000001000c800000-fffff80015800000] page_structs=131072 node=0 entry=50/8192
> [    0.000000] [000001000c800000-fffff80015c00000] page_structs=131072 node=0 entry=51/8192
> [    0.000000] [000001000d000000-fffff80016000000] page_structs=131072 node=0 entry=52/8192
> [    0.000000] [000001000d000000-fffff80016400000] page_structs=131072 node=0 entry=53/8192
> [    0.000000] [000001000d800000-fffff80016800000] page_structs=131072 node=0 entry=54/8192
> [    0.000000] [000001000d800000-fffff80016c00000] page_structs=131072 node=0 entry=55/8192
> [    0.000000] [000001000e000000-fffff80017000000] page_structs=131072 node=0 entry=56/8192
> [    0.000000] [000001000e000000-fffff80017400000] page_structs=131072 node=0 entry=57/8192
> [    0.000000] [000001000e800000-fffff80017800000] page_structs=131072 node=0 entry=58/8192
> [    0.000000] [000001000e800000-fffff80017c00000] page_structs=131072 node=0 entry=59/8192
> [    0.000000] [000001000f000000-fffff80018000000] page_structs=131072 node=0 entry=60/8192
> [    0.000000] [000001000f000000-fffff80018400000] page_structs=131072 node=0 entry=61/8192
> [    0.000000] [000001000f800000-fffff80018800000] page_structs=131072 node=0 entry=62/8192
> [    0.000000] [000001000f800000-fffff80018c00000] page_structs=131072 node=0 entry=63/8192
> [    0.000000] Zone PFN ranges:
> [    0.000000]   Normal   0x00004200 -> 0x003ffd8e
> [    0.000000] Movable zone start PFN for each node
> [    0.000000] early_node_map[3] active PFN ranges
> [    0.000000]     0: 0x00004200 -> 0x003ffd47
> [    0.000000]     0: 0x003ffd50 -> 0x003ffd63
> [    0.000000]     0: 0x003ffd87 -> 0x003ffd8e
> [    0.000000] Booting Linux...
> [    0.000000] CPU CAPS: [flush,stbar,swap,muldiv,v9,blkinit,n2,mul32]
> [    0.000000] CPU CAPS: [div32,v8plus,popc,vis,vis2,ASIBlkInit]
> [    0.000000] PERCPU: Embedded 5 pages/cpu @fffff80019000000 s10816 r8192 d21952 u65536
> [    0.000000] SUN4V: Mondo queue sizes [cpu(8192) dev(16384) r(8192) nr(256)]
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 4144105
> [    0.000000] Kernel command line: root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2 ip=137.226.167.242:::255.255.255.224::eth0:off nfsrootdebug
> [    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
> [    0.000000] Dentry cache hash table entries: 4194304 (order: 12, 33554432 bytes)
> [    0.000000] Inode-cache hash table entries: 2097152 (order: 11, 16777216 bytes)
> [    0.000000] Memory: 33091944k available (3568k kernel code, 1272k data, 216k init) [fffff80000000000,00000007ffb1c000]
> [    0.000000] SLUB: Genslabs=16, HWalign=32, Order=0-3, MinObjects=0, CPUs=64, Nodes=1
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000]  CONFIG_RCU_FANOUT set to non-default value of 32
> [    0.000000] NR_IRQS:255
> [    0.000000] clocksource: mult[b4e7cf] shift[24]
> [    0.000000] clockevent: mult[b5221ba3] shift[31]
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] console [tty0] enabled, bootconsole disabled
> [ 1349.933990] Calibrating delay using timer specific routine.. 2832.78 BogoMIPS (lpj=5665561)
> [ 1349.934023] pid_max: default: 65536 minimum: 512
> [ 1349.934487] Mount-cache hash table entries: 512
> [ 1349.935761] Initializing cgroup subsys cpuacct
> [ 1349.935872] Initializing cgroup subsys devices
> [ 1349.935890] Initializing cgroup subsys freezer
> [ 1349.935907] Initializing cgroup subsys net_cls
> [ 1349.936185] Performance events: Supported PMU type is 'niagara2'
> [ 1349.958675] Brought up 64 CPUs
> [ 1349.958734] Testing NMI watchdog ... OK.
> [ 1350.041367] devtmpfs: initialized
> [ 1350.041863] ldc.c:v1.1 (July 22, 2008)
> [ 1350.042167] print_constraints: dummy: 
> [ 1350.042552] NET: Registered protocol family 16
> [ 1350.051781] VIO: Adding device channel-devices
> [ 1350.051858] VIO: Adding device vldc-port-3-0
> [ 1350.051918] VIO: Adding device vldc-port-3-1
> [ 1350.051978] VIO: Adding device vldc-port-3-2
> [ 1350.052048] VIO: Adding device vldc-port-3-3
> [ 1350.052110] VIO: Adding device vldc-port-3-4
> [ 1350.052171] VIO: Adding device vldc-port-3-5
> [ 1350.052233] VIO: Adding device vldc-port-2-0
> [ 1350.052296] VIO: Adding device vldc-port-0-0
> [ 1350.052365] VIO: Adding device vldc-port-0-1
> [ 1350.052433] VIO: Adding device vldc-port-0-2
> [ 1350.052511] VIO: Adding device vldc-port-1-0
> [ 1350.052581] VIO: Adding device vldc-port-3-7
> [ 1350.052654] VIO: Adding device vldc-port-3-8
> [ 1350.052737] VIO: Adding device ds-1
> [ 1350.052801] VIO: Adding device ds-0
> [ 1350.057406] pci_sun4v: Registered hvapi major[1] minor[0]
> [ 1350.057671] /pci@0: SUN4V PCI Bus Module
> [ 1350.057690] /pci@0: On NUMA node -1
> [ 1350.057711] /pci@0: PCI IO[c0f0000000] MEM[c100000000]
> [ 1350.057739] /pci@0: Unable to request IOMMU resource.
> [ 1350.102075] /pci@0: Imported 3 TSB entries from OBP
> [ 1350.103612] /pci@0: MSI Queue first[0] num[36] count[128] devino[0x18]
> [ 1350.103640] /pci@0: MSI first[0] num[256] mask[0xff] width[32]
> [ 1350.103665] /pci@0: MSI addr32[0x7fff0000:0x10000] addr64[0x3ffff0000:0x10000]
> [ 1350.103694] /pci@0: MSI queues at RA [00000007fe580000]
> [ 1350.103718] PCI: Scanning PBM /pci@0
> [ 1350.115563] ds.c:v1.0 (Jul 11, 2007)
> [ 1350.118931] bio: create slab <bio-0> at 0
> [ 1350.119516] vgaarb: loaded
> [ 1350.120349] Switching to clocksource stick
> [ 1350.120981] Switched to NOHz mode on CPU #12
> [ 1350.120991] Switched to NOHz mode on CPU #24
> [ 1350.121098] Switched to NOHz mode on CPU #36
> [ 1350.121150] Switched to NOHz mode on CPU #59
> [ 1350.121253] Switched to NOHz mode on CPU #1
> [ 1350.121263] Switched to NOHz mode on CPU #48
> [ 1350.121272] Switched to NOHz mode on CPU #13
> [ 1350.121331] Switched to NOHz mode on CPU #25
> [ 1350.121457] Switched to NOHz mode on CPU #37
> [ 1350.121502] Switched to NOHz mode on CPU #60
> [ 1350.121608] Switched to NOHz mode on CPU #14
> [ 1350.121623] Switched to NOHz mode on CPU #49
> [ 1350.121658] Switched to NOHz mode on CPU #2
> [ 1350.121670] Switched to NOHz mode on CPU #26
> [ 1350.121798] Switched to NOHz mode on CPU #38
> [ 1350.121894] Switched to NOHz mode on CPU #61
> [ 1350.121903] Switched to NOHz mode on CPU #0
> [ 1350.121942] Switched to NOHz mode on CPU #15
> [ 1350.121960] Switched to NOHz mode on CPU #50
> [ 1350.121969] Switched to NOHz mode on CPU #3
> [ 1350.122011] Switched to NOHz mode on CPU #27
> [ 1350.122138] Switched to NOHz mode on CPU #39
> [ 1350.122204] Switched to NOHz mode on CPU #62
> [ 1350.122277] Switched to NOHz mode on CPU #16
> [ 1350.122298] Switched to NOHz mode on CPU #4
> [ 1350.122307] Switched to NOHz mode on CPU #51
> [ 1350.122351] Switched to NOHz mode on CPU #28
> [ 1350.122480] Switched to NOHz mode on CPU #40
> [ 1350.122564] Switched to NOHz mode on CPU #63
> [ 1350.122623] Switched to NOHz mode on CPU #17
> [ 1350.122640] Switched to NOHz mode on CPU #5
> [ 1350.122653] Switched to NOHz mode on CPU #52
> [ 1350.122697] Switched to NOHz mode on CPU #29
> [ 1350.122828] Switched to NOHz mode on CPU #41
> [ 1350.122954] Switched to NOHz mode on CPU #18
> [ 1350.122971] Switched to NOHz mode on CPU #6
> [ 1350.123029] Switched to NOHz mode on CPU #53
> [ 1350.123038] Switched to NOHz mode on CPU #30
> [ 1350.123175] Switched to NOHz mode on CPU #42
> [ 1350.123286] Switched to NOHz mode on CPU #19
> [ 1350.123298] Switched to NOHz mode on CPU #7
> [ 1350.123382] Switched to NOHz mode on CPU #31
> [ 1350.123400] Switched to NOHz mode on CPU #54
> [ 1350.123524] Switched to NOHz mode on CPU #43
> [ 1350.123602] Switched to NOHz mode on CPU #8
> [ 1350.123620] Switched to NOHz mode on CPU #20
> [ 1350.123729] Switched to NOHz mode on CPU #32
> [ 1350.123749] Switched to NOHz mode on CPU #55
> [ 1350.123860] Switched to NOHz mode on CPU #44
> [ 1350.123929] Switched to NOHz mode on CPU #9
> [ 1350.123971] Switched to NOHz mode on CPU #21
> [ 1350.124065] Switched to NOHz mode on CPU #33
> [ 1350.124095] Switched to NOHz mode on CPU #56
> [ 1350.124209] Switched to NOHz mode on CPU #45
> [ 1350.124268] Switched to NOHz mode on CPU #10
> [ 1350.124303] Switched to NOHz mode on CPU #22
> [ 1350.124402] Switched to NOHz mode on CPU #34
> [ 1350.124442] Switched to NOHz mode on CPU #57
> [ 1350.124564] Switched to NOHz mode on CPU #46
> [ 1350.124737] Switched to NOHz mode on CPU #58
> [ 1350.124747] Switched to NOHz mode on CPU #23
> [ 1350.124756] Switched to NOHz mode on CPU #47
> [ 1350.124766] Switched to NOHz mode on CPU #11
> [ 1350.124776] Switched to NOHz mode on CPU #35
> [ 1350.129462] NET: Registered protocol family 2
> [ 1350.129995] IP route cache hash table entries: 524288 (order: 9, 4194304 bytes)
> [ 1350.132183] TCP established hash table entries: 524288 (order: 10, 8388608 bytes)
> [ 1350.132224] ds-1: Registered pri service.
> [ 1350.132328] ds-1: Registered var-config-backup service.
> [ 1350.157752] TCP bind hash table entries: 65536 (order: 7, 1048576 bytes)
> [ 1350.161496] TCP: Hash tables configured (established 524288 bind 65536)
> [ 1350.161523] TCP reno registered
> [ 1350.161562] UDP hash table entries: 16384 (order: 6, 524288 bytes)
> [ 1350.163563] UDP-Lite hash table entries: 16384 (order: 6, 524288 bytes)
> [ 1350.166529] NET: Registered protocol family 1
> [ 1350.166613] RPC:       creating workqueue rpciod
> [ 1350.166921] RPC:       registering /proc/net/rpc
> [ 1350.167024] svc: Adding svc transport class 'tcp'
> [ 1350.167051] svc: Adding svc transport class 'udp'
> [ 1350.167121] RPC: Registered named UNIX socket transport module.
> [ 1350.167145] RPC: Registered udp transport module.
> [ 1350.167165] RPC: Registered tcp transport module.
> [ 1350.167185] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [ 1350.168544] audit: initializing netlink socket (disabled)
> [ 1350.168591] type=2000 audit(0.304:1): initialized
> [ 1350.872401] HugeTLB registered 4 MB page size, pre-allocated 0 pages
> [ 1350.881157] VFS: Disk quotas dquot_6.5.2
> [ 1350.881602] Dquot-cache hash table entries: 1024 (order 0, 8192 bytes)
> [ 1350.882234] RPC:       creating workqueue nfsiod
> [ 1350.883014] RPC:       registering /proc/net/rpc/nfs
> [ 1350.883068] msgmni has been set to 32768
> [ 1350.884176] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
> [ 1350.884211] io scheduler noop registered
> [ 1350.884230] io scheduler deadline registered
> [ 1350.884466] io scheduler cfq registered (default)
> [ 1350.885978] f027ab74: ttyS0 at I/O 0x0 (irq = 17) is a SUN4V HCONS
> [ 1351.101139] console [ttyHV0] enabled
> [ 1351.103812] f028af14: ttyS1 at MMIO 0xfff0ca0000 (irq = 24) is a 16550A
> [ 1351.104504] [drm] Initialized drm 1.1.0 20060810
> [ 1351.105715] e1000e: Intel(R) PRO/1000 Network Driver - 1.4.4-k
> [ 1351.105850] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
> [ 1351.105948] e1000e 0000:08:00.0: Disabling ASPM  L1
> [ 1351.279997] e1000e 0000:08:00.0: eth0: (PCI Express:2.5GT/s:Width x4) 00:14:4f:98:09:c2
> [ 1351.280059] e1000e 0000:08:00.0: eth0: Intel(R) PRO/1000 Network Connection
> [ 1351.280186] e1000e 0000:08:00.0: eth0: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
> [ 1351.280267] e1000e 0000:08:00.1: Disabling ASPM  L1
> [ 1351.457748] e1000e 0000:08:00.1: eth1: (PCI Express:2.5GT/s:Width x4) 00:14:4f:98:09:c3
> [ 1351.457809] e1000e 0000:08:00.1: eth1: Intel(R) PRO/1000 Network Connection
> [ 1351.457935] e1000e 0000:08:00.1: eth1: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
> [ 1351.458003] e1000e 0000:09:00.0: Disabling ASPM  L1
> [ 1351.632096] e1000e 0000:09:00.0: eth2: (PCI Express:2.5GT/s:Width x4) 00:14:4f:98:09:c4
> [ 1351.632157] e1000e 0000:09:00.0: eth2: Intel(R) PRO/1000 Network Connection
> [ 1351.632283] e1000e 0000:09:00.0: eth2: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
> [ 1351.632351] e1000e 0000:09:00.1: Disabling ASPM  L1
> [ 1351.809926] e1000e 0000:09:00.1: eth3: (PCI Express:2.5GT/s:Width x4) 00:14:4f:98:09:c5
> [ 1351.810047] e1000e 0000:09:00.1: eth3: Intel(R) PRO/1000 Network Connection
> [ 1351.810231] e1000e 0000:09:00.1: eth3: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
> [ 1351.810858] mousedev: PS/2 mouse device common for all mice
> [ 1351.811886] rtc-sun4v rtc-sun4v: rtc core: registered sun4v as rtc0
> [ 1351.812592] TCP cubic registered
> [ 1351.813469] NET: Registered protocol family 10
> [ 1351.815597] Mobile IPv6
> [ 1351.815633] NET: Registered protocol family 17
> [ 1351.815704] Registering the dns_resolver key type
> [ 1351.816174] registered taskstats version 1
> [ 1351.818649] rtc-sun4v rtc-sun4v: setting system clock to 2011-11-04 23:31:46 UTC (1320449506)
> [ 1352.067344] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [ 1354.200067] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
> [ 1354.222397] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [ 1354.243385] IP-Config: Complete:
> [ 1354.243457]      device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=255.255.255.255,
> [ 1354.243659]      host=137.226.167.242, domain=, nis-domain=(none),
> [ 1354.243774]      bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
> [ 1354.244257] Root-NFS: nfsroot=/srv/nfs/cluster2
> [ 1354.244620] NFS: nfs mount opts='vers=2,udp,rsize=4096,wsize=4096,nolock,addr=137.226.167.241'
> [ 1354.244710] NFS:   parsing nfs mount option 'vers=2'
> [ 1354.244770] NFS:   parsing nfs mount option 'udp'
> [ 1354.244834] NFS:   parsing nfs mount option 'rsize=4096'
> [ 1354.244884] NFS:   parsing nfs mount option 'wsize=4096'
> [ 1354.244934] NFS:   parsing nfs mount option 'nolock'
> [ 1354.244981] NFS:   parsing nfs mount option 'addr=137.226.167.241'
> [ 1354.245045] NFS: MNTPATH: '/srv/nfs/cluster2'
> [ 1354.245080] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
> [ 1354.245157] RPC:       set up xprt to 137.226.167.241 (autobind) via udp
> [ 1354.245236] RPC:       created transport fffff807fdf40800 with 16 slots
> [ 1354.245285] RPC:       creating mount client for 137.226.167.241 (xprt fffff807fdf40800)
> [ 1354.245346] RPC:       creating UNIX authenticator for client fffff807fdf1a200
> [ 1354.245411] RPC:       new task initialized, procpid 1
> [ 1354.245456] RPC:       allocated task fffff807fdf10000
> [ 1354.245504] RPC:     1 __rpc_execute flags=0x680
> [ 1354.245539] RPC:     1 call_start mount1 proc NULL (sync)
> [ 1354.245614] RPC:     1 call_reserve (status 0)
> [ 1354.245649] RPC:     1 reserved req fffff807fdf1a000 xid 51d47d10
> [ 1354.245698] RPC:       wake_up_next(fffff807fdf40978 "xprt_sending")
> [ 1354.245747] RPC:     1 call_reserveresult (status 0)
> [ 1354.245792] RPC:     1 call_refresh (status 0)
> [ 1354.245825] RPC:     1 holding NULL cred 00000000008b8cf0
> [ 1354.245871] RPC:     1 refreshing NULL cred 00000000008b8cf0
> [ 1354.245917] RPC:     1 call_refreshresult (status 0)
> [ 1354.245962] RPC:     1 call_allocate (status 0)
> [ 1354.246025] RPC:     1 allocated buffer of size 96 at fffff807fdf41000
> [ 1354.246073] RPC:     1 call_bind (status 0)
> [ 1354.246108] RPC:     1 rpcb_getport_async(137.226.167.241, 100005, 1, 17)
> [ 1354.246157] RPC:     1 sleep_on(queue "xprt_binding" time 4294893393)
> [ 1354.246206] RPC:     1 added to queue fffff807fdf408c8 "xprt_binding"
> [ 1354.246253] RPC:     1 setting alarm for 60000 ms
> [ 1354.246291] RPC:     1 rpcb_getport_async: trying rpcbind version 2
> [ 1354.246366] RPC:       set up xprt to 137.226.167.241 (port 111) via udp
> [ 1354.246445] RPC:       created transport fffff807fdf41800 with 16 slots
> [ 1354.246495] RPC:       creating rpcbind client for 137.226.167.241 (xprt fffff807fdf41800)
> [ 1354.246554] RPC:       creating UNIX authenticator for client fffff807fdf1c400
> [ 1354.246612] RPC:       new task initialized, procpid 1
> [ 1354.246656] RPC:       allocated task fffff807fdf100e0
> [ 1354.246708] RPC:       rpc_release_client(fffff807fdf1c400)
> [ 1354.246756] RPC:     1 sync task going to sleep
> [ 1354.246825] RPC:     2 __rpc_execute flags=0x681
> [ 1354.246860] RPC:     2 call_start rpcbind2 proc GETPORT (async)
> [ 1354.246921] RPC:     2 call_reserve (status 0)
> [ 1354.246957] RPC:     2 reserved req fffff807fdf1c200 xid 18460f63
> [ 1354.247005] RPC:       wake_up_next(fffff807fdf41978 "xprt_sending")
> [ 1354.247054] RPC:     2 call_reserveresult (status 0)
> [ 1354.247098] RPC:     2 call_refresh (status 0)
> [ 1354.247130] RPC:     2 looking up UNIX cred
> [ 1354.247189] RPC:       looking up UNIX cred
> [ 1354.247223] RPC:       allocating UNIX cred for uid 0 gid 0
> [ 1354.247270] RPC:     2 refreshing UNIX cred fffff807fdefc900
> [ 1354.247317] RPC:     2 call_refreshresult (status 0)
> [ 1354.247361] RPC:     2 call_allocate (status 0)
> [ 1354.247395] RPC:     2 allocated buffer of size 416 at fffff807fdf42000
> [ 1354.247443] RPC:     2 call_bind (status 0)
> [ 1354.247476] RPC:     2 call_connect xprt fffff807fdf41800 is not connected
> [ 1354.247526] RPC:     2 xprt_connect xprt fffff807fdf41800 is not connected
> [ 1354.247604] RPC:     2 xprt_cwnd_limited cong = 0 cwnd = 256
> [ 1354.247651] RPC:     2 sleep_on(queue "xprt_pending" time 4294893394)
> [ 1354.247700] RPC:     2 added to queue fffff807fdf41a28 "xprt_pending"
> [ 1354.247747] RPC:     2 setting alarm for 5000 ms
> [ 1354.247780] RPC:       xs_connect scheduled xprt fffff807fdf41800
> [ 1354.247922] RPC:       xs_bind 0.0.0.0:0: ok (0)
> [ 1354.247988] RPC:       worker connecting xprt fffff807fdf41800 via udp to 137.226.167.241 (port 111)
> [ 1354.248050] RPC:     2 __rpc_wake_up_task (now 4294893394)
> [ 1354.248094] RPC:     2 disabling timer
> [ 1354.248125] RPC:     2 removed from queue fffff807fdf41a28 "xprt_pending"
> [ 1354.248172] RPC:       __rpc_wake_up_task done
> [ 1354.248205] RPC:     2 __rpc_execute flags=0x681
> [ 1354.248238] RPC:     2 xprt_connect_status: connection established
> [ 1354.248285] RPC:     2 call_connect_status (status 0)
> [ 1354.248329] RPC:     2 call_transmit (status 0)
> [ 1354.248389] RPC:     2 xprt_prepare_transmit
> [ 1354.248421] RPC:     2 rpc_xdr_encode (status 0)
> [ 1354.248455] RPC:     2 marshaling UNIX cred fffff807fdefc900
> [ 1354.248503] RPC:     2 using AUTH_UNIX cred fffff807fdefc900 to wrap rpc data
> [ 1354.248556] RPC:     2 encoding PMAP_GETPORT call (100005, 1, 17, 0)
> [ 1354.248603] RPC:     2 xprt_transmit(92)
> [ 1354.253576] RPC:       xs_udp_send_request(92) = 92
> [ 1354.253611] RPC:     2 xmit complete
> [ 1354.253644] RPC:     2 sleep_on(queue "xprt_pending" time 4294893395)
> [ 1354.253692] RPC:     2 added to queue fffff807fdf41a28 "xprt_pending"
> [ 1354.253739] RPC:     2 setting alarm for 5000 ms
> [ 1359.265758] RPC:     2 timeout
...
<snip>
... 
> [ 1389.332120] RPC:     1 rpcbind request timed out
> [ 1389.332129] RPC:     1 call_timeout (major)
> [ 1389.332138] RPC:     1 return 0, status -60
> [ 1389.332145] RPC:     1 release task
> [ 1389.332158] RPC:       freeing buffer of size 96 at fffff807fdf41000
> [ 1389.332171] RPC:     1 release request fffff807fdf1a000
> [ 1389.332181] RPC:       wake_up_next(fffff807fdf40ad8 "xprt_backlog")
> [ 1389.332194] RPC:       rpc_release_client(fffff807fdf1a200)
> [ 1389.332203] RPC:     1 freeing task
> [ 1389.332213] RPC:       shutting down mount client for 137.226.167.241
> [ 1389.332222] RPC:       rpc_release_client(fffff807fdf1a200)
> [ 1389.332232] RPC:       destroying UNIX authenticator 00000000008b8d78
> [ 1389.332246] RPC:       destroying mount client for 137.226.167.241
> [ 1389.332259] NFS: failed to create MNT RPC client, status=-60
> [ 1389.332271] NFS: unable to mount server 137.226.167.241, error -60
> [ 1389.332306] VFS: Unable to mount root fs via NFS, trying floppy.
> [ 1389.332444] List of all partitions:
> [ 1389.332454] No filesystem could mount root, tried: 
> [ 1389.332469] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(2,0)
> [ 1389.332480] Call Trace:
> [ 1389.332509]  [00000000008c6d18] mount_block_root+0x210/0x228
> [ 1389.332523]  [00000000008c6df4] mount_root+0xc4/0xd4
> [ 1389.332537]  [00000000008c6f80] prepare_namespace+0x17c/0x1c0
> [ 1389.332554]  [00000000008c6250] kernel_init+0x140/0x158
> [ 1389.332574]  [000000000042ac68] kernel_thread+0x30/0x48
> [ 1389.332593]  [0000000000767840] rest_init+0x18/0x74
> [ 1389.332682] Press Stop-A (L1-A) to return to the boot prom
> [ 1389.333548] RPC:       destroying transport fffff807fdf40800
> [ 1389.334301] RPC:       xs_destroy xprt fffff807fdf40800
> [ 1389.334530] RPC:       xs_close xprt fffff807fdf40800
> [ 1389.334576] RPC:       disconnected transport fffff807fdf40800

So the NFS client is trying to establish contact with the server for a
period of 35 seconds, and there is no reply... Have you tried using
wireshark to see if any NFS traffic is arriving at the server from the
client?

Have you tried using the 'mountproto=tcp' option?

Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

