Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:36628 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337AbaEFNNA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 09:13:00 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [PATCH v3 11/17] NFS: Create a common rpcsetup function for reads and writes
Date: Tue, 6 May 2014 09:12:34 -0400
Message-ID: <1399381960-3019-12-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1399381960-3019-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

Write adds a little bit of code dealing with flush flags, but since
"how" will always be 0 when reading we can share the code.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/internal.h |  3 +++
 fs/nfs/pagelist.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/read.c     | 26 ++------------------------
 fs/nfs/write.c    | 46 ++++------------------------------------------
 4 files changed, 53 insertions(+), 66 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index e34220f..519864b 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -242,6 +242,8 @@ struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *);
 void nfs_rw_header_free(struct nfs_pgio_header *);
 struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *, unsigned int);
 void nfs_pgio_data_release(struct nfs_pgio_data *);
+void nfs_pgio_rpcsetup(struct nfs_pgio_data *, unsigned int, unsigned int, int,
+		       struct nfs_commit_info *);
 
 static inline void nfs_iocounter_init(struct nfs_io_counter *c)
 {
@@ -446,6 +448,7 @@ extern void nfs_init_commit(struct nfs_commit_data *data,
 			    struct nfs_commit_info *cinfo);
 int nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 			 struct nfs_commit_info *cinfo, int max);
+unsigned long nfs_reqs_to_commit(struct nfs_commit_info *);
 int nfs_scan_commit(struct inode *inode, struct list_head *dst,
 		    struct nfs_commit_info *cinfo);
 void nfs_mark_request_commit(struct nfs_page *req,
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index aabff78..0ccd951 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -389,6 +389,50 @@ void nfs_pgio_data_release(struct nfs_pgio_data *data)
 EXPORT_SYMBOL_GPL(nfs_pgio_data_release);
 
 /**
+ * nfs_pgio_rpcsetup - Set up arguments for a pageio call
+ * @data: The pageio data
+ * @count: Number of bytes to read
+ * @offset: Initial offset
+ * @how: How to commit data (writes only)
+ * @cinfo: Commit information for the call (writes only)
+ */
+void nfs_pgio_rpcsetup(struct nfs_pgio_data *data,
+			      unsigned int count, unsigned int offset,
+			      int how, struct nfs_commit_info *cinfo)
+{
+	struct nfs_page *req = data->header->req;
+
+	/* Set up the RPC argument and reply structs
+	 * NB: take care not to mess about with data->commit et al. */
+
+	data->args.fh     = NFS_FH(data->header->inode);
+	data->args.offset = req_offset(req) + offset;
+	/* pnfs_set_layoutcommit needs this */
+	data->mds_offset = data->args.offset;
+	data->args.pgbase = req->wb_pgbase + offset;
+	data->args.pages  = data->pages.pagevec;
+	data->args.count  = count;
+	data->args.context = get_nfs_open_context(req->wb_context);
+	data->args.lock_context = req->wb_lock_context;
+	data->args.stable  = NFS_UNSTABLE;
+	switch (how & (FLUSH_STABLE | FLUSH_COND_STABLE)) {
+	case 0:
+		break;
+	case FLUSH_COND_STABLE:
+		if (nfs_reqs_to_commit(cinfo))
+			break;
+	default:
+		data->args.stable = NFS_FILE_SYNC;
+	}
+
+	data->res.fattr   = &data->fattr;
+	data->res.count   = count;
+	data->res.eof     = 0;
+	data->res.verf    = &data->verf;
+	nfs_fattr_init(&data->fattr);
+}
+
+/**
  * nfs_pgio_prepare - Prepare pageio data to go over the wire
  * @task: The current task
  * @calldata: pageio data to prepare
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index a33490c..0c88c60 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -192,28 +192,6 @@ int nfs_initiate_read(struct rpc_clnt *clnt,
 }
 EXPORT_SYMBOL_GPL(nfs_initiate_read);
 
-/*
- * Set up the NFS read request struct
- */
-static void nfs_read_rpcsetup(struct nfs_pgio_data *data,
-		unsigned int count, unsigned int offset)
-{
-	struct nfs_page *req = data->header->req;
-
-	data->args.fh     = NFS_FH(data->header->inode);
-	data->args.offset = req_offset(req) + offset;
-	data->args.pgbase = req->wb_pgbase + offset;
-	data->args.pages  = data->pages.pagevec;
-	data->args.count  = count;
-	data->args.context = get_nfs_open_context(req->wb_context);
-	data->args.lock_context = req->wb_lock_context;
-
-	data->res.fattr   = &data->fattr;
-	data->res.count   = count;
-	data->res.eof     = 0;
-	nfs_fattr_init(&data->fattr);
-}
-
 static int nfs_do_read(struct nfs_pgio_data *data,
 		const struct rpc_call_ops *call_ops)
 {
@@ -305,7 +283,7 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc,
 			return -ENOMEM;
 		}
 		data->pages.pagevec[0] = page;
-		nfs_read_rpcsetup(data, len, offset);
+		nfs_pgio_rpcsetup(data, len, offset, 0, NULL);
 		list_add(&data->list, &hdr->rpc_list);
 		nbytes -= len;
 		offset += len;
@@ -340,7 +318,7 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc,
 		*pages++ = req->wb_page;
 	}
 
-	nfs_read_rpcsetup(data, desc->pg_count, 0);
+	nfs_pgio_rpcsetup(data, desc->pg_count, 0, 0, NULL);
 	list_add(&data->list, &hdr->rpc_list);
 	desc->pg_rpc_callops = &nfs_pgio_common_ops;
 	return 0;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d877f15..0d367aa 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -603,7 +603,7 @@ out:
 }
 
 #if  IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
-static unsigned long
+unsigned long
 nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
 {
 	return cinfo->mds->ncommit;
@@ -660,7 +660,7 @@ nfs_scan_commit(struct inode *inode, struct list_head *dst,
 }
 
 #else
-static unsigned long nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
+unsigned long nfs_reqs_to_commit(struct nfs_commit_info *cinfo)
 {
 	return 0;
 }
@@ -987,44 +987,6 @@ out:
 }
 EXPORT_SYMBOL_GPL(nfs_initiate_write);
 
-/*
- * Set up the argument/result storage required for the RPC call.
- */
-static void nfs_write_rpcsetup(struct nfs_pgio_data *data,
-		unsigned int count, unsigned int offset,
-		int how, struct nfs_commit_info *cinfo)
-{
-	struct nfs_page *req = data->header->req;
-
-	/* Set up the RPC argument and reply structs
-	 * NB: take care not to mess about with data->commit et al. */
-
-	data->args.fh     = NFS_FH(data->header->inode);
-	data->args.offset = req_offset(req) + offset;
-	/* pnfs_set_layoutcommit needs this */
-	data->mds_offset = data->args.offset;
-	data->args.pgbase = req->wb_pgbase + offset;
-	data->args.pages  = data->pages.pagevec;
-	data->args.count  = count;
-	data->args.context = get_nfs_open_context(req->wb_context);
-	data->args.lock_context = req->wb_lock_context;
-	data->args.stable  = NFS_UNSTABLE;
-	switch (how & (FLUSH_STABLE | FLUSH_COND_STABLE)) {
-	case 0:
-		break;
-	case FLUSH_COND_STABLE:
-		if (nfs_reqs_to_commit(cinfo))
-			break;
-	default:
-		data->args.stable = NFS_FILE_SYNC;
-	}
-
-	data->res.fattr   = &data->fattr;
-	data->res.count   = count;
-	data->res.verf    = &data->verf;
-	nfs_fattr_init(&data->fattr);
-}
-
 static int nfs_do_write(struct nfs_pgio_data *data,
 		const struct rpc_call_ops *call_ops,
 		int how)
@@ -1129,7 +1091,7 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc,
 			return -ENOMEM;
 		}
 		data->pages.pagevec[0] = page;
-		nfs_write_rpcsetup(data, len, offset, desc->pg_ioflags, &cinfo);
+		nfs_pgio_rpcsetup(data, len, offset, desc->pg_ioflags, &cinfo);
 		list_add(&data->list, &hdr->rpc_list);
 		requests++;
 		nbytes -= len;
@@ -1179,7 +1141,7 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc,
 		desc->pg_ioflags &= ~FLUSH_COND_STABLE;
 
 	/* Set up the argument struct */
-	nfs_write_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags, &cinfo);
+	nfs_pgio_rpcsetup(data, desc->pg_count, 0, desc->pg_ioflags, &cinfo);
 	list_add(&data->list, &hdr->rpc_list);
 	desc->pg_rpc_callops = &nfs_pgio_common_ops;
 	return 0;
-- 
1.9.2

