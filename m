Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60169 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932227Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 11/25] nfsd4: split stateowners into open and lockowners
Date: Wed, 14 Sep 2011 07:45:07 -0400
Message-Id: <1316000721-3289-12-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The stateowner has some fields that only make sense for openowners, and
some that only make sense for lockowners, and I find it a lot clearer if
those are separated out.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c  |   18 ++--
 fs/nfsd/nfs4state.c |  367 ++++++++++++++++++++++++++-------------------------
 fs/nfsd/nfs4xdr.c   |    2 +-
 fs/nfsd/state.h     |   33 ++++-
 fs/nfsd/xdr4.h      |    2 +-
 5 files changed, 224 insertions(+), 198 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ce151f0..460eeb3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -250,7 +250,7 @@ do_open_lookup(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_o
 	fh_dup2(current_fh, &resfh);
 
 	/* set reply cache */
-	fh_copy_shallow(&open->op_stateowner->so_replay.rp_openfh,
+	fh_copy_shallow(&open->op_openowner->oo_owner.so_replay.rp_openfh,
 			&resfh.fh_handle);
 	if (!created)
 		status = do_open_permission(rqstp, current_fh, open,
@@ -277,7 +277,7 @@ do_open_fhandle(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_
 	memset(&open->op_cinfo, 0, sizeof(struct nfsd4_change_info));
 
 	/* set replay cache */
-	fh_copy_shallow(&open->op_stateowner->so_replay.rp_openfh,
+	fh_copy_shallow(&open->op_openowner->oo_owner.so_replay.rp_openfh,
 			&current_fh->fh_handle);
 
 	open->op_truncate = (open->op_iattr.ia_valid & ATTR_SIZE) &&
@@ -306,9 +306,9 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct nfsd4_compoundres *resp;
 
-	dprintk("NFSD: nfsd4_open filename %.*s op_stateowner %p\n",
+	dprintk("NFSD: nfsd4_open filename %.*s op_openowner %p\n",
 		(int)open->op_fname.len, open->op_fname.data,
-		open->op_stateowner);
+		open->op_openowner);
 
 	/* This check required by spec. */
 	if (open->op_create && open->op_claim_type != NFS4_OPEN_CLAIM_NULL)
@@ -332,7 +332,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	resp = rqstp->rq_resp;
 	status = nfsd4_process_open1(&resp->cstate, open);
 	if (status == nfserr_replay_me) {
-		struct nfs4_replay *rp = &open->op_stateowner->so_replay;
+		struct nfs4_replay *rp = &open->op_openowner->oo_owner.so_replay;
 		fh_put(&cstate->current_fh);
 		fh_copy_shallow(&cstate->current_fh.fh_handle,
 				&rp->rp_openfh);
@@ -374,7 +374,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				goto out;
 			break;
 		case NFS4_OPEN_CLAIM_PREVIOUS:
-			open->op_stateowner->so_confirmed = 1;
+			open->op_openowner->oo_confirmed = 1;
 			/*
 			 * The CURRENT_FH is already set to the file being
 			 * opened.  (1) set open->op_cinfo, (2) set
@@ -387,7 +387,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 				goto out;
 			break;
              	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
-			open->op_stateowner->so_confirmed = 1;
+			open->op_openowner->oo_confirmed = 1;
 			dprintk("NFSD: unsupported OPEN claim type %d\n",
 				open->op_claim_type);
 			status = nfserr_notsupp;
@@ -405,8 +405,8 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 */
 	status = nfsd4_process_open2(rqstp, &cstate->current_fh, open);
 out:
-	if (open->op_stateowner)
-		cstate->replay_owner = open->op_stateowner;
+	if (open->op_openowner)
+		cstate->replay_owner = &open->op_openowner->oo_owner;
 	else
 		nfs4_unlock_state();
 	return status;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eb11626..567130d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -63,7 +63,7 @@ static u64 current_sessionid = 1;
 static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_delegation * search_for_delegation(stateid_t *stid);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
-static int check_for_locks(struct nfs4_file *filp, struct nfs4_stateowner *lowner);
+static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
 
 /* Locking: */
 
@@ -77,7 +77,8 @@ static DEFINE_MUTEX(client_mutex);
  */
 static DEFINE_SPINLOCK(recall_lock);
 
-static struct kmem_cache *stateowner_slab = NULL;
+static struct kmem_cache *openowner_slab = NULL;
+static struct kmem_cache *lockowner_slab = NULL;
 static struct kmem_cache *file_slab = NULL;
 static struct kmem_cache *stateid_slab = NULL;
 static struct kmem_cache *deleg_slab = NULL;
@@ -432,41 +433,39 @@ static void release_lock_stateid(struct nfs4_stateid *stp)
 	unhash_generic_stateid(stp);
 	file = find_any_file(stp->st_file);
 	if (file)
-		locks_remove_posix(file, (fl_owner_t)stp->st_stateowner);
+		locks_remove_posix(file, (fl_owner_t)lockowner(stp->st_stateowner));
 	free_generic_stateid(stp);
 }
 
-static void unhash_lockowner(struct nfs4_stateowner *sop)
+static void unhash_lockowner(struct nfs4_lockowner *lo)
 {
 	struct nfs4_stateid *stp;
 
-	list_del(&sop->so_idhash);
-	list_del(&sop->so_strhash);
-	list_del(&sop->so_perstateid);
-	while (!list_empty(&sop->so_stateids)) {
-		stp = list_first_entry(&sop->so_stateids,
+	list_del(&lo->lo_owner.so_idhash);
+	list_del(&lo->lo_owner.so_strhash);
+	list_del(&lo->lo_perstateid);
+	while (!list_empty(&lo->lo_owner.so_stateids)) {
+		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_stateid, st_perstateowner);
 		release_lock_stateid(stp);
 	}
 }
 
-static void release_lockowner(struct nfs4_stateowner *sop)
+static void release_lockowner(struct nfs4_lockowner *lo)
 {
-	unhash_lockowner(sop);
-	nfs4_free_stateowner(sop);
+	unhash_lockowner(lo);
+	nfs4_free_lockowner(lo);
 }
 
 static void
 release_stateid_lockowners(struct nfs4_stateid *open_stp)
 {
-	struct nfs4_stateowner *lock_sop;
+	struct nfs4_lockowner *lo;
 
 	while (!list_empty(&open_stp->st_lockowners)) {
-		lock_sop = list_entry(open_stp->st_lockowners.next,
-				struct nfs4_stateowner, so_perstateid);
-		/* list_del(&open_stp->st_lockowners);  */
-		BUG_ON(lock_sop->so_is_open_owner);
-		release_lockowner(lock_sop);
+		lo = list_entry(open_stp->st_lockowners.next,
+				struct nfs4_lockowner, lo_perstateid);
+		release_lockowner(lo);
 	}
 }
 
@@ -477,26 +476,25 @@ static void release_open_stateid(struct nfs4_stateid *stp)
 	free_generic_stateid(stp);
 }
 
-static void unhash_openowner(struct nfs4_stateowner *sop)
+static void unhash_openowner(struct nfs4_openowner *oo)
 {
 	struct nfs4_stateid *stp;
 
-	list_del(&sop->so_idhash);
-	list_del(&sop->so_strhash);
-	list_del(&sop->so_perclient);
-	list_del(&sop->so_perstateid); /* XXX: necessary? */
-	while (!list_empty(&sop->so_stateids)) {
-		stp = list_first_entry(&sop->so_stateids,
+	list_del(&oo->oo_owner.so_idhash);
+	list_del(&oo->oo_owner.so_strhash);
+	list_del(&oo->oo_perclient);
+	while (!list_empty(&oo->oo_owner.so_stateids)) {
+		stp = list_first_entry(&oo->oo_owner.so_stateids,
 				struct nfs4_stateid, st_perstateowner);
 		release_open_stateid(stp);
 	}
 }
 
-static void release_openowner(struct nfs4_stateowner *sop)
+static void release_openowner(struct nfs4_openowner *oo)
 {
-	unhash_openowner(sop);
-	list_del(&sop->so_close_lru);
-	nfs4_free_stateowner(sop);
+	unhash_openowner(oo);
+	list_del(&oo->oo_close_lru);
+	nfs4_free_openowner(oo);
 }
 
 #define SESSION_HASH_SIZE	512
@@ -961,7 +959,7 @@ unhash_client_locked(struct nfs4_client *clp)
 static void
 expire_client(struct nfs4_client *clp)
 {
-	struct nfs4_stateowner *sop;
+	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
 	struct list_head reaplist;
 
@@ -979,8 +977,8 @@ expire_client(struct nfs4_client *clp)
 		unhash_delegation(dp);
 	}
 	while (!list_empty(&clp->cl_openowners)) {
-		sop = list_entry(clp->cl_openowners.next, struct nfs4_stateowner, so_perclient);
-		release_openowner(sop);
+		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
+		release_openowner(oo);
 	}
 	nfsd4_shutdown_callback(clp);
 	if (clp->cl_cb_conn.cb_xprt)
@@ -2173,7 +2171,8 @@ nfsd4_free_slab(struct kmem_cache **slab)
 void
 nfsd4_free_slabs(void)
 {
-	nfsd4_free_slab(&stateowner_slab);
+	nfsd4_free_slab(&openowner_slab);
+	nfsd4_free_slab(&lockowner_slab);
 	nfsd4_free_slab(&file_slab);
 	nfsd4_free_slab(&stateid_slab);
 	nfsd4_free_slab(&deleg_slab);
@@ -2182,9 +2181,13 @@ nfsd4_free_slabs(void)
 static int
 nfsd4_init_slabs(void)
 {
-	stateowner_slab = kmem_cache_create("nfsd4_stateowners",
-			sizeof(struct nfs4_stateowner), 0, 0, NULL);
-	if (stateowner_slab == NULL)
+	openowner_slab = kmem_cache_create("nfsd4_openowners",
+			sizeof(struct nfs4_openowner), 0, 0, NULL);
+	if (openowner_slab == NULL)
+		goto out_nomem;
+	lockowner_slab = kmem_cache_create("nfsd4_lockowners",
+			sizeof(struct nfs4_openowner), 0, 0, NULL);
+	if (lockowner_slab == NULL)
 		goto out_nomem;
 	file_slab = kmem_cache_create("nfsd4_files",
 			sizeof(struct nfs4_file), 0, 0, NULL);
@@ -2205,11 +2208,16 @@ out_nomem:
 	return -ENOMEM;
 }
 
-void
-nfs4_free_stateowner(struct nfs4_stateowner *sop)
+void nfs4_free_openowner(struct nfs4_openowner *oo)
+{
+	kfree(oo->oo_owner.so_owner.data);
+	kmem_cache_free(openowner_slab, oo);
+}
+
+void nfs4_free_lockowner(struct nfs4_lockowner *lo)
 {
-	kfree(sop->so_owner.data);
-	kmem_cache_free(stateowner_slab, sop);
+	kfree(lo->lo_owner.so_owner.data);
+	kmem_cache_free(lockowner_slab, lo);
 }
 
 static void init_nfs4_replay(struct nfs4_replay *rp)
@@ -2219,74 +2227,72 @@ static void init_nfs4_replay(struct nfs4_replay *rp)
 	rp->rp_buf = rp->rp_ibuf;
 }
 
-static inline struct nfs4_stateowner *alloc_stateowner(struct xdr_netobj *owner, struct nfs4_client *clp)
+static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj *owner, struct nfs4_client *clp)
 {
 	struct nfs4_stateowner *sop;
 
-	sop = kmem_cache_alloc(stateowner_slab, GFP_KERNEL);
+	sop = kmem_cache_alloc(slab, GFP_KERNEL);
 	if (!sop)
 		return NULL;
 
 	sop->so_owner.data = kmemdup(owner->data, owner->len, GFP_KERNEL);
 	if (!sop->so_owner.data) {
-		kmem_cache_free(stateowner_slab, sop);
+		kmem_cache_free(slab, sop);
 		return NULL;
 	}
 	sop->so_owner.len = owner->len;
 
-	INIT_LIST_HEAD(&sop->so_perclient);
 	INIT_LIST_HEAD(&sop->so_stateids);
-	INIT_LIST_HEAD(&sop->so_perstateid);
-	INIT_LIST_HEAD(&sop->so_close_lru);
 	sop->so_id = current_ownerid++;
-	sop->so_time = 0;
 	sop->so_client = clp;
 	init_nfs4_replay(&sop->so_replay);
 	return sop;
 }
 
-static void hash_openowner(struct nfs4_stateowner *sop, struct nfs4_client *clp, unsigned int strhashval)
+static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, unsigned int strhashval)
 {
 	unsigned int idhashval;
 
-	idhashval = open_ownerid_hashval(sop->so_id);
-	list_add(&sop->so_idhash, &open_ownerid_hashtbl[idhashval]);
-	list_add(&sop->so_strhash, &open_ownerstr_hashtbl[strhashval]);
-	list_add(&sop->so_perclient, &clp->cl_openowners);
+	idhashval = open_ownerid_hashval(oo->oo_owner.so_id);
+	list_add(&oo->oo_owner.so_idhash, &open_ownerid_hashtbl[idhashval]);
+	list_add(&oo->oo_owner.so_strhash, &open_ownerstr_hashtbl[strhashval]);
+	list_add(&oo->oo_perclient, &clp->cl_openowners);
 }
 
-static struct nfs4_stateowner *
+static struct nfs4_openowner *
 alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_open *open) {
-	struct nfs4_stateowner *sop;
+	struct nfs4_openowner *oo;
 
-	sop = alloc_stateowner(&open->op_owner, clp);
-	if (!sop)
+	oo = alloc_stateowner(openowner_slab, &open->op_owner, clp);
+	if (!oo)
 		return NULL;
-	sop->so_is_open_owner = 1;
-	sop->so_seqid = open->op_seqid;
-	sop->so_confirmed = 0;
-	hash_openowner(sop, clp, strhashval);
-	return sop;
+	oo->oo_owner.so_is_open_owner = 1;
+	oo->oo_owner.so_seqid = open->op_seqid;
+	oo->oo_confirmed = 0;
+	oo->oo_time = 0;
+	INIT_LIST_HEAD(&oo->oo_close_lru);
+	hash_openowner(oo, clp, strhashval);
+	return oo;
 }
 
 static inline void
 init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
-	struct nfs4_stateowner *sop = open->op_stateowner;
-	unsigned int hashval = stateid_hashval(sop->so_id, fp->fi_id);
+	struct nfs4_openowner *oo = open->op_openowner;
+	unsigned int hashval = stateid_hashval(oo->oo_owner.so_id, fp->fi_id);
 
 	INIT_LIST_HEAD(&stp->st_hash);
 	INIT_LIST_HEAD(&stp->st_perstateowner);
 	INIT_LIST_HEAD(&stp->st_lockowners);
 	INIT_LIST_HEAD(&stp->st_perfile);
 	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
-	list_add(&stp->st_perstateowner, &sop->so_stateids);
+	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	stp->st_type = NFS4_OPEN_STID;
-	stp->st_stateowner = sop;
+	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
 	stp->st_stateid.si_boot = boot_time;
-	stp->st_stateid.si_stateownerid = sop->so_id;
+	stp->st_stateid.si_stateownerid = oo->oo_owner.so_id;
 	stp->st_stateid.si_fileid = fp->fi_id;
 	/* note will be incremented before first return to client: */
 	stp->st_stateid.si_generation = 0;
@@ -2299,12 +2305,12 @@ init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *
 }
 
 static void
-move_to_close_lru(struct nfs4_stateowner *sop)
+move_to_close_lru(struct nfs4_openowner *oo)
 {
-	dprintk("NFSD: move_to_close_lru nfs4_stateowner %p\n", sop);
+	dprintk("NFSD: move_to_close_lru nfs4_openowner %p\n", oo);
 
-	list_move_tail(&sop->so_close_lru, &close_lru);
-	sop->so_time = get_seconds();
+	list_move_tail(&oo->oo_close_lru, &close_lru);
+	oo->oo_time = get_seconds();
 }
 
 static int
@@ -2316,14 +2322,14 @@ same_owner_str(struct nfs4_stateowner *sop, struct xdr_netobj *owner,
 		(sop->so_client->cl_clientid.cl_id == clid->cl_id);
 }
 
-static struct nfs4_stateowner *
+static struct nfs4_openowner *
 find_openstateowner_str(unsigned int hashval, struct nfsd4_open *open)
 {
 	struct nfs4_stateowner *so = NULL;
 
 	list_for_each_entry(so, &open_ownerstr_hashtbl[hashval], so_strhash) {
 		if (same_owner_str(so, &open->op_owner, &open->op_clientid))
-			return so;
+			return container_of(so, struct nfs4_openowner, oo_owner);
 	}
 	return NULL;
 }
@@ -2474,7 +2480,7 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 	clientid_t *clientid = &open->op_clientid;
 	struct nfs4_client *clp = NULL;
 	unsigned int strhashval;
-	struct nfs4_stateowner *sop = NULL;
+	struct nfs4_openowner *oo = NULL;
 	__be32 status;
 
 	if (!check_name(open->op_owner))
@@ -2484,34 +2490,34 @@ nfsd4_process_open1(struct nfsd4_compound_state *cstate,
 		return nfserr_stale_clientid;
 
 	strhashval = open_ownerstr_hashval(clientid->cl_id, &open->op_owner);
-	sop = find_openstateowner_str(strhashval, open);
-	open->op_stateowner = sop;
-	if (!sop) {
+	oo = find_openstateowner_str(strhashval, open);
+	open->op_openowner = oo;
+	if (!oo) {
 		/* Make sure the client's lease hasn't expired. */
 		clp = find_confirmed_client(clientid);
 		if (clp == NULL)
 			return nfserr_expired;
 		goto renew;
 	}
-	if (!sop->so_confirmed) {
+	if (!oo->oo_confirmed) {
 		/* Replace unconfirmed owners without checking for replay. */
-		clp = sop->so_client;
-		release_openowner(sop);
-		open->op_stateowner = NULL;
+		clp = oo->oo_owner.so_client;
+		release_openowner(oo);
+		open->op_openowner = NULL;
 		goto renew;
 	}
-	status = nfsd4_check_seqid(cstate, sop, open->op_seqid);
+	status = nfsd4_check_seqid(cstate, &oo->oo_owner, open->op_seqid);
 	if (status)
 		return status;
 renew:
-	if (open->op_stateowner == NULL) {
-		sop = alloc_init_open_stateowner(strhashval, clp, open);
-		if (sop == NULL)
+	if (open->op_openowner == NULL) {
+		oo = alloc_init_open_stateowner(strhashval, clp, open);
+		if (oo == NULL)
 			return nfserr_jukebox;
-		open->op_stateowner = sop;
+		open->op_openowner = oo;
 	}
-	list_del_init(&sop->so_close_lru);
-	renew_client(sop->so_client);
+	list_del_init(&oo->oo_close_lru);
+	renew_client(oo->oo_owner.so_client);
 	return nfs_ok;
 }
 
@@ -2565,7 +2571,7 @@ out:
 		return nfs_ok;
 	if (status)
 		return status;
-	open->op_stateowner->so_confirmed = 1;
+	open->op_openowner->oo_confirmed = 1;
 	return nfs_ok;
 }
 
@@ -2573,14 +2579,14 @@ static __be32
 nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_stateid **stpp)
 {
 	struct nfs4_stateid *local;
-	struct nfs4_stateowner *sop = open->op_stateowner;
+	struct nfs4_openowner *oo = open->op_openowner;
 
 	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
 		/* ignore lock owners */
 		if (local->st_stateowner->so_is_open_owner == 0)
 			continue;
 		/* remember if we have seen this open owner */
-		if (local->st_stateowner == sop)
+		if (local->st_stateowner == &oo->oo_owner)
 			*stpp = local;
 		/* check for conflicting share reservations */
 		if (!test_share(local, open))
@@ -2698,8 +2704,8 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *c
 static void
 nfs4_set_claim_prev(struct nfsd4_open *open)
 {
-	open->op_stateowner->so_confirmed = 1;
-	open->op_stateowner->so_client->cl_firststate = 1;
+	open->op_openowner->oo_confirmed = 1;
+	open->op_openowner->oo_owner.so_client->cl_firststate = 1;
 }
 
 /* Should we give out recallable state?: */
@@ -2782,11 +2788,11 @@ static void
 nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_stateid *stp)
 {
 	struct nfs4_delegation *dp;
-	struct nfs4_stateowner *sop = stp->st_stateowner;
+	struct nfs4_openowner *oo = container_of(stp->st_stateowner, struct nfs4_openowner, oo_owner);
 	int cb_up;
 	int status, flag = 0;
 
-	cb_up = nfsd4_cb_channel_good(sop->so_client);
+	cb_up = nfsd4_cb_channel_good(oo->oo_owner.so_client);
 	flag = NFS4_OPEN_DELEGATE_NONE;
 	open->op_recall = 0;
 	switch (open->op_claim_type) {
@@ -2802,7 +2808,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 			 * had the chance to reclaim theirs.... */
 			if (locks_in_grace())
 				goto out;
-			if (!cb_up || !sop->so_confirmed)
+			if (!cb_up || !oo->oo_confirmed)
 				goto out;
 			if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
 				flag = NFS4_OPEN_DELEGATE_WRITE;
@@ -2813,7 +2819,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 			goto out;
 	}
 
-	dp = alloc_init_deleg(sop->so_client, stp, fh, flag);
+	dp = alloc_init_deleg(oo->oo_owner.so_client, stp, fh, flag);
 	if (dp == NULL)
 		goto out_no_deleg;
 	status = nfs4_set_delegation(dp, flag);
@@ -2901,7 +2907,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	memcpy(&open->op_stateid, &stp->st_stateid, sizeof(stateid_t));
 
 	if (nfsd4_has_session(&resp->cstate))
-		open->op_stateowner->so_confirmed = 1;
+		open->op_openowner->oo_confirmed = 1;
 
 	/*
 	* Attempt to hand out a delegation. No error return, because the
@@ -2922,7 +2928,7 @@ out:
 	* To finish the open response, we just need to set the rflags.
 	*/
 	open->op_rflags = NFS4_OPEN_RESULT_LOCKTYPE_POSIX;
-	if (!open->op_stateowner->so_confirmed &&
+	if (!open->op_openowner->oo_confirmed &&
 	    !nfsd4_has_session(&resp->cstate))
 		open->op_rflags |= NFS4_OPEN_RESULT_CONFIRM;
 
@@ -2981,7 +2987,7 @@ static time_t
 nfs4_laundromat(void)
 {
 	struct nfs4_client *clp;
-	struct nfs4_stateowner *sop;
+	struct nfs4_openowner *oo;
 	struct nfs4_delegation *dp;
 	struct list_head *pos, *next, reaplist;
 	time_t cutoff = get_seconds() - nfsd4_lease;
@@ -3038,16 +3044,16 @@ nfs4_laundromat(void)
 	}
 	test_val = nfsd4_lease;
 	list_for_each_safe(pos, next, &close_lru) {
-		sop = list_entry(pos, struct nfs4_stateowner, so_close_lru);
-		if (time_after((unsigned long)sop->so_time, (unsigned long)cutoff)) {
-			u = sop->so_time - cutoff;
+		oo = container_of(pos, struct nfs4_openowner, oo_close_lru);
+		if (time_after((unsigned long)oo->oo_time, (unsigned long)cutoff)) {
+			u = oo->oo_time - cutoff;
 			if (test_val > u)
 				test_val = u;
 			break;
 		}
 		dprintk("NFSD: purging unused open stateowner (so_id %d)\n",
-			sop->so_id);
-		release_openowner(sop);
+			oo->oo_owner.so_id);
+		release_openowner(oo);
 	}
 	if (clientid_val < NFSD_LAUNDROMAT_MINTIMEOUT)
 		clientid_val = NFSD_LAUNDROMAT_MINTIMEOUT;
@@ -3069,13 +3075,12 @@ laundromat_main(struct work_struct *not_used)
 	queue_delayed_work(laundry_wq, &laundromat_work, t*HZ);
 }
 
-static struct nfs4_stateowner *
-search_close_lru(u32 st_id)
+static struct nfs4_openowner * search_close_lru(u32 st_id)
 {
-	struct nfs4_stateowner *local;
+	struct nfs4_openowner *local;
 
-	list_for_each_entry(local, &close_lru, so_close_lru) {
-		if (local->so_id == st_id)
+	list_for_each_entry(local, &close_lru, oo_close_lru) {
+		if (local->oo_owner.so_id == st_id)
 			return local;
 	}
 	return NULL;
@@ -3209,7 +3214,8 @@ __be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
 		goto out;
 	status = nfserr_bad_stateid;
 
-	if (!stp->st_stateowner->so_confirmed)
+	if (stp->st_stateowner->so_is_open_owner
+	    && !openowner(stp->st_stateowner)->oo_confirmed)
 		goto out;
 
 	status = check_stateid_generation(stateid, &stp->st_stateid, has_session);
@@ -3274,7 +3280,8 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		status = nfserr_bad_stateid;
 		if (nfs4_check_fh(current_fh, stp))
 			goto out;
-		if (!stp->st_stateowner->so_confirmed)
+		if (stp->st_stateowner->so_is_open_owner
+		    && !openowner(stp->st_stateowner)->oo_confirmed)
 			goto out;
 		status = check_stateid_generation(stateid, &stp->st_stateid,
 						  nfsd4_has_session(cstate));
@@ -3308,7 +3315,7 @@ nfsd4_free_delegation_stateid(stateid_t *stateid)
 static __be32
 nfsd4_free_lock_stateid(struct nfs4_stateid *stp)
 {
-	if (check_for_locks(stp->st_file, stp->st_stateowner))
+	if (check_for_locks(stp->st_file, lockowner(stp->st_stateowner)))
 		return nfserr_locks_held;
 	release_lock_stateid(stp);
 	return nfs_ok;
@@ -3417,7 +3424,8 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	if (status)
 		return status;
 
-	if (!sop->so_confirmed && !(flags & CONFIRM)) {
+	if (sop->so_is_open_owner && !openowner(sop)->oo_confirmed
+			&& !(flags & CONFIRM)) {
 		dprintk("NFSD: preprocess_seqid_op: stateowner not"
 				" confirmed yet!\n");
 		return nfserr_bad_stateid;
@@ -3434,7 +3442,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		   struct nfsd4_open_confirm *oc)
 {
 	__be32 status;
-	struct nfs4_stateowner *sop;
+	struct nfs4_openowner *oo;
 	struct nfs4_stateid *stp;
 
 	dprintk("NFSD: nfsd4_open_confirm on file %.*s\n",
@@ -3452,17 +3460,17 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					CONFIRM | OPEN_STATE, &stp);
 	if (status)
 		goto out;
-	sop = stp->st_stateowner;
+	oo = openowner(stp->st_stateowner);
 	status = nfserr_bad_stateid;
-	if (sop->so_confirmed)
+	if (oo->oo_confirmed)
 		goto out;
-	sop->so_confirmed = 1;
+	oo->oo_confirmed = 1;
 	update_stateid(&stp->st_stateid);
 	memcpy(&oc->oc_resp_stateid, &stp->st_stateid, sizeof(stateid_t));
 	dprintk("NFSD: %s: success, seqid=%d stateid=" STATEID_FMT "\n",
 		__func__, oc->oc_seqid, STATEID_VAL(&stp->st_stateid));
 
-	nfsd4_create_clid_dir(sop->so_client);
+	nfsd4_create_clid_dir(oo->oo_owner.so_client);
 	status = nfs_ok;
 out:
 	if (!cstate->replay_owner)
@@ -3513,7 +3521,6 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 					&od->od_stateid, OPEN_STATE, &stp);
 	if (status)
 		goto out; 
-
 	status = nfserr_inval;
 	if (!test_bit(od->od_share_access, &stp->st_access_bmap)) {
 		dprintk("NFSD:access not a subset current bitmap: 0x%lx, input access=%08x\n",
@@ -3546,8 +3553,8 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_close *close)
 {
 	__be32 status;
+	struct nfs4_openowner *oo;
 	struct nfs4_stateid *stp;
-	struct nfs4_stateowner *so;
 
 	dprintk("NFSD: nfsd4_close on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
@@ -3563,19 +3570,19 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		 * Also, we should make sure this isn't just the result of
 		 * a replayed close:
 		 */
-		so = search_close_lru(close->cl_stateid.si_stateownerid);
+		oo = search_close_lru(close->cl_stateid.si_stateownerid);
 		/* It's not stale; let's assume it's expired: */
-		if (so == NULL)
+		if (oo == NULL)
 			goto out;
-		cstate->replay_owner = so;
-		status = nfsd4_check_seqid(cstate, so, close->cl_seqid);
+		cstate->replay_owner = &oo->oo_owner;
+		status = nfsd4_check_seqid(cstate, &oo->oo_owner, close->cl_seqid);
 		if (status)
 			goto out;
 		status = nfserr_bad_seqid;
 	}
 	if (status)
 		goto out; 
-	so = stp->st_stateowner;
+	oo = openowner(stp->st_stateowner);
 	status = nfs_ok;
 	update_stateid(&stp->st_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stateid, sizeof(stateid_t));
@@ -3587,8 +3594,8 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * released by the laundromat service after the lease period
 	 * to enable us to handle CLOSE replay
 	 */
-	if (list_empty(&so->so_stateids))
-		move_to_close_lru(so);
+	if (list_empty(&oo->oo_owner.so_stateids))
+		move_to_close_lru(oo);
 out:
 	if (!cstate->replay_owner)
 		nfs4_unlock_state();
@@ -3768,17 +3775,17 @@ static const struct lock_manager_operations nfsd_posix_mng_ops  = {
 static inline void
 nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny)
 {
-	struct nfs4_stateowner *sop;
+	struct nfs4_lockowner *lo;
 
 	if (fl->fl_lmops == &nfsd_posix_mng_ops) {
-		sop = (struct nfs4_stateowner *) fl->fl_owner;
-		deny->ld_owner.data = kmemdup(sop->so_owner.data,
-					sop->so_owner.len, GFP_KERNEL);
+		lo = (struct nfs4_lockowner *) fl->fl_owner;
+		deny->ld_owner.data = kmemdup(lo->lo_owner.so_owner.data,
+					lo->lo_owner.so_owner.len, GFP_KERNEL);
 		if (!deny->ld_owner.data)
 			/* We just don't care that much */
 			goto nevermind;
-		deny->ld_owner.len = sop->so_owner.len;
-		deny->ld_clientid = sop->so_client->cl_clientid;
+		deny->ld_owner.len = lo->lo_owner.so_owner.len;
+		deny->ld_clientid = lo->lo_owner.so_client->cl_clientid;
 	} else {
 nevermind:
 		deny->ld_owner.len = 0;
@@ -3795,8 +3802,8 @@ nevermind:
 		deny->ld_type = NFS4_WRITE_LT;
 }
 
-static struct nfs4_stateowner *
-find_lockstateowner_str(struct inode *inode, clientid_t *clid,
+static struct nfs4_lockowner *
+find_lockowner_str(struct inode *inode, clientid_t *clid,
 		struct xdr_netobj *owner)
 {
 	unsigned int hashval = lock_ownerstr_hashval(inode, clid->cl_id, owner);
@@ -3804,19 +3811,19 @@ find_lockstateowner_str(struct inode *inode, clientid_t *clid,
 
 	list_for_each_entry(op, &lock_ownerstr_hashtbl[hashval], so_strhash) {
 		if (same_owner_str(op, owner, clid))
-			return op;
+			return lockowner(op);
 	}
 	return NULL;
 }
 
-static void hash_lockowner(struct nfs4_stateowner *sop, unsigned int strhashval, struct nfs4_client *clp, struct nfs4_stateid *open_stp)
+static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, struct nfs4_client *clp, struct nfs4_stateid *open_stp)
 {
 	unsigned int idhashval;
 
-	idhashval = lockownerid_hashval(sop->so_id);
-	list_add(&sop->so_idhash, &lock_ownerid_hashtbl[idhashval]);
-	list_add(&sop->so_strhash, &lock_ownerstr_hashtbl[strhashval]);
-	list_add(&sop->so_perstateid, &open_stp->st_lockowners);
+	idhashval = lockownerid_hashval(lo->lo_owner.so_id);
+	list_add(&lo->lo_owner.so_idhash, &lock_ownerid_hashtbl[idhashval]);
+	list_add(&lo->lo_owner.so_strhash, &lock_ownerstr_hashtbl[strhashval]);
+	list_add(&lo->lo_perstateid, &open_stp->st_lockowners);
 }
 
 /*
@@ -3827,28 +3834,27 @@ static void hash_lockowner(struct nfs4_stateowner *sop, unsigned int strhashval,
  * strhashval = lock_ownerstr_hashval 
  */
 
-static struct nfs4_stateowner *
+static struct nfs4_lockowner *
 alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfs4_stateid *open_stp, struct nfsd4_lock *lock) {
-	struct nfs4_stateowner *sop;
+	struct nfs4_lockowner *lo;
 
-	sop = alloc_stateowner(&lock->lk_new_owner, clp);
-	if (!sop)
+	lo = alloc_stateowner(lockowner_slab, &lock->lk_new_owner, clp);
+	if (!lo)
 		return NULL;
-	INIT_LIST_HEAD(&sop->so_stateids);
-	sop->so_is_open_owner = 0;
+	INIT_LIST_HEAD(&lo->lo_owner.so_stateids);
+	lo->lo_owner.so_is_open_owner = 0;
 	/* It is the openowner seqid that will be incremented in encode in the
 	 * case of new lockowners; so increment the lock seqid manually: */
-	sop->so_seqid = lock->lk_new_lock_seqid + 1;
-	sop->so_confirmed = 1;
-	hash_lockowner(sop, strhashval, clp, open_stp);
-	return sop;
+	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid + 1;
+	hash_lockowner(lo, strhashval, clp, open_stp);
+	return lo;
 }
 
 static struct nfs4_stateid *
-alloc_init_lock_stateid(struct nfs4_stateowner *sop, struct nfs4_file *fp, struct nfs4_stateid *open_stp)
+alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct nfs4_stateid *open_stp)
 {
 	struct nfs4_stateid *stp;
-	unsigned int hashval = stateid_hashval(sop->so_id, fp->fi_id);
+	unsigned int hashval = stateid_hashval(lo->lo_owner.so_id, fp->fi_id);
 
 	stp = nfs4_alloc_stateid();
 	if (stp == NULL)
@@ -3859,13 +3865,13 @@ alloc_init_lock_stateid(struct nfs4_stateowner *sop, struct nfs4_file *fp, struc
 	INIT_LIST_HEAD(&stp->st_lockowners); /* not used */
 	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
-	list_add(&stp->st_perstateowner, &sop->so_stateids);
-	stp->st_stateowner = sop;
+	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
+	stp->st_stateowner = &lo->lo_owner;
 	stp->st_type = NFS4_LOCK_STID;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
 	stp->st_stateid.si_boot = boot_time;
-	stp->st_stateid.si_stateownerid = sop->so_id;
+	stp->st_stateid.si_stateownerid = lo->lo_owner.so_id;
 	stp->st_stateid.si_fileid = fp->fi_id;
 	/* note will be incremented before first return to client: */
 	stp->st_stateid.si_generation = 0;
@@ -3902,8 +3908,8 @@ __be32
 nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	   struct nfsd4_lock *lock)
 {
-	struct nfs4_stateowner *open_sop = NULL;
-	struct nfs4_stateowner *lock_sop = NULL;
+	struct nfs4_openowner *open_sop = NULL;
+	struct nfs4_lockowner *lock_sop = NULL;
 	struct nfs4_stateid *lock_stp;
 	struct nfs4_file *fp;
 	struct file *filp = NULL;
@@ -3949,23 +3955,23 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					OPEN_STATE, &open_stp);
 		if (status)
 			goto out;
+		open_sop = openowner(open_stp->st_stateowner);
 		status = nfserr_bad_stateid;
-		open_sop = open_stp->st_stateowner;
 		if (!nfsd4_has_session(cstate) &&
-				!same_clid(&open_sop->so_client->cl_clientid,
+			!same_clid(&open_sop->oo_owner.so_client->cl_clientid,
 						&lock->v.new.clientid))
 			goto out;
 		/* create lockowner and lock stateid */
 		fp = open_stp->st_file;
-		strhashval = lock_ownerstr_hashval(fp->fi_inode, 
-				open_sop->so_client->cl_clientid.cl_id, 
+		strhashval = lock_ownerstr_hashval(fp->fi_inode,
+				open_sop->oo_owner.so_client->cl_clientid.cl_id,
 				&lock->v.new.owner);
 		/* XXX: Do we need to check for duplicate stateowners on
 		 * the same file, or should they just be allowed (and
 		 * create new stateids)? */
 		status = nfserr_jukebox;
 		lock_sop = alloc_init_lock_stateowner(strhashval,
-				open_sop->so_client, open_stp, lock);
+				open_sop->oo_owner.so_client, open_stp, lock);
 		if (lock_sop == NULL)
 			goto out;
 		lock_stp = alloc_init_lock_stateid(lock_sop, fp, open_stp);
@@ -3974,12 +3980,12 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	} else {
 		/* lock (lock owner + lock stateid) already exists */
 		status = nfs4_preprocess_seqid_op(cstate,
-				       lock->lk_old_lock_seqid, 
-				       &lock->lk_old_lock_stateid, 
+				       lock->lk_old_lock_seqid,
+				       &lock->lk_old_lock_stateid,
 				       LOCK_STATE, &lock_stp);
 		if (status)
 			goto out;
-		lock_sop = lock_stp->st_stateowner;
+		lock_sop = lockowner(lock_stp->st_stateowner);
 		fp = lock_stp->st_file;
 	}
 	/* lock_sop and lock_stp have been created or found */
@@ -4092,7 +4098,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct inode *inode;
 	struct file_lock file_lock;
-	struct nfs4_stateowner *so;
+	struct nfs4_lockowner *lo;
 	int error;
 	__be32 status;
 
@@ -4128,10 +4134,9 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	so = find_lockstateowner_str(inode,
-			&lockt->lt_clientid, &lockt->lt_owner);
-	if (so)
-		file_lock.fl_owner = (fl_owner_t)so;
+	lo = find_lockowner_str(inode, &lockt->lt_clientid, &lockt->lt_owner);
+	if (lo)
+		file_lock.fl_owner = (fl_owner_t)lo;
 	file_lock.fl_pid = current->tgid;
 	file_lock.fl_flags = FL_POSIX;
 
@@ -4186,7 +4191,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	BUG_ON(!filp);
 	locks_init_lock(&file_lock);
 	file_lock.fl_type = F_UNLCK;
-	file_lock.fl_owner = (fl_owner_t) stp->st_stateowner;
+	file_lock.fl_owner = (fl_owner_t)lockowner(stp->st_stateowner);
 	file_lock.fl_pid = current->tgid;
 	file_lock.fl_file = filp;
 	file_lock.fl_flags = FL_POSIX; 
@@ -4225,7 +4230,7 @@ out_nfserr:
  * 	0: no locks held by lockowner
  */
 static int
-check_for_locks(struct nfs4_file *filp, struct nfs4_stateowner *lowner)
+check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner)
 {
 	struct file_lock **flpp;
 	struct inode *inode = filp->fi_inode;
@@ -4250,6 +4255,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 {
 	clientid_t *clid = &rlockowner->rl_clientid;
 	struct nfs4_stateowner *sop;
+	struct nfs4_lockowner *lo;
 	struct nfs4_stateid *stp;
 	struct xdr_netobj *owner = &rlockowner->rl_owner;
 	struct list_head matches;
@@ -4279,11 +4285,10 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 				continue;
 			list_for_each_entry(stp, &sop->so_stateids,
 					st_perstateowner) {
-				if (check_for_locks(stp->st_file, sop))
+				lo = lockowner(sop);
+				if (check_for_locks(stp->st_file, lo))
 					goto out;
-				/* Note: so_perclient unused for lockowners,
-				 * so it's OK to fool with here. */
-				list_add(&sop->so_perclient, &matches);
+				list_add(&lo->lo_list, &matches);
 			}
 		}
 	}
@@ -4292,12 +4297,12 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	 * have been checked. */
 	status = nfs_ok;
 	while (!list_empty(&matches)) {
-		sop = list_entry(matches.next, struct nfs4_stateowner,
-								so_perclient);
+		lo = list_entry(matches.next, struct nfs4_lockowner,
+								lo_list);
 		/* unhash_stateowner deletes so_perclient only
 		 * for openowners. */
-		list_del(&sop->so_perclient);
-		release_lockowner(sop);
+		list_del(&lo->lo_list);
+		release_lockowner(lo);
 	}
 out:
 	nfs4_unlock_state();
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c4dcba3..182570b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -646,7 +646,7 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 
 	memset(open->op_bmval, 0, sizeof(open->op_bmval));
 	open->op_iattr.ia_valid = 0;
-	open->op_stateowner = NULL;
+	open->op_openowner = NULL;
 
 	/* seqid, share_access, share_deny, clientid, ownerlen */
 	READ_BUF(16 + sizeof(clientid_t));
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 0d88000..7994ed9 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -337,14 +337,11 @@ struct nfs4_replay {
 *         reaped (when so_perfilestate is empty) to hold the last close replay.
 *         reaped by laundramat thread after lease period.
 */
+
 struct nfs4_stateowner {
 	struct list_head        so_idhash;   /* hash by so_id */
 	struct list_head        so_strhash;   /* hash by op_name */
-	struct list_head        so_perclient;
 	struct list_head        so_stateids;
-	struct list_head        so_perstateid; /* for lockowners only */
-	struct list_head	so_close_lru; /* tail queue */
-	time_t			so_time; /* time of placement on so_close_lru */
 	int			so_is_open_owner; /* 1=openowner,0=lockowner */
 	u32                     so_id;
 	struct nfs4_client *    so_client;
@@ -352,10 +349,33 @@ struct nfs4_stateowner {
 	 * sequence id expected from the client: */
 	u32                     so_seqid;
 	struct xdr_netobj       so_owner;     /* open owner name */
-	int                     so_confirmed; /* successful OPEN_CONFIRM? */
 	struct nfs4_replay	so_replay;
 };
 
+struct nfs4_openowner {
+	struct nfs4_stateowner	oo_owner; /* must be first field */
+	struct list_head        oo_perclient;
+	struct list_head	oo_close_lru; /* tail queue */
+	time_t			oo_time; /* time of placement on so_close_lru */
+	int                     oo_confirmed; /* successful OPEN_CONFIRM? */
+};
+
+struct nfs4_lockowner {
+	struct nfs4_stateowner	lo_owner; /* must be first element */
+	struct list_head        lo_perstateid; /* for lockowners only */
+	struct list_head	lo_list; /* for temporary uses */
+};
+
+static inline struct nfs4_openowner * openowner(struct nfs4_stateowner *so)
+{
+	return container_of(so, struct nfs4_openowner, oo_owner);
+}
+
+static inline struct nfs4_lockowner * lockowner(struct nfs4_stateowner *so)
+{
+	return container_of(so, struct nfs4_lockowner, lo_owner);
+}
+
 /*
 *  nfs4_file: a file opened by some number of (open) nfs4_stateowners.
 *    o fi_perfile list is used to search for conflicting 
@@ -457,7 +477,8 @@ extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
 extern int nfs4_in_grace(void);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid);
-extern void nfs4_free_stateowner(struct nfs4_stateowner *sop);
+extern void nfs4_free_openowner(struct nfs4_openowner *);
+extern void nfs4_free_lockowner(struct nfs4_lockowner *);
 extern int set_callback_cred(void);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 27a3dfa..f95a724 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -227,7 +227,7 @@ struct nfsd4_open {
 	struct nfsd4_change_info  op_cinfo; /* response */
 	u32		op_rflags;          /* response */
 	int		op_truncate;        /* used during processing */
-	struct nfs4_stateowner *op_stateowner; /* used during processing */
+	struct nfs4_openowner *op_openowner; /* used during processing */
 	struct nfs4_acl *op_acl;
 };
 #define op_iattr	iattr
-- 
1.7.4.1

