Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:33525 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934360AbdBQRcO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Feb 2017 12:32:14 -0500
Received: by mail-oi0-f67.google.com with SMTP id s131so2307620oie.0
        for <linux-nfs@vger.kernel.org>; Fri, 17 Feb 2017 09:32:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFSv4: Fix reboot recovery in copy offload
Date: Fri, 17 Feb 2017 12:32:09 -0500
Message-Id: <20170217173209.17502-1-trond.myklebust@primarydata.com>
In-Reply-To: <CAN-5tyFM88h5XMvnYQ3hnq6DgE_wsctFhjQuX_bAvUJkr3xKjw@mail.gmail.com>
References: <CAN-5tyFM88h5XMvnYQ3hnq6DgE_wsctFhjQuX_bAvUJkr3xKjw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Copy offload code needs to be hooked into the code for handling
NFS4ERR_BAD_STATEID by ensuring that we set the "stateid" field
in struct nfs4_exception.

Reported-by: Olga Kornievskaia <aglo@umich.edu>
Fixes: 2e72448b07dc3 ("NFS: Add COPY nfs operation")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs42proc.c | 67 +++++++++++++++++++++++++++++++++---------------------
 1 file changed, 41 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index d12ff9385f49..1f8bfffc9f04 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -128,20 +128,13 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	return err;
 }
 
-static ssize_t _nfs42_proc_copy(struct file *src, loff_t pos_src,
+static ssize_t _nfs42_proc_copy(struct file *src,
 				struct nfs_lock_context *src_lock,
-				struct file *dst, loff_t pos_dst,
+				struct file *dst,
 				struct nfs_lock_context *dst_lock,
-				size_t count)
+				struct nfs42_copy_args *args,
+				struct nfs42_copy_res *res)
 {
-	struct nfs42_copy_args args = {
-		.src_fh		= NFS_FH(file_inode(src)),
-		.src_pos	= pos_src,
-		.dst_fh		= NFS_FH(file_inode(dst)),
-		.dst_pos	= pos_dst,
-		.count		= count,
-	};
-	struct nfs42_copy_res res;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COPY],
 		.rpc_argp = &args,
@@ -149,9 +142,12 @@ static ssize_t _nfs42_proc_copy(struct file *src, loff_t pos_src,
 	};
 	struct inode *dst_inode = file_inode(dst);
 	struct nfs_server *server = NFS_SERVER(dst_inode);
+	loff_t pos_src = args->src_pos;
+	loff_t pos_dst = args->dst_pos;
+	size_t count = args->count;
 	int status;
 
-	status = nfs4_set_rw_stateid(&args.src_stateid, src_lock->open_context,
+	status = nfs4_set_rw_stateid(&args->src_stateid, src_lock->open_context,
 				     src_lock, FMODE_READ);
 	if (status)
 		return status;
@@ -161,7 +157,7 @@ static ssize_t _nfs42_proc_copy(struct file *src, loff_t pos_src,
 	if (status)
 		return status;
 
-	status = nfs4_set_rw_stateid(&args.dst_stateid, dst_lock->open_context,
+	status = nfs4_set_rw_stateid(&args->dst_stateid, dst_lock->open_context,
 				     dst_lock, FMODE_WRITE);
 	if (status)
 		return status;
@@ -171,22 +167,22 @@ static ssize_t _nfs42_proc_copy(struct file *src, loff_t pos_src,
 		return status;
 
 	status = nfs4_call_sync(server->client, server, &msg,
-				&args.seq_args, &res.seq_res, 0);
+				&args->seq_args, &res->seq_res, 0);
 	if (status == -ENOTSUPP)
 		server->caps &= ~NFS_CAP_COPY;
 	if (status)
 		return status;
 
-	if (res.write_res.verifier.committed != NFS_FILE_SYNC) {
-		status = nfs_commit_file(dst, &res.write_res.verifier.verifier);
+	if (res->write_res.verifier.committed != NFS_FILE_SYNC) {
+		status = nfs_commit_file(dst, &res->write_res.verifier.verifier);
 		if (status)
 			return status;
 	}
 
 	truncate_pagecache_range(dst_inode, pos_dst,
-				 pos_dst + res.write_res.count);
+				 pos_dst + res->write_res.count);
 
-	return res.write_res.count;
+	return res->write_res.count;
 }
 
 ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
@@ -196,8 +192,22 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 	struct nfs_server *server = NFS_SERVER(file_inode(dst));
 	struct nfs_lock_context *src_lock;
 	struct nfs_lock_context *dst_lock;
-	struct nfs4_exception src_exception = { };
-	struct nfs4_exception dst_exception = { };
+	struct nfs42_copy_args args = {
+		.src_fh		= NFS_FH(file_inode(src)),
+		.src_pos	= pos_src,
+		.dst_fh		= NFS_FH(file_inode(dst)),
+		.dst_pos	= pos_dst,
+		.count		= count,
+	};
+	struct nfs42_copy_res res;
+	struct nfs4_exception src_exception = {
+		.inode		= file_inode(src),
+		.stateid	= &args.src_stateid,
+	};
+	struct nfs4_exception dst_exception = {
+		.inode		= file_inode(dst),
+		.stateid	= &args.dst_stateid,
+	};
 	ssize_t err, err2;
 
 	if (!nfs_server_capable(file_inode(dst), NFS_CAP_COPY))
@@ -207,7 +217,6 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 	if (IS_ERR(src_lock))
 		return PTR_ERR(src_lock);
 
-	src_exception.inode = file_inode(src);
 	src_exception.state = src_lock->open_context->state;
 
 	dst_lock = nfs_get_lock_context(nfs_file_open_context(dst));
@@ -216,25 +225,31 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 		goto out_put_src_lock;
 	}
 
-	dst_exception.inode = file_inode(dst);
 	dst_exception.state = dst_lock->open_context->state;
 
-	do {
+	for (;;) {
 		inode_lock(file_inode(dst));
-		err = _nfs42_proc_copy(src, pos_src, src_lock,
-				       dst, pos_dst, dst_lock, count);
+		err = _nfs42_proc_copy(src, src_lock,
+				dst, dst_lock,
+				&args, &res);
 		inode_unlock(file_inode(dst));
 
+		if (err >= 0)
+			break;
 		if (err == -ENOTSUPP) {
 			err = -EOPNOTSUPP;
 			break;
 		}
 
 		err2 = nfs4_handle_exception(server, err, &src_exception);
+		if (src_exception.retry)
+			continue;
 		err  = nfs4_handle_exception(server, err, &dst_exception);
 		if (!err)
 			err = err2;
-	} while (src_exception.retry || dst_exception.retry);
+		if (!dst_exception.retry)
+			break;
+	}
 
 	nfs_put_lock_context(dst_lock);
 out_put_src_lock:
-- 
2.9.3

