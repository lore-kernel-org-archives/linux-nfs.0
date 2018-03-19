Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41694 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755749AbeCSOgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Mar 2018 10:36:47 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/10] nfsd: factor out common delegation-destruction code
Date: Mon, 19 Mar 2018 10:36:31 -0400
Message-Id: <1521470194-24840-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1521470194-24840-1-git-send-email-bfields@redhat.com>
References: <1521470194-24840-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Pull some duplicated code into a common helper.

This changes the order in destroy_delegation a little, but it looks to
me like that shouldn't matter.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b49000797c6f..268d095477e8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -864,6 +864,13 @@ static void nfs4_put_deleg_lease(struct nfs4_delegation *dp)
 	}
 }
 
+static void destroy_unhashed_deleg(struct nfs4_delegation *dp)
+{
+	put_clnt_odstate(dp->dl_clnt_odstate);
+	nfs4_put_deleg_lease(dp);
+	nfs4_put_stid(&dp->dl_stid);
+}
+
 void nfs4_unhash_stid(struct nfs4_stid *s)
 {
 	s->sc_type = 0;
@@ -955,11 +962,8 @@ static void destroy_delegation(struct nfs4_delegation *dp)
 	spin_lock(&state_lock);
 	unhashed = unhash_delegation_locked(dp);
 	spin_unlock(&state_lock);
-	if (unhashed) {
-		put_clnt_odstate(dp->dl_clnt_odstate);
-		nfs4_put_deleg_lease(dp);
-		nfs4_put_stid(&dp->dl_stid);
-	}
+	if (unhashed)
+		destroy_unhashed_deleg(dp);
 }
 
 static void revoke_delegation(struct nfs4_delegation *dp)
@@ -968,17 +972,14 @@ static void revoke_delegation(struct nfs4_delegation *dp)
 
 	WARN_ON(!list_empty(&dp->dl_recall_lru));
 
-	put_clnt_odstate(dp->dl_clnt_odstate);
-	nfs4_put_deleg_lease(dp);
-
-	if (clp->cl_minorversion == 0)
-		nfs4_put_stid(&dp->dl_stid);
-	else {
+	if (clp->cl_minorversion) {
 		dp->dl_stid.sc_type = NFS4_REVOKED_DELEG_STID;
+		refcount_inc(&dp->dl_stid.sc_count);
 		spin_lock(&clp->cl_lock);
 		list_add(&dp->dl_recall_lru, &clp->cl_revoked);
 		spin_unlock(&clp->cl_lock);
 	}
+	destroy_unhashed_deleg(dp);
 }
 
 /* 
@@ -1879,9 +1880,7 @@ __destroy_client(struct nfs4_client *clp)
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
-		put_clnt_odstate(dp->dl_clnt_odstate);
-		nfs4_put_deleg_lease(dp);
-		nfs4_put_stid(&dp->dl_stid);
+		destroy_unhashed_deleg(dp);
 	}
 	while (!list_empty(&clp->cl_revoked)) {
 		dp = list_entry(clp->cl_revoked.next, struct nfs4_delegation, dl_recall_lru);
@@ -7219,9 +7218,7 @@ nfs4_state_shutdown_net(struct net *net)
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
-		put_clnt_odstate(dp->dl_clnt_odstate);
-		nfs4_put_deleg_lease(dp);
-		nfs4_put_stid(&dp->dl_stid);
+		destroy_unhashed_deleg(dp);
 	}
 
 	BUG_ON(!list_empty(&reaplist));
-- 
2.14.3

