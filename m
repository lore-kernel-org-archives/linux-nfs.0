Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:50203 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752810AbdCBQPB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:15:01 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 18/19] NFS recover from destination server reboot for copies
Date: Thu, 2 Mar 2017 11:01:22 -0500
Message-ID: <20170302160123.30375-19-kolga@netapp.com>
In-Reply-To: <20170302160123.30375-1-kolga@netapp.com>
References: <20170302160123.30375-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mark the destination state to indicate a server-side copy is
happening. On detecting a reboot and recovering open state check
if any state is engaged in a server-side copy, if so, find the
copy and mark it and then signal the waiting thread. Upon wakeup,
if copy was marked then propage EAGAIN to the nfsd_copy_file_range
and restart the copy from scratch (no partial state is being
queried at this point).

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c     | 22 +++++++++++++++++-----
 fs/nfs/nfs4_fs.h       |  1 +
 fs/nfs/nfs4file.c      |  3 +++
 fs/nfs/nfs4state.c     | 15 +++++++++++++++
 include/linux/nfs_fs.h |  2 ++
 5 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index c9d8d7a..232447d 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -181,6 +181,7 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	struct nfs4_copy_state *copy;
 	int status;
 	bool found_pending = false;
+	struct nfs_open_context *ctx = nfs_file_open_context(dst);
 
 	spin_lock(&server->nfs_client->cl_lock);
 	list_for_each_entry(copy, &server->nfs_client->pending_cb_stateids,
@@ -204,6 +205,7 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	}
 	memcpy(&copy->stateid, &res->write_res.stateid, NFS4_STATEID_SIZE);
 	init_completion(&copy->completion);
+	copy->parent_state = ctx->state;
 
 	list_add_tail(&copy->copies, &server->ss_copies);
 	spin_unlock(&server->nfs_client->cl_lock);
@@ -213,10 +215,10 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	list_del_init(&copy->copies);
 	spin_unlock(&server->nfs_client->cl_lock);
 	if (status == -ERESTARTSYS) {
-		nfs42_do_offload_cancel_async(dst, &copy->stateid);
-		nfs42_do_offload_cancel_async(src, src_stateid);
-		kfree(copy);
-		return status;
+		goto out_cancel;
+	} else if (copy->flags) {
+		status = -EAGAIN;
+		goto out_cancel;
 	}
 out:
 	*ret_count = copy->count;
@@ -225,6 +227,11 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 		status = nfs_commit_file(dst, &copy->verf.verifier);
 	kfree(copy);
 	return status;
+out_cancel:
+	nfs42_do_offload_cancel_async(dst, &copy->stateid);
+	nfs42_do_offload_cancel_async(src, src_stateid);
+	kfree(copy);
+	return status;
 }
 
 static ssize_t _nfs42_proc_copy(struct file *src,
@@ -273,6 +280,8 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 	if (status)
 		return status;
 
+	set_bit(NFS_CLNT_DST_SSC_COPY_STATE,
+		&dst_lock->open_context->state->flags);
 retry:
 	args->sync = sync;
 	status = nfs4_call_sync(server->client, server, &msg,
@@ -363,9 +372,12 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 
 		if (err >= 0)
 			break;
-		if (err == -ENOTSUPP) {
+		switch (err) {
+		case -ENOTSUPP:
 			err = -EOPNOTSUPP;
 			break;
+		case -EAGAIN:
+			break;
 		}
 
 		err2 = nfs4_handle_exception(server, err, &src_exception);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 07b93fde..8037ec3 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -162,6 +162,7 @@ enum {
 	NFS_STATE_RECOVERY_FAILED,	/* OPEN stateid state recovery failed */
 	NFS_STATE_MAY_NOTIFY_LOCK,	/* server may CB_NOTIFY_LOCK */
 #ifdef CONFIG_NFS_V4_2
+	NFS_CLNT_DST_SSC_COPY_STATE,    /* dst server open state on client*/
 	NFS_SRV_SSC_COPY_STATE,		/* ssc state on the dst server */
 #endif /* CONFIG_NFS_V4_2 */
 };
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index f6ccc6f..92822c4 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -142,6 +142,7 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (file_inode(file_in) == file_inode(file_out))
 		return -EINVAL;
 
+retry:
 	if (nfs42_intra_ssc(file_in, file_out)) {  /* Intra-ssc */
 		if (file_in->f_op != file_out->f_op)
 			return -EXDEV;
@@ -173,6 +174,8 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 		kfree(cn_resp->cnr_src.nl_svr);
 		kfree(cn_resp);
 	}
+	if (ret == -EAGAIN)
+		goto retry;
 	return ret;
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index af5d8d7..47ece10 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1550,6 +1550,21 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 					&state->flags);
 				nfs4_put_open_state(state);
 				spin_lock(&sp->so_lock);
+#ifdef CONFIG_NFS_V4_2
+				if (test_bit(NFS_CLNT_DST_SSC_COPY_STATE, &state->flags)) {
+					struct nfs4_copy_state *copy;
+
+					spin_lock(&sp->so_server->nfs_client->cl_lock);
+					list_for_each_entry(copy, &sp->so_server->ss_copies, copies) {
+						if (memcmp(&state->stateid.other, &copy->parent_state->stateid.other, NFS4_STATEID_SIZE))
+							continue;
+						copy->flags = 1;
+						complete(&copy->completion);
+						break;
+					}
+					spin_unlock(&sp->so_server->nfs_client->cl_lock);
+				}
+#endif /* CONFIG_NFS_V4_2 */
 				goto restart;
 			}
 		}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index e174cba..7d60a0a 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -189,6 +189,8 @@ struct nfs4_copy_state {
 	uint64_t		count;
 	struct nfs_writeverf	verf;
 	int			error;
+	int			flags;
+	struct nfs4_state	*parent_state;
 };
 
 /*
-- 
1.8.3.1

