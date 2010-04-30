From: andros@netapp.com
Subject: [PATCH 4/5] pnfs_post_submit: restore ds_wsize and ds_rsize
Date: Fri, 30 Apr 2010 14:27:11 -0400
Message-ID: <1272652032-2496-5-git-send-email-andros@netapp.com>
References: <1272652032-2496-1-git-send-email-andros@netapp.com>
 <1272652032-2496-2-git-send-email-andros@netapp.com>
 <1272652032-2496-3-git-send-email-andros@netapp.com>
 <1272652032-2496-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22740 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933866Ab0D3S1s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 14:27:48 -0400
In-Reply-To: <1272652032-2496-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The object layout driver uses ds_wsize and ds_rsize

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c           |    4 +++-
 fs/nfs/pnfs.c             |   22 +++++++++++++++++-----
 fs/nfs/pnfs.h             |    7 +++++--
 fs/nfs/read.c             |    2 +-
 fs/nfs/write.c            |    2 +-
 include/linux/nfs_fs_sb.h |    2 ++
 6 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8f3bf8a..b8c459d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -879,8 +879,10 @@ static void nfs4_init_pnfs(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
 	struct nfs_client *clp = server->nfs_client;
 
 	if (nfs4_has_session(clp) &&
-	    (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
+	    (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS)) {
 		set_pnfs_layoutdriver(server, fsinfo->layouttype);
+		pnfs_set_ds_iosize(server);
+	}
 #endif /* CONFIG_NFS_V4_1 */
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 40b09bf..fadfd7c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1419,7 +1419,8 @@ void
 pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 		  struct inode *inode,
 		  struct nfs_open_context *ctx,
-		  struct list_head *pages)
+		  struct list_head *pages,
+		  size_t *rsize)
 {
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	size_t count = 0;
@@ -1440,10 +1441,12 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	if (count > 0 && !below_threshold(inode, count, 0)) {
 		status = pnfs_update_layout(inode, ctx, count,
 						loff, IOMODE_READ, NULL);
-		dprintk("%s virt update returned %d\n", __func__, status);
+		dprintk("%s *rsize %Zd virt update returned %d\n",
+			__func__, *rsize, status);
 		if (status != 0)
 			return;
 
+		*rsize = NFS_SERVER(inode)->ds_rsize;
 		pgio->pg_boundary = pnfs_getboundary(inode);
 		if (pgio->pg_boundary)
 			pnfs_set_pg_test(inode, pgio);
@@ -1451,7 +1454,8 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 }
 
 void
-pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
+pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode,
+		       size_t *wsize)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 
@@ -1465,6 +1469,7 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 	pgio->pg_threshold = pnfs_getthreshold(inode, 1);
 	pgio->pg_boundary = pnfs_getboundary(inode);
 	pnfs_set_pg_test(inode, pgio);
+	*wsize = server->ds_wsize;
 }
 
 /* Retrieve I/O parameters for O_DIRECT.
@@ -1487,9 +1492,9 @@ _pnfs_direct_init_io(struct inode *inode, struct nfs_open_context *ctx,
 		return;
 
 	if (iswrite)
-		rwsize = nfss->wsize;
+		rwsize = nfss->ds_wsize;
 	else
-		rwsize = nfss->rsize;
+		rwsize = nfss->ds_rsize;
 
 	boundary = pnfs_getboundary(inode);
 
@@ -1593,6 +1598,13 @@ pnfs_use_write(struct inode *inode, ssize_t count)
 	return 1; /* use pNFS I/O */
 }
 
+void
+pnfs_set_ds_iosize(struct nfs_server *server)
+{
+	server->ds_wsize = server->wsize;
+	server->ds_rsize = server->rsize;
+}
+
 static int
 pnfs_call_done(struct pnfs_call_data *pdata, struct rpc_task *task, void *data)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 08b2af7..338ba4b 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -58,11 +58,14 @@ int pnfs_layoutcommit_inode(struct inode *inode, int sync);
 void pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent);
 void pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx);
 unsigned int pnfs_getiosize(struct nfs_server *server);
+void pnfs_set_ds_iosize(struct nfs_server *server);
 enum pnfs_try_status _pnfs_try_to_commit(struct nfs_write_data *,
 					 const struct rpc_call_ops *, int);
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
-			   struct nfs_open_context *, struct list_head *);
-void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
+			   struct nfs_open_context *, struct list_head *,
+			   size_t *);
+void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *,
+			    size_t *);
 void pnfs_update_layout_commit(struct inode *, struct list_head *, pgoff_t, unsigned int);
 void pnfs_free_fsdata(struct pnfs_fsdata *fsdata);
 ssize_t pnfs_file_write(struct file *, const char __user *, size_t, loff_t *);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 1d30336..fd8bac7 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -663,7 +663,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 		goto read_complete; /* all pages were read */
 
 #ifdef CONFIG_NFS_V4_1
-	pnfs_pageio_init_read(&pgio, inode, desc.ctx, pages);
+	pnfs_pageio_init_read(&pgio, inode, desc.ctx, pages, &rsize);
 #endif /* CONFIG_NFS_V4_1 */
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0faf909..38e542a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1009,7 +1009,7 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 	size_t wsize = NFS_SERVER(inode)->wsize;
 
 #ifdef CONFIG_NFS_V4_1
-	pnfs_pageio_init_write(pgio, inode);
+	pnfs_pageio_init_write(pgio, inode, &wsize);
 #endif /* CONFIG_NFS_V4_1 */
 
 	if (wsize < PAGE_CACHE_SIZE)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 276735f..cad56a7 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -164,6 +164,8 @@ struct nfs_server {
 
 #ifdef CONFIG_NFS_V4_1
 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
+	unsigned int			ds_rsize;  /* Data server read size */
+	unsigned int			ds_wsize;  /* Data server write size */
 #endif /* CONFIG_NFS_V4_1 */
 
 	void (*destroy)(struct nfs_server *);
-- 
1.6.6

