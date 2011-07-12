Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55428 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754107Ab1GLTaK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 15:30:10 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/8] NFS: Move the pnfs read code into pnfs.c
Date: Tue, 12 Jul 2011 15:29:52 -0400
Message-Id: <1310498994-12685-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1310498994-12685-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1310498994-12685-1-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-2-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-3-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-4-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-5-git-send-email-Trond.Myklebust@netapp.com>
 <1310498994-12685-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

...and ensure that we recoalese to take into account differences in
block sizes when falling back to read through the MDS.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/internal.h            |    4 +++
 fs/nfs/nfs4filelayout.c      |    2 +-
 fs/nfs/objlayout/objio_osd.c |    2 +-
 fs/nfs/pnfs.c                |   57 ++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h                |   10 +------
 fs/nfs/read.c                |   46 ++++++++++++++-------------------
 include/linux/nfs_page.h     |    1 -
 7 files changed, 82 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 31e8b50..795b3e0 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -295,10 +295,14 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
 extern int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 			     const struct rpc_call_ops *call_ops);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
+extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
+		struct list_head *head);
 
 struct nfs_pageio_descriptor;
 extern void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
 		struct inode *inode);
+extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
+extern void nfs_readdata_release(struct nfs_read_data *rdata);
 
 /* write.c */
 extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index af9bf9e..fc556d6 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -735,7 +735,7 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 static const struct nfs_pageio_ops filelayout_pg_read_ops = {
 	.pg_init = filelayout_pg_init_read,
 	.pg_test = filelayout_pg_test,
-	.pg_doio = nfs_generic_pg_readpages,
+	.pg_doio = pnfs_generic_pg_readpages,
 };
 
 static const struct nfs_pageio_ops filelayout_pg_write_ops = {
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 70272d5..add6289 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -1007,7 +1007,7 @@ static bool objio_pg_test(struct nfs_pageio_descriptor *pgio,
 static const struct nfs_pageio_ops objio_pg_read_ops = {
 	.pg_init = pnfs_generic_pg_init_read,
 	.pg_test = objio_pg_test,
-	.pg_doio = nfs_generic_pg_readpages,
+	.pg_doio = pnfs_generic_pg_readpages,
 };
 
 static const struct nfs_pageio_ops objio_pg_write_ops = {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5b3cc3f..9eca5a8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -28,6 +28,7 @@
  */
 
 #include <linux/nfs_fs.h>
+#include <linux/nfs_page.h>
 #include "internal.h"
 #include "pnfs.h"
 #include "iostat.h"
@@ -1216,18 +1217,32 @@ pnfs_ld_read_done(struct nfs_read_data *data)
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
 
+static void
+pnfs_read_through_mds(struct nfs_pageio_descriptor *desc,
+		struct nfs_read_data *data)
+{
+	list_splice_tail_init(&data->pages, &desc->pg_list);
+	if (data->req && list_empty(&data->req->wb_list))
+		nfs_list_add_request(data->req, &desc->pg_list);
+	nfs_pageio_reset_read_mds(desc);
+	desc->pg_recoalesce = 1;
+	nfs_readdata_release(data);
+}
+
 /*
  * Call the appropriate parallel I/O subsystem read function.
  */
-enum pnfs_try_status
+static enum pnfs_try_status
 pnfs_try_to_read_data(struct nfs_read_data *rdata,
-		       const struct rpc_call_ops *call_ops)
+		       const struct rpc_call_ops *call_ops,
+		       struct pnfs_layout_segment *lseg)
 {
 	struct inode *inode = rdata->inode;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	enum pnfs_try_status trypnfs;
 
 	rdata->mds_ops = call_ops;
+	rdata->lseg = get_lseg(lseg);
 
 	dprintk("%s: Reading ino:%lu %u@%llu\n",
 		__func__, inode->i_ino, rdata->args.count, rdata->args.offset);
@@ -1243,6 +1258,44 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 	return trypnfs;
 }
 
+static void
+pnfs_do_multiple_reads(struct nfs_pageio_descriptor *desc, struct list_head *head)
+{
+	struct nfs_read_data *data;
+	const struct rpc_call_ops *call_ops = desc->pg_rpc_callops;
+	struct pnfs_layout_segment *lseg = desc->pg_lseg;
+
+	desc->pg_lseg = NULL;
+	while (!list_empty(head)) {
+		enum pnfs_try_status trypnfs;
+
+		data = list_entry(head->next, struct nfs_read_data, list);
+		list_del_init(&data->list);
+
+		trypnfs = pnfs_try_to_read_data(data, call_ops, lseg);
+		if (trypnfs == PNFS_NOT_ATTEMPTED)
+			pnfs_read_through_mds(desc, data);
+	}
+	put_lseg(lseg);
+}
+
+int
+pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
+{
+	LIST_HEAD(head);
+	int ret;
+
+	ret = nfs_generic_pagein(desc, &head);
+	if (ret != 0) {
+		put_lseg(desc->pg_lseg);
+		desc->pg_lseg = NULL;
+		return ret;
+	}
+	pnfs_do_multiple_reads(desc, &head);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(pnfs_generic_pg_readpages);
+
 /*
  * Currently there is only one (whole file) write lseg.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a59736e..c40ffa5 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -157,9 +157,8 @@ void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
 					     const struct rpc_call_ops *, int);
-enum pnfs_try_status pnfs_try_to_read_data(struct nfs_read_data *,
-					    const struct rpc_call_ops *);
 void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *);
+int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
 void pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *, struct nfs_page *);
 bool pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev, struct nfs_page *req);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
@@ -330,13 +329,6 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
 }
 
 static inline enum pnfs_try_status
-pnfs_try_to_read_data(struct nfs_read_data *data,
-		      const struct rpc_call_ops *call_ops)
-{
-	return PNFS_NOT_ATTEMPTED;
-}
-
-static inline enum pnfs_try_status
 pnfs_try_to_write_data(struct nfs_write_data *data,
 		       const struct rpc_call_ops *call_ops, int how)
 {
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 47f92c1..3745eed 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -67,7 +67,7 @@ void nfs_readdata_free(struct nfs_read_data *p)
 	mempool_free(p, nfs_rdata_mempool);
 }
 
-static void nfs_readdata_release(struct nfs_read_data *rdata)
+void nfs_readdata_release(struct nfs_read_data *rdata)
 {
 	put_lseg(rdata->lseg);
 	put_nfs_open_context(rdata->args.context);
@@ -120,6 +120,12 @@ void nfs_pageio_init_read_mds(struct nfs_pageio_descriptor *pgio,
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_init_read_mds);
 
+void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio)
+{
+	pgio->pg_ops = &nfs_pageio_read_ops;
+	pgio->pg_bsize = NFS_SERVER(pgio->pg_inode)->rsize;
+}
+
 static void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 		struct inode *inode)
 {
@@ -235,26 +241,16 @@ static void nfs_read_rpcsetup(struct nfs_page *req, struct nfs_read_data *data,
 }
 
 static int nfs_do_read(struct nfs_read_data *data,
-		const struct rpc_call_ops *call_ops,
-		struct pnfs_layout_segment *lseg)
+		const struct rpc_call_ops *call_ops)
 {
 	struct inode *inode = data->args.context->path.dentry->d_inode;
 
-	if (lseg) {
-		data->lseg = get_lseg(lseg);
-		if (pnfs_try_to_read_data(data, call_ops) == PNFS_ATTEMPTED)
-			return 0;
-		put_lseg(data->lseg);
-		data->lseg = NULL;
-	}
-
 	return nfs_initiate_read(data, NFS_CLIENT(inode), call_ops);
 }
 
 static int
 nfs_do_multiple_reads(struct list_head *head,
-		const struct rpc_call_ops *call_ops,
-		struct pnfs_layout_segment *lseg)
+		const struct rpc_call_ops *call_ops)
 {
 	struct nfs_read_data *data;
 	int ret = 0;
@@ -265,7 +261,7 @@ nfs_do_multiple_reads(struct list_head *head,
 		data = list_entry(head->next, struct nfs_read_data, list);
 		list_del_init(&data->list);
 
-		ret2 = nfs_do_read(data, call_ops, lseg);
+		ret2 = nfs_do_read(data, call_ops);
 		if (ret == 0)
 			ret = ret2;
 	}
@@ -372,25 +368,23 @@ out:
 	return ret;
 }
 
-int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
+int nfs_generic_pagein(struct nfs_pageio_descriptor *desc, struct list_head *head)
+{
+	if (desc->pg_bsize < PAGE_CACHE_SIZE)
+		return nfs_pagein_multi(desc, head);
+	return nfs_pagein_one(desc, head);
+}
+
+static int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 {
 	LIST_HEAD(head);
 	int ret;
 
-	if (desc->pg_bsize < PAGE_CACHE_SIZE)
-		ret = nfs_pagein_multi(desc, &head);
-	else
-		ret = nfs_pagein_one(desc, &head);
-
+	ret = nfs_generic_pagein(desc, &head);
 	if (ret == 0)
-		ret = nfs_do_multiple_reads(&head, desc->pg_rpc_callops,
-				desc->pg_lseg);
-	put_lseg(desc->pg_lseg);
-	desc->pg_lseg = NULL;
+		ret = nfs_do_multiple_reads(&head, desc->pg_rpc_callops);
 	return ret;
 }
-EXPORT_SYMBOL_GPL(nfs_generic_pg_readpages);
-
 
 static const struct nfs_pageio_ops nfs_pageio_read_ops = {
 	.pg_test = nfs_generic_pg_test,
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 7241b2a..0a48f84 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -108,7 +108,6 @@ extern	void nfs_unlock_request(struct nfs_page *req);
 extern	int nfs_set_page_tag_locked(struct nfs_page *req);
 extern  void nfs_clear_page_tag_locked(struct nfs_page *req);
 
-extern	int nfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
 extern	int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc);
 
 
-- 
1.7.6

