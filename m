Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:33363 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508AbaFZTP3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:15:29 -0400
Received: by mail-qg0-f48.google.com with SMTP id q108so3415801qgd.21
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:15:29 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 076/117] nfsd: optimize destroy_lockowner cl_lock thrashing
Date: Thu, 26 Jun 2014 15:12:56 -0400
Message-Id: <1403810017-16062-77-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reduce the cl_lock trashing in destroy_lockowner. Unhash all of the
lockstateids on the lockowner's list. Put the reference under the lock
and see if it was the last one. If so, then add it to a private list
to be destroyed after we drop the lock.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 50 +++++++++++++++++++++++++++++++++-----------------
 1 file changed, 33 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 92680d6531e7..790ff7dacbfb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -938,14 +938,23 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 	nfs4_put_stid(&stp->st_stid);
 }
 
-static void release_lock_stateid(struct nfs4_ol_stateid *stp)
+static void unhash_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_openowner *oo = openowner(stp->st_openstp->st_stateowner);
 
-	spin_lock(&oo->oo_owner.so_client->cl_lock);
-	list_del(&stp->st_locks);
+	lockdep_assert_held(&oo->oo_owner.so_client->cl_lock);
+
+	list_del_init(&stp->st_locks);
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
+}
+
+static void release_lock_stateid(struct nfs4_ol_stateid *stp)
+{
+	struct nfs4_openowner *oo = openowner(stp->st_openstp->st_stateowner);
+
+	spin_lock(&oo->oo_owner.so_client->cl_lock);
+	unhash_lock_stateid(stp);
 	spin_unlock(&oo->oo_owner.so_client->cl_lock);
 	put_generic_stateid(stp);
 }
@@ -959,30 +968,37 @@ static void unhash_lockowner_locked(struct nfs4_lockowner *lo)
 	list_del_init(&lo->lo_owner.so_strhash);
 }
 
-static void release_lockowner_stateids(struct nfs4_lockowner *lo)
+static void release_lockowner(struct nfs4_lockowner *lo)
 {
 	struct nfs4_client *clp = lo->lo_owner.so_client;
 	struct nfs4_ol_stateid *stp;
+	struct list_head reaplist;
 
-	lockdep_assert_held(&clp->cl_lock);
+	INIT_LIST_HEAD(&reaplist);
 
+	spin_lock(&clp->cl_lock);
+	unhash_lockowner_locked(lo);
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		spin_unlock(&clp->cl_lock);
-		release_lock_stateid(stp);
-		spin_lock(&clp->cl_lock);
+		unhash_lock_stateid(stp);
+		/*
+		 * We now know that no new references can be added to the
+		 * stateid. If ours is the last one, finish the unhashing
+		 * and put it on the list to be reaped.
+		 */
+		if (atomic_dec_and_test(&stp->st_stid.sc_count)) {
+			remove_stid_locked(clp, &stp->st_stid);
+			list_add(&stp->st_locks, &reaplist);
+		}
 	}
-}
-
-static void release_lockowner(struct nfs4_lockowner *lo)
-{
-	struct nfs4_client *clp = lo->lo_owner.so_client;
-
-	spin_lock(&clp->cl_lock);
-	unhash_lockowner_locked(lo);
-	release_lockowner_stateids(lo);
 	spin_unlock(&clp->cl_lock);
+	while (!list_empty(&reaplist)) {
+		stp = list_first_entry(&reaplist, struct nfs4_ol_stateid,
+					st_locks);
+		list_del(&stp->st_locks);
+		stp->st_stid.sc_free(&stp->st_stid);
+	}
 	nfs4_put_stateowner(&lo->lo_owner);
 }
 
-- 
1.9.3

