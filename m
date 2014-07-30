Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:42014 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656AbaG3Bfo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:44 -0400
Received: by mail-qg0-f45.google.com with SMTP id f51so658518qge.32
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:44 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 36/38] nfsd: reduce cl_lock thrashing in release_openowner
Date: Tue, 29 Jul 2014 21:34:41 -0400
Message-Id: <1406684083-19736-37-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Releasing an openowner is a bit inefficient as it can potentially thrash
the cl_lock if you have a lot of stateids attached to it. Once we remove
the client_mutex, it'll also potentially be dangerous to do this.

Add some functions to make it easier to defer the part of putting a
generic stateid reference that needs to be done outside the cl_lock while
doing the parts that must be done while holding it under a single lock.

First we unhash each open stateid. Then we call
put_generic_stateid_locked which will put the reference to an
nfs4_ol_stateid. If it turns out to be the last reference, it'll go
ahead and remove the stid from the IDR tree and put it onto the reaplist
using the st_locks list_head.

Then, after dropping the lock we'll call free_ol_stateid_reaplist to
walk the list of stateids that are fully unhashed and ready to be freed,
and free each of them. This function can sleep, so it must be done
outside any spinlocks.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 96 +++++++++++++++++++++++++++++++++++------------------
 1 file changed, 63 insertions(+), 33 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9c7dcbb68094..879342bc16b2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -983,6 +983,30 @@ static void nfs4_free_lock_stateid(struct nfs4_stid *stid)
 	nfs4_free_ol_stateid(stid);
 }
 
+/*
+ * Put the persistent reference to an already unhashed generic stateid, while
+ * holding the cl_lock. If it's the last reference, then put it onto the
+ * reaplist for later destruction.
+ */
+static void put_ol_stateid_locked(struct nfs4_ol_stateid *stp,
+				       struct list_head *reaplist)
+{
+	struct nfs4_stid *s = &stp->st_stid;
+	struct nfs4_client *clp = s->sc_client;
+
+	lockdep_assert_held(&clp->cl_lock);
+
+	WARN_ON_ONCE(!list_empty(&stp->st_locks));
+
+	if (!atomic_dec_and_test(&s->sc_count)) {
+		wake_up_all(&close_wq);
+		return;
+	}
+
+	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
+	list_add(&stp->st_locks, reaplist);
+}
+
 static void unhash_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_openowner *oo = openowner(stp->st_openstp->st_stateowner);
@@ -1013,6 +1037,25 @@ static void unhash_lockowner_locked(struct nfs4_lockowner *lo)
 	list_del_init(&lo->lo_owner.so_strhash);
 }
 
+/*
+ * Free a list of generic stateids that were collected earlier after being
+ * fully unhashed.
+ */
+static void
+free_ol_stateid_reaplist(struct list_head *reaplist)
+{
+	struct nfs4_ol_stateid *stp;
+
+	might_sleep();
+
+	while (!list_empty(reaplist)) {
+		stp = list_first_entry(reaplist, struct nfs4_ol_stateid,
+				       st_locks);
+		list_del(&stp->st_locks);
+		stp->st_stid.sc_free(&stp->st_stid);
+	}
+}
+
 static void release_lockowner(struct nfs4_lockowner *lo)
 {
 	struct nfs4_client *clp = lo->lo_owner.so_client;
@@ -1027,24 +1070,10 @@ static void release_lockowner(struct nfs4_lockowner *lo)
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
 		unhash_lock_stateid(stp);
-		/*
-		 * We now know that no new references can be added to the
-		 * stateid. If ours is the last one, finish the unhashing
-		 * and put it on the list to be reaped.
-		 */
-		if (atomic_dec_and_test(&stp->st_stid.sc_count)) {
-			idr_remove(&clp->cl_stateids,
-				stp->st_stid.sc_stateid.si_opaque.so_id);
-			list_add(&stp->st_locks, &reaplist);
-		}
+		put_ol_stateid_locked(stp, &reaplist);
 	}
 	spin_unlock(&clp->cl_lock);
-	while (!list_empty(&reaplist)) {
-		stp = list_first_entry(&reaplist, struct nfs4_ol_stateid,
-					st_locks);
-		list_del(&stp->st_locks);
-		stp->st_stid.sc_free(&stp->st_stid);
-	}
+	free_ol_stateid_reaplist(&reaplist);
 	nfs4_put_stateowner(&lo->lo_owner);
 }
 
@@ -1065,16 +1094,21 @@ static void release_open_stateid_locks(struct nfs4_ol_stateid *open_stp)
 
 static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 {
-	spin_lock(&stp->st_stateowner->so_client->cl_lock);
+	lockdep_assert_held(&stp->st_stid.sc_client->cl_lock);
+
 	unhash_generic_stateid(stp);
 	release_open_stateid_locks(stp);
-	spin_unlock(&stp->st_stateowner->so_client->cl_lock);
 }
 
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
 {
+	LIST_HEAD(reaplist);
+
+	spin_lock(&stp->st_stid.sc_client->cl_lock);
 	unhash_open_stateid(stp);
-	nfs4_put_stid(&stp->st_stid);
+	put_ol_stateid_locked(stp, &reaplist);
+	spin_unlock(&stp->st_stid.sc_client->cl_lock);
+	free_ol_stateid_reaplist(&reaplist);
 }
 
 static void unhash_openowner_locked(struct nfs4_openowner *oo)
@@ -1098,30 +1132,24 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
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
+		put_ol_stateid_locked(stp, &reaplist);
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
+	free_ol_stateid_reaplist(&reaplist);
 	release_last_closed_stateid(oo);
 	nfs4_put_stateowner(&oo->oo_owner);
 }
@@ -4675,7 +4703,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 	struct nfs4_client *clp = s->st_stid.sc_client;
 
 	s->st_stid.sc_type = NFS4_CLOSED_STID;
+	spin_lock(&clp->cl_lock);
 	unhash_open_stateid(s);
+	spin_unlock(&clp->cl_lock);
 
 	if (clp->cl_minorversion)
 		nfs4_put_stid(&s->st_stid);
-- 
1.9.3

