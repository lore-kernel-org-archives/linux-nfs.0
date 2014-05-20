Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:18920 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807AbaETSI0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 14:08:26 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [RFC 01/12] nfs: Create a common pnfs_pageio_reset_mds() function
Date: Tue, 20 May 2014 14:08:08 -0400
Message-ID: <1400609299-32558-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

bsize never changes once it is set in the pageio descriptor, so we don't
need to add extra code to reset it.  I also moved this function into
pnfs.c because it is only called from pnfs.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c |  4 ++--
 fs/nfs/internal.h                |  2 --
 fs/nfs/nfs4filelayout.c          |  4 ++--
 fs/nfs/pagelist.c                |  1 +
 fs/nfs/pnfs.c                    | 14 ++++++++++----
 fs/nfs/pnfs.h                    |  1 +
 fs/nfs/read.c                    |  7 -------
 fs/nfs/write.c                   |  8 --------
 8 files changed, 16 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 04ac32b..eb0f5a7 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1183,7 +1183,7 @@ bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
 	if (pgio->pg_dreq != NULL &&
 	    !is_aligned_req(req, SECTOR_SIZE))
-		nfs_pageio_reset_read_mds(pgio);
+		pnfs_pageio_reset_mds(pgio);
 	else
 		pnfs_generic_pg_init_read(pgio, req);
 }
@@ -1231,7 +1231,7 @@ bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
 	if (pgio->pg_dreq != NULL &&
 	    !is_aligned_req(req, PAGE_CACHE_SIZE)) {
-		nfs_pageio_reset_write_mds(pgio);
+		pnfs_pageio_reset_mds(pgio);
 	} else {
 		u64 wb_size;
 		if (pgio->pg_dreq == NULL)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index e0e2b6d..5b64177 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -406,7 +406,6 @@ extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 			struct inode *inode, bool force_mds,
 			const struct nfs_pgio_completion_ops *compl_ops);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
-extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 
 /* super.c */
 void nfs_clone_super(struct super_block *, struct nfs_mount_info *);
@@ -423,7 +422,6 @@ int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 			struct inode *inode, int ioflags, bool force_mds,
 			const struct nfs_pgio_completion_ops *compl_ops);
-extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_commit_free(struct nfs_commit_data *p);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
 extern void nfs_commit_prepare(struct rpc_task *task, void *calldata);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 37e0b65..9586cfa 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -957,7 +957,7 @@ filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 					   GFP_KERNEL);
 	/* If no lseg, fall back to read through mds */
 	if (pgio->pg_lseg == NULL)
-		nfs_pageio_reset_read_mds(pgio);
+		pnfs_pageio_reset_mds(pgio);
 }
 
 static void
@@ -986,7 +986,7 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	}
 	return;
 out_mds:
-	nfs_pageio_reset_write_mds(pgio);
+	pnfs_pageio_reset_mds(pgio);
 }
 
 static const struct nfs_pageio_ops filelayout_pg_read_ops = {
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 0fcd34a..d1670a2 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1040,3 +1040,4 @@ const struct nfs_pageio_ops nfs_pgio_rw_ops = {
 	.pg_test = nfs_generic_pg_test,
 	.pg_doio = nfs_generic_pg_pgios,
 };
+EXPORT_SYMBOL_GPL(nfs_pgio_rw_ops);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 79792a4..8da7ff6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1381,6 +1381,12 @@ out_forget_reply:
 	goto out;
 }
 
+void pnfs_pageio_reset_mds(struct nfs_pageio_descriptor *pgio)
+{
+	pgio->pg_ops = &nfs_pgio_rw_ops;
+}
+EXPORT_SYMBOL_GPL(pnfs_pageio_reset_mds);
+
 void
 pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
@@ -1401,7 +1407,7 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
 					   GFP_KERNEL);
 	/* If no lseg, fall back to read through mds */
 	if (pgio->pg_lseg == NULL)
-		nfs_pageio_reset_read_mds(pgio);
+		pnfs_pageio_reset_mds(pgio);
 
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_read);
@@ -1420,7 +1426,7 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 					   GFP_NOFS);
 	/* If no lseg, fall back to write through mds */
 	if (pgio->pg_lseg == NULL)
-		nfs_pageio_reset_write_mds(pgio);
+		pnfs_pageio_reset_mds(pgio);
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
 
@@ -1510,7 +1516,7 @@ pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
 {
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		list_splice_tail_init(&hdr->pages, &desc->pg_list);
-		nfs_pageio_reset_write_mds(desc);
+		pnfs_pageio_reset_mds(desc);
 		desc->pg_recoalesce = 1;
 	}
 	nfs_generic_pgio_reset(hdr);
@@ -1627,7 +1633,7 @@ pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
 {
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		list_splice_tail_init(&hdr->pages, &desc->pg_list);
-		nfs_pageio_reset_read_mds(desc);
+		pnfs_pageio_reset_mds(desc);
 		desc->pg_recoalesce = 1;
 	}
 	nfs_generic_pgio_reset(hdr);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 552b2e9..52310df 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -186,6 +186,7 @@ void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *
 int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
 void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			        struct nfs_page *req, u64 wb_size);
+void pnfs_pageio_reset_mds(struct nfs_pageio_descriptor *pgio);
 int pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc);
 size_t pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio,
 			    struct nfs_page *prev, struct nfs_page *req);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index b1532b7..c9217e6 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -68,13 +68,6 @@ void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_init_read);
 
-void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
-{
-	pgio->pg_ops = &nfs_pgio_rw_ops;
-	pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->rsize;
-}
-EXPORT_SYMBOL_GPL(nfs_pageio_reset_read_mds);
-
 int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 		       struct page *page)
 {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1baca45..2929648 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1063,14 +1063,6 @@ void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_init_write);
 
-void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
-{
-	pgio->pg_ops = &nfs_pgio_rw_ops;
-	pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->wsize;
-}
-EXPORT_SYMBOL_GPL(nfs_pageio_reset_write_mds);
-
-
 void nfs_commit_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_commit_data *data = calldata;
-- 
1.9.2

