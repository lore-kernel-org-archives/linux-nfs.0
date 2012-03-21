Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44677 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000Ab2CUTqx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 15:46:53 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 04/12] NFSv4.1 set RPC_TASK_SOFTCONN for filelayout DS RPC calls
Date: Wed, 21 Mar 2012 15:46:16 -0400
Message-Id: <1332359184-1887-5-git-send-email-andros@netapp.com>
In-Reply-To: <1332359184-1887-1-git-send-email-andros@netapp.com>
References: <1332359184-1887-1-git-send-email-andros@netapp.com>
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
index f9ac1f0..eebd7f1 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -297,7 +297,7 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
 struct nfs_pageio_descriptor;
 /* read.c */
 extern int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
-			     const struct rpc_call_ops *call_ops);
+			     const struct rpc_call_ops *call_ops, int flags);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
 		struct list_head *head);
@@ -318,12 +318,12 @@ extern void nfs_commit_free(struct nfs_write_data *p);
 extern int nfs_initiate_write(struct nfs_write_data *data,
 			      struct rpc_clnt *clnt,
 			      const struct rpc_call_ops *call_ops,
-			      int how);
+			      int how, int flags);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_initiate_commit(struct nfs_write_data *data,
 			       struct rpc_clnt *clnt,
 			       const struct rpc_call_ops *call_ops,
-			       int how);
+			       int how, int flags);
 extern void nfs_init_commit(struct nfs_write_data *data,
 			    struct list_head *head,
 			    struct pnfs_layout_segment *lseg);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index acafc4d..3802937 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -406,7 +406,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 
 	/* Perform an asynchronous read to ds */
 	status = nfs_initiate_read(data, ds->ds_clp->cl_rpcclient,
-				   &filelayout_read_call_ops);
+				  &filelayout_read_call_ops, RPC_TASK_SOFTCONN);
 	BUG_ON(status != 0);
 	return PNFS_ATTEMPTED;
 }
@@ -445,7 +445,8 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 
 	/* Perform an asynchronous write */
 	status = nfs_initiate_write(data, ds->ds_clp->cl_rpcclient,
-				    &filelayout_write_call_ops, sync);
+				    &filelayout_write_call_ops, sync,
+				    RPC_TASK_SOFTCONN);
 	BUG_ON(status != 0);
 	return PNFS_ATTEMPTED;
 }
@@ -913,7 +914,8 @@ static int filelayout_initiate_commit(struct nfs_write_data *data, int how)
 	if (fh)
 		data->args.fh = fh;
 	return nfs_initiate_commit(data, ds->ds_clp->cl_rpcclient,
-				   &filelayout_commit_call_ops, how);
+				   &filelayout_commit_call_ops, how,
+				    RPC_TASK_SOFTCONN);
 }
 
 /*
@@ -1064,7 +1066,7 @@ filelayout_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 		if (!data->lseg) {
 			nfs_init_commit(data, mds_pages, NULL);
 			nfs_initiate_commit(data, NFS_CLIENT(inode),
-					    data->mds_ops, how);
+					    data->mds_ops, how, 0);
 		} else {
 			nfs_init_commit(data, &FILELAYOUT_LSEG(data->lseg)->commit_buckets[data->ds_commit_index].committing, data->lseg);
 			filelayout_initiate_commit(data, how);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index cc1f758..da7c0b1 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -171,7 +171,7 @@ static void nfs_readpage_release(struct nfs_page *req)
 }
 
 int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
-		      const struct rpc_call_ops *call_ops)
+		      const struct rpc_call_ops *call_ops, int flags)
 {
 	struct inode *inode = data->inode;
 	int swap_flags = IS_SWAPFILE(inode) ? NFS_RPC_SWAPFLAGS : 0;
@@ -188,7 +188,7 @@ int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
 		.callback_ops = call_ops,
 		.callback_data = data,
 		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC | swap_flags,
+		.flags = RPC_TASK_ASYNC | swap_flags | flags,
 	};
 
 	/* Set up the initial task struct. */
@@ -241,7 +241,7 @@ static int nfs_do_read(struct nfs_read_data *data,
 {
 	struct inode *inode = data->args.context->dentry->d_inode;
 
-	return nfs_initiate_read(data, NFS_CLIENT(inode), call_ops);
+	return nfs_initiate_read(data, NFS_CLIENT(inode), call_ops, 0);
 }
 
 static int
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2c68818..3b620e4 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -839,7 +839,7 @@ static int flush_task_priority(int how)
 int nfs_initiate_write(struct nfs_write_data *data,
 		       struct rpc_clnt *clnt,
 		       const struct rpc_call_ops *call_ops,
-		       int how)
+		       int how, int flags)
 {
 	struct inode *inode = data->inode;
 	int priority = flush_task_priority(how);
@@ -856,7 +856,7 @@ int nfs_initiate_write(struct nfs_write_data *data,
 		.callback_ops = call_ops,
 		.callback_data = data,
 		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC,
+		.flags = RPC_TASK_ASYNC | flags,
 		.priority = priority,
 	};
 	int ret = 0;
@@ -937,7 +937,7 @@ static int nfs_do_write(struct nfs_write_data *data,
 {
 	struct inode *inode = data->args.context->dentry->d_inode;
 
-	return nfs_initiate_write(data, NFS_CLIENT(inode), call_ops, how);
+	return nfs_initiate_write(data, NFS_CLIENT(inode), call_ops, how, 0);
 }
 
 static int nfs_do_multiple_writes(struct list_head *head,
@@ -1365,7 +1365,7 @@ EXPORT_SYMBOL_GPL(nfs_commitdata_release);
 
 int nfs_initiate_commit(struct nfs_write_data *data, struct rpc_clnt *clnt,
 			const struct rpc_call_ops *call_ops,
-			int how)
+			int how, int flags)
 {
 	struct rpc_task *task;
 	int priority = flush_task_priority(how);
@@ -1381,7 +1381,7 @@ int nfs_initiate_commit(struct nfs_write_data *data, struct rpc_clnt *clnt,
 		.callback_ops = call_ops,
 		.callback_data = data,
 		.workqueue = nfsiod_workqueue,
-		.flags = RPC_TASK_ASYNC,
+		.flags = RPC_TASK_ASYNC | flags,
 		.priority = priority,
 	};
 	/* Set up the initial task struct.  */
@@ -1463,7 +1463,8 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 
 	/* Set up the argument struct */
 	nfs_init_commit(data, head, NULL);
-	return nfs_initiate_commit(data, NFS_CLIENT(inode), data->mds_ops, how);
+	return nfs_initiate_commit(data, NFS_CLIENT(inode), data->mds_ops,
+				   how, 0);
  out_bad:
 	nfs_retry_commit(head, NULL);
 	nfs_commit_clear_lock(NFS_I(inode));
-- 
1.7.6.4

