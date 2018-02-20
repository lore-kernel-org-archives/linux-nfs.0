Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:20667 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752823AbeBTQv7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Feb 2018 11:51:59 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v7 12/12] NFS add a simple sync nfs4_proc_commit after async COPY
Date: Tue, 20 Feb 2018 11:42:24 -0500
Message-ID: <20180220164224.65366-13-kolga@netapp.com>
In-Reply-To: <20180220164224.65366-1-kolga@netapp.com>
References: <20180220164224.65366-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A COPY with unstable write data needs a simple sync commit.
Filehandle value is gotten as a part of the inner loop so in
case of a reboot retry it should get the new value.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 31 +++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h   |  2 +-
 fs/nfs/nfs4proc.c  | 34 ++++++++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index fbd1f8a..94b654a 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -185,6 +185,30 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	return status;
 }
 
+static int process_copy_commit(struct file *dst, loff_t pos_dst,
+			       struct nfs42_copy_res *res)
+{
+	struct nfs_commitres cres;
+	int status = -ENOMEM;
+
+	cres.verf = kzalloc(sizeof(struct nfs_writeverf), GFP_NOFS);
+	if (!cres.verf)
+		goto out;
+
+	status = nfs4_proc_commit(dst, pos_dst, res->write_res.count, &cres);
+	if (status)
+		goto out_free;
+	if (nfs_write_verifier_cmp(&res->write_res.verifier.verifier,
+				    &cres.verf->verifier)) {
+		dprintk("commit verf differs from copy verf\n");
+		status = -EAGAIN;
+	}
+out_free:
+	kfree(cres.verf);
+out:
+	return status;
+}
+
 static ssize_t _nfs42_proc_copy(struct file *src,
 				struct nfs_lock_context *src_lock,
 				struct file *dst,
@@ -251,6 +275,13 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 			return status;
 	}
 
+	if ((!res->synchronous || !args->sync) &&
+			res->write_res.verifier.committed != NFS_FILE_SYNC) {
+		status = process_copy_commit(dst, pos_dst, res);
+		if (status)
+			return status;
+	}
+
 	truncate_pagecache_range(dst_inode, pos_dst,
 				 pos_dst + res->write_res.count);
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 7303a6f..6f113f0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -483,7 +483,7 @@ extern int nfs4_sequence_done(struct rpc_task *task,
 			      struct nfs4_sequence_res *res);
 
 extern void nfs4_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp);
-
+extern int nfs4_proc_commit(struct file *dst, __u64 offset, __u32 count, struct nfs_commitres *res);
 extern const nfs4_stateid zero_stateid;
 extern const nfs4_stateid invalid_stateid;
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dcd08ba..c8b554a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4972,6 +4972,40 @@ static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 }
 
+static int _nfs4_proc_commit(struct file *dst, struct nfs_commitargs *args,
+				struct nfs_commitres *res)
+{
+	struct inode *dst_inode = file_inode(dst);
+	struct nfs_server *server = NFS_SERVER(dst_inode);
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT],
+		.rpc_argp = args,
+		.rpc_resp = res,
+	};
+
+	args->fh = NFS_FH(dst_inode);
+	return nfs4_call_sync(server->client, server, &msg,
+			&args->seq_args, &res->seq_res, 1);
+}
+
+int nfs4_proc_commit(struct file *dst, __u64 offset, __u32 count, struct nfs_commitres *res)
+{
+	struct nfs_commitargs args = {
+		.offset = offset,
+		.count = count,
+	};
+	struct nfs_server *dst_server = NFS_SERVER(file_inode(dst));
+	struct nfs4_exception exception = { };
+	int status;
+
+	do {
+		status = _nfs4_proc_commit(dst, &args, res);
+		status = nfs4_handle_exception(dst_server, status, &exception);
+	} while (exception.retry);
+
+	return status;
+}
+
 struct nfs4_renewdata {
 	struct nfs_client	*client;
 	unsigned long		timestamp;
-- 
1.8.3.1

