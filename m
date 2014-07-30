Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:56495 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbaG3Bez (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:34:55 -0400
Received: by mail-qg0-f53.google.com with SMTP id q107so655219qgd.26
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:34:55 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 04/38] nfsd: Replace nfs4_ol_stateid->st_file with the st_stid.sc_file
Date: Tue, 29 Jul 2014 21:34:09 -0400
Message-Id: <1406684083-19736-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 48 ++++++++++++++++++++++++------------------------
 fs/nfsd/state.h     |  1 -
 2 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d6b0ef4e90fe..344cd1ac3f67 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -863,7 +863,7 @@ reset_union_bmap_deny(u32 deny, struct nfs4_ol_stateid *stp)
 
 	/* Recalculate per-file deny mode if there was a change */
 	if (change)
-		recalculate_deny_mode(stp->st_file);
+		recalculate_deny_mode(stp->st_stid.sc_file);
 }
 
 /* release all access and file references for a given stateid */
@@ -871,21 +871,21 @@ static void
 release_all_access(struct nfs4_ol_stateid *stp)
 {
 	int i;
-	struct nfs4_file *fp = stp->st_file;
+	struct nfs4_file *fp = stp->st_stid.sc_file;
 
 	if (fp && stp->st_deny_bmap != 0)
 		recalculate_deny_mode(fp);
 
 	for (i = 1; i < 4; i++) {
 		if (test_access(i, stp))
-			nfs4_file_put_access(stp->st_file, i);
+			nfs4_file_put_access(stp->st_stid.sc_file, i);
 		clear_access(i, stp);
 	}
 }
 
 static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	struct nfs4_file *fp = stp->st_file;
+	struct nfs4_file *fp = stp->st_stid.sc_file;
 
 	spin_lock(&fp->fi_lock);
 	list_del(&stp->st_perfile);
@@ -898,8 +898,6 @@ static void nfs4_free_ol_stateid(struct nfs4_stid *stid)
 	struct nfs4_ol_stateid *stp = openlockstateid(stid);
 
 	release_all_access(stp);
-	if (stp->st_file)
-		put_nfs4_file(stp->st_file);
 	kmem_cache_free(stateid_slab, stid);
 }
 
@@ -910,7 +908,7 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 	list_del(&stp->st_locks);
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
-	file = find_any_file(stp->st_file);
+	file = find_any_file(stp->st_stid.sc_file);
 	if (file)
 		filp_close(file, (fl_owner_t)lockowner(stp->st_stateowner));
 	nfs4_put_stid(&stp->st_stid);
@@ -2975,7 +2973,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
-	stp->st_file = fp;
+	stp->st_stid.sc_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
 	stp->st_openstp = NULL;
@@ -3668,7 +3666,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
 		default:
 			goto out_no_deleg;
 	}
-	dp = nfs4_set_delegation(clp, fh, stp->st_file);
+	dp = nfs4_set_delegation(clp, fh, stp->st_stid.sc_file);
 	if (IS_ERR(dp))
 		goto out_no_deleg;
 
@@ -3958,7 +3956,7 @@ laundromat_main(struct work_struct *laundry)
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
 {
-	if (!nfsd_fh_match(&fhp->fh_handle, &stp->st_file->fi_fhandle))
+	if (!nfsd_fh_match(&fhp->fh_handle, &stp->st_stid.sc_file->fi_fhandle))
 		return nfserr_bad_stateid;
 	return nfs_ok;
 }
@@ -4188,10 +4186,12 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 		if (status)
 			goto out;
 		if (filpp) {
+			struct nfs4_file *fp = stp->st_stid.sc_file;
+
 			if (flags & RD_STATE)
-				file = find_readable_file(stp->st_file);
+				file = find_readable_file(fp);
 			else
-				file = find_writeable_file(stp->st_file);
+				file = find_writeable_file(fp);
 		}
 		break;
 	default:
@@ -4211,7 +4211,7 @@ nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
 
-	if (check_for_locks(stp->st_file, lo))
+	if (check_for_locks(stp->st_stid.sc_file, lo))
 		return nfserr_locks_held;
 	release_lockowner_if_empty(lo);
 	return nfs_ok;
@@ -4402,7 +4402,7 @@ static inline void nfs4_stateid_downgrade_bit(struct nfs4_ol_stateid *stp, u32 a
 {
 	if (!test_access(access, stp))
 		return;
-	nfs4_file_put_access(stp->st_file, access);
+	nfs4_file_put_access(stp->st_stid.sc_file, access);
 	clear_access(access, stp);
 }
 
@@ -4491,9 +4491,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 		 * before returning however.
 		 */
 		release_all_access(s);
-		if (s->st_file) {
-			put_nfs4_file(s->st_file);
-			s->st_file = NULL;
+		if (s->st_stid.sc_file) {
+			put_nfs4_file(s->st_stid.sc_file);
+			s->st_stid.sc_file = NULL;
 		}
 		oo->oo_last_closed_stid = s;
 		if (list_empty(&oo->oo_owner.so_stateids))
@@ -4694,7 +4694,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp,
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
-	stp->st_file = fp;
+	stp->st_stid.sc_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
@@ -4711,7 +4711,7 @@ find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
 	struct nfs4_ol_stateid *lst;
 
 	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
-		if (lst->st_file == fp)
+		if (lst->st_stid.sc_file == fp)
 			return lst;
 	}
 	return NULL;
@@ -4727,7 +4727,7 @@ check_lock_length(u64 offset, u64 length)
 
 static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 {
-	struct nfs4_file *fp = lock_stp->st_file;
+	struct nfs4_file *fp = lock_stp->st_stid.sc_file;
 
 	lockdep_assert_held(&fp->fi_lock);
 
@@ -4739,7 +4739,7 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 
 static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct nfs4_ol_stateid *ost, struct nfsd4_lock *lock, struct nfs4_ol_stateid **lst, bool *new)
 {
-	struct nfs4_file *fi = ost->st_file;
+	struct nfs4_file *fi = ost->st_stid.sc_file;
 	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
 	struct nfs4_client *cl = oo->oo_owner.so_client;
 	struct inode *inode = cstate->current_fh.fh_dentry->d_inode;
@@ -4864,7 +4864,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	fp = lock_stp->st_file;
+	fp = lock_stp->st_stid.sc_file;
 	locks_init_lock(file_lock);
 	switch (lock->lk_type) {
 		case NFS4_READ_LT:
@@ -5064,7 +5064,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					&stp, nn);
 	if (status)
 		goto out;
-	filp = find_any_file(stp->st_file);
+	filp = find_any_file(stp->st_stid.sc_file);
 	if (!filp) {
 		status = nfserr_lock_range;
 		goto out;
@@ -5187,7 +5187,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	lo = lockowner(sop);
 	/* see if there are still any locks associated with it */
 	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
-		if (check_for_locks(stp->st_file, lo))
+		if (check_for_locks(stp->st_stid.sc_file, lo))
 			goto out;
 	}
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c856601c15f6..af1d9c42e939 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -407,7 +407,6 @@ struct nfs4_ol_stateid {
 	struct list_head              st_perstateowner;
 	struct list_head              st_locks;
 	struct nfs4_stateowner      * st_stateowner;
-	struct nfs4_file            * st_file;
 	unsigned char                 st_access_bmap;
 	unsigned char                 st_deny_bmap;
 	struct nfs4_ol_stateid         * st_openstp;
-- 
1.9.3

