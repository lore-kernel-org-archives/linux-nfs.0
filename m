Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f178.google.com ([209.85.213.178]:64771 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbaDRSpz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:55 -0400
Received: by mail-ig0-f178.google.com with SMTP id hn18so944022igb.5
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:55 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 31/70] NFSd: Replace nfs4_ol_stateid->st_file with the st_stid.sc_file
Date: Fri, 18 Apr 2014 14:44:25 -0400
Message-Id: <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 38 ++++++++++++++++++--------------------
 fs/nfsd/state.h     |  1 -
 2 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 48979ee79888..2cb4124276d0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -688,7 +688,7 @@ release_all_access(struct nfs4_ol_stateid *stp)
 
 	for (i = 1; i < 4; i++) {
 		if (test_access(i, stp))
-			nfs4_file_put_access(stp->st_file,
+			nfs4_file_put_access(stp->st_stid.sc_file,
 					     nfs4_access_to_omode(i));
 		clear_access(i, stp);
 	}
@@ -696,7 +696,7 @@ release_all_access(struct nfs4_ol_stateid *stp)
 
 static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	struct nfs4_file *fp = stp->st_file;
+	struct nfs4_file *fp = stp->st_stid.sc_file;
 
 	spin_lock(&fp->fi_lock);
 	list_del(&stp->st_perfile);
@@ -714,8 +714,6 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
 		return;
 	remove_stid(&stp->st_stid);
-	if (stp->st_file)
-		put_nfs4_file(stp->st_file);
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
 
@@ -727,7 +725,7 @@ static void __release_lock_stateid(struct nfs4_lockowner *lo,
 	list_del(&stp->st_locks);
 	unhash_generic_stateid(stp);
 	unhash_stid(&stp->st_stid);
-	file = find_any_file(stp->st_file);
+	file = find_any_file(stp->st_stid.sc_file);
 	if (file)
 		filp_close(file, (fl_owner_t)lo);
 	close_generic_stateid(stp);
@@ -2774,7 +2772,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	list_add(&stp->st_perstateowner, &oo->oo_owner.so_stateids);
 	stp->st_stateowner = &oo->oo_owner;
 	get_nfs4_file(fp);
-	stp->st_file = fp;
+	stp->st_stid.sc_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
 	set_access(open->op_share_access, stp);
@@ -3350,7 +3348,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
 	dp = alloc_init_deleg(oo->oo_owner.so_client, stp, fh);
 	if (dp == NULL)
 		goto out_no_deleg;
-	status = nfs4_set_delegation(dp, stp->st_file);
+	status = nfs4_set_delegation(dp, stp->st_stid.sc_file);
 	if (status)
 		goto out_free;
 
@@ -3668,7 +3666,7 @@ laundromat_main(struct work_struct *laundry)
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
 {
-	if (fhp->fh_dentry->d_inode != stp->st_file->fi_inode)
+	if (fhp->fh_dentry->d_inode != stp->st_stid.sc_file->fi_inode)
 		return nfserr_bad_stateid;
 	return nfs_ok;
 }
@@ -3897,9 +3895,9 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
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
@@ -3917,7 +3915,7 @@ out:
 static __be32
 nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 {
-	if (check_for_locks(stp->st_file, lockowner(stp->st_stateowner)))
+	if (check_for_locks(stp->st_stid.sc_file, lockowner(stp->st_stateowner)))
 		return nfserr_locks_held;
 	release_lock_stateid(stp);
 	return nfs_ok;
@@ -4100,7 +4098,7 @@ static inline void nfs4_stateid_downgrade_bit(struct nfs4_ol_stateid *stp, u32 a
 {
 	if (!test_access(access, stp))
 		return;
-	nfs4_file_put_access(stp->st_file, nfs4_access_to_omode(access));
+	nfs4_file_put_access(stp->st_stid.sc_file, nfs4_access_to_omode(access));
 	clear_access(access, stp);
 }
 
@@ -4401,7 +4399,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	list_add(&stp->st_perstateowner, &lo->lo_owner.so_stateids);
 	stp->st_stateowner = &lo->lo_owner;
 	get_nfs4_file(fp);
-	stp->st_file = fp;
+	stp->st_stid.sc_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
@@ -4418,7 +4416,7 @@ find_lock_stateid(struct nfs4_lockowner *lo, struct inode *inode)
 	struct nfs4_ol_stateid *lst;
 
 	list_for_each_entry(lst, &lo->lo_owner.so_stateids, st_perstateowner) {
-		if (lst->st_file->fi_inode == inode)
+		if (lst->st_stid.sc_file->fi_inode == inode)
 			return lst;
 	}
 	return NULL;
@@ -4434,7 +4432,7 @@ check_lock_length(u64 offset, u64 length)
 
 static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 {
-	struct nfs4_file *fp = lock_stp->st_file;
+	struct nfs4_file *fp = lock_stp->st_stid.sc_file;
 	int oflag = nfs4_access_to_omode(access);
 
 	if (test_access(access, lock_stp))
@@ -4445,7 +4443,7 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
 
 static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, struct nfs4_ol_stateid *ost, struct nfsd4_lock *lock, struct nfs4_ol_stateid **lst, bool *new)
 {
-	struct nfs4_file *fi = ost->st_file;
+	struct nfs4_file *fi = ost->st_stid.sc_file;
 	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
 	struct nfs4_client *cl = oo->oo_owner.so_client;
 	struct nfs4_lockowner *lo;
@@ -4568,14 +4566,14 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -4758,7 +4756,7 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					&stp, nn);
 	if (status)
 		goto out;
-	filp = find_any_file(stp->st_file);
+	filp = find_any_file(stp->st_stid.sc_file);
 	if (!filp) {
 		status = nfserr_lock_range;
 		goto out;
@@ -4862,7 +4860,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 		list_for_each_entry(stp, &sop->so_stateids,
 				st_perstateowner) {
 			lo = lockowner(sop);
-			if (check_for_locks(stp->st_file, lo))
+			if (check_for_locks(stp->st_stid.sc_file, lo))
 				goto out;
 			list_add(&lo->lo_list, &matches);
 		}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index de198600616b..0539db97f7d3 100644
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
1.9.0

