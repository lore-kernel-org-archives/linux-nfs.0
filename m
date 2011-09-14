Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60185 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932247Ab1INLp3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 19/25] nfsd4: move some of nfs4_stateid into a separate structure
Date: Wed, 14 Sep 2011 07:45:15 -0400
Message-Id: <1316000721-3289-20-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We want delegations to share more with open/lock stateid's, so first
we'll pull out some of the common stuff we want to share.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |  174 +++++++++++++++++++++++++-------------------------
 fs/nfsd/state.h     |   29 ++++++---
 2 files changed, 106 insertions(+), 97 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 768382d..d0bb5a5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -159,7 +159,7 @@ static struct list_head	open_ownerstr_hashtbl[OPEN_OWNER_HASH_SIZE];
 #define FILE_HASH_BITS                   8
 #define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
 
-/* hash table for (open)nfs4_stateid */
+/* hash table for (open)nfs4_ol_stateid */
 #define STATEID_HASH_BITS              10
 #define STATEID_HASH_SIZE              (1 << STATEID_HASH_BITS)
 #define STATEID_HASH_MASK              (STATEID_HASH_SIZE - 1)
@@ -219,7 +219,7 @@ static void nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 }
 
 static struct nfs4_delegation *
-alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_fh *current_fh, u32 type)
+alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh, u32 type)
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_file *fp = stp->st_file;
@@ -380,7 +380,7 @@ set_deny(unsigned int *deny, unsigned long bmap) {
 }
 
 static int
-test_share(struct nfs4_stateid *stp, struct nfsd4_open *open) {
+test_share(struct nfs4_ol_stateid *stp, struct nfsd4_open *open) {
 	unsigned int access, deny;
 
 	set_access(&access, stp->st_access_bmap);
@@ -403,14 +403,14 @@ static int nfs4_access_to_omode(u32 access)
 	BUG();
 }
 
-static void unhash_generic_stateid(struct nfs4_stateid *stp)
+static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	list_del(&stp->st_hash);
+	list_del(&stp->st_stid.sc_hash);
 	list_del(&stp->st_perfile);
 	list_del(&stp->st_perstateowner);
 }
 
-static void close_generic_stateid(struct nfs4_stateid *stp)
+static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	int i;
 
@@ -426,13 +426,13 @@ static void close_generic_stateid(struct nfs4_stateid *stp)
 	stp->st_file = NULL;
 }
 
-static void free_generic_stateid(struct nfs4_stateid *stp)
+static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	close_generic_stateid(stp);
 	kmem_cache_free(stateid_slab, stp);
 }
 
-static void release_lock_stateid(struct nfs4_stateid *stp)
+static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct file *file;
 
@@ -445,14 +445,14 @@ static void release_lock_stateid(struct nfs4_stateid *stp)
 
 static void unhash_lockowner(struct nfs4_lockowner *lo)
 {
-	struct nfs4_stateid *stp;
+	struct nfs4_ol_stateid *stp;
 
 	list_del(&lo->lo_owner.so_idhash);
 	list_del(&lo->lo_owner.so_strhash);
 	list_del(&lo->lo_perstateid);
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
-				struct nfs4_stateid, st_perstateowner);
+				struct nfs4_ol_stateid, st_perstateowner);
 		release_lock_stateid(stp);
 	}
 }
@@ -464,7 +464,7 @@ static void release_lockowner(struct nfs4_lockowner *lo)
 }
 
 static void
-release_stateid_lockowners(struct nfs4_stateid *open_stp)
+release_stateid_lockowners(struct nfs4_ol_stateid *open_stp)
 {
 	struct nfs4_lockowner *lo;
 
@@ -475,7 +475,7 @@ release_stateid_lockowners(struct nfs4_stateid *open_stp)
 	}
 }
 
-static void release_open_stateid(struct nfs4_stateid *stp)
+static void release_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_generic_stateid(stp);
 	release_stateid_lockowners(stp);
@@ -484,14 +484,14 @@ static void release_open_stateid(struct nfs4_stateid *stp)
 
 static void unhash_openowner(struct nfs4_openowner *oo)
 {
-	struct nfs4_stateid *stp;
+	struct nfs4_ol_stateid *stp;
 
 	list_del(&oo->oo_owner.so_idhash);
 	list_del(&oo->oo_owner.so_strhash);
 	list_del(&oo->oo_perclient);
 	while (!list_empty(&oo->oo_owner.so_stateids)) {
 		stp = list_first_entry(&oo->oo_owner.so_stateids,
-				struct nfs4_stateid, st_perstateowner);
+				struct nfs4_ol_stateid, st_perstateowner);
 		release_open_stateid(stp);
 	}
 }
@@ -1068,26 +1068,26 @@ same_stateid(stateid_t *id_one, stateid_t *id_two)
 	return id_one->si_fileid == id_two->si_fileid;
 }
 
-static struct nfs4_stateid *find_stateid(stateid_t *t)
+static struct nfs4_ol_stateid *find_stateid(stateid_t *t)
 {
-	struct nfs4_stateid *s;
+	struct nfs4_stid *s;
 	unsigned int hashval;
 
 	hashval = stateid_hashval(t->si_stateownerid, t->si_fileid);
-	list_for_each_entry(s, &stateid_hashtbl[hashval], st_hash)
-		if (same_stateid(&s->st_stateid, t))
-			return s;
+	list_for_each_entry(s, &stateid_hashtbl[hashval], sc_hash)
+		if (same_stateid(&s->sc_stateid, t))
+			return openlockstateid(s);
 	return NULL;
 }
 
-static struct nfs4_stateid *find_stateid_by_type(stateid_t *t, char typemask)
+static struct nfs4_ol_stateid *find_stateid_by_type(stateid_t *t, char typemask)
 {
-	struct nfs4_stateid *s;
+	struct nfs4_ol_stateid *s;
 
 	s = find_stateid(t);
 	if (!s)
 		return NULL;
-	if (typemask & s->st_type)
+	if (typemask & s->st_stid.sc_type)
 		return s;
 	return NULL;
 }
@@ -2232,7 +2232,7 @@ nfsd4_init_slabs(void)
 	if (file_slab == NULL)
 		goto out_nomem;
 	stateid_slab = kmem_cache_create("nfsd4_stateids",
-			sizeof(struct nfs4_stateid), 0, 0, NULL);
+			sizeof(struct nfs4_ol_stateid), 0, 0, NULL);
 	if (stateid_slab == NULL)
 		goto out_nomem;
 	deleg_slab = kmem_cache_create("nfsd4_delegations",
@@ -2314,23 +2314,23 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 }
 
 static inline void
-init_open_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
+init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
 	struct nfs4_openowner *oo = open->op_openowner;
 	unsigned int hashval = stateid_hashval(oo->oo_owner.so_id, fp->fi_id);
 
 	INIT_LIST_HEAD(&stp->st_lockowners);
-	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
+	list_add(&stp->st_stid.sc_hash, &stateid_hashtbl[hashval]);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
-	stp->st_type = NFS4_OPEN_STID;
+	stp->st_stid.sc_type = NFS4_OPEN_STID;
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
-	stp->st_stateid.si_boot = boot_time;
-	stp->st_stateid.si_stateownerid = oo->oo_owner.so_id;
-	stp->st_stateid.si_fileid = fp->fi_id;
+	stp->st_stid.sc_stateid.si_boot = boot_time;
+	stp->st_stid.sc_stateid.si_stateownerid = oo->oo_owner.so_id;
+	stp->st_stid.sc_stateid.si_fileid = fp->fi_id;
 	/* note will be incremented before first return to client: */
-	stp->st_stateid.si_generation = 0;
+	stp->st_stid.sc_stateid.si_generation = 0;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
 	__set_bit(open->op_share_access & ~NFS4_SHARE_WANT_MASK,
@@ -2422,7 +2422,7 @@ nfs4_share_conflict(struct svc_fh *current_fh, unsigned int deny_type)
 {
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_file *fp;
-	struct nfs4_stateid *stp;
+	struct nfs4_ol_stateid *stp;
 	__be32 ret;
 
 	dprintk("NFSD: nfs4_share_conflict\n");
@@ -2611,9 +2611,9 @@ out:
 }
 
 static __be32
-nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_stateid **stpp)
+nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_stateid **stpp)
 {
-	struct nfs4_stateid *local;
+	struct nfs4_ol_stateid *local;
 	struct nfs4_openowner *oo = open->op_openowner;
 
 	list_for_each_entry(local, &fp->fi_stateids, st_perfile) {
@@ -2630,7 +2630,7 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_state
 	return nfs_ok;
 }
 
-static inline struct nfs4_stateid *
+static inline struct nfs4_ol_stateid *
 nfs4_alloc_stateid(void)
 {
 	return kmem_cache_alloc(stateid_slab, GFP_KERNEL);
@@ -2672,11 +2672,11 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 }
 
 static __be32
-nfs4_new_open(struct svc_rqst *rqstp, struct nfs4_stateid **stpp,
+nfs4_new_open(struct svc_rqst *rqstp, struct nfs4_ol_stateid **stpp,
 		struct nfs4_file *fp, struct svc_fh *cur_fh,
 		struct nfsd4_open *open)
 {
-	struct nfs4_stateid *stp;
+	struct nfs4_ol_stateid *stp;
 	__be32 status;
 
 	stp = nfs4_alloc_stateid();
@@ -2708,7 +2708,7 @@ nfsd4_truncate(struct svc_rqst *rqstp, struct svc_fh *fh,
 }
 
 static __be32
-nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_stateid *stp, struct nfsd4_open *open)
+nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp, struct nfsd4_open *open)
 {
 	u32 op_share_access = open->op_share_access & ~NFS4_SHARE_WANT_MASK;
 	bool new_access;
@@ -2820,7 +2820,7 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, int flag)
  * Attempt to hand out a delegation.
  */
 static void
-nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_stateid *stp)
+nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_openowner *oo = container_of(stp->st_stateowner, struct nfs4_openowner, oo_owner);
@@ -2888,7 +2888,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_file *fp = NULL;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
-	struct nfs4_stateid *stp = NULL;
+	struct nfs4_ol_stateid *stp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	__be32 status;
 
@@ -2938,8 +2938,8 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 			goto out;
 		}
 	}
-	update_stateid(&stp->st_stateid);
-	memcpy(&open->op_stateid, &stp->st_stateid, sizeof(stateid_t));
+	update_stateid(&stp->st_stid.sc_stateid);
+	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 	if (nfsd4_has_session(&resp->cstate))
 		open->op_openowner->oo_confirmed = 1;
@@ -2953,7 +2953,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	status = nfs_ok;
 
 	dprintk("%s: stateid=" STATEID_FMT "\n", __func__,
-		STATEID_VAL(&stp->st_stateid));
+		STATEID_VAL(&stp->st_stid.sc_stateid));
 out:
 	if (fp)
 		put_nfs4_file(fp);
@@ -3122,7 +3122,7 @@ static struct nfs4_openowner * search_close_lru(u32 st_id)
 }
 
 static inline int
-nfs4_check_fh(struct svc_fh *fhp, struct nfs4_stateid *stp)
+nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
 {
 	return fhp->fh_dentry->d_inode != stp->st_file->fi_inode;
 }
@@ -3153,7 +3153,7 @@ access_permit_write(unsigned long access_bmap)
 }
 
 static
-__be32 nfs4_check_openmode(struct nfs4_stateid *stp, int flags)
+__be32 nfs4_check_openmode(struct nfs4_ol_stateid *stp, int flags)
 {
         __be32 status = nfserr_openmode;
 
@@ -3237,7 +3237,7 @@ static int is_delegation_stateid(stateid_t *stateid)
 
 __be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
 {
-	struct nfs4_stateid *stp = NULL;
+	struct nfs4_ol_stateid *stp = NULL;
 	__be32 status = nfserr_stale_stateid;
 
 	if (STALE_STATEID(stateid))
@@ -3252,7 +3252,7 @@ __be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
 	    && !openowner(stp->st_stateowner)->oo_confirmed)
 		goto out;
 
-	status = check_stateid_generation(stateid, &stp->st_stateid, has_session);
+	status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, has_session);
 	if (status)
 		goto out;
 
@@ -3268,7 +3268,7 @@ __be32
 nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 			   stateid_t *stateid, int flags, struct file **filpp)
 {
-	struct nfs4_stateid *stp = NULL;
+	struct nfs4_ol_stateid *stp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	struct svc_fh *current_fh = &cstate->current_fh;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
@@ -3317,7 +3317,7 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 		if (stp->st_stateowner->so_is_open_owner
 		    && !openowner(stp->st_stateowner)->oo_confirmed)
 			goto out;
-		status = check_stateid_generation(stateid, &stp->st_stateid,
+		status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid,
 						  nfsd4_has_session(cstate));
 		if (status)
 			goto out;
@@ -3347,7 +3347,7 @@ nfsd4_free_delegation_stateid(stateid_t *stateid)
 }
 
 static __be32
-nfsd4_free_lock_stateid(struct nfs4_stateid *stp)
+nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	if (check_for_locks(stp->st_file, lockowner(stp->st_stateowner)))
 		return nfserr_locks_held;
@@ -3374,7 +3374,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		   struct nfsd4_free_stateid *free_stateid)
 {
 	stateid_t *stateid = &free_stateid->fr_stateid;
-	struct nfs4_stateid *stp;
+	struct nfs4_ol_stateid *stp;
 	__be32 ret;
 
 	nfs4_lock_state();
@@ -3388,11 +3388,11 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		ret = nfserr_bad_stateid;
 		goto out;
 	}
-	ret = check_stateid_generation(stateid, &stp->st_stateid, 1);
+	ret = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, 1);
 	if (ret)
 		goto out;
 
-	if (stp->st_type == NFS4_OPEN_STID) {
+	if (stp->st_stid.sc_type == NFS4_OPEN_STID) {
 		ret = nfserr_locks_held;
 		goto out;
 	} else {
@@ -3421,7 +3421,7 @@ static __be32 nfs4_nospecial_stateid_checks(stateid_t *stateid)
 	return nfs_ok;
 }
 
-static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_t *stateid, u32 seqid, struct nfs4_stateid *stp)
+static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_t *stateid, u32 seqid, struct nfs4_ol_stateid *stp)
 {
 	struct svc_fh *current_fh = &cstate->current_fh;
 	struct nfs4_stateowner *sop = stp->st_stateowner;
@@ -3432,7 +3432,7 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
 	status = nfsd4_check_seqid(cstate, sop, seqid);
 	if (status)
 		return status;
-	return check_stateid_generation(stateid, &stp->st_stateid, nfsd4_has_session(cstate));
+	return check_stateid_generation(stateid, &stp->st_stid.sc_stateid, nfsd4_has_session(cstate));
 }
 
 /* 
@@ -3441,7 +3441,7 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
 static __be32
 nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 			 stateid_t *stateid, char typemask,
-			 struct nfs4_stateid **stpp)
+			 struct nfs4_ol_stateid **stpp)
 {
 	__be32 status;
 
@@ -3461,7 +3461,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	return nfs4_seqid_op_checks(cstate, stateid, seqid, *stpp);
 }
 
-static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid, stateid_t *stateid, struct nfs4_stateid **stpp)
+static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid, stateid_t *stateid, struct nfs4_ol_stateid **stpp)
 {
 	__be32 status;
 	struct nfs4_openowner *oo;
@@ -3482,7 +3482,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 status;
 	struct nfs4_openowner *oo;
-	struct nfs4_stateid *stp;
+	struct nfs4_ol_stateid *stp;
 
 	dprintk("NFSD: nfsd4_open_confirm on file %.*s\n",
 			(int)cstate->current_fh.fh_dentry->d_name.len,
@@ -3504,10 +3504,10 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (oo->oo_confirmed)
 		goto out;
 	oo->oo_confirmed = 1;
-	update_stateid(&stp->st_stateid);
-	memcpy(&oc->oc_resp_stateid, &stp->st_stateid, sizeof(stateid_t));
+	update_stateid(&stp->st_stid.sc_stateid);
+	memcpy(&oc->oc_resp_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 	dprintk("NFSD: %s: success, seqid=%d stateid=" STATEID_FMT "\n",
-		__func__, oc->oc_seqid, STATEID_VAL(&stp->st_stateid));
+		__func__, oc->oc_seqid, STATEID_VAL(&stp->st_stid.sc_stateid));
 
 	nfsd4_create_clid_dir(oo->oo_owner.so_client);
 	status = nfs_ok;
@@ -3517,7 +3517,7 @@ out:
 	return status;
 }
 
-static inline void nfs4_file_downgrade(struct nfs4_stateid *stp, unsigned int to_access)
+static inline void nfs4_file_downgrade(struct nfs4_ol_stateid *stp, unsigned int to_access)
 {
 	int i;
 
@@ -3545,7 +3545,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 		     struct nfsd4_open_downgrade *od)
 {
 	__be32 status;
-	struct nfs4_stateid *stp;
+	struct nfs4_ol_stateid *stp;
 
 	dprintk("NFSD: nfsd4_open_downgrade on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
@@ -3575,8 +3575,8 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 
 	reset_union_bmap_deny(od->od_share_deny, &stp->st_deny_bmap);
 
-	update_stateid(&stp->st_stateid);
-	memcpy(&od->od_stateid, &stp->st_stateid, sizeof(stateid_t));
+	update_stateid(&stp->st_stid.sc_stateid);
+	memcpy(&od->od_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 	status = nfs_ok;
 out:
 	if (!cstate->replay_owner)
@@ -3593,7 +3593,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 status;
 	struct nfs4_openowner *oo;
-	struct nfs4_stateid *stp;
+	struct nfs4_ol_stateid *stp;
 
 	dprintk("NFSD: nfsd4_close on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
@@ -3622,8 +3622,8 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out; 
 	oo = openowner(stp->st_stateowner);
 	status = nfs_ok;
-	update_stateid(&stp->st_stateid);
-	memcpy(&close->cl_stateid, &stp->st_stateid, sizeof(stateid_t));
+	update_stateid(&stp->st_stid.sc_stateid);
+	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 	/* release_stateid() calls nfsd_close() if needed */
 	release_open_stateid(stp);
@@ -3828,7 +3828,7 @@ find_lockowner_str(struct inode *inode, clientid_t *clid,
 	return NULL;
 }
 
-static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, struct nfs4_client *clp, struct nfs4_stateid *open_stp)
+static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, struct nfs4_client *clp, struct nfs4_ol_stateid *open_stp)
 {
 	unsigned int idhashval;
 
@@ -3847,7 +3847,7 @@ static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, s
  */
 
 static struct nfs4_lockowner *
-alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfs4_stateid *open_stp, struct nfsd4_lock *lock) {
+alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfs4_ol_stateid *open_stp, struct nfsd4_lock *lock) {
 	struct nfs4_lockowner *lo;
 
 	lo = alloc_stateowner(lockowner_slab, &lock->lk_new_owner, clp);
@@ -3862,27 +3862,27 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	return lo;
 }
 
-static struct nfs4_stateid *
-alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct nfs4_stateid *open_stp)
+static struct nfs4_ol_stateid *
+alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct nfs4_ol_stateid *open_stp)
 {
-	struct nfs4_stateid *stp;
+	struct nfs4_ol_stateid *stp;
 	unsigned int hashval = stateid_hashval(lo->lo_owner.so_id, fp->fi_id);
 
 	stp = nfs4_alloc_stateid();
 	if (stp == NULL)
 		goto out;
-	list_add(&stp->st_hash, &stateid_hashtbl[hashval]);
+	list_add(&stp->st_stid.sc_hash, &stateid_hashtbl[hashval]);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
-	stp->st_type = NFS4_LOCK_STID;
+	stp->st_stid.sc_type = NFS4_LOCK_STID;
 	get_nfs4_file(fp);
 	stp->st_file = fp;
-	stp->st_stateid.si_boot = boot_time;
-	stp->st_stateid.si_stateownerid = lo->lo_owner.so_id;
-	stp->st_stateid.si_fileid = fp->fi_id;
+	stp->st_stid.sc_stateid.si_boot = boot_time;
+	stp->st_stid.sc_stateid.si_stateownerid = lo->lo_owner.so_id;
+	stp->st_stid.sc_stateid.si_fileid = fp->fi_id;
 	/* note will be incremented before first return to client: */
-	stp->st_stateid.si_generation = 0;
+	stp->st_stid.sc_stateid.si_generation = 0;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
@@ -3898,7 +3898,7 @@ check_lock_length(u64 offset, u64 length)
 	     LOFF_OVERFLOW(offset, length)));
 }
 
-static void get_lock_access(struct nfs4_stateid *lock_stp, u32 access)
+static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 {
 	struct nfs4_file *fp = lock_stp->st_file;
 	int oflag = nfs4_access_to_omode(access);
@@ -3918,7 +3918,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct nfs4_openowner *open_sop = NULL;
 	struct nfs4_lockowner *lock_sop = NULL;
-	struct nfs4_stateid *lock_stp;
+	struct nfs4_ol_stateid *lock_stp;
 	struct nfs4_file *fp;
 	struct file *filp = NULL;
 	struct file_lock file_lock;
@@ -3949,7 +3949,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		 * Use open owner and open stateid to create lock owner and
 		 * lock stateid.
 		 */
-		struct nfs4_stateid *open_stp = NULL;
+		struct nfs4_ol_stateid *open_stp = NULL;
 		
 		status = nfserr_stale_clientid;
 		if (!nfsd4_has_session(cstate) &&
@@ -4052,8 +4052,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	err = vfs_lock_file(filp, F_SETLK, &file_lock, &conflock);
 	switch (-err) {
 	case 0: /* success! */
-		update_stateid(&lock_stp->st_stateid);
-		memcpy(&lock->lk_resp_stateid, &lock_stp->st_stateid, 
+		update_stateid(&lock_stp->st_stid.sc_stateid);
+		memcpy(&lock->lk_resp_stateid, &lock_stp->st_stid.sc_stateid, 
 				sizeof(stateid_t));
 		status = 0;
 		break;
@@ -4172,7 +4172,7 @@ __be32
 nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_locku *locku)
 {
-	struct nfs4_stateid *stp;
+	struct nfs4_ol_stateid *stp;
 	struct file *filp = NULL;
 	struct file_lock file_lock;
 	__be32 status;
@@ -4220,8 +4220,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/*
 	* OK, unlock succeeded; the only thing left to do is update the stateid.
 	*/
-	update_stateid(&stp->st_stateid);
-	memcpy(&locku->lu_stateid, &stp->st_stateid, sizeof(stateid_t));
+	update_stateid(&stp->st_stid.sc_stateid);
+	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 out:
 	nfs4_unlock_state();
@@ -4264,7 +4264,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	clientid_t *clid = &rlockowner->rl_clientid;
 	struct nfs4_stateowner *sop;
 	struct nfs4_lockowner *lo;
-	struct nfs4_stateid *stp;
+	struct nfs4_ol_stateid *stp;
 	struct xdr_netobj *owner = &rlockowner->rl_owner;
 	struct list_head matches;
 	int i;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ef949eb..d7fffab 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -328,10 +328,10 @@ struct nfs4_replay {
 *         for lock_owner
 *    so_perclient: nfs4_client->cl_perclient entry - used when nfs4_client
 *         struct is reaped.
-*    so_perfilestate: heads the list of nfs4_stateid (either open or lock) 
-*         and is used to ensure no dangling nfs4_stateid references when we 
+*    so_perfilestate: heads the list of nfs4_ol_stateid (either open or lock) 
+*         and is used to ensure no dangling nfs4_ol_stateid references when we 
 *         release a stateowner.
-*    so_perlockowner: (open) nfs4_stateid->st_perlockowner entry - used when
+*    so_perlockowner: (open) nfs4_ol_stateid->st_perlockowner entry - used when
 *         close is called to reap associated byte-range locks
 *    so_close_lru: (open) stateowner is placed on this list instead of being
 *         reaped (when so_perfilestate is empty) to hold the last close replay.
@@ -430,9 +430,9 @@ static inline struct file *find_any_file(struct nfs4_file *f)
 }
 
 /*
-* nfs4_stateid can either be an open stateid or (eventually) a lock stateid
+* nfs4_ol_stateid can either be an open stateid or (eventually) a lock stateid
 *
-* (open)nfs4_stateid: one per (open)nfs4_stateowner, nfs4_file
+* (open)nfs4_ol_stateid: one per (open)nfs4_stateowner, nfs4_file
 *
 * 	st_hash: stateid_hashtbl[] entry or lockstateid_hashtbl entry
 * 	st_perfile: file_hashtbl[] entry.
@@ -446,22 +446,31 @@ static inline struct file *find_any_file(struct nfs4_file *f)
 * we should consider defining separate structs for the two cases.
 */
 
-struct nfs4_stateid {
+struct nfs4_stid {
 #define NFS4_OPEN_STID 1
 #define NFS4_LOCK_STID 2
-	char st_type;
-	struct list_head              st_hash; 
+	char sc_type;
+	struct list_head sc_hash;
+	stateid_t sc_stateid;
+};
+
+struct nfs4_ol_stateid {
+	struct nfs4_stid    st_stid;
 	struct list_head              st_perfile;
 	struct list_head              st_perstateowner;
 	struct list_head              st_lockowners;
 	struct nfs4_stateowner      * st_stateowner;
 	struct nfs4_file            * st_file;
-	stateid_t                     st_stateid;
 	unsigned long                 st_access_bmap;
 	unsigned long                 st_deny_bmap;
-	struct nfs4_stateid         * st_openstp;
+	struct nfs4_ol_stateid         * st_openstp;
 };
 
+static inline struct nfs4_ol_stateid *openlockstateid(struct nfs4_stid *s)
+{
+	return container_of(s, struct nfs4_ol_stateid, st_stid);
+}
+
 /* flags for preprocess_seqid_op() */
 #define RD_STATE	        0x00000010
 #define WR_STATE	        0x00000020
-- 
1.7.4.1

