Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.18]:54703 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754804AbaEEIPS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2014 04:15:18 -0400
From: Marc Dietrich <marvin24@gmx.de>
To: linux-kernel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: nfs oom on 3.15
Date: Mon, 05 May 2014 10:15:14 +0200
Message-ID: <2562595.ix17LO7uqe@fb07-iapwap2>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

this is spaming my log quite a bit.

Any idea?

Marc

[252906.140962] CPU: 1 PID: 23621 Comm: firefox Tainted: G           O  3.15.0-rc3-12.gfc9498b-desktop+ #6
[252906.140963] Hardware name: System manufacturer System Product Name/M4A785TD-V EVO, BIOS 2105    07/23/2010
[252906.140965]  0000000000000000 ffff880105c67938 ffffffff815e693c 0000000000204000
[252906.140967]  ffff880105c679c0 ffffffff81137bd2 0000000000000000 0000001000000000
[252906.140968]  ffff88011ffebc38 0000000000000001 0000000000204000 ffff88011ffea000
[252906.140970] Call Trace:
[252906.140975]  [<ffffffff815e693c>] dump_stack+0x4d/0x6f
[252906.140977]  [<ffffffff81137bd2>] warn_alloc_failed+0xd2/0x140
[252906.140979]  [<ffffffff8113be19>] __alloc_pages_nodemask+0x7e9/0xa30
[252906.140981]  [<ffffffff8113be19>] ? __alloc_pages_nodemask+0x7e9/0xa30
[252906.140983]  [<ffffffff811824a8>] kmem_getpages+0x58/0x140
[252906.140985]  [<ffffffff81183de6>] fallback_alloc+0x1d6/0x210
[252906.140986]  [<ffffffff81183be3>] ____cache_alloc_node+0x123/0x150
[252906.140988]  [<ffffffff81185953>] __kmalloc+0x203/0x490
[252906.141004]  [<ffffffffa06b0ee2>] ? rpc_malloc+0x32/0xa0 [sunrpc]
[252906.141009]  [<ffffffffa06b0ee2>] rpc_malloc+0x32/0xa0 [sunrpc]
[252906.141014]  [<ffffffffa06a6999>] call_allocate+0xb9/0x170 [sunrpc]
[252906.141018]  [<ffffffffa06a68e0>] ? call_reserveresult+0x120/0x120 [sunrpc]
[252906.141022]  [<ffffffffa06a68e0>] ? call_reserveresult+0x120/0x120 [sunrpc]
[252906.141027]  [<ffffffffa06b19d8>] __rpc_execute+0x88/0x460 [sunrpc]
[252906.141033]  [<ffffffffa06b2da9>] rpc_execute+0x59/0xc0 [sunrpc]
[252906.141037]  [<ffffffffa06a932b>] rpc_run_task+0x6b/0x90 [sunrpc]
[252906.141048]  [<ffffffffa077b5c1>] nfs4_call_sync_sequence+0x51/0x80 [nfsv4]
[252906.141053]  [<ffffffffa078109b>] nfs4_do_create+0x4b/0x90 [nfsv4]
[252906.141058]  [<ffffffffa0784cdb>] nfs4_proc_symlink+0x10b/0x210 [nfsv4]
[252906.141067]  [<ffffffffa0743a30>] nfs_symlink+0x100/0x300 [nfs]
[252906.141070]  [<ffffffff8128f107>] ? security_inode_permission+0x17/0x20
[252906.141073]  [<ffffffff811a9e9c>] ? __inode_permission+0x4c/0xc0
[252906.141074]  [<ffffffff811ad380>] vfs_symlink+0xa0/0x120
[252906.141076]  [<ffffffff811afdeb>] SyS_symlink+0xab/0xe0
[252906.141078]  [<ffffffff815f4cfd>] system_call_fastpath+0x1a/0x1f
[252906.141078] Mem-Info:
[252906.141079] Node 0 DMA per-cpu:
[252906.141081] CPU    0: hi:    0, btch:   1 usd:   0
[252906.141082] CPU    1: hi:    0, btch:   1 usd:   0
[252906.141082] CPU    2: hi:    0, btch:   1 usd:   0
[252906.141083] CPU    3: hi:    0, btch:   1 usd:   0
[252906.141084] Node 0 DMA32 per-cpu:
[252906.141085] CPU    0: hi:  186, btch:  31 usd: 177
[252906.141086] CPU    1: hi:  186, btch:  31 usd:  46
[252906.141087] CPU    2: hi:  186, btch:  31 usd:  49
[252906.141088] CPU    3: hi:  186, btch:  31 usd: 183
[252906.141088] Node 0 Normal per-cpu:
[252906.141089] CPU    0: hi:  186, btch:  31 usd: 165
[252906.141090] CPU    1: hi:  186, btch:  31 usd: 159
[252906.141091] CPU    2: hi:  186, btch:  31 usd:  53
[252906.141091] CPU    3: hi:  186, btch:  31 usd: 169
[252906.141094] active_anon:98161 inactive_anon:138888 isolated_anon:0
 active_file:304538 inactive_file:306318 isolated_file:0
 unevictable:0 dirty:1294 writeback:0 unstable:233
 free:29806 slab_reclaimable:90163 slab_unreclaimable:14165
 mapped:50081 shmem:9437 pagetables:10020 bounce:0
 free_cma:0
[252906.141096] Node 0 DMA free:15036kB min:264kB low:328kB high:396kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[252906.141099] lowmem_reserve[]: 0 3488 3941 3941
[252906.141100] Node 0 DMA32 free:89144kB min:59580kB low:74472kB high:89368kB active_anon:339164kB inactive_anon:471268kB active_file:1121148kB inactive_file:1114728kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3652160kB managed:3575212kB mlocked:0kB dirty:4796kB writeback:0kB mapped:177500kB shmem:28324kB slab_reclaimable:313600kB slab_unreclaimable:46176kB kernel_stack:2808kB pagetables:35312kB unstable:932kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:2 all_unreclaimable? no
[252906.141103] lowmem_reserve[]: 0 0 452 452
[252906.141104] Node 0 Normal free:15044kB min:7732kB low:9664kB high:11596kB active_anon:53480kB inactive_anon:84284kB active_file:97004kB inactive_file:110544kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:463788kB mlocked:0kB dirty:380kB writeback:0kB mapped:22824kB shmem:9424kB slab_reclaimable:47052kB slab_unreclaimable:10484kB kernel_stack:984kB pagetables:4768kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[252906.141107] lowmem_reserve[]: 0 0 0 0
[252906.141108] Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 1*32kB (U) 0*64kB 1*128kB (U) 0*256kB 1*512kB (U) 0*1024kB 1*2048kB (R) 3*4096kB (M) = 15036kB
[252906.141114] Node 0 DMA32: 17155*4kB (UEM) 2312*8kB (UEM) 25*16kB (UM) 7*32kB (M) 5*64kB (EM) 3*128kB (M) 2*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 88956kB
[252906.141120] Node 0 Normal: 3346*4kB (UE) 240*8kB (UEM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15304kB
[252906.141124] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[252906.141125] 621133 total pagecache pages
[252906.141126] 730 pages in swap cache
[252906.141127] Swap cache stats: add 21157, delete 20427, find 7261/8241
[252906.141128] Free swap  = 4153964kB
[252906.141128] Total swap = 4192928kB
[252906.141129] 1048110 pages RAM
[252906.141130] 0 pages HighMem/MovableOnly
[252906.141130] 15125 pages reserved
[252906.141131] 0 pages hwpoisoned
[252906.141132] SLAB: Unable to allocate memory on node 0 (gfp=0x4000)
[252906.141133]   cache: kmalloc-8192, object size: 8192, order: 1
[252906.141145]   node 0: slabs: 207/207, objs: 207/207, free: 0
[252913.260693] rekonq: page allocation failure: order:1, mode:0x204000
[252913.260706] CPU: 2 PID: 14321 Comm: rekonq Tainted: G           O  3.15.0-rc3-12.gfc9498b-desktop+ #6
[252913.260711] Hardware name: System manufacturer System Product Name/M4A785TD-V EVO, BIOS 2105    07/23/2010
[252913.260715]  0000000000000000 ffff880010ff17d0 ffffffff815e693c 0000000000204000
[252913.260723]  ffff880010ff1858 ffffffff81137bd2 0000000000000000 0000001000000000
[252913.260729]  ffff88011ffebc38 0000000000000001 0000000000204000 ffff88011ffea000
[252913.260735] Call Trace:
[252913.260748]  [<ffffffff815e693c>] dump_stack+0x4d/0x6f
[252913.260757]  [<ffffffff81137bd2>] warn_alloc_failed+0xd2/0x140
[252913.260765]  [<ffffffff8113be19>] __alloc_pages_nodemask+0x7e9/0xa30
[252913.260771]  [<ffffffff8113be19>] ? __alloc_pages_nodemask+0x7e9/0xa30
[252913.260780]  [<ffffffff811824a8>] kmem_getpages+0x58/0x140
[252913.260786]  [<ffffffff81183de6>] fallback_alloc+0x1d6/0x210
[252913.260793]  [<ffffffff81183be3>] ____cache_alloc_node+0x123/0x150
[252913.260800]  [<ffffffff81185953>] __kmalloc+0x203/0x490
[252913.260835]  [<ffffffffa06b0ee2>] ? rpc_malloc+0x32/0xa0 [sunrpc]
[252913.260860]  [<ffffffffa06b0ee2>] rpc_malloc+0x32/0xa0 [sunrpc]
[252913.260880]  [<ffffffffa06a6999>] call_allocate+0xb9/0x170 [sunrpc]
[252913.260900]  [<ffffffffa06a68e0>] ? call_reserveresult+0x120/0x120 [sunrpc]
[252913.260919]  [<ffffffffa06a68e0>] ? call_reserveresult+0x120/0x120 [sunrpc]
[252913.260941]  [<ffffffffa06b19d8>] __rpc_execute+0x88/0x460 [sunrpc]
[252913.260965]  [<ffffffffa06b2da9>] rpc_execute+0x59/0xc0 [sunrpc]
[252913.260985]  [<ffffffffa06a932b>] rpc_run_task+0x6b/0x90 [sunrpc]
[252913.261008]  [<ffffffffa077b5c1>] nfs4_call_sync_sequence+0x51/0x80 [nfsv4]
[252913.261028]  [<ffffffffa077d45d>] _nfs4_do_setattr+0x1ed/0x280 [nfsv4]
[252913.261056]  [<ffffffffa07567bc>] ? nfs_commit_inode+0x7c/0x140 [nfs]
[252913.261078]  [<ffffffffa0782a72>] nfs4_do_setattr+0x72/0x180 [nfsv4]
[252913.261098]  [<ffffffffa078334c>] nfs4_proc_setattr+0xbc/0x140 [nfsv4]
[252913.261118]  [<ffffffffa074a7e8>] nfs_setattr+0xd8/0x240 [nfs]
[252913.261125]  [<ffffffff811baa71>] notify_change+0x231/0x380
[252913.261132]  [<ffffffff8119cf5c>] chmod_common+0xfc/0x120
[252913.261138]  [<ffffffff8119df80>] SyS_chmod+0x40/0x90
[252913.261145]  [<ffffffff815f4cfd>] system_call_fastpath+0x1a/0x1f
[252913.261148] Mem-Info:
[252913.261151] Node 0 DMA per-cpu:
[252913.261156] CPU    0: hi:    0, btch:   1 usd:   0
[252913.261160] CPU    1: hi:    0, btch:   1 usd:   0
[252913.261163] CPU    2: hi:    0, btch:   1 usd:   0
[252913.261167] CPU    3: hi:    0, btch:   1 usd:   0
[252913.261170] Node 0 DMA32 per-cpu:
[252913.261174] CPU    0: hi:  186, btch:  31 usd: 161
[252913.261178] CPU    1: hi:  186, btch:  31 usd:  40
[252913.261182] CPU    2: hi:  186, btch:  31 usd:  77
[252913.261186] CPU    3: hi:  186, btch:  31 usd: 181
[252913.261188] Node 0 Normal per-cpu:
[252913.261192] CPU    0: hi:  186, btch:  31 usd: 110
[252913.261196] CPU    1: hi:  186, btch:  31 usd:  72
[252913.261199] CPU    2: hi:  186, btch:  31 usd:  62
[252913.261203] CPU    3: hi:  186, btch:  31 usd: 172
[252913.261212] active_anon:120204 inactive_anon:138014 isolated_anon:0
 active_file:292381 inactive_file:291905 isolated_file:0
 unevictable:0 dirty:5117 writeback:0 unstable:311
 free:34228 slab_reclaimable:91243 slab_unreclaimable:14349
 mapped:55118 shmem:9485 pagetables:10127 bounce:0
 free_cma:0
[252913.261221] Node 0 DMA free:15036kB min:264kB low:328kB high:396kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[252913.261233] lowmem_reserve[]: 0 3488 3941 3941
[252913.261240] Node 0 DMA32 free:110648kB min:59580kB low:74472kB high:89368kB active_anon:406532kB inactive_anon:467592kB active_file:1074512kB inactive_file:1073100kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3652160kB managed:3575212kB mlocked:0kB dirty:18216kB writeback:0kB mapped:192080kB shmem:28328kB slab_reclaimable:316968kB slab_unreclaimable:46588kB kernel_stack:2856kB pagetables:35624kB unstable:1244kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:31 all_unreclaimable? no
[252913.261253] lowmem_reserve[]: 0 0 452 452
[252913.261259] Node 0 Normal free:11228kB min:7732kB low:9664kB high:11596kB active_anon:74284kB inactive_anon:84464kB active_file:95012kB inactive_file:94520kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:524288kB managed:463788kB mlocked:0kB dirty:2252kB writeback:0kB mapped:28392kB shmem:9612kB slab_reclaimable:48004kB slab_unreclaimable:10808kB kernel_stack:1024kB pagetables:4884kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:8 all_unreclaimable? no
[252913.261270] lowmem_reserve[]: 0 0 0 0
[252913.261276] Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 1*32kB (U) 0*64kB 1*128kB (U) 0*256kB 1*512kB (U) 0*1024kB 1*2048kB (R) 3*4096kB (M) = 15036kB
[252913.261300] Node 0 DMA32: 25984*4kB (UEM) 580*8kB (UEM) 103*16kB (UEM) 13*32kB (UEM) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 110640kB
[252913.261319] Node 0 Normal: 2218*4kB (UEM) 127*8kB (UEM) 39*16kB (U) 13*32kB (UM) 3*64kB (UM) 1*128kB (M) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 11248kB
[252913.261342] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[252913.261345] 594527 total pagecache pages
[252913.261349] 732 pages in swap cache
[252913.261353] Swap cache stats: add 21451, delete 20719, find 7261/8243
[252913.261356] Free swap  = 4152796kB
[252913.261358] Total swap = 4192928kB
[252913.261361] 1048110 pages RAM
[252913.261364] 0 pages HighMem/MovableOnly
[252913.261366] 15125 pages reserved
[252913.261366] 0 pages hwpoisoned
[252913.261366] SLAB: Unable to allocate memory on node 0 (gfp=0x4000)
[252913.261366]   cache: kmalloc-8192, object size: 8192, order: 1
[252913.261366]   node 0: slabs: 208/208, objs: 208/208, free: 0


