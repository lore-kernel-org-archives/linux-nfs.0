From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 12/30] NFS: Allow concurrent inode revalidation
Date: Tue, 07 Oct 2008 18:19:53 -0400
Message-ID: <20081007221953.20945.70360.stgit@localhost.localdomain>
References: <20081007221952.20945.69529.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4712 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756338AbYJGWcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2008 18:32:53 -0400
Received: from sacexrs02.hq.netapp.com (sacexrs02.hq.netapp.com [10.99.190.106])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m97MWkwE026300
	for <linux-nfs@vger.kernel.org>; Tue, 7 Oct 2008 15:32:49 -0700 (PDT)
In-Reply-To: <20081007221952.20945.69529.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, if two processes are both trying to revalidate metadata for the
same inode, they will find themselves being serialised. There is no good
justification for this now that we have improved our ability to detect
stale attribute data, so we should remove that serialisation.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c         |   43 ++-----------------------------------------
 include/linux/nfs_fs.h |    9 ++++-----
 2 files changed, 6 insertions(+), 46 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f3b8ed9..e25009f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -472,37 +472,6 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
 	}
 }
 
-static int nfs_wait_schedule(void *word)
-{
-	if (signal_pending(current))
-		return -ERESTARTSYS;
-	schedule();
-	return 0;
-}
-
-/*
- * Wait for the inode to get unlocked.
- */
-static int nfs_wait_on_inode(struct inode *inode)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-	int error;
-
-	error = wait_on_bit_lock(&nfsi->flags, NFS_INO_REVALIDATING,
-					nfs_wait_schedule, TASK_KILLABLE);
-
-	return error;
-}
-
-static void nfs_wake_up_inode(struct inode *inode)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-
-	clear_bit(NFS_INO_REVALIDATING, &nfsi->flags);
-	smp_mb__after_clear_bit();
-	wake_up_bit(&nfsi->flags, NFS_INO_REVALIDATING);
-}
-
 int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
 	struct inode *inode = dentry->d_inode;
@@ -697,20 +666,15 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 	dfprintk(PAGECACHE, "NFS: revalidating (%s/%Ld)\n",
 		inode->i_sb->s_id, (long long)NFS_FILEID(inode));
 
-	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
 	if (is_bad_inode(inode))
- 		goto out_nowait;
+		goto out;
 	if (NFS_STALE(inode))
- 		goto out_nowait;
-
-	status = nfs_wait_on_inode(inode);
-	if (status < 0)
 		goto out;
 
-	status = -ESTALE;
 	if (NFS_STALE(inode))
 		goto out;
 
+	nfs_inc_stats(inode, NFSIOS_INODEREVALIDATE);
 	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), &fattr);
 	if (status != 0) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) getattr failed, error=%d\n",
@@ -740,9 +704,6 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		(long long)NFS_FILEID(inode));
 
  out:
-	nfs_wake_up_inode(inode);
-
- out_nowait:
 	return status;
 }
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 78a5922..ca563ee 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -200,11 +200,10 @@ struct nfs_inode {
 /*
  * Bit offsets in flags field
  */
-#define NFS_INO_REVALIDATING	(0)		/* revalidating attrs */
-#define NFS_INO_ADVISE_RDPLUS	(1)		/* advise readdirplus */
-#define NFS_INO_STALE		(2)		/* possible stale inode */
-#define NFS_INO_ACL_LRU_SET	(3)		/* Inode is on the LRU list */
-#define NFS_INO_MOUNTPOINT	(4)		/* inode is remote mountpoint */
+#define NFS_INO_ADVISE_RDPLUS	(0)		/* advise readdirplus */
+#define NFS_INO_STALE		(1)		/* possible stale inode */
+#define NFS_INO_ACL_LRU_SET	(2)		/* Inode is on the LRU list */
+#define NFS_INO_MOUNTPOINT	(3)		/* inode is remote mountpoint */
 
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {

