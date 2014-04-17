Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:34982 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbaDQVKd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Apr 2014 17:10:33 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 11/17] NFS: Create a common rpcsetup function for reads and writes
Date: Thu, 17 Apr 2014 17:09:35 -0400
Message-ID: <1397768981-12856-12-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com>
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
 fs/nfs/pageio.c   | 36 ++++++++++++++++++++++++++++++++++++
 fs/nfs/read.c     | 26 ++------------------------
 fs/nfs/write.c    | 46 ++++------------------------------------------
 4 files changed, 45 insertions(+), 66 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 798eb47..7bc36ee 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -401,6 +401,8 @@ extern struct nfs_rw_header *nfs_rw_header_alloc(const struct nfs_rw_ops *);
 extern void nfs_rw_header_free(struct nfs_pgio_header *);
 extern struct nfs_pgio_data *nfs_pgio_data_alloc(struct nfs_pgio_header *, unsigned int);
 extern void nfs_pgio_data_release(struct nfs_pgio_data *);
+extern void nfs_pgio_rpcsetup(struct nfs_pgio_data *, unsigned int,
+			      unsigned int, int, struct nfs_commit_info *);
 
 /* read.c */
 extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
@@ -449,6 +451,7 @@ extern void nfs_init_commit(struct nfs_commit_data *data,
 			    struct nfs_commit_info *cinfo);
 int nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 			 struct nfs_commit_info *cinfo, int max);
+unsigned long nfs_reqs_to_commit(struct nfs_commit_info *);
 int nfs_scan_commit(struct inode *inode, struct list_head *dst,
 		    struct nfs_commit_info *cinfo);
 void nfs_mark_request_commit(struct nfs_page *req,
diff --git a/fs/nfs/pageio.c b/fs/nfs/pageio.c
index f64fd70..fddb3e3 100644
--- a/fs/nfs/pageio.c
+++ b/fs/nfs/pageio.c
@@ -87,6 +87,42 @@ void nfs_pgio_data_release(struct nfs_pgio_data *data)
 }
 EXPORT_SYMBOL_GPL(nfs_pgio_data_release);
 
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
 static void nfs_pgio_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_pgio_data *data = calldata;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 98373ba..2c33fc3 100644
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
index e492537..15f2ffc 100644
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

