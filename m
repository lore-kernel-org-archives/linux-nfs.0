Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:60488 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932184AbaFSOwd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:33 -0400
Received: by mail-qg0-f43.google.com with SMTP id z60so2237195qgd.30
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:32 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 065/104] nfsd: reduce cl_lock trashing in release_openowner
Date: Thu, 19 Jun 2014 10:50:11 -0400
Message-Id: <1403189450-18729-66-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 46 ++++++++++++++++++++++++----------------------
 1 file changed, 24 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 62af2431f118..7bb7dd19e275 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -899,16 +899,10 @@ static void release_open_stateid_locks(struct nfs4_ol_stateid *open_stp)
 
 static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 {
-	spin_lock(&stp->st_stateowner->so_client->cl_lock);
+	lockdep_assert_held(&stp->st_stateowner->so_client->cl_lock);
+
 	unhash_generic_stateid(stp);
 	release_open_stateid_locks(stp);
-	spin_unlock(&stp->st_stateowner->so_client->cl_lock);
-}
-
-static void release_open_stateid(struct nfs4_ol_stateid *stp)
-{
-	unhash_open_stateid(stp);
-	put_generic_stateid(stp);
 }
 
 static void unhash_openowner_locked(struct nfs4_openowner *oo)
@@ -932,30 +926,36 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	}
 }
 
-static void release_openowner_stateids(struct nfs4_openowner *oo)
+static void release_openowner(struct nfs4_openowner *oo)
 {
 	struct nfs4_ol_stateid *stp;
 	struct nfs4_client *clp = oo->oo_owner.so_client;
+	struct list_head reaplist;
 
-	lockdep_assert_held(&clp->cl_lock);
+	INIT_LIST_HEAD(&reaplist);
 
+	spin_lock(&clp->cl_lock);
+	unhash_openowner_locked(oo);
 	while (!list_empty(&oo->oo_owner.so_stateids)) {
 		stp = list_first_entry(&oo->oo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		spin_unlock(&clp->cl_lock);
-		release_open_stateid(stp);
-		spin_lock(&clp->cl_lock);
+		unhash_open_stateid(stp);
+		/*
+		 * Put the persistent reference to the stateid. If it's
+		 * the last reference, then put it onto the reaplist
+		 * for later destruction.
+		 */
+		if (atomic_dec_and_test(&stp->st_stid.sc_count)) {
+			remove_stid_locked(clp, &stp->st_stid);
+			list_add(&stp->st_locks, &reaplist);
+		}
 	}
-}
-
-static void release_openowner(struct nfs4_openowner *oo)
-{
-	struct nfs4_client *clp = oo->oo_owner.so_client;
-
-	spin_lock(&clp->cl_lock);
-	unhash_openowner_locked(oo);
-	release_openowner_stateids(oo);
 	spin_unlock(&clp->cl_lock);
+	while (!list_empty(&reaplist)) {
+		stp = list_first_entry(&reaplist, struct nfs4_ol_stateid, st_locks);
+		list_del(&stp->st_locks);
+		stp->st_stid.sc_free(&stp->st_stid);
+	}
 	release_last_closed_stateid(oo);
 	nfs4_put_stateowner(&oo->oo_owner);
 }
@@ -4554,7 +4554,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 	struct nfs4_client *clp = s->st_stid.sc_client;
 
 	s->st_stid.sc_type = NFS4_CLOSED_STID;
+	spin_lock(&clp->cl_lock);
 	unhash_open_stateid(s);
+	spin_unlock(&clp->cl_lock);
 
 	/*
 	 * We can't safely clear the sc_file pointer while there are still
-- 
1.9.3

