Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:53222 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354AbaG2Ued (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:34:33 -0400
Received: by mail-qg0-f45.google.com with SMTP id f51so293218qge.18
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:34:32 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v2 02/38] nfsd: Cleanup the freeing of stateids
Date: Tue, 29 Jul 2014 16:33:45 -0400
Message-Id: <1406666061-14175-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a ->free() callback to the struct nfs4_stid, so that we can
release a reference to the stid without caring about the contents.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4callback.c |  2 +-
 fs/nfsd/nfs4state.c    | 99 ++++++++++++++++++++++++++------------------------
 fs/nfsd/state.h        |  3 +-
 3 files changed, 55 insertions(+), 49 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index e9813389687b..8574c708cf8c 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -905,7 +905,7 @@ static void nfsd4_cb_recall_release(void *calldata)
 		spin_lock(&clp->cl_lock);
 		list_del(&cb->cb_per_client);
 		spin_unlock(&clp->cl_lock);
-		nfs4_put_delegation(dp);
+		nfs4_put_stid(&dp->dl_stid);
 	}
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3b0836db8553..7ade2499294a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -71,6 +71,7 @@ static u64 current_sessionid = 1;
 
 /* forward declarations */
 static bool check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner);
+static void nfs4_free_ol_stateid(struct nfs4_stid *stid);
 
 /* Locking: */
 
@@ -463,8 +464,8 @@ static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
 		__nfs4_file_put_access(fp, O_RDONLY);
 }
 
-static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct
-kmem_cache *slab)
+static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
+					 struct kmem_cache *slab)
 {
 	struct idr *stateids = &cl->cl_stateids;
 	struct nfs4_stid *stid;
@@ -500,7 +501,26 @@ out_free:
 
 static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
 {
-	return openlockstateid(nfs4_alloc_stid(clp, stateid_slab));
+	struct nfs4_stid *stid;
+	struct nfs4_ol_stateid *stp;
+
+	stid = nfs4_alloc_stid(clp, stateid_slab);
+	if (!stid)
+		return NULL;
+
+	stp = openlockstateid(stid);
+	stp->st_stid.sc_free = nfs4_free_ol_stateid;
+	return stp;
+}
+
+static void nfs4_free_deleg(struct nfs4_stid *stid)
+{
+	struct nfs4_delegation *dp = delegstateid(stid);
+
+	if (dp->dl_file)
+		put_nfs4_file(dp->dl_file);
+	kmem_cache_free(deleg_slab, stid);
+	atomic_long_dec(&num_delegations);
 }
 
 /*
@@ -594,6 +614,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh)
 	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
 	if (dp == NULL)
 		goto out_dec;
+
+	dp->dl_stid.sc_free = nfs4_free_deleg;
 	/*
 	 * delegation seqid's are never incremented.  The 4.1 special
 	 * meaning of seqid 0 isn't meaningful, really, but let's avoid
@@ -611,28 +633,15 @@ out_dec:
 	return NULL;
 }
 
-static void remove_stid(struct nfs4_stid *s)
-{
-	struct idr *stateids = &s->sc_client->cl_stateids;
-
-	idr_remove(stateids, s->sc_stateid.si_opaque.so_id);
-}
-
-static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
-{
-	kmem_cache_free(slab, s);
-}
-
 void
-nfs4_put_delegation(struct nfs4_delegation *dp)
+nfs4_put_stid(struct nfs4_stid *s)
 {
-	if (atomic_dec_and_test(&dp->dl_stid.sc_count)) {
-		if (dp->dl_file)
-			put_nfs4_file(dp->dl_file);
-		remove_stid(&dp->dl_stid);
-		nfs4_free_stid(deleg_slab, &dp->dl_stid);
-		atomic_long_dec(&num_delegations);
-	}
+	struct nfs4_client *clp = s->sc_client;
+
+	if (!atomic_dec_and_test(&s->sc_count))
+		return;
+	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
+	s->sc_free(s);
 }
 
 static void nfs4_put_deleg_lease(struct nfs4_file *fp)
@@ -689,7 +698,7 @@ static void destroy_delegation(struct nfs4_delegation *dp)
 	spin_lock(&state_lock);
 	unhash_delegation_locked(dp);
 	spin_unlock(&state_lock);
-	nfs4_put_delegation(dp);
+	nfs4_put_stid(&dp->dl_stid);
 }
 
 static void revoke_delegation(struct nfs4_delegation *dp)
@@ -699,7 +708,7 @@ static void revoke_delegation(struct nfs4_delegation *dp)
 	WARN_ON(!list_empty(&dp->dl_recall_lru));
 
 	if (clp->cl_minorversion == 0)
-		nfs4_put_delegation(dp);
+		nfs4_put_stid(&dp->dl_stid);
 	else {
 		dp->dl_stid.sc_type = NFS4_REVOKED_DELEG_STID;
 		spin_lock(&clp->cl_lock);
@@ -885,19 +894,14 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 	list_del(&stp->st_perstateowner);
 }
 
-static void close_generic_stateid(struct nfs4_ol_stateid *stp)
+static void nfs4_free_ol_stateid(struct nfs4_stid *stid)
 {
-	release_all_access(stp);
-}
+	struct nfs4_ol_stateid *stp = openlockstateid(stid);
 
-static void put_ol_stateid(struct nfs4_ol_stateid *stp)
-{
-	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
-		return;
+	release_all_access(stp);
 	if (stp->st_file)
 		put_nfs4_file(stp->st_file);
-	remove_stid(&stp->st_stid);
-	nfs4_free_stid(stateid_slab, &stp->st_stid);
+	kmem_cache_free(stateid_slab, stid);
 }
 
 static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
@@ -910,8 +914,7 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 	file = find_any_file(stp->st_file);
 	if (file)
 		filp_close(file, (fl_owner_t)lockowner(stp->st_stateowner));
-	close_generic_stateid(stp);
-	put_ol_stateid(stp);
+	nfs4_put_stid(&stp->st_stid);
 }
 
 static void unhash_lockowner(struct nfs4_lockowner *lo)
@@ -968,13 +971,12 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_generic_stateid(stp);
 	release_open_stateid_locks(stp);
-	close_generic_stateid(stp);
 }
 
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_open_stateid(stp);
-	put_ol_stateid(stp);
+	nfs4_put_stid(&stp->st_stid);
 }
 
 static void unhash_openowner(struct nfs4_openowner *oo)
@@ -995,7 +997,7 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	struct nfs4_ol_stateid *s = oo->oo_last_closed_stid;
 
 	if (s) {
-		put_ol_stateid(s);
+		nfs4_put_stid(&s->st_stid);
 		oo->oo_last_closed_stid = NULL;
 	}
 }
@@ -1469,12 +1471,12 @@ destroy_client(struct nfs4_client *clp)
 	while (!list_empty(&reaplist)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
-		nfs4_put_delegation(dp);
+		nfs4_put_stid(&dp->dl_stid);
 	}
 	while (!list_empty(&clp->cl_revoked)) {
 		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
-		nfs4_put_delegation(dp);
+		nfs4_put_stid(&dp->dl_stid);
 	}
 	while (!list_empty(&clp->cl_openowners)) {
 		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
@@ -3590,7 +3592,7 @@ out_unlock:
 	spin_unlock(&state_lock);
 out:
 	if (status) {
-		nfs4_put_delegation(dp);
+		nfs4_put_stid(&dp->dl_stid);
 		return ERR_PTR(status);
 	}
 	return dp;
@@ -3820,7 +3822,7 @@ void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
 	if (open->op_file)
 		nfsd4_free_file(open->op_file);
 	if (open->op_stp)
-		put_ol_stateid(open->op_stp);
+		nfs4_put_stid(&open->op_stp->st_stid);
 }
 
 __be32
@@ -4268,7 +4270,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		spin_lock(&cl->cl_lock);
 		list_del_init(&dp->dl_recall_lru);
 		spin_unlock(&cl->cl_lock);
-		nfs4_put_delegation(dp);
+		nfs4_put_stid(s);
 		ret = nfs_ok;
 		break;
 	default:
@@ -4481,7 +4483,7 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 	if (clp->cl_minorversion) {
 		if (list_empty(&oo->oo_owner.so_stateids))
 			release_openowner(oo);
-		put_ol_stateid(s);
+		nfs4_put_stid(&s->st_stid);
 	} else {
 		if (s->st_file) {
 			put_nfs4_file(s->st_file);
@@ -4490,8 +4492,11 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 		oo->oo_last_closed_stid = s;
 		/*
 		 * In the 4.0 case we need to keep the owners around a
-		 * little while to handle CLOSE replay.
+		 * little while to handle CLOSE replay. We still do need
+		 * to release any file access that is held by them
+		 * before returning however.
 		 */
+		release_all_access(s);
 		if (list_empty(&oo->oo_owner.so_stateids))
 			move_to_close_lru(oo, clp->net);
 	}
@@ -5667,7 +5672,7 @@ nfs4_state_shutdown_net(struct net *net)
 	list_for_each_safe(pos, next, &reaplist) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
-		nfs4_put_delegation(dp);
+		nfs4_put_stid(&dp->dl_stid);
 	}
 
 	nfsd4_client_tracking_exit(net);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 39747736e83b..32c466265ac1 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -85,6 +85,7 @@ struct nfs4_stid {
 	unsigned char sc_type;
 	stateid_t sc_stateid;
 	struct nfs4_client *sc_client;
+	void (*sc_free)(struct nfs4_stid *);
 };
 
 struct nfs4_delegation {
@@ -429,6 +430,7 @@ extern __be32 nfs4_preprocess_stateid_op(struct net *net,
 		stateid_t *stateid, int flags, struct file **filp);
 extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
+void nfs4_put_stid(struct nfs4_stid *s);
 void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *, struct nfsd_net *);
 extern void nfs4_release_reclaim(struct nfsd_net *);
 extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
@@ -446,7 +448,6 @@ extern int nfsd4_create_callback_queue(void);
 extern void nfsd4_destroy_callback_queue(void);
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfsd4_prepare_cb_recall(struct nfs4_delegation *dp);
-extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
-- 
1.9.3

