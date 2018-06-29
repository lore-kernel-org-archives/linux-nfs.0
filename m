Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:59462 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751114AbeF2KsU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 29 Jun 2018 06:48:20 -0400
From: Punit Agrawal <punit.agrawal@arm.com>
To: linux-nfs@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: anna.schumaker@netapp.com, trond.myklebust@hammerspace.com,
        linux-kernel@vger.kernel.org
Subject: use-after-free in NFS
Date: Fri, 29 Jun 2018 11:48:18 +0100
Message-ID: <87lgaxvpfx.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Nightly LTP runs are hitting a use-after-free on upstream kernels when
running with 64k pages. There isn't a specific test triggering the
issue. Also, the problem is not encountered with 4k pages.

The boards used for the nightly runs mount their filesystem (Debian
Jessie) via NFS with the following filesystem relevant command line
options -

    "root=/dev/nfs rw nfsroot=<server IP>:<export path>,tcp,hard,intr,vers=3 rootwait"

I suspect that the larger page size is uncovering a latent race but I'm
not familiar with NFS client implementation and so could be barking up
the wrong tree. Frustratingly I've not been able to reproduce it locally
to create a reproducer.

Thanks,
Punit

---- >8 ----

[ 4116.235125] LTP: starting data_space
[ 4116.497897] ------------[ cut here ]------------
[ 4116.511558] refcount_t: increment on 0; use-after-free.
[ 4116.522421] WARNING: CPU: 4 PID: 11116 at lib/refcount.c:153 refcount_inc+0x44/0x50
[ 4116.537845] Modules linked in: overlay btrfs libcrc32c xor zstd_decompress zstd_compress xxhash raid6_pq fuse crc32_ce crct10dif_ce ipv6
[ 4116.562596] CPU: 4 PID: 11116 Comm: kworker/4:0 Not tainted 4.18.0-rc2-00119-g59ec39fe3826 #1
[ 4116.579770] Hardware name: ARM LTD ARM Juno Development Platform/ARM Juno Development Platform, BIOS EDK II Feb 13 2018
[ 4116.601505] Workqueue: nfsiod rpc_async_release
[ 4116.610627] pstate: 40000005 (nZcv daif -PAN -UAO)
[ 4116.620273] pc : refcount_inc+0x44/0x50
[ 4116.627989] lr : refcount_inc+0x44/0x50
[ 4116.635705] sp : ffff00000a7efba0
[ 4116.642369] x29: ffff00000a7efba0 x28: 0000000000000000 
[ 4116.653068] x27: 000000007fffffff x26: ffff00000a7efca0 
[ 4116.663767] x25: 0000000000000008 x24: ffff80092054d6a0 
[ 4116.674465] x23: ffff800942ba7140 x22: ffff00000a7efc90 
[ 4116.685162] x21: ffff800942ba7100 x20: ffff800942ba7b00 
[ 4116.695861] x19: ffff800942ba7100 x18: 0000000000000011 
[ 4116.706557] x17: 0000000000000000 x16: 0000000000000000 
[ 4116.717256] x15: 0000000000000000 x14: 0000000000000400 
[ 4116.727953] x13: 0000000000000001 x12: 0000000000000000 
[ 4116.738650] x11: 00000000000048ca x10: 0000000000000930 
[ 4116.749347] x9 : ffff00000a7ef8a0 x8 : ffff8009416f0990 
[ 4116.760046] x7 : ffff8009416f00c0 x6 : ffff80097fba20c0 
[ 4116.770742] x5 : ffff80097fba20c0 x4 : 0000000000000000 
[ 4116.781439] x3 : ffff80097fba8ea8 x2 : ffff8009416f0000 
[ 4116.792137] x1 : 2e35a06ccfe9d400 x0 : 0000000000000000 
[ 4116.802834] Call trace:
[ 4116.807750]  refcount_inc+0x44/0x50
[ 4116.814770]  nfs_scan_commit_list+0x84/0x128
[ 4116.823362]  nfs_scan_commit.part.12+0x4c/0xe0
[ 4116.832305]  __nfs_commit_inode+0x100/0x190
[ 4116.840722]  nfs_io_completion_commit+0x14/0x20
[ 4116.849838]  nfs_io_completion_put+0x38/0x58
[ 4116.858430]  nfs_write_completion+0x108/0x1a0
[ 4116.867199]  nfs_pgio_release+0x14/0x20
[ 4116.874916]  rpc_free_task+0x28/0x48
[ 4116.882108]  rpc_async_release+0x10/0x18
[ 4116.890002]  process_one_work+0x1dc/0x330
[ 4116.898068]  worker_thread+0x48/0x430
[ 4116.905433]  kthread+0xf8/0x128
[ 4116.911750]  ret_from_fork+0x10/0x18
[ 4116.918939] ---[ end trace 9745b48d60ab22f6 ]---
[ 4116.931729] WARNING: CPU: 4 PID: 11116 at fs/nfs/pagelist.c:426 nfs_free_request+0x150/0x160
[ 4116.948730] Modules linked in: overlay btrfs libcrc32c xor zstd_decompress zstd_compress xxhash raid6_pq fuse crc32_ce crct10dif_ce ipv6
[ 4116.973478] CPU: 4 PID: 11116 Comm: kworker/4:0 Tainted: G        W         4.18.0-rc2-00119-g59ec39fe3826 #1
[ 4116.993452] Hardware name: ARM LTD ARM Juno Development Platform/ARM Juno Development Platform, BIOS EDK II Feb 13 2018
[ 4117.015185] Workqueue: nfsiod rpc_async_release
[ 4117.024306] pstate: 60000005 (nZCv daif -PAN -UAO)
[ 4117.033951] pc : nfs_free_request+0x150/0x160
[ 4117.042718] lr : nfs_release_request+0x84/0x98
[ 4117.051657] sp : ffff00000a7efc40
[ 4117.058321] x29: ffff00000a7efc40 x28: 0000000000000000 
[ 4117.069021] x27: ffff80097fbac330 x26: ffff0000091280f8 
[ 4117.079720] x25: 0000000000000000 x24: ffff000009113000 
[ 4117.090419] x23: ffff8009432338c8 x22: ffff8009432338d8 
[ 4117.101119] x21: ffff800942bce480 x20: ffff800942ba4b80 
[ 4117.111817] x19: ffff800942bce480 x18: 0000000000000000 
[ 4117.122514] x17: 0000000000000000 x16: 0000000000000001 
[ 4117.133211] x15: 0000000000000000 x14: 0000000000000400 
[ 4117.143908] x13: 0000000000000001 x12: ffffffffffffffff 
[ 4117.154604] x11: 0000000000000040 x10: 0000000000000930 
[ 4117.165302] x9 : ffff00000a7efd50 x8 : 0000000000000000 
[ 4117.175999] x7 : ffffffffffffffff x6 : 0000000000000001 
[ 4117.186695] x5 : 0000000000000000 x4 : ffff0000091136c8 
[ 4117.197392] x3 : ffff000009111388 x2 : 0000000000000005 
[ 4117.208088] x1 : ffff800942bce480 x0 : 0000000000000c02 
[ 4117.218784] Call trace:
[ 4117.223700]  nfs_free_request+0x150/0x160
[ 4117.231766]  nfs_release_request+0x84/0x98
[ 4117.240009]  nfs_release_request+0x60/0x98
[ 4117.248252]  nfs_unlock_and_release_request+0x1c/0x28
[ 4117.258420]  nfs_commit_release_pages+0xa4/0x1b8
[ 4117.267711]  nfs_commit_release+0x1c/0x30
[ 4117.275778]  rpc_free_task+0x28/0x48
[ 4117.282968]  rpc_async_release+0x10/0x18
[ 4117.290860]  process_one_work+0x1dc/0x330
[ 4117.298926]  worker_thread+0x48/0x430
[ 4117.306290]  kthread+0xf8/0x128
[ 4117.312606]  ret_from_fork+0x10/0x18
[ 4117.319795] ---[ end trace 9745b48d60ab22f7 ]---
[ 4117.329432] ------------[ cut here ]------------
[ 4117.338741] refcount_t: underflow; use-after-free.
[ 4117.348423] WARNING: CPU: 4 PID: 11116 at lib/refcount.c:187 refcount_sub_and_test+0x94/0xb8
[ 4117.365418] Modules linked in: overlay btrfs libcrc32c xor zstd_decompress zstd_compress xxhash raid6_pq fuse crc32_ce crct10dif_ce ipv6
[ 4117.390160] CPU: 4 PID: 11116 Comm: kworker/4:0 Tainted: G        W         4.18.0-rc2-00119-g59ec39fe3826 #1
[ 4117.410133] Hardware name: ARM LTD ARM Juno Development Platform/ARM Juno Development Platform, BIOS EDK II Feb 13 2018
[ 4117.431861] Workqueue: nfsiod rpc_async_release
[ 4117.440982] pstate: 40000005 (nZcv daif -PAN -UAO)
[ 4117.450625] pc : refcount_sub_and_test+0x94/0xb8
[ 4117.459918] lr : refcount_sub_and_test+0x94/0xb8
[ 4117.469207] sp : ffff00000a7efc80
[ 4117.475870] x29: ffff00000a7efc80 x28: 0000000000000000 
[ 4117.486567] x27: ffff80097fbac330 x26: ffff0000091280f8 
[ 4117.497263] x25: 0000000000000000 x24: ffff000009113000 
[ 4117.507960] x23: ffff8009432338c8 x22: ffff8009432338d8 
[ 4117.518655] x21: 0000000000000000 x20: ffff800943233700 
[ 4117.529352] x19: ffff800942ba7100 x18: ffffffffffffffff 
[ 4117.540048] x17: 0000000000000000 x16: 0000000000000000 
[ 4117.550744] x15: ffff0000091136c8 x14: ffff0000892976c7 
[ 4117.561441] x13: ffff0000092976d5 x12: ffff00000912b260 
[ 4117.572137] x11: ffff00000912b000 x10: 0000000005f5e0ff 
[ 4117.582834] x9 : ffff0000085b09a0 x8 : 6572662d72657466 
[ 4117.593530] x7 : 612d657375203b77 x6 : ffff80097fba20c0 
[ 4117.604225] x5 : ffff80097fba20c0 x4 : 0000000000000000 
[ 4117.614922] x3 : ffff80097fba8ea8 x2 : ffff8009416f0000 
[ 4117.625619] x1 : 2e35a06ccfe9d400 x0 : 0000000000000000 
[ 4117.636315] Call trace:
[ 4117.641229]  refcount_sub_and_test+0x94/0xb8
[ 4117.649820]  refcount_dec_and_test+0x14/0x20
[ 4117.658413]  nfs_release_request+0x1c/0x98
[ 4117.666656]  nfs_unlock_and_release_request+0x1c/0x28
[ 4117.676824]  nfs_commit_release_pages+0xa4/0x1b8
[ 4117.686116]  nfs_commit_release+0x1c/0x30
[ 4117.694181]  rpc_free_task+0x28/0x48
[ 4117.701372]  rpc_async_release+0x10/0x18
[ 4117.709262]  process_one_work+0x1dc/0x330
[ 4117.717330]  worker_thread+0x48/0x430
[ 4117.724695]  kthread+0xf8/0x128
[ 4117.731010]  ret_from_fork+0x10/0x18
[ 4117.738198] ---[ end trace 9745b48d60ab22f8 ]---
[ 4117.747517] NFS: Invalid unlock attempted
[ 4117.755609] ------------[ cut here ]------------
[ 4117.764899] kernel BUG at fs/nfs/pagelist.c:359!
[ 4117.774190] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
[ 4117.785232] Modules linked in: overlay btrfs libcrc32c xor zstd_decompress zstd_compress xxhash raid6_pq fuse crc32_ce crct10dif_ce ipv6
[ 4117.809973] CPU: 4 PID: 11116 Comm: kworker/4:0 Tainted: G        W         4.18.0-rc2-00119-g59ec39fe3826 #1
[ 4117.829946] Hardware name: ARM LTD ARM Juno Development Platform/ARM Juno Development Platform, BIOS EDK II Feb 13 2018
[ 4117.851675] Workqueue: nfsiod rpc_async_release
[ 4117.860795] pstate: 40000005 (nZcv daif -PAN -UAO)
[ 4117.870440] pc : nfs_unlock_request+0x5c/0x60
[ 4117.879207] lr : nfs_unlock_request+0x5c/0x60
[ 4117.887970] sp : ffff00000a7efcb0
[ 4117.894633] x29: ffff00000a7efcb0 x28: 0000000000000000 
[ 4117.905330] x27: ffff80097fbac330 x26: ffff0000091280f8 
[ 4117.916027] x25: 0000000000000000 x24: ffff000009113000 
[ 4117.926724] x23: ffff8009432338c8 x22: ffff8009432338d8 
[ 4117.937421] x21: 0000000000000000 x20: ffff800943233700 
[ 4117.948117] x19: ffff800942ba1780 x18: ffffffffffffffff 
[ 4117.958814] x17: 0000000000000000 x16: 0000000000000000 
[ 4117.969512] x15: ffff0000091136c8 x14: ffff0000892976c7 
[ 4117.980208] x13: ffff0000092976d5 x12: ffff00000912b260 
[ 4117.990905] x11: ffff00000912b000 x10: 0000000005f5e0ff 
[ 4118.001602] x9 : ffff0000085b09a0 x8 : 206b636f6c6e7520 
[ 4118.012299] x7 : 64696c61766e4920 x6 : ffff80097fba20c0 
[ 4118.022996] x5 : ffff80097fba20c0 x4 : 0000000000000000 
[ 4118.033693] x3 : ffff80097fba8ea8 x2 : 2e35a06ccfe9d400 
[ 4118.044389] x1 : 0000000000000000 x0 : 000000000000001d 
[ 4118.055088] Process kworker/4:0 (pid: 11116, stack limit = 0x00000000049b7686)
[ 4118.069631] Call trace:
[ 4118.074546]  nfs_unlock_request+0x5c/0x60
[ 4118.082613]  nfs_unlock_and_release_request+0x14/0x28
[ 4118.092781]  nfs_commit_release_pages+0xa4/0x1b8
[ 4118.102071]  nfs_commit_release+0x1c/0x30
[ 4118.110136]  rpc_free_task+0x28/0x48
[ 4118.117326]  rpc_async_release+0x10/0x18
[ 4118.125218]  process_one_work+0x1dc/0x330
[ 4118.133284]  worker_thread+0x48/0x430
[ 4118.140649]  kthread+0xf8/0x128
[ 4118.146963]  ret_from_fork+0x10/0x18
[ 4118.154155] Code: d65f03c0 d0005920 912c4000 97f8103d (d4210000) 
[ 4118.166424] ---[ end trace 9745b48d60ab22f9 ]---
