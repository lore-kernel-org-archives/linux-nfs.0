Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:38585 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726762AbeILBYs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2018 21:24:48 -0400
Received: by mail-qt0-f196.google.com with SMTP id x7-v6so29691452qtk.5
        for <linux-nfs@vger.kernel.org>; Tue, 11 Sep 2018 13:23:51 -0700 (PDT)
From: schumaker.anna@gmail.com
To: Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFS: Split out the body of nfs4_reclaim_open_state()
Date: Tue, 11 Sep 2018 16:23:46 -0400
Message-Id: <20180911202348.23160-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Moving all of this into a new function removes the need for cramped
indentation, making the code overall easier to look at.   I also take
this chance to switch copy recovery over to using
nfs4_stateid_match_other()

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4state.c | 83 ++++++++++++++++++++++++++--------------------
 1 file changed, 47 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 3df0eb52da1c..aa46a3216d60 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1547,10 +1547,51 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 	return status;
 }
 
+static int __nfs4_reclaim_open_state(struct nfs4_state_owner *sp, struct nfs4_state *state,
+				     const struct nfs4_state_recovery_ops *ops)
+{
+	struct nfs4_lock_state *lock;
+	int status;
+
+	status = ops->recover_open(sp, state);
+	if (status < 0)
+		return status;
+
+	status = nfs4_reclaim_locks(state, ops);
+	if (status < 0)
+		return status;
+
+	if (!test_bit(NFS_DELEGATED_STATE, &state->flags)) {
+		spin_lock(&state->state_lock);
+		list_for_each_entry(lock, &state->lock_states, ls_locks) {
+			if (!test_bit(NFS_LOCK_INITIALIZED, &lock->ls_flags))
+				pr_warn_ratelimited("NFS: %s: Lock reclaim failed!\n", __func__);
+		}
+		spin_unlock(&state->state_lock);
+	}
+
+#ifdef CONFIG_NFS_V4_2
+	if (test_bit(NFS_CLNT_DST_SSC_COPY_STATE, &state->flags)) {
+		struct nfs4_copy_state *copy;
+		spin_lock(&sp->so_server->nfs_client->cl_lock);
+		list_for_each_entry(copy, &sp->so_server->ss_copies, copies) {
+			if (nfs4_stateid_match_other(&state->stateid, &copy->parent_state->stateid))
+				continue;
+			copy->flags = 1;
+			complete(&copy->completion);
+			break;
+		}
+		spin_unlock(&sp->so_server->nfs_client->cl_lock);
+	}
+#endif /* CONFIG_NFS_V4_2 */
+
+	clear_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags);
+	return status;
+}
+
 static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs4_state_recovery_ops *ops)
 {
 	struct nfs4_state *state;
-	struct nfs4_lock_state *lock;
 	int status = 0;
 
 	/* Note: we rely on the sp->so_states list being ordered 
@@ -1573,43 +1614,13 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 			continue;
 		atomic_inc(&state->count);
 		spin_unlock(&sp->so_lock);
-		status = ops->recover_open(sp, state);
+		status = __nfs4_reclaim_open_state(sp, state, ops);
 		if (status >= 0) {
-			status = nfs4_reclaim_locks(state, ops);
-			if (status >= 0) {
-				if (!test_bit(NFS_DELEGATED_STATE, &state->flags)) {
-					spin_lock(&state->state_lock);
-					list_for_each_entry(lock, &state->lock_states, ls_locks) {
-						if (!test_bit(NFS_LOCK_INITIALIZED, &lock->ls_flags))
-							pr_warn_ratelimited("NFS: "
-									    "%s: Lock reclaim "
-									    "failed!\n", __func__);
-					}
-					spin_unlock(&state->state_lock);
-				}
-				clear_bit(NFS_STATE_RECLAIM_NOGRACE,
-					&state->flags);
-#ifdef CONFIG_NFS_V4_2
-				if (test_bit(NFS_CLNT_DST_SSC_COPY_STATE, &state->flags)) {
-					struct nfs4_copy_state *copy;
-
-					spin_lock(&sp->so_server->nfs_client->cl_lock);
-					list_for_each_entry(copy, &sp->so_server->ss_copies, copies) {
-						if (memcmp(&state->stateid.other, &copy->parent_state->stateid.other, NFS4_STATEID_SIZE))
-							continue;
-						copy->flags = 1;
-						complete(&copy->completion);
-						printk("AGLO: server rebooted waking up the copy\n");
-						break;
-					}
-					spin_unlock(&sp->so_server->nfs_client->cl_lock);
-				}
-#endif /* CONFIG_NFS_V4_2 */
-				nfs4_put_open_state(state);
-				spin_lock(&sp->so_lock);
-				goto restart;
-			}
+			nfs4_put_open_state(state);
+			spin_lock(&sp->so_lock);
+			goto restart;
 		}
+
 		switch (status) {
 			default:
 				printk(KERN_ERR "NFS: %s: unhandled error %d\n",
-- 
2.18.0
