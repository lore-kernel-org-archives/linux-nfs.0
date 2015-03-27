Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:35702 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbbC0RH6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 13:07:58 -0400
Received: by ierf6 with SMTP id f6so8531966ier.2
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 10:07:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4.1/pnfs: Separate out metadata and data consistency for pNFS
Date: Fri, 27 Mar 2015 13:07:54 -0400
Message-Id: <1427476074-14736-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1427476074-14736-1-git-send-email-trond.myklebust@primarydata.com>
References: <1427476074-14736-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The LAYOUTCOMMIT operation means different things to different layout types.
For blocks and objects, it is both a data and metadata consistency operation.
For files and flexfiles, it is only a metadata consistency operation.

This patch separates out the 2 cases, allowing the files/flexfiles layout
drivers to optimise away the data consistency calls to layoutcommit.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/blocklayout/blocklayout.c       |  1 +
 fs/nfs/filelayout/filelayout.c         |  1 +
 fs/nfs/flexfilelayout/flexfilelayout.c |  1 +
 fs/nfs/nfs4file.c                      |  2 +-
 fs/nfs/objlayout/objio_osd.c           |  2 ++
 fs/nfs/pnfs.c                          |  7 +++++++
 fs/nfs/pnfs.h                          | 18 ++++++++++++++++++
 fs/nfs/pnfs_nfs.c                      | 10 ++++++++++
 fs/nfs/write.c                         | 13 ++++++-------
 9 files changed, 47 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 1cac3c175d18..d2554fe140a3 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -890,6 +890,7 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.free_deviceid_node		= bl_free_deviceid_node,
 	.pg_read_ops			= &bl_pg_read_ops,
 	.pg_write_ops			= &bl_pg_write_ops,
+	.sync				= pnfs_generic_sync,
 };
 
 static int __init nfs4blocklayout_init(void)
diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index a317b007e436..a46bf6de9ce4 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -1139,6 +1139,7 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.write_pagelist		= filelayout_write_pagelist,
 	.alloc_deviceid_node	= filelayout_alloc_deviceid_node,
 	.free_deviceid_node	= filelayout_free_deviceid_node,
+	.sync			= pnfs_nfs_generic_sync,
 };
 
 static int __init nfs4filelayout_init(void)
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 92d2943e54f8..f3ff66e4fb6a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1509,6 +1509,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.write_pagelist		= ff_layout_write_pagelist,
 	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
 	.encode_layoutreturn    = ff_layout_encode_layoutreturn,
+	.sync			= pnfs_nfs_generic_sync,
 };
 
 static int __init nfs4flexfilelayout_init(void)
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index befe7a2c6284..866842b048ef 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -112,7 +112,7 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 		mutex_lock(&inode->i_mutex);
 		ret = nfs_file_fsync_commit(file, start, end, datasync);
 		if (!ret)
-			ret = pnfs_layoutcommit_inode(inode, true);
+			ret = pnfs_sync_inode(inode, !!datasync);
 		mutex_unlock(&inode->i_mutex);
 		/*
 		 * If nfs_file_fsync_commit detected a server reboot, then
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 8b5e0e687d5e..5aaed363556a 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -637,6 +637,8 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.pg_read_ops             = &objio_pg_read_ops,
 	.pg_write_ops            = &objio_pg_write_ops,
 
+	.sync			 = pnfs_generic_sync,
+
 	.free_deviceid_node	 = objio_free_deviceid_node,
 
 	.encode_layoutcommit	 = objlayout_encode_layoutcommit,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c2ce2db771b7..3f0affebcf05 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2231,6 +2231,13 @@ clear_layoutcommitting:
 }
 EXPORT_SYMBOL_GPL(pnfs_layoutcommit_inode);
 
+int
+pnfs_generic_sync(struct inode *inode, bool datasync)
+{
+	return pnfs_layoutcommit_inode(inode, true);
+}
+EXPORT_SYMBOL_GPL(pnfs_generic_sync);
+
 struct nfs4_threshold *pnfs_mdsthreshold_alloc(void)
 {
 	struct nfs4_threshold *thp;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 66bf5e1cf93d..231eb23c22da 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -155,6 +155,8 @@ struct pnfs_layoutdriver_type {
 			       int how,
 			       struct nfs_commit_info *cinfo);
 
+	int (*sync)(struct inode *inode, bool datasync);
+
 	/*
 	 * Return PNFS_ATTEMPTED to indicate the layout code has attempted
 	 * I/O, else return PNFS_NOT_ATTEMPTED to fall back to normal NFS
@@ -267,6 +269,8 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier, struct rpc_task *task);
 void pnfs_set_layoutcommit(struct inode *, struct pnfs_layout_segment *, loff_t);
 void pnfs_cleanup_layoutcommit(struct nfs4_layoutcommit_data *data);
 int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
+int pnfs_generic_sync(struct inode *inode, bool datasync);
+int pnfs_nfs_generic_sync(struct inode *inode, bool datasync);
 int _pnfs_return_layout(struct inode *);
 int pnfs_commit_and_return_layout(struct inode *);
 void pnfs_ld_write_done(struct nfs_pgio_header *);
@@ -488,6 +492,14 @@ pnfs_ld_read_whole_page(struct inode *inode)
 	return NFS_SERVER(inode)->pnfs_curr_ld->flags & PNFS_READ_WHOLE_PAGE;
 }
 
+static inline int
+pnfs_sync_inode(struct inode *inode, bool datasync)
+{
+	if (!pnfs_enabled_sb(NFS_SERVER(inode)))
+		return 0;
+	return NFS_SERVER(inode)->pnfs_curr_ld->sync(inode, datasync);
+}
+
 static inline bool
 pnfs_layoutcommit_outstanding(struct inode *inode)
 {
@@ -570,6 +582,12 @@ pnfs_ld_read_whole_page(struct inode *inode)
 	return false;
 }
 
+static inline int
+pnfs_sync_inode(struct inode *inode, bool datasync)
+{
+	return 0;
+}
+
 static inline bool
 pnfs_roc(struct inode *ino)
 {
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 54e36b38fb5f..64d2a5932f7b 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -868,3 +868,13 @@ pnfs_layout_mark_request_commit(struct nfs_page *req,
 	nfs_request_add_commit_list(req, list, cinfo);
 }
 EXPORT_SYMBOL_GPL(pnfs_layout_mark_request_commit);
+
+int
+pnfs_nfs_generic_sync(struct inode *inode, bool datasync)
+{
+	if (datasync)
+		return 0;
+	return pnfs_layoutcommit_inode(inode, true);
+}
+EXPORT_SYMBOL_GPL(pnfs_nfs_generic_sync);
+
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 849ed784d6ac..7f933a39f385 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1840,17 +1840,16 @@ EXPORT_SYMBOL_GPL(nfs_write_inode);
  */
 int nfs_wb_all(struct inode *inode)
 {
-	struct writeback_control wbc = {
-		.sync_mode = WB_SYNC_ALL,
-		.nr_to_write = LONG_MAX,
-		.range_start = 0,
-		.range_end = LLONG_MAX,
-	};
 	int ret;
 
 	trace_nfs_writeback_inode_enter(inode);
 
-	ret = sync_inode(inode, &wbc);
+	ret = filemap_write_and_wait(inode->i_mapping);
+	if (!ret) {
+		ret = nfs_commit_inode(inode, FLUSH_SYNC);
+		if (!ret)
+			pnfs_sync_inode(inode, true);
+	}
 
 	trace_nfs_writeback_inode_exit(inode, ret);
 	return ret;
-- 
2.1.0

