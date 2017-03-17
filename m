Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:15974 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751318AbdCQVES (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 17 Mar 2017 17:04:18 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v2 06/12] NFS add support for asynchronous COPY
Date: Fri, 17 Mar 2017 17:03:51 -0400
Message-ID: <20170317210357.48079-7-kolga@netapp.com>
In-Reply-To: <20170317210357.48079-1-kolga@netapp.com>
References: <20170317210357.48079-1-kolga@netapp.com>
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
 fs/nfs/callback_proc.c    | 34 ++++++++++++++++++++++++++++++++++
 fs/nfs/client.c           |  1 +
 fs/nfs/nfs42proc.c        | 46 ++++++++++++++++++++++++++++++++++++++++++----
 fs/nfs/nfs42xdr.c         |  2 +-
 include/linux/nfs_fs.h    |  9 +++++++++
 include/linux/nfs_fs_sb.h |  1 +
 6 files changed, 88 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index b68b803..c1b081c 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -681,9 +681,43 @@ __be32 nfs4_callback_notify_lock(struct cb_notify_lock_args *args, void *dummy,
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
index 91a8d61..a72cd1d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -885,6 +885,7 @@ struct nfs_server *nfs_alloc_server(void)
 	INIT_LIST_HEAD(&server->delegations);
 	INIT_LIST_HEAD(&server->layouts);
 	INIT_LIST_HEAD(&server->state_owners_lru);
+	INIT_LIST_HEAD(&server->ss_copies);
 
 	atomic_set(&server->active, 0);
 
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index d4e7f60..27a6eb8 100644
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
+	status = -copy->error;
+	if (copy->count && copy->verf.committed != NFS_FILE_SYNC)
+		status = nfs_commit_file(dst, &copy->verf.verifier);
+	kfree(copy);
+	return status;
+}
+
 static ssize_t _nfs42_proc_copy(struct file *src,
 				struct nfs_lock_context *src_lock,
 				struct file *dst,
@@ -147,6 +179,7 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	loff_t pos_dst = args->dst_pos;
 	size_t count = args->count;
 	int status;
+	uint64_t ret_count;
 
 	status = nfs4_set_rw_stateid(&args->src_stateid, src_lock->open_context,
 				     src_lock, FMODE_READ);
@@ -174,16 +207,21 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	if (status)
 		return status;
 
-	if (res->write_res.verifier.committed != NFS_FILE_SYNC) {
+	ret_count = res->write_res.count;
+	if (!res->synchronous) {
+		status = handle_async_copy(res, server, src, dst,
+				&args->src_stateid, &ret_count);
+		if (status)
+			return status;
+	} else if (res->write_res.verifier.committed != NFS_FILE_SYNC) {
 		status = nfs_commit_file(dst, &res->write_res.verifier.verifier);
 		if (status)
 			return status;
 	}
 
-	truncate_pagecache_range(dst_inode, pos_dst,
-				 pos_dst + res->write_res.count);
+	truncate_pagecache_range(dst_inode, pos_dst, pos_dst + ret_count);
 
-	return res->write_res.count;
+	return ret_count;
 }
 
 ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 83dce11..059d074 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -158,7 +158,7 @@ static void encode_copy(struct xdr_stream *xdr,
 	encode_uint64(xdr, args->count);
 
 	encode_uint32(xdr, 1); /* consecutive = true */
-	encode_uint32(xdr, 1); /* synchronous = true */
+	encode_uint32(xdr, 0); /* synchronous = false */
 	encode_uint32(xdr, 0); /* src server list */
 }
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 287f341..a862b7f 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -182,6 +182,15 @@ struct nfs_inode {
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
index 298ce5a..9b252bb 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -206,6 +206,7 @@ struct nfs_server {
 	struct list_head	state_owners_lru;
 	struct list_head	layouts;
 	struct list_head	delegations;
+	struct list_head	ss_copies;
 
 	unsigned long		mig_gen;
 	unsigned long		mig_status;
-- 
1.8.3.1

