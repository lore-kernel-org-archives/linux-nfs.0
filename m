Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:39317 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478AbaGYLeq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2014 07:34:46 -0400
Received: by mail-qg0-f54.google.com with SMTP id z60so4843941qgd.41
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 04:34:45 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v6 3/9] nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock
Date: Fri, 25 Jul 2014 07:34:21 -0400
Message-Id: <1406288067-20663-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
References: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, both destroy_revoked_delegation and revoke_delegation
manipulate the cl_revoked list without any locking aside from the
client_mutex. Ensure that the clp->cl_lock is held when manipulating it,
except for the list walking in destroy_client. At that point, the client
should no longer be in use, and so it should be safe to walk the list
without any locking. That also means that we don't need to do the
list_splice_init there either.

Also, the fact that revoke_delegation deletes dl_recall_lru list_head
without any locking makes it difficult to know whether it's doing so
safely in all cases. Move the list_del_init calls into the callers, and
add a WARN_ON in the event that t's passed a delegation that has a
non-empty list_head.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 618daa0d4109..9c912c004247 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -680,12 +680,6 @@ unhash_delegation_locked(struct nfs4_delegation *dp)
 		nfs4_put_deleg_lease(fp);
 }
 
-static void destroy_revoked_delegation(struct nfs4_delegation *dp)
-{
-	list_del_init(&dp->dl_recall_lru);
-	nfs4_put_delegation(dp);
-}
-
 static void destroy_delegation(struct nfs4_delegation *dp)
 {
 	spin_lock(&state_lock);
@@ -698,11 +692,15 @@ static void revoke_delegation(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 
+	WARN_ON(!list_empty(&dp->dl_recall_lru));
+
 	if (clp->cl_minorversion == 0)
-		destroy_revoked_delegation(dp);
+		nfs4_put_delegation(dp);
 	else {
 		dp->dl_stid.sc_type = NFS4_REVOKED_DELEG_STID;
-		list_move(&dp->dl_recall_lru, &clp->cl_revoked);
+		spin_lock(&clp->cl_lock);
+		list_add(&dp->dl_recall_lru, &clp->cl_revoked);
+		spin_unlock(&clp->cl_lock);
 	}
 }
 
@@ -1467,10 +1465,10 @@ destroy_client(struct nfs4_client *clp)
 		list_del_init(&dp->dl_recall_lru);
 		nfs4_put_delegation(dp);
 	}
-	list_splice_init(&clp->cl_revoked, &reaplist);
-	while (!list_empty(&reaplist)) {
+	while (!list_empty(&clp->cl_revoked)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
-		destroy_revoked_delegation(dp);
+		list_del_init(&dp->dl_recall_lru);
+		nfs4_put_delegation(dp);
 	}
 	while (!list_empty(&clp->cl_openowners)) {
 		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
@@ -3903,8 +3901,10 @@ nfs4_laundromat(struct nfsd_net *nn)
 		list_add(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
-	list_for_each_safe(pos, next, &reaplist) {
-		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
+	while (!list_empty(&reaplist)) {
+		dp = list_first_entry(&reaplist, struct nfs4_delegation,
+					dl_recall_lru);
+		list_del_init(&dp->dl_recall_lru);
 		revoke_delegation(dp);
 	}
 	list_for_each_safe(pos, next, &nn->close_lru) {
@@ -4248,7 +4248,10 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		break;
 	case NFS4_REVOKED_DELEG_STID:
 		dp = delegstateid(s);
-		destroy_revoked_delegation(dp);
+		spin_lock(&cl->cl_lock);
+		list_del_init(&dp->dl_recall_lru);
+		spin_unlock(&cl->cl_lock);
+		nfs4_put_delegation(dp);
 		ret = nfs_ok;
 		break;
 	default:
@@ -5401,8 +5404,10 @@ u64 nfsd_forget_client_delegations(struct nfs4_client *clp, u64 max)
 	count = nfsd_find_all_delegations(clp, max, &victims);
 	spin_unlock(&state_lock);
 
-	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru)
+	list_for_each_entry_safe(dp, next, &victims, dl_recall_lru) {
+		list_del_init(&dp->dl_recall_lru);
 		revoke_delegation(dp);
+	}
 
 	return count;
 }
-- 
1.9.3

