Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:10685 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752350AbeDMRDb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Apr 2018 13:03:31 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v8 13/13] NFS recover from destination server reboot for copies
Date: Fri, 13 Apr 2018 13:03:14 -0400
Message-ID: <20180413170314.17634-14-kolga@netapp.com>
In-Reply-To: <20180413170314.17634-1-kolga@netapp.com>
References: <20180413170314.17634-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mark the destination state to indicate a server-side copy is
happening. On detecting a reboot and recovering open state check
if any state is engaged in a server-side copy, if so, find the
copy and mark it and then signal the waiting thread. Upon wakeup,
if copy was marked then propage EAGAIN to the nfsd_copy_file_range
and restart the copy from scratch.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c     | 16 +++++++++++++---
 fs/nfs/nfs4_fs.h       |  3 +++
 fs/nfs/nfs4file.c      |  9 +++++++--
 fs/nfs/nfs4state.c     | 15 +++++++++++++++
 include/linux/nfs_fs.h |  2 ++
 5 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 94b654a..305284d 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -140,6 +140,7 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	struct nfs4_copy_state *copy;
 	int status = NFS4_OK;
 	bool found_pending = false;
+	struct nfs_open_context *ctx = nfs_file_open_context(dst);
 
 	spin_lock(&server->nfs_client->cl_lock);
 	list_for_each_entry(copy, &server->nfs_client->pending_cb_stateids,
@@ -163,6 +164,7 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	}
 	memcpy(&copy->stateid, &res->write_res.stateid, NFS4_STATEID_SIZE);
 	init_completion(&copy->completion);
+	copy->parent_state = ctx->state;
 
 	list_add_tail(&copy->copies, &server->ss_copies);
 	spin_unlock(&server->nfs_client->cl_lock);
@@ -172,9 +174,10 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	list_del_init(&copy->copies);
 	spin_unlock(&server->nfs_client->cl_lock);
 	if (status == -ERESTARTSYS) {
-		nfs42_do_offload_cancel_async(dst, &copy->stateid);
-		kfree(copy);
-		return status;
+		goto out_cancel;
+	} else if (copy->flags) {
+		status = -EAGAIN;
+		goto out_cancel;
 	}
 out:
 	res->write_res.count = copy->count;
@@ -183,6 +186,10 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 
 	kfree(copy);
 	return status;
+out_cancel:
+	nfs42_do_offload_cancel_async(dst, &copy->stateid);
+	kfree(copy);
+	return status;
 }
 
 static int process_copy_commit(struct file *dst, loff_t pos_dst,
@@ -254,6 +261,9 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 		if (!res->commit_res.verf)
 			return -ENOMEM;
 	}
+	set_bit(NFS_CLNT_DST_SSC_COPY_STATE,
+		&dst_lock->open_context->state->flags);
+
 	status = nfs4_call_sync(server->client, server, &msg,
 				&args->seq_args, &res->seq_res, 0);
 	if (status == -ENOTSUPP)
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 6f113f0..83d252a 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -163,6 +163,9 @@ enum {
 	NFS_STATE_RECOVERY_FAILED,	/* OPEN stateid state recovery failed */
 	NFS_STATE_MAY_NOTIFY_LOCK,	/* server may CB_NOTIFY_LOCK */
 	NFS_STATE_CHANGE_WAIT,		/* A state changing operation is outstanding */
+#ifdef CONFIG_NFS_V4_2
+	NFS_CLNT_DST_SSC_COPY_STATE,    /* dst server open state on client*/
+#endif /* CONFIG_NFS_V4_2 */
 };
 
 struct nfs4_state {
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 6b3b372..eaef5fa 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -133,10 +133,15 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 				    struct file *file_out, loff_t pos_out,
 				    size_t count, unsigned int flags)
 {
+	ssize_t ret;
+
 	if (file_inode(file_in) == file_inode(file_out))
 		return -EINVAL;
-
-	return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+retry:
+	ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
+	if (ret == -EAGAIN)
+		goto retry;
+	return ret;
 }
 
 static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 91a4d4e..041bb50 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1584,6 +1584,21 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
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
index e1c1f82..93a5c9f 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -192,6 +192,8 @@ struct nfs4_copy_state {
 	uint64_t		count;
 	struct nfs_writeverf	verf;
 	int			error;
+	int			flags;
+	struct nfs4_state	*parent_state;
 };
 
 /*
-- 
1.8.3.1

