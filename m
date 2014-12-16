Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:43359 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbaLPTC1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:27 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so14657031pad.37
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:26 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 12/50] nfs: allow different protocol in nfs_initiate_commit
Date: Tue, 16 Dec 2014 11:01:15 -0800
Message-Id: <1418756513-95187-13-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

pnfs flexfile layout client may want to use NFSv3 ops rather
than the default MDS v4 ops.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c | 2 +-
 fs/nfs/internal.h              | 1 +
 fs/nfs/pnfs_nfsio.c            | 1 +
 fs/nfs/write.c                 | 7 ++++---
 4 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 25c4896..e5a3c5b 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -1055,7 +1055,7 @@ static int filelayout_initiate_commit(struct nfs_commit_data *data, int how)
 	fh = select_ds_fh_from_commit(lseg, data->ds_commit_index);
 	if (fh)
 		data->args.fh = fh;
-	return nfs_initiate_commit(ds_clnt, data,
+	return nfs_initiate_commit(ds_clnt, data, NFS_PROTO(data->inode),
 				   &filelayout_commit_call_ops, how,
 				   RPC_TASK_SOFTCONN);
 out_err:
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0b1dda7..2979a91 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -439,6 +439,7 @@ extern void nfs_write_prepare(struct rpc_task *task, void *calldata);
 extern void nfs_commit_prepare(struct rpc_task *task, void *calldata);
 extern int nfs_initiate_commit(struct rpc_clnt *clnt,
 			       struct nfs_commit_data *data,
+			       const struct nfs_rpc_ops *nfs_ops,
 			       const struct rpc_call_ops *call_ops,
 			       int how, int flags);
 extern void nfs_init_commit(struct nfs_commit_data *data,
diff --git a/fs/nfs/pnfs_nfsio.c b/fs/nfs/pnfs_nfsio.c
index fd2a2f0..329447c 100644
--- a/fs/nfs/pnfs_nfsio.c
+++ b/fs/nfs/pnfs_nfsio.c
@@ -273,6 +273,7 @@ pnfs_generic_commit_pagelist(struct inode *inode, struct list_head *mds_pages,
 		if (!data->lseg) {
 			nfs_init_commit(data, mds_pages, NULL, cinfo);
 			nfs_initiate_commit(NFS_CLIENT(inode), data,
+					    NFS_PROTO(data->inode),
 					    data->mds_ops, how, 0);
 		} else {
 			struct pnfs_commit_bucket *buckets;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e5ed21c..ab392af 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1466,6 +1466,7 @@ void nfs_commitdata_release(struct nfs_commit_data *data)
 EXPORT_SYMBOL_GPL(nfs_commitdata_release);
 
 int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
+			const struct nfs_rpc_ops *nfs_ops,
 			const struct rpc_call_ops *call_ops,
 			int how, int flags)
 {
@@ -1487,7 +1488,7 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 		.priority = priority,
 	};
 	/* Set up the initial task struct.  */
-	NFS_PROTO(data->inode)->commit_setup(data, &msg);
+	nfs_ops->commit_setup(data, &msg);
 
 	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
 
@@ -1590,8 +1591,8 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how,
 	/* Set up the argument struct */
 	nfs_init_commit(data, head, NULL, cinfo);
 	atomic_inc(&cinfo->mds->rpcs_out);
-	return nfs_initiate_commit(NFS_CLIENT(inode), data, data->mds_ops,
-				   how, 0);
+	return nfs_initiate_commit(NFS_CLIENT(inode), data, NFS_PROTO(inode),
+				   data->mds_ops, how, 0);
  out_bad:
 	nfs_retry_commit(head, NULL, cinfo);
 	cinfo->completion_ops->error_cleanup(NFS_I(inode));
-- 
1.9.3

