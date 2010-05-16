From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 15/22] pnfs_submit: remove pnfs_file_operations
Date: Sat, 15 May 2010 21:23:06 -0400
Message-ID: <1273972993-15369-16-git-send-email-iisaman@netapp.com>
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com>
 <1273972993-15369-2-git-send-email-iisaman@netapp.com>
 <1273972993-15369-3-git-send-email-iisaman@netapp.com>
 <1273972993-15369-4-git-send-email-iisaman@netapp.com>
 <1273972993-15369-5-git-send-email-iisaman@netapp.com>
 <1273972993-15369-6-git-send-email-iisaman@netapp.com>
 <1273972993-15369-7-git-send-email-iisaman@netapp.com>
 <1273972993-15369-8-git-send-email-iisaman@netapp.com>
 <1273972993-15369-9-git-send-email-iisaman@netapp.com>
 <1273972993-15369-10-git-send-email-iisaman@netapp.com>
 <1273972993-15369-11-git-send-email-iisaman@netapp.com>
 <1273972993-15369-12-git-send-email-iisaman@netapp.com>
 <1273972993-15369-13-git-send-email-iisaman@netapp.com>
 <1273972993-15369-14-git-send-email-iisaman@netapp.com>
 <1273972993-15369-15-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754829Ab0ETKan (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 06:30:43 -0400
Received: from localhost.localdomain (vpn2ntap-176975.hq.netapp.com [10.58.56.200])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4KAUQc5022655
	for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 03:30:42 -0700 (PDT)
In-Reply-To: <1273972993-15369-15-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pnfs_writepages is useful, but not necessary, for determining size
parameters for LAYUTGET.

Also, the pnfs_file_operations were getting out of sync with
nfs_file_operations (see commits e1ebfd33be068 and bf40d3435caf49369).

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c          |   24 ------------------------
 fs/nfs/nfs4proc.c      |    1 -
 fs/nfs/pnfs.c          |   35 -----------------------------------
 fs/nfs/pnfs.h          |    1 -
 include/linux/nfs_fs.h |    3 ---
 5 files changed, 0 insertions(+), 64 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 1479289..80e7dc2 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -82,30 +82,6 @@ const struct file_operations nfs_file_operations = {
 	.setlease	= nfs_setlease,
 };
 
-#ifdef CONFIG_NFS_V4_1
-const struct file_operations pnfs_file_operations = {
-	.llseek		= nfs_file_llseek,
-	.read		= do_sync_read,
-	.write		= pnfs_file_write,
-	.aio_read	= nfs_file_read,
-	.aio_write	= nfs_file_write,
-#ifdef CONFIG_MMU
-	.mmap		= nfs_file_mmap,
-#else
-	.mmap		= generic_file_mmap,
-#endif
-	.open		= nfs_file_open,
-	.flush		= nfs_file_flush,
-	.release	= nfs_file_release,
-	.fsync		= nfs_file_fsync,
-	.lock		= nfs_lock,
-	.flock		= nfs_flock,
-	.splice_read	= nfs_file_splice_read,
-	.check_flags	= nfs_check_flags,
-	.setlease	= nfs_setlease,
-};
-#endif /* CONFIG_NFS_V4_1 */
-
 const struct inode_operations nfs_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8b375a7..9786391 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5935,7 +5935,6 @@ pnfs_v4_clientops_init(void)
 	struct nfs_rpc_ops *p = (struct nfs_rpc_ops *)&pnfs_v4_clientops;
 
 	memcpy(p, &nfs_v4_clientops, sizeof(*p));
-	p->file_ops		= &pnfs_file_operations;
 	p->setattr		= pnfs4_proc_setattr;
 	p->read_done		= pnfs4_read_done;
 	p->write_setup		= pnfs4_proc_write_setup;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 07a8c33..a542601 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1539,41 +1539,6 @@ pnfs_writeback_done(struct nfs_write_data *data)
 }
 
 /*
- * Obtain a layout for the the write range, and call do_sync_write.
- *
- * Unlike the read path which can wait until page coalescing
- * (pnfs_pageio_init_read) to get a layout, the write path discards the
- * request range to form the address_mapping - so we get a layout in
- * the file operations write method.
- *
- * If pnfs_update_layout fails, pages will be coalesced for MDS I/O.
- */
-ssize_t
-pnfs_file_write(struct file *filp, const char __user *buf, size_t count,
-		loff_t *pos)
-{
-	struct inode *inode = filp->f_dentry->d_inode;
-	struct nfs_open_context *context = filp->private_data;
-	int status;
-
-	if (!pnfs_enabled_sb(NFS_SERVER(inode)))
-		goto out;
-
-	/* Retrieve and set layout if not allready cached */
-	status = _pnfs_update_layout(inode,
-				    context,
-				    count,
-				    *pos,
-				    IOMODE_RW,
-				    NULL);
-	if (status)
-		dprintk("%s: Unable to get a layout for %Zu@%llu iomode %d)\n",
-			__func__, count, *pos, IOMODE_RW);
-out:
-	return do_sync_write(filp, buf, count, pos);
-}
-
-/*
  * Call the appropriate parallel I/O subsystem write function.
  * If no I/O device driver exists, or one does match the returned
  * fstype, then return a positive status for regular NFS processing.
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5201973..bec3c49 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -59,7 +59,6 @@ void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   struct nfs_open_context *, struct list_head *);
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 void pnfs_update_layout_commit(struct inode *, struct list_head *, pgoff_t, unsigned int);
-ssize_t pnfs_file_write(struct file *, const char __user *, size_t, loff_t *);
 void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
 int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
 void pnfs_layout_release(struct pnfs_layout_type *, atomic_t *,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 9d41821..16acf96 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -402,9 +402,6 @@ extern const struct inode_operations nfs3_file_inode_operations;
 #endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_file_operations;
 extern const struct address_space_operations nfs_file_aops;
-#ifdef CONFIG_NFS_V4_1
-extern const struct file_operations pnfs_file_operations;
-#endif /* CONFIG_NFS_V4_1 */
 
 static inline struct nfs_open_context *nfs_file_open_context(struct file *filp)
 {
-- 
1.6.6.1

