From: Andrew Morton <akpm@linux-foundation.org>
Subject: nfsd stuckage
Date: Tue, 6 Jan 2009 14:56:12 -0800
Message-ID: <20090106145612.d4d9948d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46590 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751017AbZAFW5L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 17:57:11 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I just built current mainline plus the just-sent 266 -mm patches.

The machine failed to power off when hit with `halt -pfn'.  dmesg output:

[   37.087037] calling  rfcomm_init+0x0/0xb6 [rfcomm] @ 3946
[   37.087294] initcall rfcomm_init+0x0/0xb6 [rfcomm] returned 0 after 72 usecs
[   37.505855] calling  hidp_init+0x0/0x5e [hidp] @ 4046
[   37.506072] initcall hidp_init+0x0/0x5e [hidp] returned 0 after 28 usecs
[   37.636638] calling  init_autofs4_fs+0x0/0x23 [autofs4] @ 4081
[   37.636990] initcall init_autofs4_fs+0x0/0x23 [autofs4] returned 0 after 54 usecs
[   39.630075] calling  init_nlm+0x0/0x22 [lockd] @ 4264
[   39.630321] initcall init_nlm+0x0/0x22 [lockd] returned 0 after 59 usecs
[   39.690077] calling  init_rpcsec_gss+0x0/0x4a [auth_rpcgss] @ 4264
[   39.690281] initcall init_rpcsec_gss+0x0/0x4a [auth_rpcgss] returned 0 after 12 usecs
[   39.834034] calling  init_nfsd+0x0/0xe2 [nfsd] @ 4302
[   39.834471] initcall init_nfsd+0x0/0xe2 [nfsd] returned 0 after 236 usecs
[   39.924213] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[  672.162677] INFO: task nfsd4:4324 blocked for more than 480 seconds.
[  672.162706] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  672.162725]  ffff880251df1d60 0000000000000046 ffff88025e1c0580 ffff8802488013d8
[  672.162753]  ffff880251df1d20 ffff88024c49a7a0 ffff88025e088760 ffff88024c49ab18
[  672.162834]  000000002807ee00 00000000ffff59ec ffff880251df1d50 0000000000000282
[  672.162865] Call Trace:
[  672.162880]  [<ffffffff8052a1d8>] __mutex_lock_slowpath+0x6a/0xac
[  672.162895]  [<ffffffff8052a0c5>] mutex_lock+0x2c/0x30
[  672.162908]  [<ffffffff802c4747>] vfs_fsync+0x63/0xa9
[  672.162933]  [<ffffffffa048c74c>] nfsd_sync_dir+0x10/0x12 [nfsd]
[  672.162960]  [<ffffffffa04a5427>] nfsd4_sync_rec_dir+0x27/0x40 [nfsd]
[  672.162984]  [<ffffffffa04a592a>] nfsd4_recdir_purge_old+0x3d/0x6a [nfsd]
[  672.163023]  [<ffffffffa04a1745>] laundromat_main+0x62/0x225 [nfsd]
[  672.163049]  [<ffffffffa04a16e3>] ? laundromat_main+0x0/0x225 [nfsd]
[  672.163064]  [<ffffffff8024b4a7>] run_workqueue+0x8d/0x124
[  672.163076]  [<ffffffff8024b5e0>] ? worker_thread+0x0/0xe5
[  672.163089]  [<ffffffff8024b6b8>] worker_thread+0xd8/0xe5
[  672.163102]  [<ffffffff8024e8cc>] ? autoremove_wake_function+0x0/0x36
[  672.163115]  [<ffffffff8024b5e0>] ? worker_thread+0x0/0xe5
[  672.163127]  [<ffffffff8024e5e0>] kthread+0x44/0x6b
[  672.163140]  [<ffffffff8020cfba>] child_rip+0xa/0x20
[  672.163151]  [<ffffffff8024e59c>] ? kthread+0x0/0x6b
[  672.163162]  [<ffffffff8020cfb0>] ? child_rip+0x0/0x20
[ 1204.739381] INFO: task nfsd4:4324 blocked for more than 480 seconds.
[ 1204.739415] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1204.739436]  ffff880251df1d60 0000000000000046 ffff88025e1c0580 ffff8802488013d8
[ 1204.739523]  ffff880251df1d20 ffff88024c49a7a0 ffff88025e088760 ffff88024c49ab18
[ 1204.739551]  000000002807ee00 00000000ffff59ec ffff880251df1d50 0000000000000282
[ 1204.739579] Call Trace:

This didn't happen in linux-next a week or so ago.
