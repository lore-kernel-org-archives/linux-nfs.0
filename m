Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:57669 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975Ab1KDXPt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 19:15:49 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Apple Message framework v1084)
Subject: NFSROOT mount fails on SPARC after 2.6.37
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 4 Nov 2011 19:15:33 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Lukas Razik <linux@razik.name>
Message-Id: <119BC4C8-E1AB-4415-AF00-B183FC7EB16A@oracle.com>
References: <1320429339.53513.YahooMailNeo@web24704.mail.ird.yahoo.com>
To: netdev@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Below is an example of an NFSROOT failure on SPARC with 2.6.37+.  NFSROOT worked on earlier kernels because NFSROOT in those kernels ignored this failure and went ahead with a default.  On any kernel, later socket creation works as expected.

To perform the NFSROOT mount, the kernel RPC client creates a socket and sends an RPC request (in this case) before the system NIC becomes ready.  The request times out, the NIC becomes ready, and the RPC request is resent, but the resend never appears at the server.

NFSROOT is designed to retry RPC requests after a few seconds to avoid just this scenario.  On other platforms with other NICs, this design seemed to work (or perhaps it papers over the problem with a high degree of success).

Questions:

1.  Why does the retransmitted request not get sent, even though the NIC has become ready?

2.  Should kernel_sendmsg() report an error (say, EHOSTUNREACH, ENETDOWN, or ENETUNREACH) if a UDP packet cannot be sent because the local NIC is down?  Trying with TCP, we get EHOSTUNREACH.  Is the difference the use of a connected socket?

3.  Naively, is there a way to cause the kernel to wait until the local NIC is ready before attempting to mount NFSROOT?

4.  What should the RPC client retransmit logic do to better guarantee recovery and swift retransmission in this case?


Thanks for any advice.


Begin forwarded message:

> From: Lukas Razik <linux@razik.name>
> Date: November 4, 2011 1:55:39 PM EDT
> To: Chuck Lever <chuck.lever@oracle.com>
> Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>
> Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
> Reply-To: Lukas Razik <linux@razik.name>
> 
>> As for a patch: no-one can write a patch unless we understand precisely why the 
> 
>> first RPC fails.  I already explained how to add a line or two to 
>> fs/nfs/nfsroot.c to give us more information.  If you need a patch to do this, I 
>> can send one later today.
>> 
>> I might be able to reproduce it here, now that I understand your set up, but it 
>> would require building a partial NFSROOT environment.  I can't get to that 
>> until next week.
> 
> OK, it was easier than I thought...
> I've set NFSDBG_ALL where you wanted it and rpc_debug = RPCDBG_ALL .
> 
> That's the linux-2.6.39.4 output now. Hopefully you can see the problem now...
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
> /
> [    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 4.30.0 2008/12/11 12:15'
> [    0.000000] PROMLIB: Root node compatible: sun4v
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 2.6.39.4-razik-2011-11-04 (root@cluster1) (gcc version 4.4.5 (Debian 4.4.5-8) ) #8 SMP Fri Nov 4 18:40:53 CET 2011
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
> [    0.000000] PERCPU: Embedded 6 pages/cpu @fffff80019000000 s15616 r8192 d25344 u65536
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 4144105
> [    0.000000] Kernel command line: root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2 ip=137.226.167.242:::255.255.255.224::eth0:off nfsrootdebug
> [    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
> [    0.000000] Dentry cache hash table entries: 4194304 (order: 12, 33554432 bytes)
> [    0.000000] Inode-cache hash table entries: 2097152 (order: 11, 16777216 bytes)
> [    0.000000] Memory: 33091488k available (3528k kernel code, 1248k data, 208k init) [fffff80000000000,00000007ffb1c000]
> [    0.000000] SLUB: Genslabs=16, HWalign=32, Order=0-3, MinObjects=0, CPUs=64, Nodes=1
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000]  CONFIG_RCU_FANOUT set to non-default value of 32
> [    0.000000]  RCU-based detection of stalled CPUs is disabled.
> [    0.000000] NR_IRQS:255
> [    0.000000] clocksource: mult[5a73e7bb] shift[31]
> [    0.000000] clockevent: mult[b5221ba3] shift[31]
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] console [tty0] enabled, bootconsole disabled
> [    0.000000] PROMLIB: Sun IEEE Boot Prom 'OBP 4.30.0 2008/12/11 12:15'
> [    0.000000] PROMLIB: Root node compatible: sun4v
> [    0.000000] Initializing cgroup subsys cpuset
> [    0.000000] Initializing cgroup subsys cpu
> [    0.000000] Linux version 2.6.39.4-razik-2011-11-04 (root@cluster1) (gcc version 4.4.5 (Debian 4.4.5-8) ) #8 SMP Fri Nov 4 18:40:53 CET 2011
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
> [    0.000000] PERCPU: Embedded 6 pages/cpu @fffff80019000000 s15616 r8192 d25344 u65536
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 4144105
> [    0.000000] Kernel command line: root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2 ip=137.226.167.242:::255.255.255.224::eth0:off nfsrootdebug
> [    0.000000] PID hash table entries: 4096 (order: 2, 32768 bytes)
> [    0.000000] Dentry cache hash table entries: 4194304 (order: 12, 33554432 bytes)
> [    0.000000] Inode-cache hash table entries: 2097152 (order: 11, 16777216 bytes)
> [    0.000000] Memory: 33091488k available (3528k kernel code, 1248k data, 208k init) [fffff80000000000,00000007ffb1c000]
> [    0.000000] SLUB: Genslabs=16, HWalign=32, Order=0-3, MinObjects=0, CPUs=64, Nodes=1
> [    0.000000] Hierarchical RCU implementation.
> [    0.000000]  CONFIG_RCU_FANOUT set to non-default value of 32
> [    0.000000]  RCU-based detection of stalled CPUs is disabled.
> [    0.000000] NR_IRQS:255
> [    0.000000] clocksource: mult[5a73e7bb] shift[31]
> [    0.000000] clockevent: mult[b5221ba3] shift[31]
> [    0.000000] Console: colour dummy device 80x25
> [    0.000000] console [tty0] enabled, bootconsole disabled
> [  120.892024] Calibrating delay using timer specific routine.. 2832.74 BogoMIPS (lpj=5665497)
> [  120.892057] pid_max: default: 65536 minimum: 512
> [  120.892502] Mount-cache hash table entries: 512
> [  120.893663] Initializing cgroup subsys ns
> [  120.893682] ns_cgroup deprecated: consider using the 'clone_children' flag without the ns_cgroup.
> [  120.893710] Initializing cgroup subsys cpuacct
> [  120.893817] Initializing cgroup subsys devices
> [  120.893835] Initializing cgroup subsys freezer
> [  120.893851] Initializing cgroup subsys net_cls
> [  120.894117] Performance events: Supported PMU type is 'niagara2'
> [  120.916617] Brought up 64 CPUs
> [  120.916685] Testing NMI watchdog ... OK.
> [  120.998031] devtmpfs: initialized
> [  120.998482] ldc.c:v1.1 (July 22, 2008)
> [  120.998753] print_constraints: dummy: 
> [  120.999091] NET: Registered protocol family 16
> [  121.008200] VIO: Adding device channel-devices
> [  121.008276] VIO: Adding device vldc-port-3-0
> [  121.008338] VIO: Adding device vldc-port-3-1
> [  121.008398] VIO: Adding device vldc-port-3-2
> [  121.008457] VIO: Adding device vldc-port-3-3
> [  121.008526] VIO: Adding device vldc-port-3-4
> [  121.008594] VIO: Adding device vldc-port-3-5
> [  121.008663] VIO: Adding device vldc-port-2-0
> [  121.008730] VIO: Adding device vldc-port-0-0
> [  121.008795] VIO: Adding device vldc-port-0-1
> [  121.008862] VIO: Adding device vldc-port-0-2
> [  121.008939] VIO: Adding device vldc-port-1-0
> [  121.009011] VIO: Adding device vldc-port-3-7
> [  121.009082] VIO: Adding device vldc-port-3-8
> [  121.009164] VIO: Adding device ds-1
> [  121.009227] VIO: Adding device ds-0
> [  121.013776] pci_sun4v: Registered hvapi major[1] minor[0]
> [  121.014050] /pci@0: SUN4V PCI Bus Module
> [  121.014069] /pci@0: On NUMA node -1
> [  121.014089] /pci@0: PCI IO[c0f0000000] MEM[c100000000]
> [  121.014117] /pci@0: Unable to request IOMMU resource.
> [  121.058300] /pci@0: Imported 3 TSB entries from OBP
> [  121.059736] /pci@0: MSI Queue first[0] num[36] count[128] devino[0x18]
> [  121.059764] /pci@0: MSI first[0] num[256] mask[0xff] width[32]
> [  121.059788] /pci@0: MSI addr32[0x7fff0000:0x10000] addr64[0x3ffff0000:0x10000]
> [  121.059817] /pci@0: MSI queues at RA [00000007f8180000]
> [  121.059841] PCI: Scanning PBM /pci@0
> [  121.071538] ds.c:v1.0 (Jul 11, 2007)
> [  121.074662] bio: create slab <bio-0> at 0
> [  121.075346] vgaarb: loaded
> [  121.076145] Switching to clocksource stick
> [  121.076886] Switched to NOHz mode on CPU #30
> [  121.077007] Switched to NOHz mode on CPU #42
> [  121.077128] Switched to NOHz mode on CPU #19
> [  121.077162] Switched to NOHz mode on CPU #7
> [  121.077206] Switched to NOHz mode on CPU #54
> [  121.077215] Switched to NOHz mode on CPU #31
> [  121.077346] Switched to NOHz mode on CPU #43
> [  121.077457] Switched to NOHz mode on CPU #20
> [  121.077468] Switched to NOHz mode on CPU #8
> [  121.077551] Switched to NOHz mode on CPU #32
> [  121.077563] Switched to NOHz mode on CPU #55
> [  121.077693] Switched to NOHz mode on CPU #44
> [  121.077791] Switched to NOHz mode on CPU #9
> [  121.077799] Switched to NOHz mode on CPU #21
> [  121.077897] Switched to NOHz mode on CPU #33
> [  121.077910] Switched to NOHz mode on CPU #56
> [  121.078038] Switched to NOHz mode on CPU #45
> [  121.078125] Switched to NOHz mode on CPU #10
> [  121.078134] Switched to NOHz mode on CPU #22
> [  121.078231] Switched to NOHz mode on CPU #34
> [  121.078262] Switched to NOHz mode on CPU #57
> [  121.078382] Switched to NOHz mode on CPU #46
> [  121.078457] Switched to NOHz mode on CPU #11
> [  121.078479] Switched to NOHz mode on CPU #23
> [  121.078586] Switched to NOHz mode on CPU #35
> [  121.078607] Switched to NOHz mode on CPU #58
> [  121.078730] Switched to NOHz mode on CPU #47
> [  121.078786] Switched to NOHz mode on CPU #12
> [  121.078819] Switched to NOHz mode on CPU #24
> [  121.078922] Switched to NOHz mode on CPU #36
> [  121.078973] Switched to NOHz mode on CPU #59
> [  121.079081] Switched to NOHz mode on CPU #48
> [  121.079103] Switched to NOHz mode on CPU #1
> [  121.079115] Switched to NOHz mode on CPU #13
> [  121.079158] Switched to NOHz mode on CPU #25
> [  121.079275] Switched to NOHz mode on CPU #37
> [  121.079323] Switched to NOHz mode on CPU #60
> [  121.079438] Switched to NOHz mode on CPU #14
> [  121.079447] Switched to NOHz mode on CPU #49
> [  121.079494] Switched to NOHz mode on CPU #26
> [  121.079504] Switched to NOHz mode on CPU #2
> [  121.079612] Switched to NOHz mode on CPU #38
> [  121.079674] Switched to NOHz mode on CPU #61
> [  121.079777] Switched to NOHz mode on CPU #15
> [  121.079788] Switched to NOHz mode on CPU #50
> [  121.079828] Switched to NOHz mode on CPU #3
> [  121.079843] Switched to NOHz mode on CPU #27
> [  121.079928] Switched to NOHz mode on CPU #0
> [  121.079946] Switched to NOHz mode on CPU #39
> [  121.080027] Switched to NOHz mode on CPU #62
> [  121.080115] Switched to NOHz mode on CPU #16
> [  121.080137] Switched to NOHz mode on CPU #51
> [  121.080163] Switched to NOHz mode on CPU #4
> [  121.080178] Switched to NOHz mode on CPU #28
> [  121.080300] Switched to NOHz mode on CPU #40
> [  121.080378] Switched to NOHz mode on CPU #63
> [  121.080631] Switched to NOHz mode on CPU #53
> [  121.080640] Switched to NOHz mode on CPU #52
> [  121.080649] Switched to NOHz mode on CPU #29
> [  121.080658] Switched to NOHz mode on CPU #18
> [  121.080666] Switched to NOHz mode on CPU #17
> [  121.080676] Switched to NOHz mode on CPU #6
> [  121.080685] Switched to NOHz mode on CPU #5
> [  121.080694] Switched to NOHz mode on CPU #41
> [  121.084586] NET: Registered protocol family 2
> [  121.085036] IP route cache hash table entries: 524288 (order: 9, 4194304 bytes)
> [  121.087098] TCP established hash table entries: 524288 (order: 10, 8388608 bytes)
> [  121.112468] TCP bind hash table entries: 65536 (order: 7, 1048576 bytes)
> [  121.116211] TCP: Hash tables configured (established 524288 bind 65536)
> [  121.116237] TCP reno registered
> [  121.116275] UDP hash table entries: 16384 (order: 6, 524288 bytes)
> [  121.118284] UDP-Lite hash table entries: 16384 (order: 6, 524288 bytes)
> [  121.121764] NET: Registered protocol family 1
> [  121.121844] RPC:       creating workqueue rpciod
> [  121.122191] RPC:       registering /proc/net/rpc
> [  121.122304] svc: Adding svc transport class 'tcp'
> [  121.122330] svc: Adding svc transport class 'udp'
> [  121.122417] RPC: Registered udp transport module.
> [  121.122439] RPC: Registered tcp transport module.
> [  121.122460] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [  121.123725] audit: initializing netlink socket (disabled)
> [  121.123771] type=2000 audit(0.304:1): initialized
> [  121.138489] ds-1: Registered pri service.
> [  121.144197] ds-1: Registered var-config-backup service.
> [  121.172347] HugeTLB registered 4 MB page size, pre-allocated 0 pages
> [  121.180933] VFS: Disk quotas dquot_6.5.2
> [  121.181389] Dquot-cache hash table entries: 1024 (order 0, 8192 bytes)
> [  121.181957] RPC:       creating workqueue nfsiod
> [  121.182576] RPC:       registering /proc/net/rpc/nfs
> [  121.182629] msgmni has been set to 32768
> [  121.183725] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
> [  121.183758] io scheduler noop registered
> [  121.183777] io scheduler deadline registered
> [  121.184006] io scheduler cfq registered (default)
> [  121.185364] f027ab74: ttyS0 at I/O 0x0 (irq = 17) is a SUN4V HCONS
> [  121.290493] console [ttyHV0] enabled
> [  121.296625] f028af14: ttyS1 at MMIO 0xfff0ca0000 (irq = 24) is a 16550A
> [  121.297233] [drm] Initialized drm 1.1.0 20060810
> [  121.298368] e1000e: Intel(R) PRO/1000 Network Driver - 1.3.10-k2
> [  121.298415] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
> [  121.316970] e1000e 0000:08:00.0: Disabling ASPM  L1
> [  121.495481] e1000e 0000:08:00.0: eth0: (PCI Express:2.5GB/s:Width x4) 00:14:4f:98:09:c2
> [  121.495542] e1000e 0000:08:00.0: eth0: Intel(R) PRO/1000 Network Connection
> [  121.495668] e1000e 0000:08:00.0: eth0: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
> [  121.495749] e1000e 0000:08:00.1: Disabling ASPM  L1
> [  121.677262] e1000e 0000:08:00.1: eth1: (PCI Express:2.5GB/s:Width x4) 00:14:4f:98:09:c3
> [  121.677322] e1000e 0000:08:00.1: eth1: Intel(R) PRO/1000 Network Connection
> [  121.677448] e1000e 0000:08:00.1: eth1: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
> [  121.677516] e1000e 0000:09:00.0: Disabling ASPM  L1
> [  121.855616] e1000e 0000:09:00.0: eth2: (PCI Express:2.5GB/s:Width x4) 00:14:4f:98:09:c4
> [  121.855736] e1000e 0000:09:00.0: eth2: Intel(R) PRO/1000 Network Connection
> [  121.855919] e1000e 0000:09:00.0: eth2: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
> [  121.856045] e1000e 0000:09:00.1: Disabling ASPM  L1
> [  122.037491] e1000e 0000:09:00.1: eth3: (PCI Express:2.5GB/s:Width x4) 00:14:4f:98:09:c5
> [  122.037612] e1000e 0000:09:00.1: eth3: Intel(R) PRO/1000 Network Connection
> [  122.037795] e1000e 0000:09:00.1: eth3: MAC: 0, PHY: 4, PBA No: FFFFFF-0FF
> [  122.038436] mousedev: PS/2 mouse device common for all mice
> [  122.039494] rtc-sun4v rtc-sun4v: rtc core: registered sun4v as rtc0
> [  122.040139] TCP cubic registered
> [  122.041005] NET: Registered protocol family 10
> [  122.045854] Mobile IPv6
> [  122.045927] NET: Registered protocol family 17
> [  122.046031] Registering the dns_resolver key type
> [  122.046545] registered taskstats version 1
> [  122.049569] rtc-sun4v rtc-sun4v: setting system clock to 2011-11-04 17:52:28 UTC (1320429148)
> [  122.798799] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [  123.821111] IP-Config: Complete:
> [  123.821180]      device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=255.255.255.255,
> [  123.821382]      host=137.226.167.242, domain=, nis-domain=(none),
> [  123.821497]      bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
> [  123.821828] Root-NFS: nfsroot=/srv/nfs/cluster2
> [  123.822225] NFS: nfs mount opts='udp,nolock,addr=137.226.167.241'
> [  123.822447] NFS:   parsing nfs mount option 'udp'
> [  123.822514] NFS:   parsing nfs mount option 'nolock'
> [  123.822589] NFS:   parsing nfs mount option 'addr=137.226.167.241'
> [  123.822657] NFS: MNTPATH: '/srv/nfs/cluster2'
> [  123.822720] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
> [  123.822816] RPC:       set up xprt to 137.226.167.241 (autobind) via udp
> [  123.822898] RPC:       created transport fffff807f7595000 with 16 slots
> [  123.822947] RPC:       creating mount client for 137.226.167.241 (xprt fffff807f7595000)
> [  123.823037] RPC:       creating UNIX authenticator for client fffff807f74f4c00
> [  123.823125] RPC:       new task initialized, procpid 1
> [  123.823198] RPC:       allocated task fffff807f8212700
> [  123.823274] RPC:     1 __rpc_execute flags=0x680
> [  123.823309] RPC:     1 call_start mount3 proc NULL (sync)
> [  123.823384] RPC:     1 call_reserve (status 0)
> [  123.823417] RPC:     1 reserved req fffff807f71c8000 xid 28f70b9f
> [  123.823493] RPC:     1 call_reserveresult (status 0)
> [  123.823566] RPC:     1 call_refresh (status 0)
> [  123.823599] RPC:     1 holding NULL cred 00000000008aa050
> [  123.823674] RPC:     1 refreshing NULL cred 00000000008aa050
> [  123.823719] RPC:     1 call_refreshresult (status 0)
> [  123.823792] RPC:     1 call_allocate (status 0)
> [  123.823856] RPC:     1 allocated buffer of size 96 at fffff807f7595800
> [  123.823904] RPC:     1 call_bind (status 0)
> [  123.823967] RPC:     1 rpcb_getport_async(137.226.167.241, 100005, 3, 17)
> [  123.824016] RPC:     1 sleep_on(queue "xprt_binding" time 4294893049)
> [  123.824093] RPC:     1 added to queue fffff807f75950c8 "xprt_binding"
> [  123.824169] RPC:     1 setting alarm for 60000 ms
> [  123.824206] RPC:     1 rpcb_getport_async: trying rpcbind version 2
> [  123.824296] RPC:       set up xprt to 137.226.167.241 (port 111) via udp
> [  123.824376] RPC:       created transport fffff807f7596000 with 16 slots
> [  123.824454] RPC:       creating rpcbind client for 137.226.167.241 (xprt fffff807f7596000)
> [  123.824513] RPC:       creating UNIX authenticator for client fffff807f74f4e00
> [  123.824599] RPC:       new task initialized, procpid 1
> [  123.824672] RPC:       allocated task fffff807f82127e0
> [  123.824752] RPC:       rpc_release_client(fffff807f74f4e00)
> [  123.824800] RPC:     1 sync task going to sleep
> [  123.824869] RPC:     2 __rpc_execute flags=0x681
> [  123.824933] RPC:     2 call_start rpcbind2 proc GETPORT (async)
> [  123.824980] RPC:     2 call_reserve (status 0)
> [  123.825042] RPC:     2 reserved req fffff807f71ca000 xid 61482335
> [  123.825088] RPC:     2 call_reserveresult (status 0)
> [  123.825161] RPC:     2 call_refresh (status 0)
> [  123.825221] RPC:     2 looking up UNIX cred
> [  123.825252] RPC:       looking up UNIX cred
> [  123.825286] RPC:       allocating UNIX cred for uid 0 gid 0
> [  123.825362] RPC:     2 refreshing UNIX cred fffff807f74035c0
> [  123.825437] RPC:     2 call_refreshresult (status 0)
> [  123.825481] RPC:     2 call_allocate (status 0)
> [  123.825543] RPC:     2 allocated buffer of size 416 at fffff807f7596800
> [  123.825620] RPC:     2 call_bind (status 0)
> [  123.825653] RPC:     2 call_connect xprt fffff807f7596000 is not connected
> [  123.825731] RPC:     2 xprt_connect xprt fffff807f7596000 is not connected
> [  123.825809] RPC:     2 xprt_cwnd_limited cong = 0 cwnd = 256
> [  123.825856] RPC:     2 sleep_on(queue "xprt_pending" time 4294893049)
> [  123.825933] RPC:     2 added to queue fffff807f75962d8 "xprt_pending"
> [  123.826008] RPC:     2 setting alarm for 5000 ms
> [  123.826042] RPC:       xs_connect scheduled xprt fffff807f7596000
> [  123.826167] RPC:       xs_bind 0.0.0.0:0: ok (0)
> [  123.826232] RPC:       worker connecting xprt fffff807f7596000 via udp to 137.226.167.241 (port 111)
> [  123.826323] RPC:     2 __rpc_wake_up_task (now 4294893050)
> [  123.826396] RPC:     2 disabling timer
> [  123.826428] RPC:     2 removed from queue fffff807f75962d8 "xprt_pending"
> [  123.826475] RPC:       __rpc_wake_up_task done
> [  123.826508] RPC:     2 __rpc_execute flags=0x681
> [  123.826541] RPC:     2 xprt_connect_status: connection established
> [  123.826588] RPC:     2 call_connect_status (status 0)
> [  123.826632] RPC:     2 call_transmit (status 0)
> [  123.826664] RPC:     2 xprt_prepare_transmit
> [  123.826696] RPC:     2 rpc_xdr_encode (status 0)
> [  123.826729] RPC:     2 marshaling UNIX cred fffff807f74035c0
> [  123.826777] RPC:     2 using AUTH_UNIX cred fffff807f74035c0 to wrap rpc data
> [  123.826830] RPC:     2 encoding PMAP_GETPORT call (100005, 3, 17, 0)
> [  123.826877] RPC:     2 xprt_transmit(92)
> [  123.826973] RPC:       xs_udp_send_request(92) = 92
> [  123.827007] RPC:     2 xmit complete
> [  123.827040] RPC:     2 sleep_on(queue "xprt_pending" time 4294893050)
> [  123.827088] RPC:     2 added to queue fffff807f75962d8 "xprt_pending"
> [  123.827135] RPC:     2 setting alarm for 5000 ms
> [  124.915844] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
> [  124.936050] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [  128.844738] RPC:     2 timeout
> [  128.844798] RPC:     2 __rpc_wake_up_task (now 4294894304)
> [  128.844901] RPC:     2 disabling timer
> [  128.844962] RPC:     2 removed from queue fffff807f75962d8 "xprt_pending"
> [  128.845068] RPC:       __rpc_wake_up_task done
> [  128.845172] RPC:     2 __rpc_execute flags=0xe81
> [  128.845206] RPC:     2 xprt_timer
> [  128.845238] RPC:       cong 256, cwnd was 256, now 256
> [  128.845312] RPC:       wake_up_next(fffff807f7596228 "xprt_resend")
> [  128.845360] RPC:       wake_up_next(fffff807f7596178 "xprt_sending")
> [  128.845437] RPC:     2 call_status (status -60)
> [  128.845470] RPC:     2 call_timeout (minor)
> [  128.845530] RPC:     2 call_bind (status 0)
> [  128.845563] RPC:     2 call_connect xprt fffff807f7596000 is connected
> [  128.845638] RPC:     2 call_transmit (status 0)
> [  128.845669] RPC:     2 xprt_prepare_transmit
> [  128.845731] RPC:     2 xprt_cwnd_limited cong = 0 cwnd = 256
> [  128.845776] RPC:     2 rpc_xdr_encode (status 0)
> [  128.845839] RPC:     2 marshaling UNIX cred fffff807f74035c0
> [  128.845915] RPC:     2 using AUTH_UNIX cred fffff807f74035c0 to wrap rpc data
> [  128.845968] RPC:     2 encoding PMAP_GETPORT call (100005, 3, 17, 0)
> [  128.846044] RPC:     2 xprt_transmit(92)
> [  128.846125] RPC:       xs_udp_send_request(92) = 92
> [  128.846159] RPC:     2 xmit complete
> [  128.846220] RPC:     2 sleep_on(queue "xprt_pending" time 4294894304)
> [  128.846297] RPC:     2 added to queue fffff807f75962d8 "xprt_pending"
> [  128.846344] RPC:     2 setting alarm for 10000 ms
> [  138.865672] RPC:     2 timeout
> [  138.865733] RPC:     2 __rpc_wake_up_task (now 4294896808)
> [  138.865834] RPC:     2 disabling timer
> [  138.865894] RPC:     2 removed from queue fffff807f75962d8 "xprt_pending"
> [  138.866002] RPC:       __rpc_wake_up_task done
> [  138.866101] RPC:     2 __rpc_execute flags=0xe81
> [  138.866134] RPC:     2 xprt_timer
> [  138.866165] RPC:       cong 256, cwnd was 256, now 256
> [  138.866238] RPC:       wake_up_next(fffff807f7596228 "xprt_resend")
> [  138.866285] RPC:       wake_up_next(fffff807f7596178 "xprt_sending")
> [  138.866362] RPC:     2 call_status (status -60)
> [  138.866394] RPC:     2 call_timeout (minor)
> [  138.866454] RPC:     2 call_bind (status 0)
> [  138.866486] RPC:     2 call_connect xprt fffff807f7596000 is connected
> [  138.866562] RPC:     2 call_transmit (status 0)
> [  138.866593] RPC:     2 xprt_prepare_transmit
> [  138.866654] RPC:     2 xprt_cwnd_limited cong = 0 cwnd = 256
> [  138.866700] RPC:     2 rpc_xdr_encode (status 0)
> [  138.866761] RPC:     2 marshaling UNIX cred fffff807f74035c0
> [  138.866837] RPC:     2 using AUTH_UNIX cred fffff807f74035c0 to wrap rpc data
> [  138.866889] RPC:     2 encoding PMAP_GETPORT call (100005, 3, 17, 0)
> [  138.866963] RPC:     2 xprt_transmit(92)
> [  138.867007] RPC:       xs_udp_send_request(92) = 92
> [  138.867070] RPC:     2 xmit complete
> [  138.867130] RPC:     2 sleep_on(queue "xprt_pending" time 4294896808)
> [  138.867179] RPC:     2 added to queue fffff807f75962d8 "xprt_pending"
> [  138.867254] RPC:     2 setting alarm for 20000 ms
> [  158.940429] RPC:     2 timeout
> [  158.940490] RPC:     2 __rpc_wake_up_task (now 4294901824)
> [  158.940591] RPC:     2 disabling timer
> [  158.940651] RPC:     2 removed from queue fffff807f75962d8 "xprt_pending"
> [  158.940756] RPC:       __rpc_wake_up_task done
> [  158.940902] RPC:     2 __rpc_execute flags=0xe81
> [  158.940965] RPC:     2 xprt_timer
> [  158.940995] RPC:       cong 256, cwnd was 256, now 256
> [  158.941039] RPC:       wake_up_next(fffff807f7596228 "xprt_resend")
> [  158.941115] RPC:       wake_up_next(fffff807f7596178 "xprt_sending")
> [  158.941163] RPC:     2 call_status (status -60)
> [  158.941225] RPC:     2 call_timeout (major)
> [  158.941258] RPC:       setting port for xprt fffff807f7595000 to 0
> [  158.941337] RPC:     2 rpcb_getport_done(status -60, port 0)
> [  158.941412] RPC:     2 return 0, status -60
> [  158.941442] RPC:     2 release task
> [  158.941504] RPC:       freeing buffer of size 416 at fffff807f7596800
> [  158.941554] RPC:     2 release request fffff807f71ca000
> [  158.941628] RPC:       wake_up_next(fffff807f7596388 "xprt_backlog")
> [  158.941705] RPC:       rpc_release_client(fffff807f74f4e00)
> [  158.941751] RPC:       destroying rpcbind client for 137.226.167.241
> [  158.941827] RPC:       destroying transport fffff807f7596000
> [  158.941937] RPC:       xs_destroy xprt fffff807f7596000
> [  158.942033] RPC:       xs_close xprt fffff807f7596000
> [  158.942125] RPC:       disconnected transport fffff807f7596000
> [  158.942205] RPC:     2 freeing task
> [  158.942238] RPC:     1 __rpc_wake_up_task (now 4294901824)
> [  158.942310] RPC:     1 disabling timer
> [  158.942371] RPC:     1 removed from queue fffff807f75950c8 "xprt_binding"
> [  158.942427] RPC:       __rpc_wake_up_task done
> [  158.942439] RPC:     1 sync task resuming
> [  158.942447] RPC:     1 rpcbind request timed out
> [  158.942456] RPC:     1 call_timeout (major)
> [  158.942465] RPC:     1 return 0, status -60
> [  158.942472] RPC:     1 release task
> [  158.942485] RPC:       freeing buffer of size 96 at fffff807f7595800
> [  158.942498] RPC:     1 release request fffff807f71c8000
> [  158.942508] RPC:       wake_up_next(fffff807f7595388 "xprt_backlog")
> [  158.942520] RPC:       rpc_release_client(fffff807f74f4c00)
> [  158.942531] RPC:     1 freeing task
> [  158.942541] RPC:       shutting down mount client for 137.226.167.241
> [  158.942550] RPC:       rpc_release_client(fffff807f74f4c00)
> [  158.942560] RPC:       destroying UNIX authenticator 00000000008aa0d8
> [  158.942575] RPC:       destroying mount client for 137.226.167.241
> [  158.942587] NFS: failed to create MNT RPC client, status=-60
> [  158.942599] NFS: unable to mount server 137.226.167.241, error -60
> [  158.942642] VFS: Unable to mount root fs via NFS, trying floppy.
> [  158.942804] List of all partitions:
> [  158.942815] No filesystem could mount root, tried: 
> [  158.942829] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(2,0)
> [  158.942840] Call Trace:
> [  158.942867]  [00000000008b8d18] mount_block_root+0x210/0x228
> [  158.942884]  [00000000008b8df4] mount_root+0xc4/0xd4
> [  158.942899]  [00000000008b8f80] prepare_namespace+0x17c/0x1c0
> [  158.942915]  [00000000008b8260] kernel_init+0x164/0x17c
> [  158.942934]  [000000000042ac74] kernel_thread+0x30/0x48
> [  158.942952]  [000000000075d1fc] rest_init+0x18/0x74
> [  158.943026] Press Stop-A (L1-A) to return to the boot prom
> [  158.943848] RPC:       destroying transport fffff807f7595000
> [  158.943913] RPC:       xs_destroy xprt fffff807f7595000
> [  158.944013] RPC:       xs_close xprt fffff807f7595000
> [  158.944087] RPC:       disconnected transport fffff807f7595000

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




