Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36972 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484Ab1FHGn0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 02:43:26 -0400
Date: Wed, 8 Jun 2011 09:43:00 +0300
From: Dan Carpenter <error27@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
Subject: [patch] NFS: using freed variable in debug code
Message-ID: <20110608064300.GE3846@shale.localdomain>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

"ds" gets dereferenced after a kfree in the debug output.  I just
moved the free down a line.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 77c171e..c63bbce 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -362,11 +362,11 @@ nfs4_pnfs_ds_add(struct list_head *dsaddrs, gfp_t gfp_flags)
 				__func__, tmp_ds->ds_remotestr, remotestr);
 		}
 		kfree(remotestr);
-		kfree(ds);
 		atomic_inc(&tmp_ds->ds_count);
 		dprintk("%s data server %s found, inc'ed ds_count to %d\n",
 			__func__, ds->ds_remotestr,
 			atomic_read(&tmp_ds->ds_count));
+		kfree(ds);
 		ds = tmp_ds;
 	}
 	spin_unlock(&nfs4_ds_cache_lock);
