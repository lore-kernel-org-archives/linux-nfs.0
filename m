Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:39666
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752468Ab0HPGQz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Aug 2010 02:16:55 -0400
Date: Mon, 16 Aug 2010 08:16:44 +0200
From: Michael Guntsche <mike@it-loops.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Page alloc error on nfs4 via automount
Message-ID: <20100816061644.GA2401@gibson.comsick.at>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Good morning,

I hit this problem once again, the backtrace is completely the same.

The server in question is exporting the same filesystem (a
subdirectory) as nfs3 and a second client is using this with automount
too. I do not see any problems there, it is an older kernel version
though.

I get this backtrace on first access to the autofs directory. Subsequent
access works and the filesystem gets mounted ok.

[1033591.057007] mount.nfs4: page allocation failure. order:4, mode:0xc0d0
[1033591.064574] Call Trace:
[1033591.067584] [c3183c00] [c00082d4] show_stack+0x48/0x168 (unreliable)
[1033591.076962] [c3183c40] [c0062a28] __alloc_pages_nodemask+0x3d4/0x52c
[1033591.085536] [c3183ce0] [c0062ba0] __get_free_pages+0x20/0x50
[1033591.093511] [c3183cf0] [c9c82eb8] nfs_idmap_new+0x38/0xf4 [nfs]
[1033591.101687] [c3183d10] [c9c519b4] nfs4_set_client+0xe0/0x2f0 [nfs]
[1033591.111524] [c3183d60] [c9c521ec] nfs4_create_server+0xa8/0x31c [nfs]
[1033591.118803] [c3183db0] [c9c5c618] nfs4_remote_get_sb+0x6c/0x184 [nfs]
[1033591.125775] [c3183de0] [c008dc90] vfs_kern_mount+0x68/0x128
[1033591.132075] [c3183e00] [c9c5c988] nfs_do_root_mount+0x6c/0x90 [nfs]
[1033591.139059] [c3183e30] [c9c5cdbc] nfs4_try_mount+0x58/0xe4 [nfs]
[1033591.145566] [c3183e50] [c9c5cfe8] nfs4_get_sb+0x1a0/0x438 [nfs]
[1033591.152019] [c3183e80] [c008dc90] vfs_kern_mount+0x68/0x128
[1033591.158030] [c3183ea0] [c008dda0] do_kern_mount+0x40/0x100
[1033591.163821] [c3183ec0] [c00a7130] do_mount+0x184/0x79c
[1033591.169199] [c3183f10] [c00a77f8] sys_mount+0xb0/0xdc
[1033591.174487] [c3183f40] [c001130c] ret_from_syscall+0x0/0x38
[1033591.180455] --- Exception: c01 at 0xff5dd94
[1033591.180469]     LR = 0x1000af4c
[1033591.188524] Mem-Info:
[1033591.191240] DMA per-cpu:
[1033591.194342] CPU    0: hi:   42, btch:   7 usd:   0
[1033591.199848] active_anon:125 inactive_anon:2084 isolated_anon:0
[1033591.199864]  active_file:13430 inactive_file:8648 isolated_file:39
[1033591.199876]  unevictable:493 dirty:2 writeback:0 unstable:0
[1033591.199887]  free:2460 slab_reclaimable:798 slab_unreclaimable:2595
[1033591.199899]  mapped:1510 shmem:40 pagetables:201 bounce:0
[1033591.232165] DMA free:9840kB min:1440kB low:1800kB high:2160kB active_anon:500kB inactive_anon:8336kB active_file:53720kB inactive_file:34592kB unevictable:1972kB isolated(anon):0kB isolated(file):156kB present:130048kB mlocked:1972kB dirty:8kB writeback:0kB mapped:6040kB shmem:160kB slab_reclaimable:3192kB slab_unreclaimable:10380kB kernel_stack:584kB pagetables:804kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[1033591.273677] lowmem_reserve[]: 0 0 0
[1033591.277820] DMA: 998*4kB 469*8kB 13*16kB 57*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 9840kB
[1033591.289330] 22552 total pagecache pages
[1033591.293474] 0 pages in swap cache
[1033591.297054] Swap cache stats: add 0, delete 0, find 0/0
[1033591.302497] Free swap  = 0kB
[1033591.305571] Total swap = 0kB
[1033591.316097] 32768 pages RAM
[1033591.319299] 1234 pages reserved
[1033591.322687] 22622 pages shared
[1033591.326074] 11104 pages non-shared

Kind regards,
Michael Guntsche
