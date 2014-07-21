Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:38984 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbaGUPDG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:06 -0400
Received: by mail-qg0-f41.google.com with SMTP id q107so5472109qgd.14
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:04 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 04/40] nfsd: Replace nfs4_ol_stateid->st_file with the st_stid.sc_file
Date: Mon, 21 Jul 2014 11:02:16 -0400
Message-Id: <1405954972-28904-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 48 ++++++++++++++++++++++++------------------------
 fs/nfsd/state.h     |  1 -
 2 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 55cb95154731..076de12c3fa6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -848,7 +848,7 @@ reset_union_bmap_deny(u32 deny, struct nfs4_ol_stateid *stp)
 
 	/* Recalculate per-file deny mode if there was a change */
 	if (change)
-		recalculate_deny_mode(stp->st_file);
+		recalculate_deny_mode(stp->st_stid.sc_file);
 }
 
 /* release all access and file references for a given stateid */
@@ -856,21 +856,21 @@ static void
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
@@ -887,8 +887,6 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
 		return;
-	if (stp->st_file)
-		put_nfs4_file(stp->st_file);
 	remove_stid(&stp->st_stid);
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
@@ -900,7 +898,7 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 	list_del(&stp->st_locks);
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
-	file = find_any_file(stp->st_file);
+	file = find_any_file(stp->st_stid.sc_file);
 	if (file)
 		filp_close(file, (fl_owner_t)lockowner(stp->st_stateowner));
 	close_generic_stateid(stp);
@@ -2976,7 +2974,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
-	stp->st_file = fp;
+	stp->st_stid.sc_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
 	set_access(open->op_share_access, stp);
@@ -3671,7 +3669,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
 		default:
 			goto out_no_deleg;
 	}
-	dp = nfs4_set_delegation(clp, fh, stp->st_file);
+	dp = nfs4_set_delegation(clp, fh, stp->st_stid.sc_file);
 	if (IS_ERR(dp))
 		goto out_no_deleg;
 
@@ -3962,7 +3960,7 @@ laundromat_main(struct work_struct *laundry)
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
 {
-	if (fhp->fh_dentry->d_inode != stp->st_file->fi_inode)
+	if (fhp->fh_dentry->d_inode != stp->st_stid.sc_file->fi_inode)
 		return nfserr_bad_stateid;
 	return nfs_ok;
 }
@@ -4192,10 +4190,12 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
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
@@ -4215,7 +4215,7 @@ nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
 
-	if (check_for_locks(stp->st_file, lo))
+	if (check_for_locks(stp->st_stid.sc_file, lo))
 		return nfserr_locks_held;
 	release_lockowner_if_empty(lo);
 	return nfs_ok;
@@ -4406,7 +4406,7 @@ static inline void nfs4_stateid_downgrade_bit(struct nfs4_ol_stateid *stp, u32 a
 {
 	if (!test_access(access, stp))
 		return;
-	nfs4_file_put_access(stp->st_file, access);
+	nfs4_file_put_access(stp->st_stid.sc_file, access);
 	clear_access(access, stp);
 }
 
@@ -4488,9 +4488,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 			release_openowner(oo);
 		put_generic_stateid(s);
 	} else {
-		if (s->st_file) {
-			put_nfs4_file(s->st_file);
-			s->st_file = NULL;
+		if (s->st_stid.sc_file) {
+			put_nfs4_file(s->st_stid.sc_file);
+			s->st_stid.sc_file = NULL;
 		}
 		oo->oo_last_closed_stid = s;
 		/*
@@ -4693,7 +4693,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
-	stp->st_file = fp;
+	stp->st_stid.sc_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
@@ -4710,7 +4710,7 @@ find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
 	struct nfs4_ol_stateid *lst;
 
 	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
-		if (lst->st_file == fp)
+		if (lst->st_stid.sc_file == fp)
 			return lst;
 	}
 	return NULL;
@@ -4726,7 +4726,7 @@ check_lock_length(u64 offset, u64 length)
 
 static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 {
-	struct nfs4_file *fp = lock_stp->st_file;
+	struct nfs4_file *fp = lock_stp->st_stid.sc_file;
 
 	lockdep_assert_held(&fp->fi_lock);
 
@@ -4738,7 +4738,7 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 
 static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct nfs4_ol_stateid *ost, struct nfsd4_lock *lock, struct nfs4_ol_stateid **lst, bool *new)
 {
-	struct nfs4_file *fi = ost->st_file;
+	struct nfs4_file *fi = ost->st_stid.sc_file;
 	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
 	struct nfs4_client *cl = oo->oo_owner.so_client;
 	struct nfs4_lockowner *lo;
@@ -4862,7 +4862,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	fp = lock_stp->st_file;
+	fp = lock_stp->st_stid.sc_file;
 	locks_init_lock(file_lock);
 	switch (lock->lk_type) {
 		case NFS4_READ_LT:
@@ -5062,7 +5062,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					&stp, nn);
 	if (status)
 		goto out;
-	filp = find_any_file(stp->st_file);
+	filp = find_any_file(stp->st_stid.sc_file);
 	if (!filp) {
 		status = nfserr_lock_range;
 		goto out;
@@ -5176,7 +5176,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	lo = lockowner(sop);
 	/* see if there are still any locks associated with it */
 	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
-		if (check_for_locks(stp->st_file, lo))
+		if (check_for_locks(stp->st_stid.sc_file, lo))
 			goto out;
 	}
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b14bb7407448..1be148ec9440 100644
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

