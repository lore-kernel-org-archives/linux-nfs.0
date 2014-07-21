Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:61495 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaGUWy2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 18:54:28 -0400
Received: by mail-ig0-f177.google.com with SMTP id hn18so3380283igb.10
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 15:54:28 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] knfsd: Do not let nfs4_file pin the struct inode
Date: Mon, 21 Jul 2014 18:54:31 -0400
Message-Id: <1405983271-61861-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1405983271-61861-3-git-send-email-trond.myklebust@primarydata.com>
References: <1405983271-61861-1-git-send-email-trond.myklebust@primarydata.com>
 <1405983271-61861-2-git-send-email-trond.myklebust@primarydata.com>
 <1405983271-61861-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the fi_inode field in struct nfs4_file in order to remove the
possibility of struct nfs4_file pinning the inode when it does not have
any open state.
Add a field to struct nfs4_ol_stateid, so that the lock stateid
may continue to check for existing lock state before being released.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 31 ++++++++++++++++---------------
 fs/nfsd/state.h     |  2 +-
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2b2cd6814615..2bc89bfc905a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -69,7 +69,7 @@ static u64 current_sessionid = 1;
 #define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
 
 /* forward declarations */
-static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
+static int check_for_locks(struct inode *inode, struct nfs4_lockowner *lowner);
 static void nfs4_free_generic_stateid(struct nfs4_stid *stid);
 static struct nfs4_openowner *find_openstateowner_str_locked(
 		unsigned int hashval, struct nfsd4_open *open,
@@ -251,7 +251,6 @@ put_nfs4_file(struct nfs4_file *fi)
 	if (atomic_dec_and_lock(&fi->fi_ref, &state_lock)) {
 		hlist_del(&fi->fi_hash);
 		spin_unlock(&state_lock);
-		iput(fi->fi_inode);
 		nfsd4_free_file(fi);
 	}
 }
@@ -796,6 +795,8 @@ static void nfs4_free_generic_stateid(struct nfs4_stid *stid)
 	release_all_access(stp);
 	if (stp->st_stateowner)
 		nfs4_put_stateowner(stp->st_stateowner);
+	if (stp->st_inode)
+		iput(stp->st_inode);
 	nfs4_free_stid(stateid_slab, stid);
 }
 
@@ -2820,8 +2821,7 @@ static struct nfs4_file *nfsd4_alloc_file(void)
 }
 
 /* OPEN Share state helper functions */
-static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
-		struct knfsd_fh *fh)
+static void nfsd4_init_file(struct nfs4_file *fp, struct knfsd_fh *fh)
 {
 	unsigned int hashval = file_hashval(fh);
 
@@ -2829,7 +2829,6 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
 	spin_lock_init(&fp->fi_lock);
 	INIT_LIST_HEAD(&fp->fi_stateids);
 	INIT_LIST_HEAD(&fp->fi_delegations);
-	fp->fi_inode = igrab(ino);
 	fh_copy_shallow(&fp->fi_fhandle, fh);
 	fp->fi_had_conflict = false;
 	fp->fi_lease = NULL;
@@ -3090,14 +3089,14 @@ find_file(struct knfsd_fh *fh)
 }
 
 static struct nfs4_file *
-find_or_add_file(struct inode *ino, struct nfs4_file *new, struct knfsd_fh *fh)
+find_or_add_file(struct nfs4_file *new, struct knfsd_fh *fh)
 {
 	struct nfs4_file *fp;
 
 	spin_lock(&state_lock);
 	fp = find_file_locked(fh);
 	if (fp == NULL) {
-		nfsd4_init_file(new, ino, fh);
+		nfsd4_init_file(new, fh);
 		fp = new;
 	}
 	spin_unlock(&state_lock);
@@ -3675,7 +3674,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
 	struct nfs4_file *fp = NULL;
-	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_ol_stateid *stp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	__be32 status;
@@ -3685,7 +3683,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	 * and check for delegations in the process of being recalled.
 	 * If not found, create the nfs4_file struct
 	 */
-	fp = find_or_add_file(ino, open->op_file, &current_fh->fh_handle);
+	fp = find_or_add_file(open->op_file, &current_fh->fh_handle);
 	if (fp != open->op_file) {
 		if ((status = nfs4_check_open(fp, open, &stp)))
 			goto out;
@@ -4217,7 +4215,7 @@ unlock_state:
 static __be32
 nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 {
-	if (check_for_locks(stp->st_stid.sc_file, lockowner(stp->st_stateowner)))
+	if (check_for_locks(stp->st_inode, lockowner(stp->st_stateowner)))
 		return nfserr_locks_held;
 	release_lock_stateid(stp);
 	return nfs_ok;
@@ -4761,7 +4759,9 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 }
 
 static struct nfs4_ol_stateid *
-alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct nfs4_ol_stateid *open_stp)
+alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp,
+		struct inode *inode,
+		struct nfs4_ol_stateid *open_stp)
 {
 	struct nfs4_openowner *oo = openowner(open_stp->st_stateowner);
 	struct nfs4_ol_stateid *stp;
@@ -4775,6 +4775,7 @@ alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct
 	stp->st_stateowner = &lo->lo_owner;
 	atomic_inc(&lo->lo_owner.so_count);
 	get_nfs4_file(fp);
+	stp->st_inode = igrab(inode);
 	stp->st_stid.sc_file = fp;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
@@ -4828,6 +4829,7 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
 	struct nfs4_file *fi = ost->st_stid.sc_file;
 	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
 	struct nfs4_client *cl = oo->oo_owner.so_client;
+	struct inode *inode = cstate->current_fh.fh_dentry->d_inode;
 	struct nfs4_lockowner *lo;
 	unsigned int strhashval;
 	__be32 status;
@@ -4844,7 +4846,7 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
 		goto out;
 	*lst = find_lock_stateid(lo, fi);
 	if (*lst == NULL) {
-		*lst = alloc_init_lock_stateid(lo, fi, ost);
+		*lst = alloc_init_lock_stateid(lo, fi, inode, ost);
 		if (*lst == NULL) {
 			status = nfserr_jukebox;
 			release_lockowner_if_empty(lo);
@@ -5201,10 +5203,9 @@ out_nfserr:
  * 	0: no locks held by lockowner
  */
 static int
-check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner)
+check_for_locks(struct inode *inode, struct nfs4_lockowner *lowner)
 {
 	struct file_lock **flpp;
-	struct inode *inode = filp->fi_inode;
 	int status = 0;
 
 	spin_lock(&inode->i_lock);
@@ -5256,7 +5257,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 		list_for_each_entry(stp, &sop->so_stateids,
 				st_perstateowner) {
 			lo = lockowner(sop);
-			if (check_for_locks(stp->st_stid.sc_file, lo))
+			if (check_for_locks(stp->st_inode, lo))
 				goto out;
 			list_add(&lo->lo_list, &matches);
 		}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 38c575c084e4..5d2c327cb7df 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -406,7 +406,6 @@ struct nfs4_file {
 	struct file_lock	*fi_lease;
 	atomic_t		fi_delegees;
 	struct knfsd_fh		fi_fhandle;
-	struct inode		*fi_inode;
 	bool			fi_had_conflict;
 };
 
@@ -420,6 +419,7 @@ struct nfs4_ol_stateid {
 	unsigned long                 st_access_bmap;
 	unsigned long                 st_deny_bmap;
 	struct nfs4_ol_stateid         * st_openstp;
+	struct inode		    * st_inode;
 };
 
 static inline struct nfs4_ol_stateid *openlockstateid(struct nfs4_stid *s)
-- 
1.9.3

