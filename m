From: Norman Weathers <norman.r.weathers@conocophillips.com>
Subject: 2.6.20.3 kernel crash using NFS
Date: Tue, 22 May 2007 10:19:33 -0500
Message-ID: <1179847173.8508.7.camel@hoeplx2923>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqW9G-0001aW-HU
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 08:19:42 -0700
Received: from mailman2.ppco.com ([138.32.33.140])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1HqW9I-00054R-NR
	for nfs@lists.sourceforge.net; Tue, 22 May 2007 08:19:45 -0700
Received: from bvlextrd2.conoco.net (bvlextrd2.conoco.net [158.139.203.93])
	by mailman2.ppco.com (Switch-3.1.8/Switch-3.1.7) with ESMTP id
	l4MFJZhj026707
	for <nfs@lists.sourceforge.net>; Tue, 22 May 2007 10:19:37 -0500
Received: from bvlexbh4.conoco.net (bvlexbh4.conoco.net [158.139.203.25])
	by mail1.ppco.com (Switch-3.1.8/Switch-3.1.7) with ESMTP id
	l4MFJYug021611
	for <nfs@lists.sourceforge.net>; Tue, 22 May 2007 10:19:34 -0500
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello, all.

I have had a recent outage from an NFS server that appears to have a
memory leak somewhere.  Following is a "small" clip of the errors that
happened (this went on for over 100000 lines of error messages over
night).

<May/23 00:05 am>Call Trace:
<May/23 00:05 am> <IRQ>  [<ffffffff802101d9>] __alloc_pages+0x2e9/0x310
<May/23 00:05 am> [<ffffffff802e34e0>] kmem_getpages+0x70/0x170
<May/23 00:05 am> [<ffffffff802e394b>] fallback_alloc+0x13b/0x210
<May/23 00:05 am> [<ffffffff802e378d>] kmem_cache_alloc_node+0xad/0xe0
<May/23 00:05 am> [<ffffffff80231bf7>] __alloc_skb+0x77/0x170
<May/23 00:05 am> [<ffffffff804601ab>] __netdev_alloc_skb+0x2b/0x50
<May/23 00:05 am> [<ffffffff880d59f1>] :bnx2:bnx2_poll+0x6b1/0xca0
<May/23 00:05 am> [<ffffffff802905c5>] load_elf32_binary+0x735/0x21f0
<May/23 00:05 am> [<ffffffff8020cbea>] net_rx_action+0xba/0x1f0
<May/23 00:05 am> [<ffffffff8026c139>] _spin_unlock_irq+0x9/0x10
<May/23 00:05 am> [<ffffffff8021314f>] __do_softirq+0x5f/0xd0
<May/23 00:05 am> [<ffffffff8026623c>] call_softirq+0x1c/0x28^M<May/23
00:05 am>
<May/23 00:05 am> [<ffffffff8027473c>] do_softirq+0x2c/0x90
<May/23 00:05 am> [<ffffffff8027490a>] do_IRQ+0x16a/0x1a0
<May/23 00:05 am> [<ffffffff80265631>] ret_from_intr+0x0/0xa
<May/23 00:05 am> <EOI>  [<ffffffff80269213>] __read_lock_failed
+0x3/0x20
<May/23 00:05 am> [<ffffffff8020ce4e>] _raw_read_lock+0x2e/0x30
<May/23 00:05 am> [<ffffffff882d2124>] :sunrpc:sunrpc_cache_lookup
+0x34/0x170
<May/23 00:05 am> [<ffffffff882cb080>] :sunrpc:svc_sock_enqueue
+0x260/0x2f0
<May/23 00:05 am> [<ffffffff882cdb89>] :sunrpc:ip_map_lookup+0xc9/0xe0
<May/23 00:05 am> [<ffffffff882cdc3d>] :sunrpc:svcauth_unix_set_client
+0x9d/0x190^M<May/23 00:05 am>
<May/23 00:05 am> [<ffffffff882ca336>] :sunrpc:svc_process+0x276/0x760
<May/23 00:05 am> [<ffffffff883117c0>] :nfsd:nfsd+0x0/0x2d0
<May/23 00:05 am> [<ffffffff8831195d>] :nfsd:nfsd+0x19d/0x2d0
<May/23 00:05 am> [<ffffffff80265ec8>] child_rip+0xa/0x12
<May/23 00:05 am> [<ffffffff883117c0>] :nfsd:nfsd+0x0/0x2d0
<May/23 00:05 am> [<ffffffff883117c0>] :nfsd:nfsd+0x0/0x2d0
<May/23 00:05 am> [<ffffffff80265ebe>] child_rip+0x0/0x12

<May/23 00:05 am>Mem-info:
<May/23 00:05 am>Node 0 DMA per-cpu:
<May/23 00:05 am>CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:
0, btch:   1 usd:   0
<May/23 00:05 am>CPU    1: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:
0, btch:   1 usd:   0
<May/23 00:05 am>CPU    2: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:
0, btch:   1 usd:   0
<May/23 00:05 am>CPU    3: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:
0, btch:   1 usd:   0
<May/23 00:05 am>Node 0 DMA32 per-cpu:
<May/23 00:05 am>CPU    0: Hot: hi:  186, btch:  31 usd:  30   Cold: hi:
62, btch:  15 usd:   4^M<May/23 00:05 am>
<May/23 00:05 am>CPU    1: Hot: hi:  186, btch:  31 usd: 165   Cold: hi:
62, btch:  15 usd:  54
<May/23 00:05 am>CPU    2: Hot: hi:  186, btch:  31 usd: 180   Cold: hi:
62, btch:  15 usd:   9
<May/23 00:05 am>CPU    3: Hot: hi:  186, btch:  31 usd:  23   Cold: hi:
62, btch:  15 usd:  58
<May/23 00:05 am>Node 0 Normal per-cpu:
<May/23 00:05 am>CPU    0: Hot: hi:  186, btch:  31 usd:  31   Cold: hi:
62, btch:  15 usd:  14
<May/23 00:05 am>CPU    1: Hot: hi:  186, btch:  31 usd:  28   Cold: hi:
62, btch:  15 usd:  49
<May/23 00:05 am>CPU    2: Hot: hi:  186, btch:  31 usd:  10   Cold: hi:
62, btch:  15 usd:  11
<May/23 00:05 am>CPU    3: Hot: hi:  186, btch:  31 usd:  59   Cold: hi:
62, btch:  15 usd:  49
<May/23 00:05 am>Active:570821 inactive:1384706 dirty:218637
writeback:2205 unstable:0 free:12340 slab:55305 mapped:2492
pagetables:667
<May/23 00:05 am>Node 0 DMA free:10512kB min:60kB low:72kB high:88kB
active:0kB inactive:0kB present:9948kB pages_scanned:0
all_unreclaimable? yes
<May/23 00:05 am>lowmem_reserve[]: 0 2992 8032^M<May/23 00:05 am>
<May/23 00:05 am>Node 0 DMA32 free:27104kB min:18600kB low:23248kB
high:27900kB active:845596kB inactive:1904364kB present:3063852kB
pages_scanned:
0 all_unreclaimable? no
<May/23 00:05 am>lowmem_reserve[]: 0 0 5040
<May/23 00:05 am>Node 0 Normal free:11744kB min:31336kB low:39168kB
high:47004kB active:1437688kB inactive:3634460kB present:5160960kB
pages_scanne
d:0 all_unreclaimable? no
<May/23 00:05 am>lowmem_reserve[]: 0 0 0
<May/23 00:05 am>Node 0 DMA: 6*4kB 5*8kB 1*16kB 4*32kB 5*64kB 4*128kB
1*256kB 0*512kB 1*1024kB 0*2048kB 2*4096kB = 10512kB^M<May/23 00:05 am>
<May/23 00:05 am>Node 0 DMA32: 0*4kB 0*8kB 0*16kB 1*32kB 1*64kB 1*128kB
1*256kB 0*512kB 0*1024kB 1*2048kB 6*4096kB = 27104kB
<May/23 00:05 am>Node 0 Normal: 0*4kB 0*8kB 0*16kB 1*32kB 1*64kB 1*128kB
1*256kB 0*512kB 1*1024kB 1*2048kB 2*4096kB = 11744kB
<May/23 00:05 am>Swap cache: add 26, delete 26, find 0/0, race 0+0
<May/23 00:05 am>Free swap  = 4192852kB
<May/23 00:05 am>Total swap = 4192956kB
<May/23 00:05 am>Free swap:       4192852kB
<May/23 00:05 am>2359296 pages of RAM
<May/23 00:05 am>320234 reserved pages
<May/23 00:05 am>830306 pages shared
<May/23 00:05 am>0 pages swap cached
<May/23 00:05 am>printk: 59 messages suppressed.^M<May/23 00:05 am>
<May/23 00:05 am>nfsd: page allocation failure. order:0, mode:0x20

This is a 2.6.20.3 kernel running on a 64 bit box.  I am not for sure at
this point if this particular kernel had any of the Trond 2.6.20 patches
added on it or not (I don't believe so).
Other particulars:

Fedora Core 6
Qlogic 2462 4Gb fibre controller
Broadcom dual 1 Gb ethernet (bonded).

Other things of note, to get this guy stable, I had to turn off irq
balance due to a bug in the irq handler and the broadcom 1 GB ethernet
device (bnx2).  If you leave on irqbalance,
it will hang up on startup.  This particular card still has MSI
interrupts enabled, but no irqbalance (I mention these because I notice
that bnx2 is listed in the crash dump).

Any information would be helpful.

Norman Weathers

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
