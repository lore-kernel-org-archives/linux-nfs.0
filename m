Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:20668 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752882AbeBTQwB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Feb 2018 11:52:01 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v7 07/12] NFS add support for asynchronous COPY
Date: Tue, 20 Feb 2018 11:42:19 -0500
Message-ID: <20180220164224.65366-8-kolga@netapp.com>
In-Reply-To: <20180220164224.65366-1-kolga@netapp.com>
References: <20180220164224.65366-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change xdr to always send COPY asynchronously.

Keep the list copies send in a list under a server structure.
Once copy is sent, it waits on a completion structure that will
be signalled by the callback thread that receives CB_OFFLOAD.

If CB_OFFLOAD returned an error and even if it returned partial
bytes, ignore them (as we can't commit without a verifier to
match) and return an error.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/callback_proc.c    | 38 +++++++++++++++++++++++++++++++-
 fs/nfs/client.c           |  1 +
 fs/nfs/nfs42proc.c        | 55 ++++++++++++++++++++++++++++++++++++++++++-----
 fs/nfs/nfs42xdr.c         |  8 ++++---
 include/linux/nfs_fs.h    |  9 ++++++++
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  1 +
 7 files changed, 104 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index cc0b9dd..942d0b2 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -658,9 +658,45 @@ __be32 nfs4_callback_notify_lock(void *argp, void *resp,
 }
 #endif /* CONFIG_NFS_V4_1 */
 #ifdef CONFIG_NFS_V4_2
-__be32 nfs4_callback_offload(void *args, void *dummy,
+static void nfs4_copy_cb_args(struct nfs4_copy_state *cp_state,
+				struct cb_offloadargs *args)
+{
+	cp_state->count = args->wr_count;
+	cp_state->error = args->error;
+	if (!args->error) {
+		cp_state->verf.committed = args->wr_writeverf.committed;
+		memcpy(&cp_state->verf.verifier.data[0],
+			&args->wr_writeverf.verifier.data[0],
+			NFS4_VERIFIER_SIZE);
+	}
+}
+
+__be32 nfs4_callback_offload(void *data, void *dummy,
 			     struct cb_process_state *cps)
 {
+	struct cb_offloadargs *args = data;
+	struct nfs_server *server;
+	struct nfs4_copy_state *copy;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &cps->clp->cl_superblocks,
+				client_link) {
+		spin_lock(&server->nfs_client->cl_lock);
+		list_for_each_entry(copy, &server->ss_copies, copies) {
+			if (memcmp(args->coa_stateid.other,
+					copy->stateid.other,
+					sizeof(args->coa_stateid.other)))
+				continue;
+			nfs4_copy_cb_args(copy, args);
+			complete(&copy->completion);
+			spin_unlock(&server->nfs_client->cl_lock);
+			goto out;
+		}
+		spin_unlock(&server->nfs_client->cl_lock);
+	}
+out:
+	rcu_read_unlock();
+
 	return 0;
 }
 #endif /* CONFIG_NFS_V4_2 */
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index b9129e2..09649f5 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -886,6 +886,7 @@ struct nfs_server *nfs_alloc_server(void)
 	INIT_LIST_HEAD(&server->delegations);
 	INIT_LIST_HEAD(&server->layouts);
 	INIT_LIST_HEAD(&server->state_owners_lru);
+	INIT_LIST_HEAD(&server->ss_copies);
 
 	atomic_set(&server->active, 0);
 
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index c78e235..06f779b 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -130,6 +130,37 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	return err;
 }
 
+static int handle_async_copy(struct nfs42_copy_res *res,
+			     struct nfs_server *server,
+			     struct file *src,
+			     struct file *dst,
+			     nfs4_stateid *src_stateid)
+{
+	struct nfs4_copy_state *copy;
+	int status = NFS4_OK;
+
+	copy = kzalloc(sizeof(struct nfs4_copy_state), GFP_NOFS);
+	if (!copy)
+		return -ENOMEM;
+	memcpy(&copy->stateid, &res->write_res.stateid, NFS4_STATEID_SIZE);
+	init_completion(&copy->completion);
+
+	spin_lock(&server->nfs_client->cl_lock);
+	list_add_tail(&copy->copies, &server->ss_copies);
+	spin_unlock(&server->nfs_client->cl_lock);
+
+	wait_for_completion_interruptible(&copy->completion);
+	spin_lock(&server->nfs_client->cl_lock);
+	list_del_init(&copy->copies);
+	spin_unlock(&server->nfs_client->cl_lock);
+	res->write_res.count = copy->count;
+	memcpy(&res->write_res.verifier, &copy->verf, sizeof(copy->verf));
+	status = -copy->error;
+
+	kfree(copy);
+	return status;
+}
+
 static ssize_t _nfs42_proc_copy(struct file *src,
 				struct nfs_lock_context *src_lock,
 				struct file *dst,
@@ -168,9 +199,13 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	if (status)
 		return status;
 
-	res->commit_res.verf = kzalloc(sizeof(struct nfs_writeverf), GFP_NOFS);
-	if (!res->commit_res.verf)
-		return -ENOMEM;
+	res->commit_res.verf = NULL;
+	if (args->sync) {
+		res->commit_res.verf =
+			kzalloc(sizeof(struct nfs_writeverf), GFP_NOFS);
+		if (!res->commit_res.verf)
+			return -ENOMEM;
+	}
 	status = nfs4_call_sync(server->client, server, &msg,
 				&args->seq_args, &res->seq_res, 0);
 	if (status == -ENOTSUPP)
@@ -178,18 +213,27 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	if (status)
 		goto out;
 
-	if (nfs_write_verifier_cmp(&res->write_res.verifier.verifier,
+	if (args->sync &&
+		nfs_write_verifier_cmp(&res->write_res.verifier.verifier,
 				    &res->commit_res.verf->verifier)) {
 		status = -EAGAIN;
 		goto out;
 	}
 
+	if (!res->synchronous) {
+		status = handle_async_copy(res, server, src, dst,
+				&args->src_stateid);
+		if (status)
+			return status;
+	}
+
 	truncate_pagecache_range(dst_inode, pos_dst,
 				 pos_dst + res->write_res.count);
 
 	status = res->write_res.count;
 out:
-	kfree(res->commit_res.verf);
+	if (args->sync)
+		kfree(res->commit_res.verf);
 	return status;
 }
 
@@ -206,6 +250,7 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 		.dst_fh		= NFS_FH(file_inode(dst)),
 		.dst_pos	= pos_dst,
 		.count		= count,
+		.sync		= false,
 	};
 	struct nfs42_copy_res res;
 	struct nfs4_exception src_exception = {
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 9d70892..bc0bae6 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -161,7 +161,7 @@ static void encode_copy(struct xdr_stream *xdr,
 	encode_uint64(xdr, args->count);
 
 	encode_uint32(xdr, 1); /* consecutive = true */
-	encode_uint32(xdr, 1); /* synchronous = true */
+	encode_uint32(xdr, args->sync);
 	encode_uint32(xdr, 0); /* src server list */
 }
 
@@ -292,7 +292,8 @@ static void nfs4_xdr_enc_copy(struct rpc_rqst *req,
 	encode_savefh(xdr, &hdr);
 	encode_putfh(xdr, args->dst_fh, &hdr);
 	encode_copy(xdr, args, &hdr);
-	encode_copy_commit(xdr, args, &hdr);
+	if (args->sync)
+		encode_copy_commit(xdr, args, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -616,7 +617,8 @@ static int nfs4_xdr_dec_copy(struct rpc_rqst *rqstp,
 	status = decode_copy(xdr, res);
 	if (status)
 		goto out;
-	status = decode_commit(xdr, &res->commit_res);
+	if (res->commit_res.verf)
+		status = decode_commit(xdr, &res->commit_res);
 out:
 	return status;
 }
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 38187c6..e1c1f82 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -185,6 +185,15 @@ struct nfs_inode {
 	struct inode		vfs_inode;
 };
 
+struct nfs4_copy_state {
+	struct list_head	copies;
+	nfs4_stateid		stateid;
+	struct completion	completion;
+	uint64_t		count;
+	struct nfs_writeverf	verf;
+	int			error;
+};
+
 /*
  * Access bit flags
  */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 6d2a5c8..4836a1c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -208,6 +208,7 @@ struct nfs_server {
 	struct list_head	state_owners_lru;
 	struct list_head	layouts;
 	struct list_head	delegations;
+	struct list_head	ss_copies;
 
 	unsigned long		mig_gen;
 	unsigned long		mig_status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 4735f7d..ef66fce 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1385,6 +1385,7 @@ struct nfs42_copy_args {
 	u64				dst_pos;
 
 	u64				count;
+	bool				sync;
 };
 
 struct nfs42_write_res {
-- 
1.8.3.1

