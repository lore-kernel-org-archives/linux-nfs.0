Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:51139 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbaDRSpr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:47 -0400
Received: by mail-ie0-f169.google.com with SMTP id to1so1906789ieb.0
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 26/70] NFSd: Fix delegation revocation
Date: Fri, 18 Apr 2014 14:44:20 -0400
Message-Id: <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that the delegations cannot be found by the laundromat etc once
we add them to the various 'revoke' lists.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 51 ++++++++++++++++++++++++++++++++-------------------
 1 file changed, 32 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 51ef179339ae..273bdddb2458 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -516,11 +516,10 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 
 /* Called under the state lock. */
 static void
-unhash_delegation(struct nfs4_delegation *dp)
+unhash_delegation_locked(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_file;
 
-	spin_lock(&state_lock);
 	spin_lock(&fp->fi_lock);
 	list_del_init(&dp->dl_perclnt);
 	list_del_init(&dp->dl_recall_lru);
@@ -531,23 +530,32 @@ unhash_delegation(struct nfs4_delegation *dp)
 	}
 	nfs4_put_deleg_lease(fp);
 	spin_unlock(&fp->fi_lock);
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
@@ -555,11 +563,10 @@ static void revoke_delegation(struct nfs4_delegation *dp)
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
 
@@ -1278,12 +1285,13 @@ destroy_client(struct nfs4_client *clp)
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
@@ -3612,7 +3620,8 @@ nfs4_laundromat(struct nfsd_net *nn)
 				test_val = u;
 			break;
 		}
-		list_move(&dp->dl_recall_lru, &reaplist);
+		unhash_delegation_locked(dp);
+		list_add(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
 	list_for_each_safe(pos, next, &reaplist) {
@@ -4245,7 +4254,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto out;
 
-	destroy_delegation(dp);
+	unhash_and_destroy_delegation(dp);
 out:
 	nfs4_unlock_state();
 
@@ -5061,8 +5070,10 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 
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
@@ -5318,11 +5329,13 @@ nfs4_state_shutdown_net(struct net *net)
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
1.9.0

