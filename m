Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41527 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757975Ab2FTTyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Jun 2012 15:54:09 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 09/10] NFS: Create an write_pageio_init() function
Date: Wed, 20 Jun 2012 15:53:48 -0400
Message-Id: <1340222029-18027-10-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
References: <1340222029-18027-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

pNFS needs to select a write function based on the layout driver
currently in use, so I let each NFS version decide how to best handle
initializing writes.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/internal.h       |  2 +-
 fs/nfs/nfs3proc.c       |  1 +
 fs/nfs/nfs4proc.c       |  1 +
 fs/nfs/pnfs.c           | 11 +++++------
 fs/nfs/pnfs.h           |  6 +++---
 fs/nfs/proc.c           |  1 +
 fs/nfs/write.c          | 18 ++++++------------
 include/linux/nfs_xdr.h |  2 ++
 8 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b312112..7edc172 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -320,7 +320,7 @@ extern struct nfs_write_header *nfs_writehdr_alloc(void);
 extern void nfs_writehdr_free(struct nfs_pgio_header *hdr);
 extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
 			     struct nfs_pgio_header *hdr);
-extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
+extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 			struct inode *inode, int ioflags,
 			const struct nfs_pgio_completion_ops *compl_ops);
 extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 9864d05..f3344f7 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -925,6 +925,7 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.read_rpc_prepare = nfs3_proc_read_rpc_prepare,
 	.read_done	= nfs3_read_done,
 	.write_setup	= nfs3_proc_write_setup,
+	.write_pageio_init = nfs_pageio_init_write,
 	.write_rpc_prepare = nfs3_proc_write_rpc_prepare,
 	.write_done	= nfs3_write_done,
 	.commit_setup	= nfs3_proc_commit_setup,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 31d9c80..9ac9c40 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6794,6 +6794,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.read_rpc_prepare = nfs4_proc_read_rpc_prepare,
 	.read_done	= nfs4_read_done,
 	.write_setup	= nfs4_proc_write_setup,
+	.write_pageio_init = pnfs_pageio_init_write,
 	.write_rpc_prepare = nfs4_proc_write_rpc_prepare,
 	.write_done	= nfs4_write_done,
 	.commit_setup	= nfs4_proc_commit_setup,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9c83060..2617831 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1222,7 +1222,7 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode,
 		nfs_pageio_init(pgio, inode, ld->pg_read_ops, compl_ops, server->rsize, 0);
 }
 
-bool
+void
 pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode,
 		       int ioflags,
 		       const struct nfs_pgio_completion_ops *compl_ops)
@@ -1231,10 +1231,9 @@ pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode,
 	struct pnfs_layoutdriver_type *ld = server->pnfs_curr_ld;
 
 	if (ld == NULL)
-		return false;
-	nfs_pageio_init(pgio, inode, ld->pg_write_ops, compl_ops,
-			server->wsize, ioflags);
-	return true;
+		nfs_pageio_init_write(pgio, inode, ioflags, compl_ops);
+	else
+		nfs_pageio_init(pgio, inode, ld->pg_write_ops, compl_ops, server->wsize, ioflags);
 }
 
 bool
@@ -1271,7 +1270,7 @@ int pnfs_write_done_resend_to_mds(struct inode *inode,
 	LIST_HEAD(failed);
 
 	/* Resend all requests through the MDS */
-	nfs_pageio_init_write_mds(&pgio, inode, FLUSH_STABLE, compl_ops);
+	nfs_pageio_init_write(&pgio, inode, FLUSH_STABLE, compl_ops);
 	while (!list_empty(head)) {
 		struct nfs_page *req = nfs_list_entry(head->next);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 80ee891..592beb0 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -180,7 +180,7 @@ void put_lseg(struct pnfs_layout_segment *lseg);
 
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
 			   const struct nfs_pgio_completion_ops *);
-bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *,
+void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *,
 			    int, const struct nfs_pgio_completion_ops *);
 
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
@@ -444,10 +444,10 @@ static inline void pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, str
 	nfs_pageio_init_read(pgio, inode, compl_ops);
 }
 
-static inline bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags,
+static inline void pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode, int ioflags,
 					  const struct nfs_pgio_completion_ops *compl_ops)
 {
-	return false;
+	nfs_pageio_init_write(pgio, inode, ioflags, compl_ops);
 }
 
 static inline int
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 6fea6e1..cf64997 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -782,6 +782,7 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.read_rpc_prepare = nfs_proc_read_rpc_prepare,
 	.read_done	= nfs_read_done,
 	.write_setup	= nfs_proc_write_setup,
+	.write_pageio_init = nfs_pageio_init_write,
 	.write_rpc_prepare = nfs_proc_write_rpc_prepare,
 	.write_done	= nfs_write_done,
 	.commit_setup	= nfs_proc_commit_setup,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f163355..c11fb00 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -336,8 +336,10 @@ static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc
 	struct nfs_pageio_descriptor pgio;
 	int err;
 
-	nfs_pageio_init_write(&pgio, page->mapping->host, wb_priority(wbc),
-			      &nfs_async_write_completion_ops);
+	NFS_PROTO(page->mapping->host)->write_pageio_init(&pgio,
+							  page->mapping->host,
+							  wb_priority(wbc),
+							  &nfs_async_write_completion_ops);
 	err = nfs_do_writepage(page, wbc, &pgio);
 	nfs_pageio_complete(&pgio);
 	if (err < 0)
@@ -380,8 +382,7 @@ int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
-	nfs_pageio_init_write(&pgio, inode, wb_priority(wbc),
-			      &nfs_async_write_completion_ops);
+	NFS_PROTO(inode)->write_pageio_init(&pgio, inode, wb_priority(wbc), &nfs_async_write_completion_ops);
 	err = write_cache_pages(mapping, wbc, nfs_writepages_callback, &pgio);
 	nfs_pageio_complete(&pgio);
 
@@ -1202,7 +1203,7 @@ static const struct nfs_pageio_ops nfs_pageio_write_ops = {
 	.pg_doio = nfs_generic_pg_writepages,
 };
 
-void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
+void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 			       struct inode *inode, int ioflags,
 			       const struct nfs_pgio_completion_ops *compl_ops)
 {
@@ -1217,13 +1218,6 @@ void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_reset_write_mds);
 
-void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
-			   struct inode *inode, int ioflags,
-			   const struct nfs_pgio_completion_ops *compl_ops)
-{
-	if (!pnfs_pageio_init_write(pgio, inode, ioflags, compl_ops))
-		nfs_pageio_init_write_mds(pgio, inode, ioflags, compl_ops);
-}
 
 void nfs_write_prepare(struct rpc_task *task, void *calldata)
 {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index e00b8b3..8ed8ec6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1413,6 +1413,8 @@ struct nfs_rpc_ops {
 	void	(*read_rpc_prepare)(struct rpc_task *, struct nfs_read_data *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
 	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
+	void	(*write_pageio_init)(struct nfs_pageio_descriptor *, struct inode *, int,
+				     const struct nfs_pgio_completion_ops *);
 	void	(*write_rpc_prepare)(struct rpc_task *, struct nfs_write_data *);
 	int	(*write_done)  (struct rpc_task *, struct nfs_write_data *);
 	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
-- 
1.7.11

