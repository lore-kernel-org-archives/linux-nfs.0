Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:22561 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735Ab3JKOTt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Oct 2013 10:19:49 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-kernel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] register_shrinker: shrinker->nr_deferred is never freed
Date: Fri, 11 Oct 2013 10:19:47 -0400
Message-Id: <20131011141946.17927.42942.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

kmemleak reports a leak after every mount-umount cycle:

unreferenced object 0xffff88006b339150 (size 8):
  comm "mount.nfs", pid 752, jiffies 4294802777 (age 1515.620s)
  hex dump (first 8 bytes):
    00 00 00 00 00 00 00 00                          ........
  backtrace:
    [<ffffffff816a9509>] kmemleak_alloc+0x79/0xb0
    [<ffffffff811a9031>] __kmalloc+0x1e1/0x380
    [<ffffffff81164110>] register_shrinker+0x40/0x90
    [<ffffffff811c8f10>] sget+0x680/0x6a0
    [<ffffffffa026a71c>] nfs_fs_mount_common+0x7c/0x180 [nfs]
    [<ffffffffa026a8e1>] nfs_xdev_mount+0xc1/0x100 [nfs]
    [<ffffffff811c9c1b>] mount_fs+0x7b/0x1a0
    [<ffffffff811e7b0a>] vfs_kern_mount+0x6a/0xf0
    [<ffffffffa0275735>] nfs_do_submount+0xe5/0x140 [nfs]
    [<ffffffffa02db6a6>] nfs4_submount+0x806/0x890 [nfsv4]
    [<ffffffffa02758d2>] nfs_d_automount+0xb2/0x1b0 [nfs]
    [<ffffffff811d0154>] follow_managed+0x1a4/0x300
    [<ffffffff816b0533>] lookup_slow+0x7a/0xa9
    [<ffffffff811d2373>] link_path_walk+0x243/0x8b0
    [<ffffffff811d2a3b>] path_lookupat+0x5b/0x7c0
    [<ffffffff811d31cb>] filename_lookup+0x2b/0xc0

Commit 1d3d4437 adds logic to kmalloc an array (nr_deferred) in
register_shrinker(), but this array is not freed when the shrinker
is released.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 mm/vmscan.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 53f2f82..eea668d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -211,6 +211,7 @@ void unregister_shrinker(struct shrinker *shrinker)
 	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
 	up_write(&shrinker_rwsem);
+	kfree(shrinker->nr_deferred);
 }
 EXPORT_SYMBOL(unregister_shrinker);
 

