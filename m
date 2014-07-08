Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:41869 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755393AbaGHSGO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:14 -0400
Received: by mail-qa0-f48.google.com with SMTP id x12so5100366qac.7
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:13 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 073/100] nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock
Date: Tue,  8 Jul 2014 14:04:01 -0400
Message-Id: <1404842668-22521-74-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
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
index 3ef8d9a577ae..06b6e3387ec7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -743,7 +743,7 @@ static void unhash_and_destroy_delegation(struct nfs4_delegation *dp)
 
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
 {
-	list_del_init(&dp->dl_recall_lru);
+	WARN_ON(!list_empty(&dp->dl_recall_lru));
 	nfs4_put_delegation(dp);
 }
 
@@ -751,11 +751,15 @@ static void revoke_delegation(struct nfs4_delegation *dp)
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
 
@@ -1622,9 +1626,9 @@ __destroy_client(struct nfs4_client *clp)
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
@@ -4206,8 +4210,10 @@ nfs4_laundromat(struct nfsd_net *nn)
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
 
@@ -4570,8 +4576,9 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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

