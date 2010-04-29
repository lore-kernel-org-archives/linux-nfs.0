From: andros@netapp.com
Subject: [PATCH 08/13] SQUASHME pnfs_submit: change initialize_mountpoint parameters
Date: Thu, 29 Apr 2010 16:34:46 -0400
Message-ID: <1272573291-8986-9-git-send-email-andros@netapp.com>
References: <1272573291-8986-1-git-send-email-andros@netapp.com>
 <1272573291-8986-2-git-send-email-andros@netapp.com>
 <1272573291-8986-3-git-send-email-andros@netapp.com>
 <1272573291-8986-4-git-send-email-andros@netapp.com>
 <1272573291-8986-5-git-send-email-andros@netapp.com>
 <1272573291-8986-6-git-send-email-andros@netapp.com>
 <1272573291-8986-7-git-send-email-andros@netapp.com>
 <1272573291-8986-8-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757583Ab0D3Qsz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 12:48:55 -0400
In-Reply-To: <1272573291-8986-8-git-send-email-andros@netapp.com>
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
 include/linux/nfs4_pnfs.h |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 16b88e2..aff11d3 100644
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
index a75a77e..0306d05 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -213,7 +213,7 @@ set_pnfs_layoutdriver(struct super_block *sb, struct nfs_fh *fh, u32 id)
 
 	if (id > 0 && find_pnfs(id, &mod)) {
 		if (!mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
-			sb, fh)) {
+			server->nfs_client)) {
 			printk(KERN_ERR "%s: Error initializing mount point "
 			       "for layout driver %u. ", __func__, id);
 			goto out_err;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 637f11d..81701a3 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -168,7 +168,7 @@ struct layoutdriver_io_operations {
 
 	/* Registration information for a new mounted file system
 	 */
-	int (*initialize_mountpoint) (struct super_block *, struct nfs_fh *fh);
+	int (*initialize_mountpoint) (struct nfs_client *);
 	int (*uninitialize_mountpoint) (struct nfs_server *server);
 };
 
-- 
1.6.6

