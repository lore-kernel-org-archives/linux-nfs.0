Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60829 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755890AbaCSQkE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Mar 2014 12:40:04 -0400
Date: Wed, 19 Mar 2014 09:40:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2 v2] nfs: remove ->write_pageio_init from rpc ops
Message-ID: <20140319164003.GA26364@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We only use one static ops vector or grab it from the layout driver,
so clean up the whole code path to make that more obvious.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/direct.c         |    4 ++--
 fs/nfs/nfs3proc.c       |    1 -
 fs/nfs/nfs4proc.c       |    1 -
 fs/nfs/pnfs.c           |   14 --------------
 fs/nfs/pnfs.h           |    8 --------
 fs/nfs/proc.c           |    1 -
 fs/nfs/write.c          |   20 ++++++++++++--------
 include/linux/nfs_xdr.h |    2 --
 8 files changed, 14 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index b8797ae..bd9d524 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -564,7 +564,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	dreq->count = 0;
 	get_dreq(dreq);
 
-	NFS_PROTO(dreq->inode)->write_pageio_init(&desc, dreq->inode, FLUSH_STABLE,
+	nfs_pageio_init_write(&desc, dreq->inode, FLUSH_STABLE,
 			      &nfs_direct_write_completion_ops);
 	desc.pg_dreq = dreq;
 
@@ -874,7 +874,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	size_t requested_bytes = 0;
 	unsigned long seg;
 
-	NFS_PROTO(inode)->write_pageio_init(&desc, inode, FLUSH_COND_STABLE,
+	nfs_pageio_init_write(&desc, inode, FLUSH_COND_STABLE,
 			      &nfs_direct_write_completion_ops);
 	desc.pg_dreq = dreq;
 	get_dreq(dreq);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index aa9bc97..5ae9abf 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -986,7 +986,6 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.read_rpc_prepare = nfs3_proc_read_rpc_prepare,
 	.read_done	= nfs3_read_done,
 	.write_setup	= nfs3_proc_write_setup,
-	.write_pageio_init = nfs_pageio_init_write,
 	.write_rpc_prepare = nfs3_proc_write_rpc_prepare,
 	.write_done	= nfs3_write_done,
 	.commit_setup	= nfs3_proc_commit_setup,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8672323..7759b5aa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8466,7 +8466,6 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.read_rpc_prepare = nfs4_proc_read_rpc_prepare,
 	.read_done	= nfs4_read_done,
 	.write_setup	= nfs4_proc_write_setup,
-	.write_pageio_init = pnfs_pageio_init_write,
 	.write_rpc_prepare = nfs4_proc_write_rpc_prepare,
 	.write_done	= nfs4_write_done,
 	.commit_setup	= nfs4_proc_commit_setup,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cb53d45..d8be82d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1447,20 +1447,6 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode,
 		nfs_pageio_init(pgio, inode, ld->pg_read_ops, compl_ops, server->rsize, 0);
 }
 
-void
-pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode,
-		       int ioflags,
-		       const struct nfs_pgio_completion_ops *compl_ops)
-{
-	struct nfs_server *server = NFS_SERVER(inode);
-	struct pnfs_layoutdriver_type *ld = server->pnfs_curr_ld;
-
-	if (ld == NULL)
-		nfs_pageio_init_write(pgio, inode, ioflags, compl_ops);
-	else
-		nfs_pageio_init(pgio, inode, ld->pg_write_ops, compl_ops, server->wsize, ioflags);
-}
-
 bool
 pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 		     struct nfs_page *req)
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 0237939..e9ac8fb 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -182,8 +182,6 @@ void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
 
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   const struct nfs_pgio_completion_ops *);
-void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *,
-			    int, const struct nfs_pgio_completion_ops *);
 
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
 void unset_pnfs_layoutdriver(struct nfs_server *);
@@ -467,12 +465,6 @@ static inline void pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, str
 	nfs_pageio_init_read(pgio, inode, compl_ops);
 }
 
-static inline void pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags,
-					  const struct nfs_pgio_completion_ops *compl_ops)
-{
-	nfs_pageio_init_write(pgio, inode, ioflags, compl_ops);
-}
-
 static inline int
 pnfs_commit_list(struct inode *inode, struct list_head *mds_pages, int how,
 		 struct nfs_commit_info *cinfo)
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index fddbba2..6ea2bed 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -764,7 +764,6 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.read_rpc_prepare = nfs_proc_read_rpc_prepare,
 	.read_done	= nfs_read_done,
 	.write_setup	= nfs_proc_write_setup,
-	.write_pageio_init = nfs_pageio_init_write,
 	.write_rpc_prepare = nfs_proc_write_rpc_prepare,
 	.write_done	= nfs_write_done,
 	.commit_setup	= nfs_proc_commit_setup,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9a3b6a4..2081ed1 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -354,10 +354,8 @@ static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc
 	struct nfs_pageio_descriptor pgio;
 	int err;
 
-	NFS_PROTO(page_file_mapping(page)->host)->write_pageio_init(&pgio,
-							  page->mapping->host,
-							  wb_priority(wbc),
-							  &nfs_async_write_completion_ops);
+	nfs_pageio_init_write(&pgio, page->mapping->host, wb_priority(wbc),
+				&nfs_async_write_completion_ops);
 	err = nfs_do_writepage(page, wbc, &pgio);
 	nfs_pageio_complete(&pgio);
 	if (err < 0)
@@ -400,7 +398,8 @@ int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
-	NFS_PROTO(inode)->write_pageio_init(&pgio, inode, wb_priority(wbc), &nfs_async_write_completion_ops);
+	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc),
+				&nfs_async_write_completion_ops);
 	err = write_cache_pages(mapping, wbc, nfs_writepages_callback, &pgio);
 	nfs_pageio_complete(&pgio);
 
@@ -1285,10 +1284,15 @@ void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 			       struct inode *inode, int ioflags,
 			       const struct nfs_pgio_completion_ops *compl_ops)
 {
-	nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops, compl_ops,
-				NFS_SERVER(inode)->wsize, ioflags);
+	struct nfs_server *server = NFS_SERVER(inode);
+	const struct nfs_pageio_ops *pg_ops = &nfs_pageio_write_ops;
+
+#ifdef CONFIG_NFS_V4_1
+	if (server->pnfs_curr_ld)
+		pg_ops = server->pnfs_curr_ld->pg_write_ops;
+#endif
+	nfs_pageio_init(pgio, inode, pg_ops, compl_ops, server->wsize, ioflags);
 }
-EXPORT_SYMBOL_GPL(nfs_pageio_init_write);
 
 void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
 {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b2fb167..ed12f03 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1467,8 +1467,6 @@ struct nfs_rpc_ops {
 	int	(*read_rpc_prepare)(struct rpc_task *, struct nfs_read_data *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
 	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
-	void	(*write_pageio_init)(struct nfs_pageio_descriptor *, struct inode *, int,
-				     const struct nfs_pgio_completion_ops *);
 	int	(*write_rpc_prepare)(struct rpc_task *, struct nfs_write_data *);
 	int	(*write_done)  (struct rpc_task *, struct nfs_write_data *);
 	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
-- 
1.7.10.4

