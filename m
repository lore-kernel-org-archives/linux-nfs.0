Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:61978 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbaFZTVj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:21:39 -0400
Received: by mail-qg0-f53.google.com with SMTP id i50so3423547qgf.26
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:21:39 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 090/117] nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock
Date: Thu, 26 Jun 2014 15:20:58 -0400
Message-Id: <1403810485-16497-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
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
 fs/nfsd/nfs4state.c | 21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 73eb34901bf2..e9daa2649275 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -764,7 +764,7 @@ static void unhash_and_destroy_delegation(struct nfs4_delegation *dp)
 
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
 {
-	list_del_init(&dp->dl_recall_lru);
+	WARN_ON(!list_empty(&dp->dl_recall_lru));
 	nfs4_put_delegation(dp);
 }
 
@@ -772,11 +772,15 @@ static void revoke_delegation(struct nfs4_delegation *dp)
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
 
@@ -1596,9 +1600,9 @@ __destroy_client(struct nfs4_client *clp)
 		list_del_init(&dp->dl_recall_lru);
 		destroy_delegation(dp);
 	}
-	list_splice_init(&clp->cl_revoked, &reaplist);
-	while (!list_empty(&reaplist)) {
+	while (!list_empty(&clp->cl_revoked)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
+		list_del_init(&dp->dl_recall_lru);
 		destroy_revoked_delegation(dp);
 	}
 	while (!list_empty(&clp->cl_openowners)) {
@@ -4165,8 +4169,10 @@ nfs4_laundromat(struct nfsd_net *nn)
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
 
@@ -4529,8 +4535,9 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		ret = nfs_ok;
 		goto out;
 	case NFS4_REVOKED_DELEG_STID:
-		spin_unlock(&cl->cl_lock);
 		dp = delegstateid(s);
+		list_del_init(&dp->dl_recall_lru);
+		spin_unlock(&cl->cl_lock);
 		destroy_revoked_delegation(dp);
 		ret = nfs_ok;
 		goto out;
-- 
1.9.3

