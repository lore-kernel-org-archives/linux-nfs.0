Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20489 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753478Ab2D0VpN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 17:45:13 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 04/13] NFSv4.1 set RPC_TASK_SOFTCONN for filelayout DS RPC calls
Date: Fri, 27 Apr 2012 17:53:44 -0400
Message-Id: <1335563633-7191-5-git-send-email-andros@netapp.com>
In-Reply-To: <1335563633-7191-1-git-send-email-andros@netapp.com>
References: <1335563633-7191-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

RPC_TASK_SOFTCONN returns connection errors to the caller which allows the pNFS
file layout to quickly try the MDS or perhaps another DS.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h       |    6 +++---
 fs/nfs/nfs4filelayout.c |   10 ++++++----
 fs/nfs/read.c           |    6 +++---
 fs/nfs/write.c          |   13 +++++++------
 4 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 12d3818..5026bcc 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -309,7 +309,7 @@ extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 			const struct nfs_pgio_completion_ops *compl_ops);
 extern int nfs_initiate_read(struct rpc_clnt *clnt,
 			     struct nfs_read_data *data,
-			     const struct rpc_call_ops *call_ops);
+			     const struct rpc_call_ops *call_ops, int flags);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
 			      struct nfs_pgio_header *hdr);
@@ -336,13 +336,13 @@ extern void nfs_commit_free(struct nfs_commit_data *p);
 extern int nfs_initiate_write(struct rpc_clnt *clnt,
 			      struct nfs_write_data *data,
 			      const struct rpc_call_ops *call_ops,
-			      int how);
+			      int how, int flags);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
 extern void nfs_commit_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_initiate_commit(struct rpc_clnt *clnt,
 			       struct nfs_commit_data *data,
 			       const struct rpc_call_ops *call_ops,
-			       int how);
+			       int how, int flags);
 extern void nfs_init_commit(struct nfs_commit_data *data,
 			    struct list_head *head,
 			    struct pnfs_layout_segment *lseg,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b9edc88..0db8c07 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -401,7 +401,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 
 	/* Perform an asynchronous read to ds */
 	status = nfs_initiate_read(ds->ds_clp->cl_rpcclient, data,
-				   &filelayout_read_call_ops);
+				  &filelayout_read_call_ops, RPC_TASK_SOFTCONN);
 	BUG_ON(status != 0);
 	return PNFS_ATTEMPTED;
 }
@@ -441,7 +441,8 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 
 	/* Perform an asynchronous write */
 	status = nfs_initiate_write(ds->ds_clp->cl_rpcclient, data,
-				    &filelayout_write_call_ops, sync);
+				    &filelayout_write_call_ops, sync,
+				    RPC_TASK_SOFTCONN);
 	BUG_ON(status != 0);
 	return PNFS_ATTEMPTED;
 }
@@ -966,7 +967,8 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
 	if (fh)
 		data->args.fh = fh;
 	return nfs_initiate_commit(ds->ds_clp->cl_rpcclient, data,
-				   &filelayout_commit_call_ops, how);
+				   &filelayout_commit_call_ops, how,
+				   RPC_TASK_SOFTCONN);
 }
 
 static int
@@ -1120,7 +1122,7 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 		if (!data->lseg) {
 			nfs_init_commit(data, mds_pages, NULL, cinfo);
 			nfs_initiate_commit(NFS_CLIENT(inode), data,
-					    data->mds_ops, how);
+					    data->mds_ops, how, 0);
 		} else {
 			struct pnfs_commit_bucket *buckets;
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 35e2dce..4d53a60 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -214,7 +214,7 @@ out:
 
 int nfs_initiate_read(struct rpc_clnt *clnt,
 		      struct nfs_read_data *data,
-		      const struct rpc_call_ops *call_ops)
+		      const struct rpc_call_ops *call_ops, int flags)
 {
 	struct inode *inode = data->header->inode;
 	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
@@ -231,7 +231,7 @@ int nfs_initiate_read(struct rpc_clnt *clnt,
 		.callback_ops = call_ops,
 		.callback_data = data,
 		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC | swap_flags,
+		.flags = RPC_TASK_ASYNC | swap_flags | flags,
 	};
 
 	/* Set up the initial task struct. */
@@ -280,7 +280,7 @@ static int nfs_do_read(struct nfs_read_data *data,
 {
 	struct inode *inode = data->header->inode;
 
-	return nfs_initiate_read(NFS_CLIENT(inode), data, call_ops);
+	return nfs_initiate_read(NFS_CLIENT(inode), data, call_ops, 0);
 }
 
 static int
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index fec214b..2407c2f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -902,7 +902,7 @@ static int flush_task_priority(int how)
 int nfs_initiate_write(struct rpc_clnt *clnt,
 		       struct nfs_write_data *data,
 		       const struct rpc_call_ops *call_ops,
-		       int how)
+		       int how, int flags)
 {
 	struct inode *inode = data->header->inode;
 	int priority = flush_task_priority(how);
@@ -919,7 +919,7 @@ int nfs_initiate_write(struct rpc_clnt *clnt,
 		.callback_ops = call_ops,
 		.callback_data = data,
 		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC,
+		.flags = RPC_TASK_ASYNC | flags,
 		.priority = priority,
 	};
 	int ret = 0;
@@ -995,7 +995,7 @@ static int nfs_do_write(struct nfs_write_data *data,
 {
 	struct inode *inode = data->header->inode;
 
-	return nfs_initiate_write(NFS_CLIENT(inode), data, call_ops, how);
+	return nfs_initiate_write(NFS_CLIENT(inode), data, call_ops, how, 0);
 }
 
 static int nfs_do_multiple_writes(struct list_head *head,
@@ -1381,7 +1381,7 @@ EXPORT_SYMBOL_GPL(nfs_commitdata_release);
 
 int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 			const struct rpc_call_ops *call_ops,
-			int how)
+			int how, int flags)
 {
 	struct rpc_task *task;
 	int priority = flush_task_priority(how);
@@ -1397,7 +1397,7 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 		.callback_ops = call_ops,
 		.callback_data = data,
 		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC,
+		.flags = RPC_TASK_ASYNC | flags,
 		.priority = priority,
 	};
 	/* Set up the initial task struct.  */
@@ -1486,7 +1486,8 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how,
 	/* Set up the argument struct */
 	nfs_init_commit(data, head, NULL, cinfo);
 	atomic_inc(&cinfo->mds->rpcs_out);
-	return nfs_initiate_commit(NFS_CLIENT(inode), data, data->mds_ops, how);
+	return nfs_initiate_commit(NFS_CLIENT(inode), data, data->mds_ops,
+				   how, 0);
  out_bad:
 	nfs_retry_commit(head, NULL, cinfo);
 	cinfo->completion_ops->error_cleanup(NFS_I(inode));
-- 
1.7.6.4

