From: andros@netapp.com
Subject: [PATCH 05/13] SQUASHME pnfs_submit: remove ds_wsize, ds_rsize, ds_wpages and ds_rpages
Date: Wed, 28 Apr 2010 18:24:17 -0400
Message-ID: <1272493465-3398-6-git-send-email-andros@netapp.com>
References: <1272493465-3398-1-git-send-email-andros@netapp.com>
 <1272493465-3398-2-git-send-email-andros@netapp.com>
 <1272493465-3398-3-git-send-email-andros@netapp.com>
 <1272493465-3398-4-git-send-email-andros@netapp.com>
 <1272493465-3398-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40918 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932240Ab0D1VYd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 17:24:33 -0400
In-Reply-To: <1272493465-3398-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

No layoutdriver uses ds_wpages or ds_rpages. The file layout driver does not
use ds_rsize nor ds_wsize - instead, rsize and wsize are used.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c   |   11 ++++++-----
 fs/nfs/pnfs.c             |   24 +++++-------------------
 fs/nfs/pnfs.h             |    6 +++---
 fs/nfs/read.c             |    2 +-
 fs/nfs/super.c            |    1 -
 fs/nfs/write.c            |    2 +-
 include/linux/nfs_fs_sb.h |    7 -------
 7 files changed, 16 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 4a3f58a..9e81195 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -407,9 +407,10 @@ filelayout_check_layout(struct pnfs_layout_type *lo,
 		goto out;
 	}
 
-	if (fl->stripe_unit % nfss->ds_rsize || fl->stripe_unit % nfss->ds_wsize) {
-		dprintk("%s Stripe unit (%u) not aligned with rsize %u wsize %u\n",
-			__func__, fl->stripe_unit, nfss->ds_rsize, nfss->ds_wsize);
+	if (fl->stripe_unit % nfss->rsize || fl->stripe_unit % nfss->wsize) {
+		dprintk("%s Stripe unit (%u) not aligned with rsize %u "
+			"wsize %u\n", __func__, fl->stripe_unit, nfss->rsize,
+			nfss->wsize);
 	}
 
 	/* reference the device */
@@ -740,9 +741,9 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	if (!pgio->pg_iswrite)
 		goto boundary;
 
-	if (pgio->pg_bsize != NFS_SERVER(pgio->pg_inode)->ds_wsize &&
+	if (pgio->pg_bsize != NFS_SERVER(pgio->pg_inode)->wsize &&
 	    pgio->pg_count > pgio->pg_threshold)
-		pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->ds_wsize;
+		pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->wsize;
 
 boundary:
 	if (pgio->pg_boundary == 0)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 32bb852..83e8448 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1428,8 +1428,7 @@ void
 pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 		  struct inode *inode,
 		  struct nfs_open_context *ctx,
-		  struct list_head *pages,
-		  size_t *rsize)
+		  struct list_head *pages)
 {
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	size_t count = 0;
@@ -1450,12 +1449,10 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	if (count > 0 && !below_threshold(inode, count, 0)) {
 		status = pnfs_update_layout(inode, ctx, count,
 						loff, IOMODE_READ, NULL);
-		dprintk("%s *rsize %Zd virt update returned %d\n",
-					__func__, *rsize, status);
+		dprintk("%s virt update returned %d\n", __func__, status);
 		if (status != 0)
 			return;
 
-		*rsize = NFS_SERVER(inode)->ds_rsize;
 		pgio->pg_boundary = pnfs_getboundary(inode);
 		if (pgio->pg_boundary)
 			pnfs_set_pg_test(inode, pgio);
@@ -1463,8 +1460,7 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 }
 
 void
-pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode,
-		       size_t *wsize)
+pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 
@@ -1478,7 +1474,6 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode,
 	pgio->pg_threshold = pnfs_getthreshold(inode, 1);
 	pgio->pg_boundary = pnfs_getboundary(inode);
 	pnfs_set_pg_test(inode, pgio);
-	*wsize = server->ds_wsize;
 }
 
 /* Retrieve I/O parameters for O_DIRECT.
@@ -1501,9 +1496,9 @@ _pnfs_direct_init_io(struct inode *inode, struct nfs_open_context *ctx,
 		return;
 
 	if (iswrite)
-		rwsize = nfss->ds_wsize;
+		rwsize = nfss->wsize;
 	else
-		rwsize = nfss->ds_rsize;
+		rwsize = nfss->rsize;
 
 	boundary = pnfs_getboundary(inode);
 
@@ -1607,15 +1602,6 @@ pnfs_use_write(struct inode *inode, ssize_t count)
 	return 1; /* use pNFS I/O */
 }
 
-void
-pnfs_set_ds_iosize(struct nfs_server *server)
-{
-	server->ds_wsize = server->wsize;
-	server->ds_rsize = server->rsize;
-	server->ds_rpages = server->rpages;
-	server->ds_wpages = server->wpages;
-}
-
 static int
 pnfs_call_done(struct pnfs_call_data *pdata, struct rpc_task *task, void *data)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 868c1ac..5745ee1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -55,11 +55,11 @@ int pnfs_layoutcommit_inode(struct inode *inode, int sync);
 void pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent);
 void pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx);
 unsigned int pnfs_getiosize(struct nfs_server *server);
-void pnfs_set_ds_iosize(struct nfs_server *server);
 enum pnfs_try_status _pnfs_try_to_commit(struct nfs_write_data *,
 					 const struct rpc_call_ops *, int);
-void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *, struct nfs_open_context *, struct list_head *, size_t *);
-void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *, size_t *wsize);
+void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
+			   struct nfs_open_context *, struct list_head *);
+void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 void pnfs_update_layout_commit(struct inode *, struct list_head *, pgoff_t, unsigned int);
 void pnfs_free_fsdata(struct pnfs_fsdata *fsdata);
 ssize_t pnfs_file_write(struct file *, const char __user *, size_t, loff_t *);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index fd8bac7..1d30336 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -663,7 +663,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 		goto read_complete; /* all pages were read */
 
 #ifdef CONFIG_NFS_V4_1
-	pnfs_pageio_init_read(&pgio, inode, desc.ctx, pages, &rsize);
+	pnfs_pageio_init_read(&pgio, inode, desc.ctx, pages);
 #endif /* CONFIG_NFS_V4_1 */
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 38b13cd..a742846 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2590,7 +2590,6 @@ static void nfs4_init_pnfs(struct super_block *sb, struct nfs_fh *fh)
 	if (nfs4_has_session(clp) &&
 	    (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS)) {
 		set_pnfs_layoutdriver(sb, fh, server->pnfs_fs_ltype);
-		pnfs_set_ds_iosize(server);
 	}
 #endif /* CONFIG_NFS_V4_1 */
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9739b2a..7eb4f30 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -997,7 +997,7 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 	size_t wsize = NFS_SERVER(inode)->wsize;
 
 #ifdef CONFIG_NFS_V4_1
-	pnfs_pageio_init_write(pgio, inode, &wsize);
+	pnfs_pageio_init_write(pgio, inode);
 #endif /* CONFIG_NFS_V4_1 */
 
 	if (wsize < PAGE_CACHE_SIZE)
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index ef2e18e..bb0aa9c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -167,13 +167,6 @@ struct nfs_server {
 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
 	struct pnfs_mount_type         *pnfs_mountid; /* Mount identifier for
 							 layout driver */
-	/* Data server values will equal NFS server values if
-	 * no pNFS layout driver exists for the mountpoint
-	 */
-	unsigned int	ds_rsize;	/* Data server read size */
-	unsigned int	ds_rpages;	/* Data server read size (in pages) */
-	unsigned int	ds_wsize;	/* Data server write size */
-	unsigned int	ds_wpages;	/* Data server write size (in pages) */
 #endif /* CONFIG_NFS_V4_1 */
 
 	void (*destroy)(struct nfs_server *);
-- 
1.6.6

