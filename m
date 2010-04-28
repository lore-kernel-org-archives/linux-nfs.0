From: andros@netapp.com
Subject: [PATCH 08/13] SQUASHME pnfs_submit: change initialize_mountpoint parameters
Date: Wed, 28 Apr 2010 18:24:20 -0400
Message-ID: <1272493465-3398-9-git-send-email-andros@netapp.com>
References: <1272493465-3398-1-git-send-email-andros@netapp.com>
 <1272493465-3398-2-git-send-email-andros@netapp.com>
 <1272493465-3398-3-git-send-email-andros@netapp.com>
 <1272493465-3398-4-git-send-email-andros@netapp.com>
 <1272493465-3398-5-git-send-email-andros@netapp.com>
 <1272493465-3398-6-git-send-email-andros@netapp.com>
 <1272493465-3398-7-git-send-email-andros@netapp.com>
 <1272493465-3398-8-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30259 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932238Ab0D1VYf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 17:24:35 -0400
In-Reply-To: <1272493465-3398-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The layoutdriver_io_operation initalize_mountpoint is used to set up the
generic device id cache.
The super block and file handle parameters are unused except by the block
layout driver which uses them to call GETDEVICELIST.
A getdevicelist call will be added for the block layout driver.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c   |    4 ++--
 fs/nfs/pnfs.c             |    2 +-
 fs/nfs/pnfs.h             |    2 +-
 include/linux/nfs4_pnfs.h |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 36a8fe1..80eb481 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -69,10 +69,10 @@ ssize_t filelayout_get_stripesize(struct pnfs_layout_type *);
 struct layoutdriver_io_operations filelayout_io_operations;
 
 int
-filelayout_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
+filelayout_initialize_mountpoint(struct nfs_client *clp)
 {
 
-	if (nfs4_alloc_init_deviceid_cache(NFS_SB(sb)->nfs_client,
+	if (nfs4_alloc_init_deviceid_cache(clp,
 					   nfs4_fl_free_deviceid_callback)) {
 		printk(KERN_WARNING "%s: deviceid cache could not be "
 			"initialized\n", __func__);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3362ef5..5cf1aa7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -214,7 +214,7 @@ set_pnfs_layoutdriver(struct super_block *sb, struct nfs_fh *fh, u32 id)
 
 	if (id > 0 && find_pnfs(id, &mod)) {
 		if (!mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
-			sb, fh)) {
+			server->nfs_client)) {
 			printk(KERN_ERR "%s: Error initializing mount point "
 			       "for layout driver %u. ", __func__, id);
 			goto out_err;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5745ee1..b95886c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -38,7 +38,7 @@ int pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
 			const nfs4_stateid *stateid, /* optional */
 			enum pnfs_layoutreturn_type);
-void set_pnfs_layoutdriver(struct super_block *sb, struct nfs_fh *fh, u32 id);
+void set_pnfs_layoutdriver(struct super_block *, struct nfs_fh *, u32 id);
 void unmount_pnfs_layoutdriver(struct super_block *sb);
 int pnfs_use_read(struct inode *inode, ssize_t count);
 int pnfs_use_ds_io(struct list_head *, struct inode *, int);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 7ca8f85..46fec95 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -168,7 +168,7 @@ struct layoutdriver_io_operations {
 
 	/* Registration information for a new mounted file system
 	 */
-	int (*initialize_mountpoint) (struct super_block *, struct nfs_fh *fh);
+	int (*initialize_mountpoint) (struct nfs_client *);
 };
 
 enum layoutdriver_policy_flags {
-- 
1.6.6

