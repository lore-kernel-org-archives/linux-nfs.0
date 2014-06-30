Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:33046 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaF3PvW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:22 -0400
Received: by mail-qg0-f51.google.com with SMTP id z60so2154670qgd.38
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 035/114] nfsd: Fix delegation revocation
Date: Mon, 30 Jun 2014 11:49:04 -0400
Message-Id: <1404143423-24381-36-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that the delegations cannot be found by the laundromat etc once
we add them to the various 'revoke' lists.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 56 +++++++++++++++++++++++++++++++++--------------------
 1 file changed, 35 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fdbd209b02a6..befeb322cb92 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -640,13 +640,13 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
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
 	spin_lock(&fp->fi_lock);
 	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_recall_lru);
@@ -654,23 +654,32 @@ unhash_delegation(struct nfs4_delegation *dp)
 	spin_unlock(&fp->fi_lock);
 	if (fp)
 		nfs4_put_deleg_lease(fp);
-	spin_unlock(&state_lock);
 }
 
+static void
+unhash_delegation(struct nfs4_delegation *dp)
+{
+	spin_lock(&state_lock);
+	unhash_delegation_locked(dp);
+	spin_unlock(&state_lock);
+}
 
-
-static void destroy_revoked_delegation(struct nfs4_delegation *dp)
+static void destroy_delegation(struct nfs4_delegation *dp)
 {
-	list_del_init(&dp->dl_recall_lru);
 	remove_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 }
 
-static void destroy_delegation(struct nfs4_delegation *dp)
+static void unhash_and_destroy_delegation(struct nfs4_delegation *dp)
 {
 	unhash_delegation(dp);
-	remove_stid(&dp->dl_stid);
-	nfs4_put_delegation(dp);
+	destroy_delegation(dp);
+}
+
+static void destroy_revoked_delegation(struct nfs4_delegation *dp)
+{
+	list_del_init(&dp->dl_recall_lru);
+	destroy_delegation(dp);
 }
 
 static void revoke_delegation(struct nfs4_delegation *dp)
@@ -678,11 +687,10 @@ static void revoke_delegation(struct nfs4_delegation *dp)
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
 
@@ -1416,12 +1424,13 @@ destroy_client(struct nfs4_client *clp)
 	spin_lock(&state_lock);
 	while (!list_empty(&clp->cl_delegations)) {
 		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
-		list_del_init(&dp->dl_perclnt);
-		list_move(&dp->dl_recall_lru, &reaplist);
+		unhash_delegation_locked(dp);
+		list_add(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
+		list_del_init(&dp->dl_recall_lru);
 		destroy_delegation(dp);
 	}
 	list_splice_init(&clp->cl_revoked, &reaplist);
@@ -3604,7 +3613,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
 	return;
 out_free:
-	destroy_delegation(dp);
+	unhash_and_destroy_delegation(dp);
 out_no_deleg:
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
 	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
@@ -3843,7 +3852,8 @@ nfs4_laundromat(struct nfsd_net *nn)
 			new_timeo = min(new_timeo, t);
 			break;
 		}
-		list_move(&dp->dl_recall_lru, &reaplist);
+		unhash_delegation_locked(dp);
+		list_add(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
 	list_for_each_safe(pos, next, &reaplist) {
@@ -4469,7 +4479,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto out;
 
-	destroy_delegation(dp);
+	unhash_and_destroy_delegation(dp);
 out:
 	nfs4_unlock_state();
 
@@ -5293,8 +5303,10 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 
 	lockdep_assert_held(&state_lock);
 	list_for_each_entry_safe(dp, next, &clp->cl_delegations, dl_perclnt) {
-		if (victims)
-			list_move(&dp->dl_recall_lru, victims);
+		if (victims) {
+			unhash_delegation_locked(dp);
+			list_add(&dp->dl_recall_lru, victims);
+		}
 		if (++count == max)
 			break;
 	}
@@ -5543,11 +5555,13 @@ nfs4_state_shutdown_net(struct net *net)
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
+		list_del_init(&dp->dl_recall_lru);
 		destroy_delegation(dp);
 	}
 
-- 
1.9.3

