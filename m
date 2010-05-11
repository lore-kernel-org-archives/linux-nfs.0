From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 4/9] nfsd4: extend the client_lock to cover cl_lru
Date: Wed, 12 May 2010 00:13:04 +0300
Message-ID: <1273612384-13573-1-git-send-email-bhalevy@panasas.com>
References: <4BE9C7A2.8030801@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:62398 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751621Ab0EKVNG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 17:13:06 -0400
In-Reply-To: <4BE9C7A2.8030801@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To be used later on to hold a reference count on the client while in use by a
nfsv4.1 compound.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   41 ++++++++++++++++++++++++++---------------
 1 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index aecafb2..3f572cb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -250,7 +250,7 @@ unhash_delegation(struct nfs4_delegation *dp)
  * SETCLIENTID state 
  */
 
-/* client_lock protects the session hash table */
+/* client_lock protects the client lru list and session hash table */
 static DEFINE_SPINLOCK(client_lock);
 
 /* Hash tables for nfs4_clientid state */
@@ -628,8 +628,9 @@ free_session(struct kref *kref)
 	kfree(ses);
 }
 
+/* must be called under the client_lock */
 static inline void
-renew_client(struct nfs4_client *clp)
+renew_client_locked(struct nfs4_client *clp)
 {
 	/*
 	* Move client to the end to the LRU list.
@@ -641,6 +642,14 @@ renew_client(struct nfs4_client *clp)
 	clp->cl_time = get_seconds();
 }
 
+static inline void
+renew_client(struct nfs4_client *clp)
+{
+	spin_lock(&client_lock);
+	renew_client_locked(clp);
+	spin_unlock(&client_lock);
+}
+
 /* SETCLIENTID and SETCLIENTID_CONFIRM Helper functions */
 static int
 STALE_CLIENTID(clientid_t *clid)
@@ -706,14 +715,14 @@ expire_client(struct nfs4_client *clp)
 		list_del_init(&dp->dl_recall_lru);
 		unhash_delegation(dp);
 	}
-	list_del(&clp->cl_idhash);
-	list_del(&clp->cl_strhash);
-	list_del(&clp->cl_lru);
 	while (!list_empty(&clp->cl_openowners)) {
 		sop = list_entry(clp->cl_openowners.next, struct nfs4_stateowner, so_perclient);
 		release_openowner(sop);
 	}
+	list_del(&clp->cl_idhash);
+	list_del(&clp->cl_strhash);
 	spin_lock(&client_lock);
+	list_del(&clp->cl_lru);
 	while (!list_empty(&clp->cl_sessions)) {
 		struct nfsd4_session  *ses;
 		ses = list_entry(clp->cl_sessions.next, struct nfsd4_session,
@@ -848,8 +857,7 @@ add_to_unconfirmed(struct nfs4_client *clp, unsigned int strhashval)
 	list_add(&clp->cl_strhash, &unconf_str_hashtbl[strhashval]);
 	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
 	list_add(&clp->cl_idhash, &unconf_id_hashtbl[idhashval]);
-	list_add_tail(&clp->cl_lru, &client_lru);
-	clp->cl_time = get_seconds();
+	renew_client(clp);
 }
 
 static void
@@ -1447,15 +1455,12 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 
 out:
 	/* Hold a session reference until done processing the compound. */
-	if (cstate->session)
-		nfsd4_get_session(cstate->session);
-	spin_unlock(&client_lock);
-	/* Renew the clientid on success and on replay */
 	if (cstate->session) {
-		nfs4_lock_state();
-		renew_client(session->se_client);
-		nfs4_unlock_state();
+		nfsd4_get_session(cstate->session);
+		/* Renew the clientid on success and on replay */
+		renew_client_locked(session->se_client);
 	}
+	spin_unlock(&client_lock);
 	dprintk("%s: return %d\n", __func__, ntohl(status));
 	return status;
 }
@@ -2564,6 +2569,8 @@ nfs4_laundromat(void)
 	dprintk("NFSD: laundromat service - starting\n");
 	if (locks_in_grace())
 		nfsd4_end_grace();
+	INIT_LIST_HEAD(&reaplist);
+	spin_lock(&client_lock);
 	list_for_each_safe(pos, next, &client_lru) {
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
@@ -2572,12 +2579,16 @@ nfs4_laundromat(void)
 				clientid_val = t;
 			break;
 		}
+		list_move(&clp->cl_lru, &reaplist);
+	}
+	spin_unlock(&client_lock);
+	list_for_each_safe(pos, next, &reaplist) {
+		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		dprintk("NFSD: purging unused client (clientid %08x)\n",
 			clp->cl_clientid.cl_id);
 		nfsd4_remove_clid_dir(clp);
 		expire_client(clp);
 	}
-	INIT_LIST_HEAD(&reaplist);
 	spin_lock(&recall_lock);
 	list_for_each_safe(pos, next, &del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
-- 
1.6.5.1

