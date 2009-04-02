From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 30/67] nfs41: setup_sequence method
Date: Thu,  2 Apr 2009 16:54:32 +0300
Message-ID: <1238680472-14339-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:32435 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751805AbZDBNyj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:54:39 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Allocate a slot in the session slot table and set the sequence op arguments.

Called at the rpc prepare stage.

Add a status to nfs41_sequence_res, initialize it to one so that we catch
rpc level failures which do not go through decode_sequence which sets
the new status field.

Note that upon an rpc level failure, we don't know if the server processed the
sequence operation or not. Proceed as if the server did process the sequence
operation.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
[nfs41: sequence args use slotid]
[nfs41: find slot return slotid]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: remove SEQ4_STATUS_USE_TK_STATUS]
As per 11-14-08 review
[move extern declaration from nfs41: sequence setup/done support]
[removed sa_session definition, changed sa_cache_this into a u8 to reduce footprint]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: rpc_sleep_on slot_tbl_waitq must be called under slot_tbl_lock]
    Otherwise there's a race (we've hit) with nfs4_free_slot where
    nfs41_setup_sequence sees a full slot table, unlocks slot_tbl_lock,
    nfs4_free_slots happen concurrently and call rpc_wake_up_next
    where there's nobody to wake up yet, context goes back to
    nfs41_setup_sequence which goes to sleep when the slot table
    is actually empty now and there's no-one to wake it up anymore.
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4_fs.h        |   10 ++++++++++
 fs/nfs/nfs4proc.c       |   34 ++++++++++++++++++++++++++++++++--
 include/linux/nfs_xdr.h |    4 ++++
 3 files changed, 46 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5d7b036..c2ef040 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -203,8 +203,18 @@ extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 extern struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops;
 extern struct nfs4_state_recovery_ops nfs4_nograce_recovery_ops;
 #if defined(CONFIG_NFS_V4_1)
+extern int nfs4_setup_sequence(struct nfs_client *clp,
+		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
+		int cache_reply, struct rpc_task *task);
 extern void nfs4_destroy_session(struct nfs4_session *session);
 extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
+#else /* CONFIG_NFS_v4_1 */
+static inline int nfs4_setup_sequence(struct nfs_client *clp,
+		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
+		int cache_reply, struct rpc_task *task)
+{
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 extern const u32 nfs4_fattr_bitmap[2];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 582d61e..b57b50e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -280,6 +280,8 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
  * If found, we mark the slot as used, update the highest_used_slotid,
  * and respectively set up the sequence operation args.
  * The slot number is returned if found, or NFS4_MAX_SLOT_TABLE otherwise.
+ *
+ * Note: must be called with under the slot_tbl_lock.
  */
 static u8
 nfs4_find_slot(struct nfs4_slot_table *tbl, struct rpc_task *task)
@@ -288,7 +290,6 @@ nfs4_find_slot(struct nfs4_slot_table *tbl, struct rpc_task *task)
 	u8 ret_id = NFS4_MAX_SLOT_TABLE;
 	BUILD_BUG_ON((u8)NFS4_MAX_SLOT_TABLE != (int)NFS4_MAX_SLOT_TABLE);
 
-	spin_lock(&tbl->slot_tbl_lock);
 	dprintk("--> %s used_slots=%04lx highest_used=%d max_slots=%d\n",
 		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
 		tbl->max_slots);
@@ -302,7 +303,6 @@ nfs4_find_slot(struct nfs4_slot_table *tbl, struct rpc_task *task)
 out:
 	dprintk("<-- %s used_slots=%04lx highest_used=%d slotid=%d \n",
 		__func__, tbl->used_slots[0], tbl->highest_used_slotid, ret_id);
-	spin_unlock(&tbl->slot_tbl_lock);
 	return ret_id;
 }
 
@@ -312,12 +312,42 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 				int cache_reply,
 				struct rpc_task *task)
 {
+	struct nfs4_slot *slot;
+	struct nfs4_slot_table *tbl;
+	u8 slotid;
+
+	dprintk("--> %s\n", __func__);
 	/* slot already allocated? */
 	if (res->sr_slotid != NFS4_MAX_SLOT_TABLE)
 		return 0;
 
 	memset(res, 0, sizeof(*res));
 	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
+	tbl = &session->fc_slot_table;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	slotid = nfs4_find_slot(tbl, task);
+	if (slotid == NFS4_MAX_SLOT_TABLE) {
+		rpc_sleep_on(&tbl->slot_tbl_waitq, task, NULL);
+		spin_unlock(&tbl->slot_tbl_lock);
+		dprintk("<-- %s: no free slots\n", __func__);
+		return -EAGAIN;
+	}
+	spin_unlock(&tbl->slot_tbl_lock);
+
+	slot = tbl->slots + slotid;
+	args->sa_slotid = slotid;
+	args->sa_cache_this = cache_reply;
+
+	dprintk("<-- %s slotid=%d seqid=%d\n", __func__, slotid, slot->seq_nr);
+
+	res->sr_slotid = slotid;
+	res->sr_renewal_time = jiffies;
+	/*
+	 * sr_status is only set in decode_sequence, and so will remain
+	 * set to 1 if an rpc level failure occurs.
+	 */
+	res->sr_status = 1;
 	return 0;
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 892fd27..1e00b79 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -163,11 +163,15 @@ struct nfs4_slot {
 
 struct nfs4_sequence_args {
 	struct nfs4_session	*sa_session;
+	u8			sa_slotid;
+	u8			sa_cache_this;
 };
 
 struct nfs4_sequence_res {
 	struct nfs4_session	*sr_session;
 	u8			sr_slotid;	/* slot used to send request */
+	unsigned long		sr_renewal_time;
+	int			sr_status;	/* sequence operation status */
 };
 
 /*
-- 
1.6.2.1

