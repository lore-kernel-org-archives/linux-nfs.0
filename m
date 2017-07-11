Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:38682 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932831AbdGKQo0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:26 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 08/42] NFS add support for asynchronous COPY
Date: Tue, 11 Jul 2017 12:43:42 -0400
Message-ID: <20170711164416.1982-9-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change xdr to always send COPY asynchronously.

Keep the list copies send in a list under a server structure.
Once copy is sent, it waits on a completion structure that will
be signalled by the callback thread that receives CB_OFFLOAD.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/callback_proc.c    | 34 ++++++++++++++++++++++++++++
 fs/nfs/client.c           |  1 +
 fs/nfs/nfs42proc.c        | 56 ++++++++++++++++++++++++++++++++++++++++++-----
 fs/nfs/nfs42xdr.c         |  8 ++++---
 include/linux/nfs_fs.h    |  9 ++++++++
 include/linux/nfs_fs_sb.h |  1 +
 include/linux/nfs_xdr.h   |  1 +
 7 files changed, 102 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 5396751..7e211ed 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -648,9 +648,43 @@ __be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args, void *dummy,
 }
 #endif /* CONFIG_NFS_V4_1 */
 #ifdef CONFIG_NFS_V4_2
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
 __be32 nfs4_callback_offload(struct cb_offloadargs *args, void *dummy,
 				struct cb_process_state *cps)
 {
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
 	return 0;
 }
 #endif /* CONFIG_NFS_V4_2 */
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ee5ddbd..6bde98a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -875,6 +875,7 @@ struct nfs_server *nfs_alloc_server(void)
 	INIT_LIST_HEAD(&server->delegations);
 	INIT_LIST_HEAD(&server->layouts);
 	INIT_LIST_HEAD(&server->state_owners_lru);
+	INIT_LIST_HEAD(&server->ss_copies);
 
 	atomic_set(&server->active, 0);
 
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 5c42e71..d92ce46 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -129,6 +129,38 @@ int nfs42_proc_deallocate(struct file *filep, loff_t offset, loff_t len)
 	return err;
 }
 
+static int handle_async_copy(struct nfs42_copy_res *res,
+			     struct nfs_server *server,
+			     struct file *src,
+			     struct file *dst,
+			     nfs4_stateid *src_stateid,
+			     uint64_t *ret_count)
+{
+	struct nfs4_copy_state *copy;
+	int status;
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
+	*ret_count = copy->count;
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
@@ -167,9 +199,13 @@ static ssize_t _nfs42_proc_copy(struct file *src,
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
@@ -177,18 +213,27 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	if (status)
 		goto out;
 
-	if (nfs_write_verifier_cmp(&res->write_res.verifier.verifier,
+	if (args->sync &&
+		!nfs_write_verifier_cmp(&res->write_res.verifier.verifier,
 				    &res->commit_res.verf->verifier)) {
 		status = -EAGAIN;
 		goto out;
 	}
 
+	if (!res->synchronous) {
+		status = handle_async_copy(res, server, src, dst,
+				&args->src_stateid, &res->write_res.count);
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
 
@@ -205,6 +250,7 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 		.dst_fh		= NFS_FH(file_inode(dst)),
 		.dst_pos	= pos_dst,
 		.count		= count,
+		.sync		= false,
 	};
 	struct nfs42_copy_res res;
 	struct nfs4_exception src_exception = {
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 27da108..f507fe4 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -160,7 +160,7 @@ static void encode_copy(struct xdr_stream *xdr,
 	encode_uint64(xdr, args->count);
 
 	encode_uint32(xdr, 1); /* consecutive = true */
-	encode_uint32(xdr, 1); /* synchronous = true */
+	encode_uint32(xdr, args->sync);
 	encode_uint32(xdr, 0); /* src server list */
 }
 
@@ -289,7 +289,8 @@ static void nfs4_xdr_enc_copy(struct rpc_rqst *req,
 	encode_savefh(xdr, &hdr);
 	encode_putfh(xdr, args->dst_fh, &hdr);
 	encode_copy(xdr, args, &hdr);
-	encode_copy_commit(xdr, args, &hdr);
+	if (args->sync)
+		encode_copy_commit(xdr, args, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -603,7 +604,8 @@ static int nfs4_xdr_dec_copy(struct rpc_rqst *rqstp,
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
index bb0eb2c..8b0192f 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -183,6 +183,15 @@ struct nfs_inode {
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
  * Cache validity bit flags
  */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 41a2af5..d4a2385 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -205,6 +205,7 @@ struct nfs_server {
 	struct list_head	state_owners_lru;
 	struct list_head	layouts;
 	struct list_head	delegations;
+	struct list_head	ss_copies;
 
 	unsigned long		mig_gen;
 	unsigned long		mig_status;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 60eafa0..4875928 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1371,6 +1371,7 @@ struct nfs42_copy_args {
 	u64				dst_pos;
 
 	u64				count;
+	bool				sync;
 };
 
 struct nfs42_write_res {
-- 
1.8.3.1

