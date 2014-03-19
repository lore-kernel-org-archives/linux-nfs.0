Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60832 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933739AbaCSQkR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Mar 2014 12:40:17 -0400
Date: Wed, 19 Mar 2014 09:40:17 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2 v2] nfs: remove ->read_pageio_init from rpc ops
Message-ID: <20140319164017.GB26364@infradead.org>
References: <20140319164003.GA26364@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140319164003.GA26364@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We only use one static ops vector or grab it from the layout driver,
so clean up the whole code path to make that more obvious.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/direct.c         |    3 +--
 fs/nfs/nfs3proc.c       |    1 -
 fs/nfs/nfs4proc.c       |    1 -
 fs/nfs/pnfs.c           |   13 -------------
 fs/nfs/pnfs.h           |    9 ---------
 fs/nfs/proc.c           |    1 -
 fs/nfs/read.c           |   16 +++++++++++-----
 include/linux/nfs_xdr.h |    2 --
 8 files changed, 12 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index bd9d524..bb6fcb8 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -424,8 +424,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	size_t requested_bytes = 0;
 	unsigned long seg;
 
-	NFS_PROTO(dreq->inode)->read_pageio_init(&desc, dreq->inode,
-			     &nfs_direct_read_completion_ops);
+	nfs_pageio_init_read(&desc, dreq->inode, &nfs_direct_read_completion_ops);
 	get_dreq(dreq);
 	desc.pg_dreq = dreq;
 	atomic_inc(&inode->i_dio_count);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 5ae9abf..feb2049 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -982,7 +982,6 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.pathconf	= nfs3_proc_pathconf,
 	.decode_dirent	= nfs3_decode_dirent,
 	.read_setup	= nfs3_proc_read_setup,
-	.read_pageio_init = nfs_pageio_init_read,
 	.read_rpc_prepare = nfs3_proc_read_rpc_prepare,
 	.read_done	= nfs3_read_done,
 	.write_setup	= nfs3_proc_write_setup,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7759b5aa..9a8eb6a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8462,7 +8462,6 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.set_capabilities = nfs4_server_capabilities,
 	.decode_dirent	= nfs4_decode_dirent,
 	.read_setup	= nfs4_proc_read_setup,
-	.read_pageio_init = pnfs_pageio_init_read,
 	.read_rpc_prepare = nfs4_proc_read_rpc_prepare,
 	.read_done	= nfs4_read_done,
 	.write_setup	= nfs4_proc_write_setup,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d8be82d..c965f7d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1434,19 +1434,6 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_init_write);
 
-void
-pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode,
-		      const struct nfs_pgio_completion_ops *compl_ops)
-{
-	struct nfs_server *server = NFS_SERVER(inode);
-	struct pnfs_layoutdriver_type *ld = server->pnfs_curr_ld;
-
-	if (ld == NULL)
-		nfs_pageio_init_read(pgio, inode, compl_ops);
-	else
-		nfs_pageio_init(pgio, inode, ld->pg_read_ops, compl_ops, server->rsize, 0);
-}
-
 bool
 pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		     struct nfs_page *req)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index e9ac8fb..94a9a18 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -180,9 +180,6 @@ extern int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp);
 void pnfs_get_layout_hdr(struct pnfs_layout_hdr *lo);
 void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
 
-void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
-			   const struct nfs_pgio_completion_ops *);
-
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *);
@@ -459,12 +456,6 @@ static inline void unset_pnfs_layoutdriver(struct nfs_server *s)
 {
 }
 
-static inline void pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode,
-					 const struct nfs_pgio_completion_ops *compl_ops)
-{
-	nfs_pageio_init_read(pgio, inode, compl_ops);
-}
-
 static inline int
 pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how,
 		 struct nfs_commit_info *cinfo)
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 6ea2bed..7676973 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -760,7 +760,6 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.pathconf	= nfs_proc_pathconf,
 	.decode_dirent	= nfs2_decode_dirent,
 	.read_setup	= nfs_proc_read_setup,
-	.read_pageio_init = nfs_pageio_init_read,
 	.read_rpc_prepare = nfs_proc_read_rpc_prepare,
 	.read_done	= nfs_read_done,
 	.write_setup	= nfs_proc_write_setup,
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 411aedd..6fb4b8e 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -24,6 +24,7 @@
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
@@ -117,10 +118,15 @@ void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 			      struct inode *inode,
 			      const struct nfs_pgio_completion_ops *compl_ops)
 {
-	nfs_pageio_init(pgio, inode, &nfs_pageio_read_ops, compl_ops,
-			NFS_SERVER(inode)->rsize, 0);
+	struct nfs_server *server = NFS_SERVER(inode);
+	const struct nfs_pageio_ops *pg_ops = &nfs_pageio_read_ops;
+
+#ifdef CONFIG_NFS_V4_1
+	if (server->pnfs_curr_ld)
+		pg_ops = server->pnfs_curr_ld->pg_read_ops;
+#endif
+	nfs_pageio_init(pgio, inode, pg_ops, compl_ops, server->rsize, 0);
 }
-EXPORT_SYMBOL_GPL(nfs_pageio_init_read);
 
 void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
 {
@@ -147,7 +153,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	if (len < PAGE_CACHE_SIZE)
 		zero_user_segment(page, len, PAGE_CACHE_SIZE);
 
-	NFS_PROTO(inode)->read_pageio_init(&pgio, inode, &nfs_async_read_completion_ops);
+	nfs_pageio_init_read(&pgio, inode, &nfs_async_read_completion_ops);
 	nfs_pageio_add_request(&pgio, new);
 	nfs_pageio_complete(&pgio);
 	NFS_I(inode)->read_io += pgio.pg_bytes_written;
@@ -654,7 +660,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
-	NFS_PROTO(inode)->read_pageio_init(&pgio, inode, &nfs_async_read_completion_ops);
+	nfs_pageio_init_read(&pgio, inode, &nfs_async_read_completion_ops);
 
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ed12f03..0146485 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1462,8 +1462,6 @@ struct nfs_rpc_ops {
 	int	(*set_capabilities)(struct nfs_server *, struct nfs_fh *);
 	int	(*decode_dirent)(struct xdr_stream *, struct nfs_entry *, int);
 	void	(*read_setup)   (struct nfs_read_data *, struct rpc_message *);
-	void	(*read_pageio_init)(struct nfs_pageio_descriptor *, struct inode *,
-				    const struct nfs_pgio_completion_ops *);
 	int	(*read_rpc_prepare)(struct rpc_task *, struct nfs_read_data *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
 	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
-- 
1.7.10.4

