Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:53761 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932418AbaGUNfW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 09:35:22 -0400
Received: by mail-qc0-f174.google.com with SMTP id o8so5481972qcw.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 06:35:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v5 05/10] nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock
Date: Mon, 21 Jul 2014 09:35:01 -0400
Message-Id: <1405949706-27757-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405949706-27757-1-git-send-email-jlayton@primarydata.com>
References: <1405949706-27757-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, both destroy_revoked_delegation and revoke_delegation
manipulate the cl_revoked list without any locking aside from the
client_mutex. Ensure that the clp->cl_lock is held when manipulating it,
except for the list walking in destroy_client. At that point, the client
should no longer be in use, and so it should be safe to walk the list
without any locking. That also means that we don't need to do the
list_splice_init there either.

Also, the fact that destroy_revoked_delegation and revoke_delegation
delete dl_recall_lru without any locking makes it difficult to know
whether they're doing so safely in all cases. Move the list_del_init
calls into the callers, and add WARN_ONs in the event that these calls
are passed a delegation that has a non-empty list_head.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d8c28d5c600f..58746f0f34a1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -667,12 +667,6 @@ unhash_delegation_locked(struct nfs4_delegation *dp)
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
@@ -685,11 +679,15 @@ static void revoke_delegation(struct nfs4_delegation *dp)
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
 
@@ -1458,10 +1456,10 @@ destroy_client(struct nfs4_client *clp)
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
@@ -3898,8 +3896,10 @@ nfs4_laundromat(struct nfsd_net *nn)
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
@@ -4243,7 +4243,10 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
-- 
1.9.3

