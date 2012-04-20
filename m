Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61571 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757419Ab2DTSsL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 14:48:11 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 09/25] NFS: reverse arg order in nfs_initiate_[read|write]
Date: Fri, 20 Apr 2012 14:47:41 -0400
Message-Id: <1334947677-28864-10-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
References: <1334947677-28864-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it consistent with nfs_initiate_commit.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/internal.h       |    7 ++++---
 fs/nfs/nfs4filelayout.c |    4 ++--
 fs/nfs/read.c           |    5 +++--
 fs/nfs/write.c          |    6 +++---
 4 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 87e899d..abdf40c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -296,7 +296,8 @@ extern int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh);
 
 struct nfs_pageio_descriptor;
 /* read.c */
-extern int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
+extern int nfs_initiate_read(struct rpc_clnt *clnt,
+			     struct nfs_read_data *data,
 			     const struct rpc_call_ops *call_ops);
 extern void nfs_read_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
@@ -315,8 +316,8 @@ extern void nfs_pageio_init_write_mds(struct nfs_pageio_descriptor *pgio,
 extern void nfs_pageio_reset_write_mds(struct nfs_pageio_descriptor *pgio);
 extern void nfs_writedata_release(struct nfs_write_data *wdata);
 extern void nfs_commit_free(struct nfs_commit_data *p);
-extern int nfs_initiate_write(struct nfs_write_data *data,
-			      struct rpc_clnt *clnt,
+extern int nfs_initiate_write(struct rpc_clnt *clnt,
+			      struct nfs_write_data *data,
 			      const struct rpc_call_ops *call_ops,
 			      int how);
 extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 675ce3b..adbadcb 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -413,7 +413,7 @@ filelayout_read_pagelist(struct nfs_read_data *data)
 	data->mds_offset = offset;
 
 	/* Perform an asynchronous read to ds */
-	status = nfs_initiate_read(data, ds->ds_clp->cl_rpcclient,
+	status = nfs_initiate_read(ds->ds_clp->cl_rpcclient, data,
 				   &filelayout_read_call_ops);
 	BUG_ON(status != 0);
 	return PNFS_ATTEMPTED;
@@ -460,7 +460,7 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	data->args.offset = filelayout_get_dserver_offset(lseg, offset);
 
 	/* Perform an asynchronous write */
-	status = nfs_initiate_write(data, ds->ds_clp->cl_rpcclient,
+	status = nfs_initiate_write(ds->ds_clp->cl_rpcclient, data,
 				    &filelayout_write_call_ops, sync);
 	BUG_ON(status != 0);
 	return PNFS_ATTEMPTED;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 0a4be28..4ddba67 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -169,7 +169,8 @@ static void nfs_readpage_release(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
-int nfs_initiate_read(struct nfs_read_data *data, struct rpc_clnt *clnt,
+int nfs_initiate_read(struct rpc_clnt *clnt,
+		      struct nfs_read_data *data,
 		      const struct rpc_call_ops *call_ops)
 {
 	struct inode *inode = data->inode;
@@ -240,7 +241,7 @@ static int nfs_do_read(struct nfs_read_data *data,
 {
 	struct inode *inode = data->args.context->dentry->d_inode;
 
-	return nfs_initiate_read(data, NFS_CLIENT(inode), call_ops);
+	return nfs_initiate_read(NFS_CLIENT(inode), data, call_ops);
 }
 
 static int
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 54f7c0f..76735dd 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -836,8 +836,8 @@ static int flush_task_priority(int how)
 	return RPC_PRIORITY_NORMAL;
 }
 
-int nfs_initiate_write(struct nfs_write_data *data,
-		       struct rpc_clnt *clnt,
+int nfs_initiate_write(struct rpc_clnt *clnt,
+		       struct nfs_write_data *data,
 		       const struct rpc_call_ops *call_ops,
 		       int how)
 {
@@ -937,7 +937,7 @@ static int nfs_do_write(struct nfs_write_data *data,
 {
 	struct inode *inode = data->args.context->dentry->d_inode;
 
-	return nfs_initiate_write(data, NFS_CLIENT(inode), call_ops, how);
+	return nfs_initiate_write(NFS_CLIENT(inode), data, call_ops, how);
 }
 
 static int nfs_do_multiple_writes(struct list_head *head,
-- 
1.7.2.1

