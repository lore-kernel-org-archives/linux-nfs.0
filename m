Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:57593 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbaGYLeo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2014 07:34:44 -0400
Received: by mail-qg0-f47.google.com with SMTP id i50so4781355qgf.20
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 04:34:43 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v6 2/9] nfsd: fully unhash delegations when revoking them
Date: Fri, 25 Jul 2014 07:34:20 -0400
Message-Id: <1406288067-20663-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
References: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that the delegations cannot be found by the laundromat etc once
we add them to the various 'revoke' lists.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 44 +++++++++++++++++++++-----------------------
 1 file changed, 21 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fdbfbcb70914..618daa0d4109 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -661,13 +661,13 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
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
 	/* Ensure that deleg break won't try to requeue it */
 	++dp->dl_time;
@@ -678,7 +678,6 @@ unhash_delegation(struct nfs4_delegation *dp)
 	spin_unlock(&fp->fi_lock);
 	if (fp)
 		nfs4_put_deleg_lease(fp);
-	spin_unlock(&state_lock);
 }
 
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
@@ -689,7 +688,9 @@ static void destroy_revoked_delegation(struct nfs4_delegation *dp)
 
 static void destroy_delegation(struct nfs4_delegation *dp)
 {
-	unhash_delegation(dp);
+	spin_lock(&state_lock);
+	unhash_delegation_locked(dp);
+	spin_unlock(&state_lock);
 	nfs4_put_delegation(dp);
 }
 
@@ -698,11 +699,10 @@ static void revoke_delegation(struct nfs4_delegation *dp)
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
 
@@ -1458,15 +1458,14 @@ destroy_client(struct nfs4_client *clp)
 	spin_lock(&state_lock);
 	while (!list_empty(&clp->cl_delegations)) {
 		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
-		list_del_init(&dp->dl_perclnt);
-		/* Ensure that deleg break won't try to requeue it */
-		++dp->dl_time;
-		list_move(&dp->dl_recall_lru, &reaplist);
+		unhash_delegation_locked(dp);
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
@@ -3662,7 +3661,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
 	return;
 out_free:
-	destroy_delegation(dp);
+	nfs4_put_delegation(dp);
 out_no_deleg:
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
 	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
@@ -3900,7 +3899,8 @@ nfs4_laundromat(struct nfsd_net *nn)
 			new_timeo = min(new_timeo, t);
 			break;
 		}
-		list_move(&dp->dl_recall_lru, &reaplist);
+		unhash_delegation_locked(dp);
+		list_add(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
 	list_for_each_safe(pos, next, &reaplist) {
@@ -5382,12 +5382,8 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 			if (dp->dl_time != 0)
 				continue;
 
-			/*
-			 * Increment dl_time to ensure that delegation breaks
-			 * don't monkey with it now that we are.
-			 */
-			++dp->dl_time;
-			list_move(&dp->dl_recall_lru, victims);
+			unhash_delegation_locked(dp);
+			list_add(&dp->dl_recall_lru, victims);
 		}
 		if (++count == max)
 			break;
@@ -5642,12 +5638,14 @@ nfs4_state_shutdown_net(struct net *net)
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

