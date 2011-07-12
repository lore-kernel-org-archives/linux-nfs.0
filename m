Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55428 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754872Ab1GLTaL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 15:30:11 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/8] NFS: Move the pnfs write code into pnfs.c
Date: Tue, 12 Jul 2011 15:29:53 -0400
Message-Id: <1310498994-12685-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1310498994-12685-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1310498994-12685-1-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-2-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-3-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-4-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-5-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-6-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

...and ensure that we recoalese to take into account differences in
differences in block sizes when falling back to write through the MDS.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/internal.h            |    4 +++
 fs/nfs/nfs4filelayout.c      |    2 +-
 fs/nfs/objlayout/objio_osd.c |    2 +-
 fs/nfs/pnfs.c                |   57 ++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h                |   10 +------
 fs/nfs/write.c               |   39 +++++++++++++---------------
 include/linux/nfs_page.h     |    3 --
 7 files changed, 80 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 795b3e0..758db89 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -305,8 +305,12 @@ extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_readdata_release(struct nfs_read_data *rdata);
 
 /* write.c */
+extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
+		struct list_head *head);
 extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
 				  struct inode *inode, int ioflags);
+extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
+extern void nfs_writedata_release(struct nfs_write_data *wdata);
 extern void nfs_commit_free(struct nfs_write_data *p);
 extern int nfs_initiate_write(struct nfs_write_data *data,
 			      struct rpc_clnt *clnt,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index fc556d6..fbc5b42 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -741,7 +741,7 @@ static const struct nfs_pageio_ops filelayout_pg_read_ops = {
 static const struct nfs_pageio_ops filelayout_pg_write_ops = {
 	.pg_init = filelayout_pg_init_write,
 	.pg_test = filelayout_pg_test,
-	.pg_doio = nfs_generic_pg_writepages,
+	.pg_doio = pnfs_generic_pg_writepages,
 };
 
 static bool filelayout_mark_pnfs_commit(struct pnfs_layout_segment *lseg)
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index add6289..7d49bb1 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -1013,7 +1013,7 @@ static const struct nfs_pageio_ops objio_pg_read_ops = {
 static const struct nfs_pageio_ops objio_pg_write_ops = {
 	.pg_init = pnfs_generic_pg_init_write,
 	.pg_test = objio_pg_test,
-	.pg_doio = nfs_generic_pg_writepages,
+	.pg_doio = pnfs_generic_pg_writepages,
 };
 
 static struct pnfs_layoutdriver_type objlayout_type = {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9eca5a8..93c7329 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1170,15 +1170,30 @@ pnfs_ld_write_done(struct nfs_write_data *data)
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
 
-enum pnfs_try_status
+static void
+pnfs_write_through_mds(struct nfs_pageio_descriptor *desc,
+		struct nfs_write_data *data)
+{
+	list_splice_tail_init(&data->pages, &desc->pg_list);
+	if (data->req && list_empty(&data->req->wb_list))
+		nfs_list_add_request(data->req, &desc->pg_list);
+	nfs_pageio_reset_write_mds(desc);
+	desc->pg_recoalesce = 1;
+	nfs_writedata_release(data);
+}
+
+static enum pnfs_try_status
 pnfs_try_to_write_data(struct nfs_write_data *wdata,
-			const struct rpc_call_ops *call_ops, int how)
+			const struct rpc_call_ops *call_ops,
+			struct pnfs_layout_segment *lseg,
+			int how)
 {
 	struct inode *inode = wdata->inode;
 	enum pnfs_try_status trypnfs;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
 	wdata->mds_ops = call_ops;
+	wdata->lseg = get_lseg(lseg);
 
 	dprintk("%s: Writing ino:%lu %u@%llu (how %d)\n", __func__,
 		inode->i_ino, wdata->args.count, wdata->args.offset, how);
@@ -1194,6 +1209,44 @@ pnfs_try_to_write_data(struct nfs_write_data *wdata,
 	return trypnfs;
 }
 
+static void
+pnfs_do_multiple_writes(struct nfs_pageio_descriptor *desc, struct list_head *head, int how)
+{
+	struct nfs_write_data *data;
+	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
+	struct pnfs_layout_segment *lseg = desc->pg_lseg;
+
+	desc->pg_lseg = NULL;
+	while (!list_empty(head)) {
+		enum pnfs_try_status trypnfs;
+
+		data = list_entry(head->next, struct nfs_write_data, list);
+		list_del_init(&data->list);
+
+		trypnfs = pnfs_try_to_write_data(data, call_ops, lseg, how);
+		if (trypnfs == PNFS_NOT_ATTEMPTED)
+			pnfs_write_through_mds(desc, data);
+	}
+	put_lseg(lseg);
+}
+
+int
+pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
+{
+	LIST_HEAD(head);
+	int ret;
+
+	ret = nfs_generic_flush(desc, &head);
+	if (ret != 0) {
+		put_lseg(desc->pg_lseg);
+		desc->pg_lseg = NULL;
+		return ret;
+	}
+	pnfs_do_multiple_writes(desc, &head, desc->pg_ioflags);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
+
 /*
  * Called by non rpc-based layout drivers
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c40ffa5..078670d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -155,11 +155,10 @@ bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *, int)
 
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
-enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
-					     const struct rpc_call_ops *, int);
 void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *);
 int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
 void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *, struct nfs_page *);
+int pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc);
 bool pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_free_lseg_list(struct list_head *tmp_list);
@@ -328,13 +327,6 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
 {
 }
 
-static inline enum pnfs_try_status
-pnfs_try_to_write_data(struct nfs_write_data *data,
-		       const struct rpc_call_ops *call_ops, int how)
-{
-	return PNFS_NOT_ATTEMPTED;
-}
-
 static inline int pnfs_return_layout(struct inode *ino)
 {
 	return 0;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 80bd74f..e18d842 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -97,7 +97,7 @@ void nfs_writedata_free(struct nfs_write_data *p)
 	mempool_free(p, nfs_wdata_mempool);
 }
 
-static void nfs_writedata_release(struct nfs_write_data *wdata)
+void nfs_writedata_release(struct nfs_write_data *wdata)
 {
 	put_lseg(wdata->lseg);
 	put_nfs_open_context(wdata->args.context);
@@ -887,25 +887,15 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 
 static int nfs_do_write(struct nfs_write_data *data,
 		const struct rpc_call_ops *call_ops,
-		struct pnfs_layout_segment *lseg,
 		int how)
 {
 	struct inode *inode = data->args.context->path.dentry->d_inode;
 
-	if (lseg != NULL) {
-		data->lseg = get_lseg(lseg);
-		if (pnfs_try_to_write_data(data, call_ops, how) == PNFS_ATTEMPTED)
-			return 0;
-		put_lseg(data->lseg);
-		data->lseg = NULL;
-	}
-
 	return nfs_initiate_write(data, NFS_CLIENT(inode), call_ops, how);
 }
 
 static int nfs_do_multiple_writes(struct list_head *head,
 		const struct rpc_call_ops *call_ops,
-		struct pnfs_layout_segment *lseg,
 		int how)
 {
 	struct nfs_write_data *data;
@@ -917,7 +907,7 @@ static int nfs_do_multiple_writes(struct list_head *head,
 		data = list_entry(head->next, struct nfs_write_data, list);
 		list_del_init(&data->list);
 		
-		ret2 = nfs_do_write(data, call_ops, lseg, how);
+		ret2 = nfs_do_write(data, call_ops, how);
 		 if (ret == 0)
 			 ret = ret2;
 	}
@@ -1037,23 +1027,24 @@ out:
 	return ret;
 }
 
-int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
+int nfs_generic_flush(struct nfs_pageio_descriptor *desc, struct list_head *head)
+{
+	if (desc->pg_bsize < PAGE_CACHE_SIZE)
+		return nfs_flush_multi(desc, head);
+	return nfs_flush_one(desc, head);
+}
+
+static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 {
 	LIST_HEAD(head);
 	int ret;
 
-	if (desc->pg_bsize < PAGE_CACHE_SIZE)
-		ret = nfs_flush_multi(desc, &head);
-	else
-		ret = nfs_flush_one(desc, &head);
+	ret = nfs_generic_flush(desc, &head);
 	if (ret == 0)
 		ret = nfs_do_multiple_writes(&head, desc->pg_rpc_callops,
-				desc->pg_lseg, desc->pg_ioflags);
-	put_lseg(desc->pg_lseg);
-	desc->pg_lseg = NULL;
+				desc->pg_ioflags);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(nfs_generic_pg_writepages);
 
 static const struct nfs_pageio_ops nfs_pageio_write_ops = {
 	.pg_test = nfs_generic_pg_test,
@@ -1068,6 +1059,12 @@ void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_init_write_mds);
 
+void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio)
+{
+	pgio->pg_ops = &nfs_pageio_write_ops;
+	pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->wsize;
+}
+
 static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 				  struct inode *inode, int ioflags)
 {
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 0a48f84..e2791a2 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -108,9 +108,6 @@ extern	void nfs_unlock_request(struct nfs_page *req);
 extern	int nfs_set_page_tag_locked(struct nfs_page *req);
 extern  void nfs_clear_page_tag_locked(struct nfs_page *req);
 
-extern	int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc);
-
-
 /*
  * Lock the page of an asynchronous request without getting a new reference
  */
-- 
1.7.6

