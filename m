Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:35729 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757959AbaFSOvc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:32 -0400
Received: by mail-qa0-f47.google.com with SMTP id hw13so2055218qab.34
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:31 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 024/104] NFSd: Replace nfs4_ol_stateid->st_file with the st_stid.sc_file
Date: Thu, 19 Jun 2014 10:49:30 -0400
Message-Id: <1403189450-18729-25-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 50 ++++++++++++++++++++++++--------------------------
 fs/nfsd/state.h     |  1 -
 2 files changed, 24 insertions(+), 27 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 068347ab4dd0..7568a05b76f1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -725,11 +725,11 @@ release_all_access(struct nfs4_ol_stateid *stp)
 
 	for (i = 1; i < 4; i++) {
 		if (test_deny(i, stp)) {
-			nfs4_file_put_access(stp->st_file, 0, i);
+			nfs4_file_put_access(stp->st_stid.sc_file, 0, i);
 			clear_deny(i, stp);
 		}
 		if (test_access(i, stp)) {
-			nfs4_file_put_access(stp->st_file, i, 0);
+			nfs4_file_put_access(stp->st_stid.sc_file, i, 0);
 			clear_access(i, stp);
 		}
 	}
@@ -737,7 +737,7 @@ release_all_access(struct nfs4_ol_stateid *stp)
 
 static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	struct nfs4_file *fp = stp->st_file;
+	struct nfs4_file *fp = stp->st_stid.sc_file;
 
 	spin_lock(&fp->fi_lock);
 	list_del(&stp->st_perfile);
@@ -755,8 +755,6 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
 		return;
 	remove_stid(&stp->st_stid);
-	if (stp->st_file)
-		put_nfs4_file(stp->st_file);
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
 
@@ -768,7 +766,7 @@ static void __release_lock_stateid(struct nfs4_lockowner *lo,
 	list_del(&stp->st_locks);
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
-	file = find_any_file(stp->st_file);
+	file = find_any_file(stp->st_stid.sc_file);
 	if (file)
 		filp_close(file, (fl_owner_t)lo);
 	close_generic_stateid(stp);
@@ -2838,7 +2836,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
-	stp->st_file = fp;
+	stp->st_stid.sc_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
 	set_access(open->op_share_access, stp);
@@ -3449,7 +3447,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 	dp = alloc_init_deleg(oo->oo_owner.so_client, stp, fh);
 	if (dp == NULL)
 		goto out_no_deleg;
-	status = nfs4_set_delegation(dp, stp->st_file);
+	status = nfs4_set_delegation(dp, stp->st_stid.sc_file);
 	if (status)
 		goto out_free;
 
@@ -3755,7 +3753,7 @@ laundromat_main(struct work_struct *laundry)
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
 {
-	if (fhp->fh_dentry->d_inode != stp->st_file->fi_inode)
+	if (fhp->fh_dentry->d_inode != stp->st_stid.sc_file->fi_inode)
 		return nfserr_bad_stateid;
 	return nfs_ok;
 }
@@ -3984,9 +3982,9 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 			goto out;
 		if (filpp) {
 			if (flags & RD_STATE)
-				file = find_readable_file(stp->st_file);
+				file = find_readable_file(stp->st_stid.sc_file);
 			else
-				file = find_writeable_file(stp->st_file);
+				file = find_writeable_file(stp->st_stid.sc_file);
 		}
 		break;
 	default:
@@ -4006,7 +4004,7 @@ nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
 
-	if (check_for_locks(stp->st_file, lo))
+	if (check_for_locks(stp->st_stid.sc_file, lo))
 		return nfserr_locks_held;
 	release_lockowner_if_empty(lo);
 	return nfs_ok;
@@ -4193,7 +4191,7 @@ static void nfs4_stateid_downgrade_bit(struct nfs4_ol_stateid *stp, u32 access)
 {
 	if (!test_access(access, stp))
 		return;
-	nfs4_file_put_access(stp->st_file, access, 0);
+	nfs4_file_put_access(stp->st_stid.sc_file, access, 0);
 	clear_access(access, stp);
 }
 
@@ -4201,7 +4199,7 @@ static void nfs4_stateid_downgrade_deny_bit(struct nfs4_ol_stateid *stp, u32 den
 {
 	if (!test_deny(deny, stp))
 		return;
-	nfs4_file_put_access(stp->st_file, 0, deny);
+	nfs4_file_put_access(stp->st_stid.sc_file, 0, deny);
 	clear_deny(deny, stp);
 }
 
@@ -4246,7 +4244,7 @@ reset_union_bmap_deny(unsigned long deny, struct nfs4_ol_stateid *stp)
 		if (i == deny)
 			continue;
 		if (test_deny(i, stp)) {
-			nfs4_file_put_access(stp->st_file, 0, i);
+			nfs4_file_put_access(stp->st_stid.sc_file, 0, i);
 			clear_deny(i, stp);
 		}
 	}
@@ -4311,9 +4309,9 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
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
@@ -4523,7 +4521,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
-	stp->st_file = fp;
+	stp->st_stid.sc_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
@@ -4540,7 +4538,7 @@ find_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp)
 	struct nfs4_ol_stateid *lst;
 
 	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
-		if (lst->st_file == fp)
+		if (lst->st_stid.sc_file == fp)
 			return lst;
 	}
 	return NULL;
@@ -4556,7 +4554,7 @@ check_lock_length(u64 offset, u64 length)
 
 static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 {
-	struct nfs4_file *fp = lock_stp->st_file;
+	struct nfs4_file *fp = lock_stp->st_stid.sc_file;
 
 	if (test_access(access, lock_stp))
 		return;
@@ -4566,7 +4564,7 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 
 static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct nfs4_ol_stateid *ost, struct nfsd4_lock *lock, struct nfs4_ol_stateid **lst, bool *new)
 {
-	struct nfs4_file *fi = ost->st_file;
+	struct nfs4_file *fi = ost->st_stid.sc_file;
 	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
 	struct nfs4_client *cl = oo->oo_owner.so_client;
 	struct nfs4_lockowner *lo;
@@ -4693,14 +4691,14 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	switch (lock->lk_type) {
 		case NFS4_READ_LT:
 		case NFS4_READW_LT:
-			filp = find_readable_file(lock_stp->st_file);
+			filp = find_readable_file(lock_stp->st_stid.sc_file);
 			if (filp)
 				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_READ);
 			file_lock->fl_type = F_RDLCK;
 			break;
 		case NFS4_WRITE_LT:
 		case NFS4_WRITEW_LT:
-			filp = find_writeable_file(lock_stp->st_file);
+			filp = find_writeable_file(lock_stp->st_stid.sc_file);
 			if (filp)
 				get_lock_access(lock_stp, NFS4_SHARE_ACCESS_WRITE);
 			file_lock->fl_type = F_WRLCK;
@@ -4883,7 +4881,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					&stp, nn);
 	if (status)
 		goto out;
-	filp = find_any_file(stp->st_file);
+	filp = find_any_file(stp->st_stid.sc_file);
 	if (!filp) {
 		status = nfserr_lock_range;
 		goto out;
@@ -4987,7 +4985,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 		list_for_each_entry(stp, &sop->so_stateids,
 				st_perstateowner) {
 			lo = lockowner(sop);
-			if (check_for_locks(stp->st_file, lo))
+			if (check_for_locks(stp->st_stid.sc_file, lo))
 				goto out;
 			list_add(&lo->lo_list, &matches);
 		}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index eaddef9048e4..600c24e475d1 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -408,7 +408,6 @@ struct nfs4_ol_stateid {
 	struct list_head              st_perstateowner;
 	struct list_head              st_locks;
 	struct nfs4_stateowner      * st_stateowner;
-	struct nfs4_file            * st_file;
 	unsigned long                 st_access_bmap;
 	unsigned long                 st_deny_bmap;
 	struct nfs4_ol_stateid         * st_openstp;
-- 
1.9.3

