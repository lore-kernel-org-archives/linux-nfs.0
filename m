Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:43792 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761887AbaGRPNv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 11:13:51 -0400
Received: by mail-qa0-f44.google.com with SMTP id f12so3033423qad.17
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jul 2014 08:13:50 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v4 05/10] nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock
Date: Fri, 18 Jul 2014 11:13:31 -0400
Message-Id: <1405696416-32585-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
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
 fs/nfsd/nfs4state.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7c5233427c9b..d11b298e625e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -669,7 +669,7 @@ unhash_delegation_locked(struct nfs4_delegation *dp)
 
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
 {
-	list_del_init(&dp->dl_recall_lru);
+	WARN_ON(!list_empty(&dp->dl_recall_lru));
 	nfs4_put_delegation(dp);
 }
 
@@ -685,11 +685,15 @@ static void revoke_delegation(struct nfs4_delegation *dp)
 {
 	struct nfs4_client *clp = dp->dl_stid.sc_client;
 
+	WARN_ON(!list_empty(&dp->dl_recall_lru));
+
 	if (clp->cl_minorversion == 0)
 		destroy_revoked_delegation(dp);
 	else {
 		dp->dl_stid.sc_type = NFS4_REVOKED_DELEG_STID;
-		list_move(&dp->dl_recall_lru, &clp->cl_revoked);
+		spin_lock(&clp->cl_lock);
+		list_add(&dp->dl_recall_lru, &clp->cl_revoked);
+		spin_unlock(&clp->cl_lock);
 	}
 }
 
@@ -1458,9 +1462,9 @@ destroy_client(struct nfs4_client *clp)
 		list_del_init(&dp->dl_recall_lru);
 		nfs4_put_delegation(dp);
 	}
-	list_splice_init(&clp->cl_revoked, &reaplist);
-	while (!list_empty(&reaplist)) {
+	while (!list_empty(&clp->cl_revoked)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
+		list_del_init(&dp->dl_recall_lru);
 		destroy_revoked_delegation(dp);
 	}
 	while (!list_empty(&clp->cl_openowners)) {
@@ -3899,8 +3903,10 @@ nfs4_laundromat(struct nfsd_net *nn)
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
@@ -4244,6 +4250,9 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		break;
 	case NFS4_REVOKED_DELEG_STID:
 		dp = delegstateid(s);
+		spin_lock(&cl->cl_lock);
+		list_del_init(&dp->dl_recall_lru);
+		spin_unlock(&cl->cl_lock);
 		destroy_revoked_delegation(dp);
 		ret = nfs_ok;
 		break;
-- 
1.9.3

