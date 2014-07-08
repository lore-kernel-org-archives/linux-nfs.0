Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:57686 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755268AbaGHSFM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:05:12 -0400
Received: by mail-qg0-f41.google.com with SMTP id i50so5614889qgf.28
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:05:11 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 026/100] nfsd: Replace nfs4_ol_stateid->st_file with the st_stid.sc_file
Date: Tue,  8 Jul 2014 14:03:14 -0400
Message-Id: <1404842668-22521-27-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 48 ++++++++++++++++++++++++------------------------
 fs/nfsd/state.h     |  1 -
 2 files changed, 24 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7ed76666d520..352cd151eff3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -851,7 +851,7 @@ reset_union_bmap_deny(u32 deny, struct nfs4_ol_stateid *stp)
 
 	/* Recalculate per-file deny mode if there was a change */
 	if (change)
-		recalculate_deny_mode(stp->st_file);
+		recalculate_deny_mode(stp->st_stid.sc_file);
 }
 
 /* release all access and file references for a given stateid */
@@ -859,21 +859,21 @@ static void
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
@@ -890,8 +890,6 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
 		return;
-	if (stp->st_file)
-		put_nfs4_file(stp->st_file);
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
 
@@ -902,7 +900,7 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 	list_del(&stp->st_locks);
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
-	file = find_any_file(stp->st_file);
+	file = find_any_file(stp->st_stid.sc_file);
 	if (file)
 		filp_close(file, (fl_owner_t)lockowner(stp->st_stateowner));
 	close_generic_stateid(stp);
@@ -2978,7 +2976,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
-	stp->st_file = fp;
+	stp->st_stid.sc_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
 	set_access(open->op_share_access, stp);
@@ -3644,7 +3642,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 	dp = alloc_init_deleg(oo->oo_owner.so_client, stp, fh);
 	if (dp == NULL)
 		goto out_no_deleg;
-	status = nfs4_set_delegation(dp, stp->st_file);
+	status = nfs4_set_delegation(dp, stp->st_stid.sc_file);
 	if (status)
 		goto out_free;
 
@@ -3935,7 +3933,7 @@ laundromat_main(struct work_struct *laundry)
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
 {
-	if (fhp->fh_dentry->d_inode != stp->st_file->fi_inode)
+	if (fhp->fh_dentry->d_inode != stp->st_stid.sc_file->fi_inode)
 		return nfserr_bad_stateid;
 	return nfs_ok;
 }
@@ -4165,10 +4163,12 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
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
@@ -4188,7 +4188,7 @@ nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
 
-	if (check_for_locks(stp->st_file, lo))
+	if (check_for_locks(stp->st_stid.sc_file, lo))
 		return nfserr_locks_held;
 	release_lockowner_if_empty(lo);
 	return nfs_ok;
@@ -4374,7 +4374,7 @@ static inline void nfs4_stateid_downgrade_bit(struct nfs4_ol_stateid *stp, u32 a
 {
 	if (!test_access(access, stp))
 		return;
-	nfs4_file_put_access(stp->st_file, access);
+	nfs4_file_put_access(stp->st_stid.sc_file, access);
 	clear_access(access, stp);
 }
 
@@ -4455,9 +4455,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
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
@@ -4659,7 +4659,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
-	stp->st_file = fp;
+	stp->st_stid.sc_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
@@ -4676,7 +4676,7 @@ find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
 	struct nfs4_ol_stateid *lst;
 
 	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
-		if (lst->st_file == fp)
+		if (lst->st_stid.sc_file == fp)
 			return lst;
 	}
 	return NULL;
@@ -4692,7 +4692,7 @@ check_lock_length(u64 offset, u64 length)
 
 static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 {
-	struct nfs4_file *fp = lock_stp->st_file;
+	struct nfs4_file *fp = lock_stp->st_stid.sc_file;
 
 	lockdep_assert_held(&fp->fi_lock);
 
@@ -4704,7 +4704,7 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 
 static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct nfs4_ol_stateid *ost, struct nfsd4_lock *lock, struct nfs4_ol_stateid **lst, bool *new)
 {
-	struct nfs4_file *fi = ost->st_file;
+	struct nfs4_file *fi = ost->st_stid.sc_file;
 	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
 	struct nfs4_client *cl = oo->oo_owner.so_client;
 	struct nfs4_lockowner *lo;
@@ -4828,7 +4828,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	fp = lock_stp->st_file;
+	fp = lock_stp->st_stid.sc_file;
 	locks_init_lock(file_lock);
 	switch (lock->lk_type) {
 		case NFS4_READ_LT:
@@ -5027,7 +5027,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					&stp, nn);
 	if (status)
 		goto out;
-	filp = find_any_file(stp->st_file);
+	filp = find_any_file(stp->st_stid.sc_file);
 	if (!filp) {
 		status = nfserr_lock_range;
 		goto out;
@@ -5140,7 +5140,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	lo = lockowner(sop);
 	/* see if there are still any locks associated with it */
 	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
-		if (check_for_locks(stp->st_file, lo))
+		if (check_for_locks(stp->st_stid.sc_file, lo))
 			goto out;
 	}
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index fa266d2612b7..95d04fae365a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -408,7 +408,6 @@ struct nfs4_ol_stateid {
 	struct list_head              st_perstateowner;
 	struct list_head              st_locks;
 	struct nfs4_stateowner      * st_stateowner;
-	struct nfs4_file            * st_file;
 	unsigned char                 st_access_bmap;
 	unsigned char                 st_deny_bmap;
 	struct nfs4_ol_stateid         * st_openstp;
-- 
1.9.3

