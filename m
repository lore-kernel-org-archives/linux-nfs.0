Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm24-vm0.bullet.mail.ird.yahoo.com ([212.82.109.239]:40358 "HELO
	nm24-vm0.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751954Ab1KDBd3 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 21:33:29 -0400
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com> <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu> <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com> <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com> <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com> <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com> <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>
Message-ID: <1320370404.48524.YahooMailNeo@web24710.mail.ird.yahoo.com>
Date: Fri, 4 Nov 2011 01:33:24 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> It agrees with our initial assessment that the first RPC request is failing.  
> The RPC client never gets the request through cluster2's network stack 
> because the NIC hasn't re-initialized when the request is sent.
> 
> It looks like your system does a PXE boot, which provides the IP configuration 
> shown above.  But then the kernel resets the NIC.  During that reset, the kernel 
> is attempting to contact the NFS server to mount the root file system.

This machine has no PXE boot but it has OpenBoot ;) and I can boot by fetching the kernel from a tftp.
But that's something we want to do in the future...
Now (for the sake of convenience) we load the kernel from hard disk but we want an NFSROOT. 

Therefore I've set a static configuration :
root=/dev/nfs rw 
nfsroot=137.226.167.241:/srv/nfs/cluster2 
ip=137.226.167.242::137.226.167.225:255.255.255.224:cluster2:eth0:off 
nfsrootdebug

Hence the NIC isn't "up" before the try to mount the NFSROOT.
Sorry, that I haven't mentioned it before my last email...


> We've set up NFSROOT to use UDP so that it will be relatively immune to 
> these initialization order problems.  The RPC client should be retrying the lost 
> request, but apparently it isn't.  What if you added "retrans=10" 
> to cluster2's mount options?  (on the chance that mount option setting would 
> be copied to the rpcbind client's RPC transport...)
> IMO the correct way to fix this is to provide proper serialization in the 
> networking layer so that RPC requests are not even attempted until the NIC is 
> ready to carry traffic.  That may be a pipe dream though.
> 

As I wrote it in my last email the retrans option doesn nothing. I've tested it again.
That's the whole bootloader/kernel output with ",retrans=10,timeo=60":
---
{0} ok boot disk
Boot device: /pci@0/pci@0/pci@2/scsi@0/disk@0  File and args: 
SILO Version 1.4.14
boot: LinuxNET3-debug
Allocated 64 Megs of memory at 0x40000000 for kernel
Uncompressing image...
Loaded kernel version 2.6.39

[    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 4.30.0 2008/12/11 12:15'
[    0.000000] PROMLIB: Root node compatible: sun4v
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 2.6.39.4-razik-2011-10-27 (root@cluster1) (gcc version 4.4.5 (Debian 4.4.5-8) ) #6 SMP Thu Nov 3 14:59:53 CET 2011
[    0.000000] bootconsole [earlyprom0] enabled
[    0.000000] ARCH: SUN4V
[    0.000000] Ethernet address: 00:14:4f:98:09:c2
[    0.000000] Kernel: Using 2 locked TLB entries for main kernel image.
[    0.000000] Remapping the kernel... done.
[    0.000000] OF stdout device is: /virtual-devices@100/console@1
[    0.000000] PROM: Built device tree with 123285 bytes of memory.
[    0.000000] MDESC: Size is 58672 bytes.
[    0.000000] PLATFORM: banner-name [SPARC Enterprise T5120]
[    0.000000] PLATFORM: name [SUNW,SPARC-Enterprise-T5120]
[    0.000000] PLATFORM: hostid [849809c2]
[    0.000000] PLATFORM: serial# [00ab4130]
[    0.000000] PLATFORM: stick-frequency [5458c3a0]
[    0.000000] PLATFORM: mac-address [144f9809c2]
[    0.000000] PLATFORM: watchdog-resolution [1000 ms]
[    0.000000] PLATFORM: watchdog-max-timeout [31536000000 ms]
[    0.000000] PLATFORM: max-cpus [64]
[    0.000000] Top of RAM: 0x7ffb1c000, Total RAM: 0x7f76c4000
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
[    0.000000]     0: 0x00004200 -> 0x003ffd51
[    0.000000]     0: 0x003ffd59 -> 0x003ffd63
[    0.000000]     0: 0x003ffd87 -> 0x003ffd8e
[    0.000000] Booting Linux...
[    0.000000] PERCPU: Embedded 6 pages/cpu @fffff80019000000 s16256 r8192 d24704 u65536
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 4144106
[    0.000000] Kernel command line: ro root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2,retrans=10,timeo=60 ip=137.226.167.242::137.226.167.225:255.255.255.224:cluster2:eth0:off nfsrootdebug
[    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 4194304 (order: 12, 33554432 bytes)
[    0.000000] Inode-cache hash table entries: 2097152 (order: 11, 16777216 bytes)
[    0.000000] Memory: 33090176k available (4192k kernel code, 1560k data, 232k init) [fffff80000000000,00000007ffb1c000]
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
[    0.000000] Linux version 2.6.39.4-razik-2011-10-27 (root@cluster1) (gcc version 4.4.5 (Debian 4.4.5-8) ) #6 SMP Thu Nov 3 14:59:53 CET 2011
[    0.000000] bootconsole [earlyprom0] enabled
[    0.000000] ARCH: SUN4V
[    0.000000] Ethernet address: 00:14:4f:98:09:c2
[    0.000000] Kernel: Using 2 locked TLB entries for main kernel image.
[    0.000000] Remapping the kernel... done.
[    0.000000] OF stdout device is: /virtual-devices@100/console@1
[    0.000000] PROM: Built device tree with 123285 bytes of memory.
[    0.000000] MDESC: Size is 58672 bytes.
[    0.000000] PLATFORM: banner-name [SPARC Enterprise T5120]
[    0.000000] PLATFORM: name [SUNW,SPARC-Enterprise-T5120]
[    0.000000] PLATFORM: hostid [849809c2]
[    0.000000] PLATFORM: serial# [00ab4130]
[    0.000000] PLATFORM: stick-frequency [5458c3a0]
[    0.000000] PLATFORM: mac-address [144f9809c2]
[    0.000000] PLATFORM: watchdog-resolution [1000 ms]
[    0.000000] PLATFORM: watchdog-max-timeout [31536000000 ms]
[    0.000000] PLATFORM: max-cpus [64]
[    0.000000] Top of RAM: 0x7ffb1c000, Total RAM: 0x7f76c4000
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
[    0.000000]     0: 0x00004200 -> 0x003ffd51
[    0.000000]     0: 0x003ffd59 -> 0x003ffd63
[    0.000000]     0: 0x003ffd87 -> 0x003ffd8e
[    0.000000] Booting Linux...
[    0.000000] PERCPU: Embedded 6 pages/cpu @fffff80019000000 s16256 r8192 d24704 u65536
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 4144106
[    0.000000] Kernel command line: ro root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2,retrans=10,timeo=60 ip=137.226.167.242::137.226.167.225:255.255.255.224:cluster2:eth0:off nfsrootdebug
[    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 4194304 (order: 12, 33554432 bytes)
[    0.000000] Inode-cache hash table entries: 2097152 (order: 11, 16777216 bytes)
[    0.000000] Memory: 33090176k available (4192k kernel code, 1560k data, 232k init) [fffff80000000000,00000007ffb1c000]
[    0.000000] SLUB: Genslabs=16, HWalign=32, Order=0-3, MinObjects=0, CPUs=64, Nodes=1
[    0.000000] Hierarchical RCU implementation.
[    0.000000]  CONFIG_RCU_FANOUT set to non-default value of 32
[    0.000000]  RCU-based detection of stalled CPUs is disabled.
[    0.000000] NR_IRQS:255
[    0.000000] clocksource: mult[5a73e7bb] shift[31]
[    0.000000] clockevent: mult[b5221ba3] shift[31]
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled, bootconsole disabled
[  542.555558] Calibrating delay using timer specific routine.. 2832.87 BogoMIPS (lpj=5665753)
[  542.555590] pid_max: default: 65536 minimum: 512
[  542.555896] Security Framework initialized
[  542.555929] SELinux:  Disabled at boot.
[  542.556065] Mount-cache hash table entries: 512
[  542.557246] Initializing cgroup subsys ns
[  542.557266] ns_cgroup deprecated: consider using the 'clone_children' flag without the ns_cgroup.
[  542.557294] Initializing cgroup subsys cpuacct
[  542.557389] Initializing cgroup subsys devices
[  542.557407] Initializing cgroup subsys freezer
[  542.557424] Initializing cgroup subsys net_cls
[  542.557704] Performance events: Supported PMU type is 'niagara2'
[  542.580874] Brought up 64 CPUs
[  542.580934] Testing NMI watchdog ... OK.
[  542.666730] devtmpfs: initialized
[  542.667184] ldc.c:v1.1 (July 22, 2008)
[  542.667793] print_constraints: dummy: 
[  542.668159] NET: Registered protocol family 16
[  542.677406] VIO: Adding device channel-devices
[  542.677484] VIO: Adding device vldc-port-3-0
[  542.677543] VIO: Adding device vldc-port-3-1
[  542.677603] VIO: Adding device vldc-port-3-2
[  542.677670] VIO: Adding device vldc-port-3-3
[  542.677745] VIO: Adding device vldc-port-3-4
[  542.677811] VIO: Adding device vldc-port-3-5
[  542.677877] VIO: Adding device vldc-port-2-0
[  542.677944] VIO: Adding device vldc-port-0-0
[  542.678011] VIO: Adding device vldc-port-0-1
[  542.678079] VIO: Adding device vldc-port-0-2
[  542.678147] VIO: Adding device vldc-port-1-0
[  542.678215] VIO: Adding device vldc-port-3-7
[  542.678287] VIO: Adding device vldc-port-3-8
[  542.678369] VIO: Adding device ds-1
[  542.678432] VIO: Adding device ds-0
[  542.683082] pci_sun4v: Registered hvapi major[1] minor[0]
[  542.683356] /pci@0: SUN4V PCI Bus Module
[  542.683376] /pci@0: On NUMA node -1
[  542.683397] /pci@0: PCI IO[c0f0000000] MEM[c100000000]
[  542.683426] /pci@0: Unable to request IOMMU resource.
[  542.727780] /pci@0: Imported 3 TSB entries from OBP
[  542.729230] /pci@0: MSI Queue first[0] num[36] count[128] devino[0x18]
[  542.729258] /pci@0: MSI first[0] num[256] mask[0xff] width[32]
[  542.729283] /pci@0: MSI addr32[0x7fff0000:0x10000] addr64[0x3ffff0000:0x10000]
[  542.729312] /pci@0: MSI queues at RA [00000007f8300000]
[  542.729335] PCI: Scanning PBM /pci@0
[  542.741097] ds.c:v1.0 (Jul 11, 2007)
[  542.744664] bio: create slab <bio-0> at 0
[  542.745277] vgaarb: loaded
[  542.746083] Switching to clocksource stick
[  542.746745] Switched to NOHz mode on CPU #35
[  542.746834] Switched to NOHz mode on CPU #12
[  542.746857] Switched to NOHz mode on CPU #58
[  542.746907] Switched to NOHz mode on CPU #24
[  542.746935] Switched to NOHz mode on CPU #47
[  542.747082] Switched to NOHz mode on CPU #36
[  542.747110] Switched to NOHz mode on CPU #1
[  542.747169] Switched to NOHz mode on CPU #13
[  542.747228] Switched to NOHz mode on CPU #59
[  542.747253] Switched to NOHz mode on CPU #25
[  542.747292] Switched to NOHz mode on CPU #48
[  542.747460] Switched to NOHz mode on CPU #37
[  542.747470] Switched to NOHz mode on CPU #0
[  542.747495] Switched to NOHz mode on CPU #2
[  542.747504] Switched to NOHz mode on CPU #14
[  542.747587] Switched to NOHz mode on CPU #60
[  542.747606] Switched to NOHz mode on CPU #26
[  542.747651] Switched to NOHz mode on CPU #49
[  542.747780] Switched to NOHz mode on CPU #38
[  542.747829] Switched to NOHz mode on CPU #3
[  542.747841] Switched to NOHz mode on CPU #15
[  542.747939] Switched to NOHz mode on CPU #61
[  542.747948] Switched to NOHz mode on CPU #27
[  542.748000] Switched to NOHz mode on CPU #50
[  542.748125] Switched to NOHz mode on CPU #39
[  542.748163] Switched to NOHz mode on CPU #4
[  542.748178] Switched to NOHz mode on CPU #16
[  542.748281] Switched to NOHz mode on CPU #28
[  542.748305] Switched to NOHz mode on CPU #62
[  542.748349] Switched to NOHz mode on CPU #51
[  542.748471] Switched to NOHz mode on CPU #40
[  542.748504] Switched to NOHz mode on CPU #5
[  542.748526] Switched to NOHz mode on CPU #17
[  542.748633] Switched to NOHz mode on CPU #29
[  542.748664] Switched to NOHz mode on CPU #63
[  542.748697] Switched to NOHz mode on CPU #52
[  542.748823] Switched to NOHz mode on CPU #41
[  542.748839] Switched to NOHz mode on CPU #6
[  542.748858] Switched to NOHz mode on CPU #18
[  542.748979] Switched to NOHz mode on CPU #30
[  542.749073] Switched to NOHz mode on CPU #53
[  542.749170] Switched to NOHz mode on CPU #7
[  542.749179] Switched to NOHz mode on CPU #42
[  542.749192] Switched to NOHz mode on CPU #19
[  542.749329] Switched to NOHz mode on CPU #31
[  542.749439] Switched to NOHz mode on CPU #54
[  542.749469] Switched to NOHz mode on CPU #8
[  542.749526] Switched to NOHz mode on CPU #43
[  542.749535] Switched to NOHz mode on CPU #20
[  542.749681] Switched to NOHz mode on CPU #32
[  542.749795] Switched to NOHz mode on CPU #55
[  542.749804] Switched to NOHz mode on CPU #9
[  542.749868] Switched to NOHz mode on CPU #44
[  542.749879] Switched to NOHz mode on CPU #21
[  542.750021] Switched to NOHz mode on CPU #33
[  542.750143] Switched to NOHz mode on CPU #10
[  542.750152] Switched to NOHz mode on CPU #56
[  542.750217] Switched to NOHz mode on CPU #45
[  542.750226] Switched to NOHz mode on CPU #22
[  542.750364] Switched to NOHz mode on CPU #34
[  542.750566] Switched to NOHz mode on CPU #23
[  542.750576] Switched to NOHz mode on CPU #46
[  542.750585] Switched to NOHz mode on CPU #57
[  542.750594] Switched to NOHz mode on CPU #11
[  542.762031] NET: Registered protocol family 2
[  542.762624] IP route cache hash table entries: 524288 (order: 9, 4194304 bytes)
[  542.763059] ds-1: Registered pri service.
[  542.765208] TCP established hash table entries: 524288 (order: 10, 8388608 bytes)
[  542.769250] ds-1: Registered var-config-backup service.
[  542.790571] TCP bind hash table entries: 65536 (order: 7, 1048576 bytes)
[  542.794314] TCP: Hash tables configured (established 524288 bind 65536)
[  542.794340] TCP reno registered
[  542.794379] UDP hash table entries: 16384 (order: 6, 524288 bytes)
[  542.796402] UDP-Lite hash table entries: 16384 (order: 6, 524288 bytes)
[  542.799835] NET: Registered protocol family 1
[  542.800489] RPC: Registered udp transport module.
[  542.800512] RPC: Registered tcp transport module.
[  542.800532] RPC: Registered tcp NFSv4.1 backchannel transport module.
[  542.801635] audit: initializing netlink socket (disabled)
[  542.801684] type=2000 audit(0.316:1): initialized
[  542.854020] HugeTLB registered 4 MB page size, pre-allocated 0 pages
[  542.862444] VFS: Disk quotas dquot_6.5.2
[  542.862958] Dquot-cache hash table entries: 1024 (order 0, 8192 bytes)
[  542.864268] msgmni has been set to 32768
[  542.865471] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
[  542.865505] io scheduler noop registered
[  542.865524] io scheduler deadline registered
[  542.865763] io scheduler cfq registered (default)
[  542.867089] f027ab74: ttyS0 at I/O 0x0 (irq = 17) is a SUN4V HCONS
[  543.075410] console [ttyHV0] enabled
[  543.077100] f028af14: ttyS1 at MMIO 0xfff0ca0000 (irq = 24) is a 16550A
[  543.077715] [drm] Initialized drm 1.1.0 20060810
[  543.081079] Uniform Multi-Platform E-IDE driver
[  543.081244] ide-gd driver 1.18
[  543.081307] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[  543.081356] e1000: Copyright (c) 1999-2006 Intel Corporation.
[  543.081486] e1000e: Intel(R) PRO/1000 Network Driver - 1.3.10-k2
[  543.081533] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[  543.081631] e1000e 0000:08:00.0: Disabling ASPM  L1
[  543.257986] e1000e 0000:08:00.0: eth0: (PCI Express:2.5GB/s:Width x4) 00:14:4f:98:09:c2
[  543.258192] e1000e 0000:08:00.0: eth0: Intel(R) PRO/1000 Network Connection
[  543.258319] e1000e 0000:08:00.0: eth0: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[  543.258400] e1000e 0000:08:00.1: Disabling ASPM  L1
[  543.443816] e1000e 0000:08:00.1: eth1: (PCI Express:2.5GB/s:Width x4) 00:14:4f:98:09:c3
[  543.443937] e1000e 0000:08:00.1: eth1: Intel(R) PRO/1000 Network Connection
[  543.444121] e1000e 0000:08:00.1: eth1: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[  543.444248] e1000e 0000:09:00.0: Disabling ASPM  L1
[  543.622266] e1000e 0000:09:00.0: eth2: (PCI Express:2.5GB/s:Width x4) 00:14:4f:98:09:c4
[  543.622387] e1000e 0000:09:00.0: eth2: Intel(R) PRO/1000 Network Connection
[  543.622570] e1000e 0000:09:00.0: eth2: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[  543.622697] e1000e 0000:09:00.1: Disabling ASPM  L1
[  543.808183] e1000e 0000:09:00.1: eth3: (PCI Express:2.5GB/s:Width x4) 00:14:4f:98:09:c5
[  543.808304] e1000e 0000:09:00.1: eth3: Intel(R) PRO/1000 Network Connection
[  543.808487] e1000e 0000:09:00.1: eth3: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
[  543.808655] Intel(R) Gigabit Ethernet Network Driver - version 3.0.6-k2
[  543.808734] Copyright (c) 2007-2011 Intel Corporation.
[  543.808854] Intel(R) Virtual Function Network Driver - version 1.0.8-k0
[  543.808904] Copyright (c) 2009 - 2010 Intel Corporation.
[  543.809548] mousedev: PS/2 mouse device common for all mice
[  543.810734] rtc-sun4v rtc-sun4v: rtc core: registered sun4v as rtc0
[  543.812500] TCP cubic registered
[  543.813350] NET: Registered protocol family 10
[  543.824976] Mobile IPv6
[  543.825023] NET: Registered protocol family 17
[  543.825107] Registering the dns_resolver key type
[  543.825741] registered taskstats version 1
[  543.828720] rtc-sun4v rtc-sun4v: setting system clock to 2011-11-04 01:12:04 UTC (1320369124)
[  543.828779] Initializing network drop monitor service
[  544.577265] ADDRCONF(NETDEV_UP): eth0: link is not ready
[  545.599366] IP-Config: Complete:
[  545.599435]      device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=137.226.167.225,
[  545.599638]      host=cluster2, domain=, nis-domain=(none),
[  545.599751]      bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
[  545.600198] Root-NFS: nfsroot=/srv/nfs/cluster2,retrans=10,timeo=60
[  545.600521] NFS: nfs mount opts='udp,retrans=10,timeo=60,nolock,addr=137.226.167.241'
[  545.600616] NFS:   parsing nfs mount option 'udp'
[  545.600654] NFS:   parsing nfs mount option 'retrans=10'
[  545.600710] NFS:   parsing nfs mount option 'timeo=60'
[  545.600760] NFS:   parsing nfs mount option 'nolock'
[  545.600807] NFS:   parsing nfs mount option 'addr=137.226.167.241'
[  545.600871] NFS: MNTPATH: '/srv/nfs/cluster2'
[  545.600906] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
[  546.737859] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
[  546.758283] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  580.671263] NFS: failed to create MNT RPC client, status=-60
[  580.671373] NFS: unable to mount server 137.226.167.241, error -60
[  580.671508] VFS: Unable to mount root fs via NFS, trying floppy.
[  580.671657] VFS: Insert root floppy and press ENTER
