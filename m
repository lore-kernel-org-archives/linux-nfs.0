From: Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Subject: Page alloc error on nfs4 via automount
Date: Tue, 10 Aug 2010 07:37:37 +0200
Message-ID: <20100810053736.GA10142@gibson.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:33482
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751990Ab0HJFhr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Aug 2010 01:37:47 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good morning list,

After sorting out my Kerberos problem I noticed another problem on my
setup here when mounting a NFS4 export with automount.

Both, client and server, are running 2.6.35 and debian SID. sec is set
to sys. The timeframe varies but after not being mounted for some time,
upon first access I see

[512416.780875] mount.nfs4: page allocation failure. order:4,
mode:0xc0d0
[512416.788166] Call Trace:
[512416.790900] [c32e3c00] [c00082d4] show_stack+0x48/0x168 (unreliable)
[512416.798440] [c32e3c40] [c0062a28] __alloc_pages_nodemask+0x3d4/0x52c
[512416.806468] [c32e3ce0] [c0062ba0] __get_free_pages+0x20/0x50
[512416.813106] [c32e3cf0] [c9c82eb8] nfs_idmap_new+0x38/0xf4 [nfs]
[512416.820290] [c32e3d10] [c9c519b4] nfs4_set_client+0xe0/0x2f0 [nfs]
[512416.828388] [c32e3d60] [c9c521ec] nfs4_create_server+0xa8/0x31c
[nfs]
[512416.835842] [c32e3db0] [c9c5c618] nfs4_remote_get_sb+0x6c/0x184
[nfs]
[512416.843145] [c32e3de0] [c008dc90] vfs_kern_mount+0x68/0x128
[512416.849909] [c32e3e00] [c9c5c988] nfs_do_root_mount+0x6c/0x90 [nfs]
[512416.857047] [c32e3e30] [c9c5cdbc] nfs4_try_mount+0x58/0xe4 [nfs]
[512416.863825] [c32e3e50] [c9c5cfe8] nfs4_get_sb+0x1a0/0x438 [nfs]
[512416.869942] [c32e3e80] [c008dc90] vfs_kern_mount+0x68/0x128
[512416.875751] [c32e3ea0] [c008dda0] do_kern_mount+0x40/0x100
[512416.881402] [c32e3ec0] [c00a7130] do_mount+0x184/0x79c
[512416.886674] [c32e3f10] [c00a77f8] sys_mount+0xb0/0xdc
[512416.891884] [c32e3f40] [c001130c] ret_from_syscall+0x0/0x38
[512416.897634] --- Exception: c01 at 0xff5dd94
[512416.897645]     LR = 0x1000af4c
[512416.905323] Mem-Info:
[512416.907703] DMA per-cpu:
[512416.910384] CPU    0: hi:   42, btch:   7 usd:   0
[512416.915318] active_anon:479 inactive_anon:1888 isolated_anon:0
[512416.915329]  active_file:16867 inactive_file:5620 isolated_file:43
[512416.915341]  unevictable:493 dirty:16 writeback:0 unstable:0
[512416.915352]  free:2208 slab_reclaimable:742 slab_unreclaimable:2324
[512416.915364]  mapped:1683 shmem:40 pagetables:216 bounce:0
[512416.945259] DMA free:8832kB min:1440kB low:1800kB high:2160kB
active_anon:1916kB inactive_anon:7552kB active_file:67468kB
inactive_file:22480kB unevictable:1972kB isolated(anon):0kB
isolated(file):172kB present:130048kB mlocked:1972kB dirty:64kB
writeback:0kB mapped:6732kB shmem:160kB slab_reclaimable:2968kB
slab_unreclaimable:9296kB kernel_stack:608kB pagetables:864kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
[512416.985146] lowmem_reserve[]: 0 0 0
[512416.988783] DMA: 1964*4kB 92*8kB 3*16kB 4*32kB 1*64kB 0*128kB
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 8832kB
[512416.999289] 22954 total pagecache pages
[512417.003266] 0 pages in swap cache
[512417.006732] Swap cache stats: add 0, delete 0, find 0/0
[512417.012856] Free swap  = 0kB
[512417.016362] Total swap = 0kB
[512417.027596] 32768 pages RAM
[512417.031153] 1234 pages reserved
[512417.034933] 23334 pages shared
[512417.038613] 11052 pages non-shared

on the client. The filesystem is obviously not mounted then. A second
try succeeds on the other hand.

Since I just recently started using this nfs mounts on the client I
cannot say if this is a .35 only problem or was already happening with
older kernels.

Kind regards,
Michael Guntsche
