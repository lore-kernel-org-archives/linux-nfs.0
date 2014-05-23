Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36204 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433AbaEWL44 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2014 07:56:56 -0400
Date: Fri, 23 May 2014 07:56:55 -0400
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        trond.myklebust@primarydata.com, NeilBrown <neilb@suse.de>,
        LKML <linux-kernel@vger.kernel.org>
Subject: Re: NFS issue while copying huge file
Message-ID: <20140523115655.GA14074@fieldses.org>
References: <CAFLxGvw_7=AuBqxNhAHpQAXq2aTqc8Afa6Z62=YCsFXcJx0Hug@mail.gmail.com>
 <CAFLxGvxm43MaOqv1JQ8vxkn4s50uHZ8Js6A-Ec+O_sjvFszehQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAFLxGvxm43MaOqv1JQ8vxkn4s50uHZ8Js6A-Ec+O_sjvFszehQ@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 22, 2014 at 12:50:34PM +0200, Richard Weinberger wrote:
> On Wed, May 21, 2014 at 11:33 PM, Richard Weinberger
> <richard.weinberger@gmail.com> wrote:
> > Hi!
> >
> > My backup server runs CentOS6 with kernel 2.6.32-431.17.1.el6.x86_64.
> > Many servers copy theirs backups to it. This setups works perfectly
> > fine since ages.
> > Today I've configured a new server which runs Kernel 3.12.20 to store
> > it's backups to the NFS server too.
> >
> > The backup file has around 400GiB, after 100GiB the client aborts the
> > copy job with EIO.
> > dmesg contains:
> > ---cut---
> > RPC: AUTH_GSS upcall timed out.
> > Please check user daemon is running.
> > nfs: server 10.42.0.1 not responding, timed out
> > nfs: server 10.42.0.1 not responding, timed out
> > nfs: server 10.42.0.1 not responding, timed out
> > nfs: server 10.42.0.1 not responding, timed out
> > ---cut---
> > Some times the client reports also a hung task too.
> >
> > I'm using vers=4 and tcp.
> > (Tried also vers=3 with udp and other combinations)
> >
> > And now the really strange part, on the NFS server the load increases up to 10.
> > I see lots of nfsd kernel threads consuming 100% CPU.
> > *sometimes* even the oom killer triggers on the NFS server.
> > Like:
> > ---cut---
> > top invoked oom-killer: gfp_mask=0x800d0, order=0, oom_adj=0, oom_score_adj=0
> > top cpuset=/ mems_allowed=0
> > Pid: 1907, comm: top Not tainted 2.6.32-431.17.1.el6.x86_64 #1
> > Call Trace:
> >  [<ffffffff810d0211>] ? cpuset_print_task_mems_allowed+0x91/0xb0
> >  [<ffffffff811225c0>] ? dump_header+0x90/0x1b0
> >  [<ffffffff8122761c>] ? security_real_capable_noaudit+0x3c/0x70
> >  [<ffffffff81122a42>] ? oom_kill_process+0x82/0x2a0
> >  [<ffffffff8112293e>] ? select_bad_process+0x9e/0x120
> >  [<ffffffff81122e80>] ? out_of_memory+0x220/0x3c0
> >  [<ffffffff8112f79f>] ? __alloc_pages_nodemask+0x89f/0x8d0
> >  [<ffffffff8116e082>] ? kmem_getpages+0x62/0x170
> >  [<ffffffff8116ec9a>] ? fallback_alloc+0x1ba/0x270
> >  [<ffffffff8116e6ef>] ? cache_grow+0x2cf/0x320
> >  [<ffffffff8116ea19>] ? ____cache_alloc_node+0x99/0x160
> >  [<ffffffff8116f99b>] ? kmem_cache_alloc+0x11b/0x190
> >  [<ffffffff811f2910>] ? proc_alloc_inode+0x20/0xb0
> >  [<ffffffff811a5747>] ? alloc_inode+0x27/0xa0
> >  [<ffffffff811a683b>] ? new_inode+0x2b/0xb0
> >  [<ffffffff811f45b4>] ? proc_pid_make_inode+0x14/0xb0
> >  [<ffffffff811f5f11>] ? proc_pident_instantiate+0x21/0xc0
> >  [<ffffffff811f610e>] ? proc_pident_lookup+0x8e/0xd0
> >  [<ffffffff811f61aa>] ? proc_tgid_base_lookup+0x1a/0x20
> >  [<ffffffff811986f5>] ? do_lookup+0x1a5/0x230
> >  [<ffffffff81199014>] ? __link_path_walk+0x794/0xff0
> >  [<ffffffff81199b2a>] ? path_walk+0x6a/0xe0
> >  [<ffffffff81199d3b>] ? filename_lookup+0x6b/0xc0
> >  [<ffffffff81226076>] ? security_file_alloc+0x16/0x20
> >  [<ffffffff8119b214>] ? do_filp_open+0x104/0xd20
> >  [<ffffffff81060aa3>] ? perf_event_task_sched_out+0x33/0x70
> >  [<ffffffff812824f5>] ? _atomic_dec_and_lock+0x55/0x80
> >  [<ffffffff811a7ea2>] ? alloc_fd+0x92/0x160
> >  [<ffffffff811859e9>] ? do_sys_open+0x69/0x140
> >  [<ffffffff8100c715>] ? math_state_restore+0x45/0x60
> >  [<ffffffff81185b00>] ? sys_open+0x20/0x30
> >  [<ffffffff8100b072>] ? system_call_fastpath+0x16/0x1b
> > Mem-Info:
> > Node 0 DMA per-cpu:
> > CPU    0: hi:    0, btch:   1 usd:   0
> > CPU    1: hi:    0, btch:   1 usd:   0
> > Node 0 DMA32 per-cpu:
> > CPU    0: hi:  186, btch:  31 usd:   0
> > CPU    1: hi:  186, btch:  31 usd:  30
> > active_anon:2091 inactive_anon:56 isolated_anon:0
> >  active_file:208587 inactive_file:215722 isolated_file:32
> >  unevictable:0 dirty:213512 writeback:481 unstable:0
> >  free:13225 slab_reclaimable:14428 slab_unreclaimable:10804
> >  mapped:299 shmem:63 pagetables:444 bounce:0
> > Node 0 DMA free:8220kB min:336kB low:420kB high:504kB active_anon:0kB
> > inactive_anon:0kB active_file:0kB inactive_file:7128kB unevictable:0kB
> > isolated(anon):0kB isolated(file):0kB present:15276kB mlocked:0kB
> > dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:332kB
> > slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB
> > bounce:0kB writeback_tmp:0kB pages_scanned:42272 all_unreclaimable?
> > yes
> > lowmem_reserve[]: 0 1976 1976 1976
> > Node 0 DMA32 free:44680kB min:44716kB low:55892kB high:67072kB
> > active_anon:8364kB inactive_anon:224kB active_file:834348kB
> > inactive_file:855676kB unevictable:0kB isolated(anon):0kB
> > isolated(file):256kB present:2024312kB mlocked:0kB dirty:854048kB
> > writeback:1924kB mapped:1196kB shmem:252kB slab_reclaimable:57380kB
> > slab_unreclaimable:43216kB kernel_stack:1384kB pagetables:1776kB
> > unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:9952
> > all_unreclaimable? no
> > lowmem_reserve[]: 0 0 0 0
> > Node 0 DMA: 5*4kB 3*8kB 3*16kB 4*32kB 1*64kB 2*128kB 0*256kB 1*512kB
> > 3*1024kB 2*2048kB 0*4096kB = 8220kB
> > Node 0 DMA32: 346*4kB 106*8kB 225*16kB 120*32kB 55*64kB 14*128kB
> > 10*256kB 5*512kB 2*1024kB 1*2048kB 5*4096kB = 44680kB
> > 424434 total pagecache pages
> > 0 pages in swap cache
> > Swap cache stats: add 0, delete 0, find 0/0
> > Free swap  = 0kB
> > Total swap = 0kB
> > 522224 pages RAM
> > 48677 pages reserved
> > 426546 pages shared
> > 31791 pages non-shared
> > [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> > [  472]     0   472     2771      274   1     -17         -1000 udevd
> > [ 1272]     0  1272     6910      148   1     -17         -1000 auditd
> > [ 1312]    32  1312     4744      137   1       0             0 rpcbind
> > [ 1338]    29  1338     5837      196   0       0             0 rpc.statd
> > [ 1350]     0  1350     1173      101   0       0             0 mdadm
> > [ 1423]     0  1423     6996      254   1       0             0 rpc.mountd
> > [ 1459]     0  1459     6291      148   0       0             0 rpc.idmapd
> > [ 1471]     0  1471   126650      252   0     -17         -1000 tgtd
> > [ 1473]     0  1473     3722       90   0     -17         -1000 tgtd
> > [ 1557]     0  1557    16652      276   1     -17         -1000 sshd
> > [ 1565]    38  1565     7680      318   0       0             0 ntpd
> > [ 1606]     0  1606    29324      235   1       0             0 crond
> > [ 1621]     0  1621     1016       74   0       0             0 mingetty
> > [ 1623]     0  1623     1016       74   1       0             0 mingetty
> > [ 1625]     0  1625     1016       73   0       0             0 mingetty
> > [ 1627]     0  1627     1016       73   0       0             0 mingetty
> > [ 1629]     0  1629     1016       73   1       0             0 mingetty
> > [ 1631]     0  1631     1016       74   1       0             0 mingetty
> > [ 1638]     0  1638     2770      264   0     -17         -1000 udevd
> > [ 1639]     0  1639     2770      264   0     -17         -1000 udevd
> > [ 1889]     0  1889    25090      389   0       0             0 sshd
> > [ 1891]   500  1891    25090      368   1       0             0 sshd
> > [ 1892]   500  1892    27076      184   1       0             0 bash
> > [ 1907]   500  1907     3757      219   0       0             0 top
> > Out of memory: Kill process 1312 (rpcbind) score 1 or sacrifice child
> > Killed process 1312, UID 32, (rpcbind) total-vm:18976kB,
> > anon-rss:248kB, file-rss:300kB
> > ---cut---
> >
> > or
> >
> > ---cut---
> > collectd invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0,
> > oom_score_adj=0
> > collectd cpuset=/ mems_allowed=0
> > Pid: 1596, comm: collectd Not tainted 2.6.32-431.17.1.el6.x86_64 #1
> > Call Trace:
> >  [<ffffffff810d0211>] ? cpuset_print_task_mems_allowed+0x91/0xb0
> >  [<ffffffff811225c0>] ? dump_header+0x90/0x1b0
> >  [<ffffffff8122761c>] ? security_real_capable_noaudit+0x3c/0x70
> >  [<ffffffff81122a42>] ? oom_kill_process+0x82/0x2a0
> >  [<ffffffff81122981>] ? select_bad_process+0xe1/0x120
> >  [<ffffffff81122e80>] ? out_of_memory+0x220/0x3c0
> >  [<ffffffff81122438>] ? try_set_zonelist_oom+0xa8/0xe0
> >  [<ffffffff8112f79f>] ? __alloc_pages_nodemask+0x89f/0x8d0
> >  [<ffffffff8116769a>] ? alloc_pages_current+0xaa/0x110
> >  [<ffffffff8111f9b7>] ? __page_cache_alloc+0x87/0x90
> >  [<ffffffff8111f39e>] ? find_get_page+0x1e/0xa0
> >  [<ffffffff81120957>] ? filemap_fault+0x1a7/0x500
> >  [<ffffffff811bea76>] ? __set_page_dirty_buffers+0x46/0xc0
> >  [<ffffffff81149c84>] ? __do_fault+0x54/0x530
> >  [<ffffffff8114a257>] ? handle_pte_fault+0xf7/0xb00
> >  [<ffffffffa0072360>] ? ext4_get_block+0x0/0x120 [ext4]
> >  [<ffffffff8114ae8a>] ? handle_mm_fault+0x22a/0x300
> >  [<ffffffff8104a8d8>] ? __do_page_fault+0x138/0x480
> >  [<ffffffff811da055>] ? fcntl_setlk+0x75/0x320
> >  [<ffffffff8152d73e>] ? do_page_fault+0x3e/0xa0
> >  [<ffffffff8152aaf5>] ? page_fault+0x25/0x30
> > Mem-Info:
> > Node 0 DMA per-cpu:
> > CPU    0: hi:    0, btch:   1 usd:   0
> > CPU    1: hi:    0, btch:   1 usd:   0
> > Node 0 DMA32 per-cpu:
> > CPU    0: hi:  186, btch:  31 usd: 177
> > CPU    1: hi:  186, btch:  31 usd:  40
> > active_anon:3664 inactive_anon:56 isolated_anon:0
> >  active_file:204351 inactive_file:217741 isolated_file:64
> >  unevictable:8 dirty:215292 writeback:777 unstable:0
> >  free:13232 slab_reclaimable:14527 slab_unreclaimable:10875
> >  mapped:631 shmem:63 pagetables:595 bounce:0
> > Node 0 DMA free:8220kB min:336kB low:420kB high:504kB active_anon:0kB
> > inactive_anon:0kB active_file:284kB inactive_file:6844kB
> > unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15276kB
> > mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB
> > slab_reclaimable:332kB slab_unreclaimable:0kB kernel_stack:0kB
> > pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB
> > pages_scanned:59200 all_unreclaimable? yes
> > lowmem_reserve[]: 0 1976 1976 1976
> > Node 0 DMA32 free:44708kB min:44716kB low:55892kB high:67072kB
> > active_anon:14656kB inactive_anon:224kB active_file:817120kB
> > inactive_file:864120kB unevictable:32kB isolated(anon):0kB
> > isolated(file):256kB present:2024312kB mlocked:32kB dirty:861168kB
> > writeback:3108kB mapped:2524kB shmem:252kB slab_reclaimable:57776kB
> > slab_unreclaimable:43500kB kernel_stack:1552kB pagetables:2380kB
> > unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:359776
> > all_unreclaimable? no
> > lowmem_reserve[]: 0 0 0 0
> > Node 0 DMA: 5*4kB 3*8kB 3*16kB 4*32kB 1*64kB 2*128kB 2*256kB 2*512kB
> > 2*1024kB 2*2048kB 0*4096kB = 8220kB
> > Node 0 DMA32: 177*4kB 378*8kB 85*16kB 148*32kB 11*64kB 1*128kB 1*256kB
> > 2*512kB 2*1024kB 1*2048kB 7*4096kB = 44708kB
> > 422228 total pagecache pages
> > 0 pages in swap cache
> > Swap cache stats: add 0, delete 0, find 0/0
> > Free swap  = 0kB
> > Total swap = 0kB
> > 522224 pages RAM
> > 48677 pages reserved
> > 426430 pages shared
> > 33618 pages non-shared
> > [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> > [  472]     0   472     2771      278   1     -17         -1000 udevd
> > [ 1272]     0  1272     6910      175   1     -17         -1000 auditd
> > [ 1289]     0  1289    63855      312   0       0             0 rsyslogd
> > [ 1312]    32  1312     4744      173   0       0             0 rpcbind
> > [ 1338]    29  1338     5837      261   0       0             0 rpc.statd
> > [ 1350]     0  1350     1173      135   0       0             0 mdadm
> > [ 1423]     0  1423     6996      324   0       0             0 rpc.mountd
> > [ 1459]     0  1459     6291      170   0       0             0 rpc.idmapd
> > [ 1471]     0  1471   126650      294   0     -17         -1000 tgtd
> > [ 1473]     0  1473     3722      109   0     -17         -1000 tgtd
> > [ 1557]     0  1557    16652      279   1     -17         -1000 sshd
> > [ 1565]    38  1565     7680      383   0       0             0 ntpd
> > [ 1582]     0  1582     1530       79   1       0             0 collectdmon
> > [ 1583]     0  1583   271094     1445   1       0             0 collectd
> > [ 1606]     0  1606    29324      288   0       0             0 crond
> > [ 1621]     0  1621     1016      140   0       0             0 mingetty
> > [ 1623]     0  1623     1016      140   1       0             0 mingetty
> > [ 1625]     0  1625     1016      139   0       0             0 mingetty
> > [ 1627]     0  1627     1016      139   0       0             0 mingetty
> > [ 1629]     0  1629     1016      139   1       0             0 mingetty
> > [ 1631]     0  1631     1016      140   1       0             0 mingetty
> > [ 1638]     0  1638     2770      266   0     -17         -1000 udevd
> > [ 1639]     0  1639     2770      266   0     -17         -1000 udevd
> > [ 1640]     0  1640    25090      467   0       0             0 sshd
> > [ 1642]   500  1642    25090      384   0       0             0 sshd
> > [ 1643]   500  1643    27076      366   1       0             0 bash
> > [ 1659]   500  1659    36362      279   1       0             0 su
> > [ 1660]     0  1660    27107      424   1       0             0 bash
> > [ 1705]     0  1705     3757      329   0       0             0 top
> > Out of memory: Kill process 1289 (rsyslogd) score 1 or sacrifice child
> > Killed process 1289, UID 0, (rsyslogd) total-vm:255420kB,
> > anon-rss:580kB, file-rss:668kB
> > ---cut---
> >
> > If I use the CentOS6 kernel (2.6.32.x) on the NFS client too,
> > everything works fine.
> > No timeout, no oom killer and the load on the NFS server is all the
> > time below 1.
> >
> > Looks like 3.12.x can DoS NFS servers. ;-)
> Just gave 3.15-rc6 a try, it happens here too.
> 
> If it helps and the issue is not known I can try to find the exact release.

It's not a known issue, and finding out where the problem was introduced
could indeed by helpful.

I'm not sure how to interpret the statistics from the oom killer.  I'll
dig around.

Knowing where the nfsd threads are spinning might also be interesting.
"perf top" might give a quick idea?  Or maybe just "for p in $(pidof
nfsd); do echo $p; cat /proc/$p/stack; done"

--b.
