From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH] nfsd4: split open/lockowner release code
Date: Sun, 11 Jan 2009 18:52:29 -0500
Message-ID: <1231717949-31908-4-git-send-email-bfields@citi.umich.edu>
References: <1231717949-31908-1-git-send-email-bfields@citi.umich.edu>
 <1231717949-31908-2-git-send-email-bfields@citi.umich.edu>
 <1231717949-31908-3-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:45576 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104AbZAKXwb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Jan 2009 18:52:31 -0500
In-Reply-To: <1231717949-31908-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The caller always knows specifically whether it's releasing a lockowner
or an openowner, and the code is simpler if we use separate functions
(and the apparent recursion is gone).

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   57 ++++++++++++++++++++++++++++++--------------------
 1 files changed, 34 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 298d6ce..847bddd 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -116,9 +116,6 @@ opaque_hashval(const void *ptr, int nbytes)
 	return x;
 }
 
-/* forward declarations */
-static void release_stateowner(struct nfs4_stateowner *sop);
-
 /*
  * Delegation state
  */
@@ -324,6 +321,26 @@ static void release_lock_stateid(struct nfs4_stateid *stp)
 	release_generic_stateid(stp);
 }
 
+static void unhash_lockowner(struct nfs4_stateowner *sop)
+{
+	struct nfs4_stateid *stp;
+
+	list_del(&sop->so_idhash);
+	list_del(&sop->so_strhash);
+	list_del(&sop->so_perstateid);
+	while (!list_empty(&sop->so_stateids)) {
+		stp = list_first_entry(&sop->so_stateids,
+				struct nfs4_stateid, st_perstateowner);
+		release_lock_stateid(stp);
+	}
+}
+
+static void release_lockowner(struct nfs4_stateowner *sop)
+{
+	unhash_lockowner(sop);
+	nfs4_put_stateowner(sop);
+}
+
 static void
 release_stateid_lockowners(struct nfs4_stateid *open_stp)
 {
@@ -334,7 +351,7 @@ release_stateid_lockowners(struct nfs4_stateid *open_stp)
 				struct nfs4_stateowner, so_perstateid);
 		/* list_del(&open_stp->st_lockowners);  */
 		BUG_ON(lock_sop->so_is_open_owner);
-		release_stateowner(lock_sop);
+		release_lockowner(lock_sop);
 	}
 }
 
@@ -345,30 +362,24 @@ static void release_open_stateid(struct nfs4_stateid *stp)
 	release_generic_stateid(stp);
 }
 
-static void
-unhash_stateowner(struct nfs4_stateowner *sop)
+static void unhash_openowner(struct nfs4_stateowner *sop)
 {
 	struct nfs4_stateid *stp;
 
 	list_del(&sop->so_idhash);
 	list_del(&sop->so_strhash);
-	if (sop->so_is_open_owner)
-		list_del(&sop->so_perclient);
-	list_del(&sop->so_perstateid);
+	list_del(&sop->so_perclient);
+	list_del(&sop->so_perstateid); /* XXX: necessary? */
 	while (!list_empty(&sop->so_stateids)) {
-		stp = list_entry(sop->so_stateids.next,
-			struct nfs4_stateid, st_perstateowner);
-		if (sop->so_is_open_owner)
-			release_open_stateid(stp);
-		else
-			release_lock_stateid(stp);
+		stp = list_first_entry(&sop->so_stateids,
+				struct nfs4_stateid, st_perstateowner);
+		release_open_stateid(stp);
 	}
 }
 
-static void
-release_stateowner(struct nfs4_stateowner *sop)
+static void release_openowner(struct nfs4_stateowner *sop)
 {
-	unhash_stateowner(sop);
+	unhash_openowner(sop);
 	list_del(&sop->so_close_lru);
 	nfs4_put_stateowner(sop);
 }
@@ -482,7 +493,7 @@ expire_client(struct nfs4_client *clp)
 	list_del(&clp->cl_lru);
 	while (!list_empty(&clp->cl_openowners)) {
 		sop = list_entry(clp->cl_openowners.next, struct nfs4_stateowner, so_perclient);
-		release_stateowner(sop);
+		release_openowner(sop);
 	}
 	put_nfs4_client(clp);
 }
@@ -1437,7 +1448,7 @@ nfsd4_process_open1(struct nfsd4_open *open)
 	if (!sop->so_confirmed) {
 		/* Replace unconfirmed owners without checking for replay. */
 		clp = sop->so_client;
-		release_stateowner(sop);
+		release_openowner(sop);
 		open->op_stateowner = NULL;
 		goto renew;
 	}
@@ -1900,7 +1911,7 @@ nfs4_laundromat(void)
 		}
 		dprintk("NFSD: purging unused open stateowner (so_id %d)\n",
 			sop->so_id);
-		release_stateowner(sop);
+		release_openowner(sop);
 	}
 	if (clientid_val < NFSD_LAUNDROMAT_MINTIMEOUT)
 		clientid_val = NFSD_LAUNDROMAT_MINTIMEOUT;
@@ -2790,7 +2801,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	}
 out:
 	if (status && lock->lk_is_new && lock_sop)
-		release_stateowner(lock_sop);
+		release_lockowner(lock_sop);
 	if (lock->lk_replay_owner) {
 		nfs4_get_stateowner(lock->lk_replay_owner);
 		cstate->replay_owner = lock->lk_replay_owner;
@@ -3040,7 +3051,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 		/* unhash_stateowner deletes so_perclient only
 		 * for openowners. */
 		list_del(&sop->so_perclient);
-		release_stateowner(sop);
+		release_lockowner(sop);
 	}
 out:
 	nfs4_unlock_state();
-- 
1.5.5.rc1

