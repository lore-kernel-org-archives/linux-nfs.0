Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:25947 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752122Ab0I2LLG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:11:06 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 9/9] SQUASHME: pnfs: get rid of lo_waitq
Date: Wed, 29 Sep 2010 13:11:03 +0200
Message-Id: <1285758663-27045-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

it has no more users at this point.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/inode.c         |    1 -
 fs/nfs/pnfs.c          |    6 +-----
 include/linux/nfs_fs.h |    1 -
 3 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e3d44a9..437d9a6 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1458,7 +1458,6 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation = NULL;
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
-	init_waitqueue_head(&nfsi->lo_waitq);
 	rpc_init_wait_queue(&nfsi->lo_rpcwaitq, "pNFS Layout");
 	nfsi->layout = NULL;
 #endif
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4e47c2a..0796c17 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -311,10 +311,8 @@ put_lseg_common(struct nfs_inode *nfsi, struct pnfs_layout_segment *lseg)
 	do_wake_up = !lseg->valid;
 	nfsi = NFS_I(lseg->layout->inode);
 	kref_put(&lseg->kref, destroy_lseg);
-	if (do_wake_up) {
-		wake_up(&nfsi->lo_waitq);
+	if (do_wake_up)
 		rpc_wake_up(&nfsi->lo_rpcwaitq);
-	}
 }
 
 void
@@ -476,7 +474,6 @@ pnfs_layoutget_release(struct pnfs_layout_hdr *lo)
 	 */
 	put_layout_hdr_locked(lo);
 	spin_unlock(&nfsi->vfs_inode.i_lock);
-	wake_up_all(&nfsi->lo_waitq);
 }
 
 void
@@ -494,7 +491,6 @@ pnfs_layoutreturn_release(struct pnfs_layout_hdr *lo,
 	 */
 	put_layout_hdr_locked(lo);
 	spin_unlock(&nfsi->vfs_inode.i_lock);
-	wake_up_all(&nfsi->lo_waitq);
 }
 
 void
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1af18fd..059e61d 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -190,7 +190,6 @@ struct nfs_inode {
 	struct rw_semaphore	rwsem;
 
 	/* pNFS layout information */
-	wait_queue_head_t lo_waitq;
 	struct rpc_wait_queue lo_rpcwaitq;
 	struct pnfs_layout_hdr *layout;
 #endif /* CONFIG_NFS_V4*/
-- 
1.7.2.3

