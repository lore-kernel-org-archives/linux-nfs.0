Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:50314 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761707AbaGRPNw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 11:13:52 -0400
Received: by mail-qc0-f174.google.com with SMTP id o8so3398480qcw.19
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jul 2014 08:13:51 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v4 04/10] nfsd: Fix delegation revocation
Date: Fri, 18 Jul 2014 11:13:30 -0400
Message-Id: <1405696416-32585-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that the delegations cannot be found by the laundromat etc once
we add them to the various 'revoke' lists.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 37 +++++++++++++++++++++----------------
 1 file changed, 21 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 60ae21abce00..7c5233427c9b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -650,13 +650,13 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 }
 
-/* Called under the state lock. */
 static void
-unhash_delegation(struct nfs4_delegation *dp)
+unhash_delegation_locked(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_file;
 
-	spin_lock(&state_lock);
+	lockdep_assert_held(&state_lock);
+
 	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
 	spin_lock(&fp->fi_lock);
 	list_del_init(&dp->dl_perclnt);
@@ -665,7 +665,6 @@ unhash_delegation(struct nfs4_delegation *dp)
 	spin_unlock(&fp->fi_lock);
 	if (fp)
 		nfs4_put_deleg_lease(fp);
-	spin_unlock(&state_lock);
 }
 
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
@@ -676,7 +675,9 @@ static void destroy_revoked_delegation(struct nfs4_delegation *dp)
 
 static void destroy_delegation(struct nfs4_delegation *dp)
 {
-	unhash_delegation(dp);
+	spin_lock(&state_lock);
+	unhash_delegation_locked(dp);
+	spin_unlock(&state_lock);
 	nfs4_put_delegation(dp);
 }
 
@@ -685,11 +686,10 @@ static void revoke_delegation(struct nfs4_delegation *dp)
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 
 	if (clp->cl_minorversion == 0)
-		destroy_delegation(dp);
+		destroy_revoked_delegation(dp);
 	else {
-		unhash_delegation(dp);
 		dp->dl_stid.sc_type = NFS4_REVOKED_DELEG_STID;
-		list_add(&dp->dl_recall_lru, &clp->cl_revoked);
+		list_move(&dp->dl_recall_lru, &clp->cl_revoked);
 	}
 }
 
@@ -1447,15 +1447,16 @@ destroy_client(struct nfs4_client *clp)
 	spin_lock(&state_lock);
 	while (!list_empty(&clp->cl_delegations)) {
 		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
-		list_del_init(&dp->dl_perclnt);
+		unhash_delegation_locked(dp);
 		/* Ensure that deleg break won't try to requeue it */
 		++dp->dl_time;
-		list_move(&dp->dl_recall_lru, &reaplist);
+		list_add(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
-		destroy_delegation(dp);
+		list_del_init(&dp->dl_recall_lru);
+		nfs4_put_delegation(dp);
 	}
 	list_splice_init(&clp->cl_revoked, &reaplist);
 	while (!list_empty(&reaplist)) {
@@ -3655,7 +3656,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
 	return;
 out_free:
-	destroy_delegation(dp);
+	nfs4_put_delegation(dp);
 out_no_deleg:
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
 	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
@@ -3894,7 +3895,8 @@ nfs4_laundromat(struct nfsd_net *nn)
 			new_timeo = min(new_timeo, t);
 			break;
 		}
-		list_move(&dp->dl_recall_lru, &reaplist);
+		unhash_delegation_locked(dp);
+		list_add(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
 	list_for_each_safe(pos, next, &reaplist) {
@@ -5369,7 +5371,8 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 			 * don't monkey with it now that we are.
 			 */
 			++dp->dl_time;
-			list_move(&dp->dl_recall_lru, victims);
+			unhash_delegation_locked(dp);
+			list_add(&dp->dl_recall_lru, victims);
 		}
 		if (++count == max)
 			break;
@@ -5624,12 +5627,14 @@ nfs4_state_shutdown_net(struct net *net)
 	spin_lock(&state_lock);
 	list_for_each_safe(pos, next, &nn->del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
-		list_move(&dp->dl_recall_lru, &reaplist);
+		unhash_delegation_locked(dp);
+		list_add(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
-		destroy_delegation(dp);
+		list_del_init(&dp->dl_recall_lru);
+		nfs4_put_delegation(dp);
 	}
 
 	nfsd4_client_tracking_exit(net);
-- 
1.9.3

