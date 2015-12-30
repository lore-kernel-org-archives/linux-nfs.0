Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754754AbbL3NOI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Dec 2015 08:14:08 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 07/10] lockd: do_vfs_lock() only needs the inode
Date: Wed, 30 Dec 2015 08:14:03 -0500
Message-Id: <c4dd22196648baffb116b90937119bee5236565b.1451480826.git.bcodding@redhat.com>
In-Reply-To: <cover.1451480826.git.bcodding@redhat.com>
References: <cover.1451480826.git.bcodding@redhat.com>
In-Reply-To: <cover.1451480826.git.bcodding@redhat.com>
References: <cover.1451480826.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Send the inode instead of the file to do_vfs_lock() by using
locks_lock_inode_wait().  This allows an unlock operation to complete
after a close when there may not be an fl_file.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/lockd/clntproc.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 91aa483..fa1d83b 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -476,9 +476,9 @@ static void nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *ho
 	fl->fl_ops = &nlmclnt_lock_ops;
 }
 
-static int do_vfs_lock(struct file_lock *fl)
+static int do_vfs_lock(struct inode *inode, struct file_lock *fl)
 {
-	return locks_lock_file_wait(fl->fl_file, fl);
+	return locks_lock_inode_wait(inode, fl);
 }
 
 /*
@@ -508,6 +508,7 @@ nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
 	struct nlm_host	*host = req->a_host;
 	struct nlm_res	*resp = &req->a_res;
 	struct nlm_wait *block = NULL;
+	struct inode *inode = file_inode(fl->fl_file);
 	unsigned char fl_flags = fl->fl_flags;
 	unsigned char fl_type;
 	int status = -ENOLCK;
@@ -517,7 +518,7 @@ nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
 	req->a_args.state = nsm_local_state;
 
 	fl->fl_flags |= FL_ACCESS;
-	status = do_vfs_lock(fl);
+	status = do_vfs_lock(inode, fl);
 	fl->fl_flags = fl_flags;
 	if (status < 0)
 		goto out;
@@ -567,7 +568,7 @@ again:
 		}
 		/* Ensure the resulting lock will get added to granted list */
 		fl->fl_flags |= FL_SLEEP;
-		if (do_vfs_lock(fl) < 0)
+		if (do_vfs_lock(inode, fl) < 0)
 			printk(KERN_WARNING "%s: VFS is out of sync with lock manager!\n", __func__);
 		up_read(&host->h_rwsem);
 		fl->fl_flags = fl_flags;
@@ -597,7 +598,7 @@ out_unlock:
 	fl_type = fl->fl_type;
 	fl->fl_type = F_UNLCK;
 	down_read(&host->h_rwsem);
-	do_vfs_lock(fl);
+	do_vfs_lock(inode, fl);
 	up_read(&host->h_rwsem);
 	fl->fl_type = fl_type;
 	fl->fl_flags = fl_flags;
@@ -665,7 +666,7 @@ nlmclnt_unlock(struct nfs_open_context *ctx,
 	 */
 	fl->fl_flags |= FL_EXISTS;
 	down_read(&host->h_rwsem);
-	status = do_vfs_lock(fl);
+	status = do_vfs_lock(d_inode(ctx->dentry), fl);
 	up_read(&host->h_rwsem);
 	fl->fl_flags = fl_flags;
 	if (status == -ENOENT) {
-- 
1.7.1

