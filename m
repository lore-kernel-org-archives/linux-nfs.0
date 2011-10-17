Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44763 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755656Ab1JQV4Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Oct 2011 17:56:24 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/8] nfsd4: do idr preallocation with stateid allocation
Date: Mon, 17 Oct 2011 17:55:55 -0400
Message-Id: <1318888557-14719-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1318888557-14719-1-git-send-email-bfields@redhat.com>
References: <1318888557-14719-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Move idr preallocation out of stateid initialization, into stateid
allocation, so that we no longer have to handle any errors from the
former.

This is a little subtle due to the way the idr code manages these
preallocated items--document that in comments.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   76 +++++++++++++++++++++++++--------------------------
 fs/nfsd/state.h     |    4 +-
 2 files changed, 39 insertions(+), 41 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ae5d250..1f8c781 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -215,13 +215,12 @@ static inline int get_new_stid(struct nfs4_stid *stid)
 	int new_stid;
 	int error;
 
-	if (!idr_pre_get(stateids, GFP_KERNEL))
-		return -ENOMEM;
-
 	error = idr_get_new_above(stateids, stid, min_stateid, &new_stid);
 	/*
-	 * All this code is currently serialized; the preallocation
-	 * above should still be ours:
+	 * Note: the necessary preallocation was done in
+	 * nfs4_alloc_stateid().  The idr code caps the number of
+	 * preallocations that can exist at a time, but the state lock
+	 * prevents anyone from using ours before we get here:
 	 */
 	BUG_ON(error);
 	/*
@@ -240,7 +239,7 @@ static inline int get_new_stid(struct nfs4_stid *stid)
 	return new_stid;
 }
 
-static inline __be32 init_stid(struct nfs4_stid *stid, struct nfs4_client *cl, unsigned char type)
+static void init_stid(struct nfs4_stid *stid, struct nfs4_client *cl, unsigned char type)
 {
 	stateid_t *s = &stid->sc_stateid;
 	int new_id;
@@ -249,12 +248,24 @@ static inline __be32 init_stid(struct nfs4_stid *stid, struct nfs4_client *cl, u
 	stid->sc_client = cl;
 	s->si_opaque.so_clid = cl->cl_clientid;
 	new_id = get_new_stid(stid);
-	if (new_id < 0)
-		return nfserr_jukebox;
 	s->si_opaque.so_id = (u32)new_id;
 	/* Will be incremented before return to client: */
 	s->si_generation = 0;
-	return 0;
+}
+
+static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab)
+{
+	struct idr *stateids = &cl->cl_stateids;
+
+	if (!idr_pre_get(stateids, GFP_KERNEL))
+		return NULL;
+	/*
+	 * Note: if we fail here (or any time between now and the time
+	 * we actually get the new idr), we won't need to undo the idr
+	 * preallocation, since the idr code caps the number of
+	 * preallocated entries.
+	 */
+	return kmem_cache_alloc(slab, GFP_KERNEL);
 }
 
 static struct nfs4_delegation *
@@ -262,7 +273,6 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_file *fp = stp->st_file;
-	__be32 status;
 
 	dprintk("NFSD alloc_init_deleg\n");
 	/*
@@ -276,14 +286,10 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 		return NULL;
 	if (num_delegations > max_delegations)
 		return NULL;
-	dp = kmem_cache_alloc(deleg_slab, GFP_KERNEL);
+	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
 	if (dp == NULL)
 		return dp;
-	status = init_stid(&dp->dl_stid, clp, NFS4_DELEG_STID);
-	if (status) {
-		kmem_cache_free(deleg_slab, dp);
-		return NULL;
-	}
+	init_stid(&dp->dl_stid, clp, NFS4_DELEG_STID);
 	/*
 	 * delegation seqid's are never incremented.  The 4.1 special
 	 * meaning of seqid 0 isn't meaningful, really, but let's avoid
@@ -2331,14 +2337,11 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	return oo;
 }
 
-static inline __be32 init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
+static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *open) {
 	struct nfs4_openowner *oo = open->op_openowner;
 	struct nfs4_client *clp = oo->oo_owner.so_client;
-	__be32 status;
 
-	status = init_stid(&stp->st_stid, clp, NFS4_OPEN_STID);
-	if (status)
-		return status;
+	init_stid(&stp->st_stid, clp, NFS4_OPEN_STID);
 	INIT_LIST_HEAD(&stp->st_lockowners);
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
@@ -2350,7 +2353,6 @@ static inline __be32 init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_
 	__set_bit(open->op_share_access, &stp->st_access_bmap);
 	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
 	stp->st_openstp = NULL;
-	return nfs_ok;
 }
 
 static void
@@ -2614,10 +2616,14 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
 	return nfs_ok;
 }
 
-static inline struct nfs4_ol_stateid *
-nfs4_alloc_stateid(void)
+static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
 {
-	return kmem_cache_alloc(stateid_slab, GFP_KERNEL);
+	return openlockstateid(nfs4_alloc_stid(clp, stateid_slab));
+}
+
+static void nfs4_free_stateid(struct nfs4_ol_stateid *s)
+{
+	kmem_cache_free(stateid_slab, s);
 }
 
 static inline int nfs4_access_to_access(u32 nfs4_access)
@@ -2661,15 +2667,16 @@ nfs4_new_open(struct svc_rqst *rqstp, struct nfs4_ol_stateid **stpp,
 		struct nfsd4_open *open)
 {
 	struct nfs4_ol_stateid *stp;
+	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
 	__be32 status;
 
-	stp = nfs4_alloc_stateid();
+	stp = nfs4_alloc_stateid(cl);
 	if (stp == NULL)
 		return nfserr_jukebox;
 
 	status = nfs4_get_vfs_file(rqstp, fp, cur_fh, open);
 	if (status) {
-		kmem_cache_free(stateid_slab, stp);
+		nfs4_free_stateid(stp);
 		return status;
 	}
 	*stpp = stp;
@@ -2912,11 +2919,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		status = nfs4_new_open(rqstp, &stp, fp, current_fh, open);
 		if (status)
 			goto out;
-		status = init_open_stateid(stp, fp, open);
-		if (status) {
-			release_open_stateid(stp);
-			goto out;
-		}
+		init_open_stateid(stp, fp, open);
 		status = nfsd4_truncate(rqstp, current_fh, open);
 		if (status) {
 			release_open_stateid(stp);
@@ -3812,16 +3815,11 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 {
 	struct nfs4_ol_stateid *stp;
 	struct nfs4_client *clp = lo->lo_owner.so_client;
-	__be32 status;
 
-	stp = nfs4_alloc_stateid();
+	stp = nfs4_alloc_stateid(clp);
 	if (stp == NULL)
 		return NULL;
-	status = init_stid(&stp->st_stid, clp, NFS4_LOCK_STID);
-	if (status) {
-		free_generic_stateid(stp);
-		return NULL;
-	}
+	init_stid(&stp->st_stid, clp, NFS4_LOCK_STID);
 	list_add(&stp->st_perfile, &fp->fi_stateids);
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index eab9dae..1a58200 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -85,6 +85,7 @@ struct nfs4_stid {
 };
 
 struct nfs4_delegation {
+	struct nfs4_stid	dl_stid; /* must be first field */
 	struct list_head	dl_perfile;
 	struct list_head	dl_perclnt;
 	struct list_head	dl_recall_lru;  /* delegation recalled */
@@ -93,7 +94,6 @@ struct nfs4_delegation {
 	u32			dl_type;
 	time_t			dl_time;
 /* For recall: */
-	struct nfs4_stid	dl_stid;
 	struct knfsd_fh		dl_fh;
 	int			dl_retries;
 	struct nfsd4_callback	dl_recall;
@@ -434,7 +434,7 @@ static inline struct file *find_any_file(struct nfs4_file *f)
 
 /* "ol" stands for "Open or Lock".  Better suggestions welcome. */
 struct nfs4_ol_stateid {
-	struct nfs4_stid    st_stid;
+	struct nfs4_stid    st_stid; /* must be first field */
 	struct list_head              st_perfile;
 	struct list_head              st_perstateowner;
 	struct list_head              st_lockowners;
-- 
1.7.5.4

