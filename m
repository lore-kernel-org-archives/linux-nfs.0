Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:41347 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933336AbaGWURy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jul 2014 16:17:54 -0400
Received: by mail-qa0-f46.google.com with SMTP id v10so1878977qac.5
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jul 2014 13:17:53 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: [PATCH v2 4/4] nfsd: Do not let nfs4_file pin the struct inode
Date: Wed, 23 Jul 2014 16:17:41 -0400
Message-Id: <1406146661-9794-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406146661-9794-1-git-send-email-jlayton@primarydata.com>
References: <1406146661-9794-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the fi_inode field in struct nfs4_file in order to remove the
possibility of struct nfs4_file pinning the inode when it does not have
any open state.

The only place we still need to get to an inode is in check_for_locks,
so change it to use find_any_file and use the inode from any that it
finds. If it doesn't find one, then just assume there aren't any.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 49 ++++++++++++++++++++++++++++---------------------
 fs/nfsd/state.h     |  1 -
 2 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6ced8d566c0b..1dfc8ee85c93 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -70,7 +70,7 @@ static u64 current_sessionid = 1;
 #define CURRENT_STATEID(stateid) (!memcmp((stateid), &currentstateid, sizeof(stateid_t)))
 
 /* forward declarations */
-static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
+static bool check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner);
 
 /* Locking: */
 
@@ -259,7 +259,6 @@ put_nfs4_file(struct nfs4_file *fi)
 	if (atomic_dec_and_lock(&fi->fi_ref, &state_lock)) {
 		hlist_del(&fi->fi_hash);
 		spin_unlock(&state_lock);
-		iput(fi->fi_inode);
 		nfsd4_free_file(fi);
 	}
 }
@@ -2845,8 +2844,7 @@ static struct nfs4_file *nfsd4_alloc_file(void)
 }
 
 /* OPEN Share state helper functions */
-static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
-		struct knfsd_fh *fh)
+static void nfsd4_init_file(struct nfs4_file *fp, struct knfsd_fh *fh)
 {
 	unsigned int hashval = file_hashval(fh);
 
@@ -2856,8 +2854,6 @@ static void nfsd4_init_file(struct nfs4_file *fp, struct inode *ino,
 	spin_lock_init(&fp->fi_lock);
 	INIT_LIST_HEAD(&fp->fi_stateids);
 	INIT_LIST_HEAD(&fp->fi_delegations);
-	ihold(ino);
-	fp->fi_inode = ino;
 	fh_copy_shallow(&fp->fi_fhandle, fh);
 	fp->fi_had_conflict = false;
 	fp->fi_lease = NULL;
@@ -3063,14 +3059,14 @@ find_file(struct knfsd_fh *fh)
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
@@ -3714,7 +3710,6 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
 	struct nfs4_file *fp = NULL;
-	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_ol_stateid *stp = NULL;
 	struct nfs4_delegation *dp = NULL;
 	__be32 status;
@@ -3724,7 +3719,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	 * and check for delegations in the process of being recalled.
 	 * If not found, create the nfs4_file struct
 	 */
-	fp = find_or_add_file(ino, open->op_file, &current_fh->fh_handle);
+	fp = find_or_add_file(open->op_file, &current_fh->fh_handle);
 	if (fp != open->op_file) {
 		status = nfs4_check_deleg(cl, open, &dp);
 		if (status)
@@ -4663,7 +4658,9 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 }
 
 static struct nfs4_ol_stateid *
-alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp, struct nfs4_ol_stateid *open_stp)
+alloc_init_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fp,
+		struct inode *inode,
+		struct nfs4_ol_stateid *open_stp)
 {
 	struct nfs4_ol_stateid *stp;
 	struct nfs4_client *clp = lo->lo_owner.so_client;
@@ -4723,6 +4720,7 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
 	struct nfs4_file *fi = ost->st_file;
 	struct nfs4_openowner *oo = openowner(ost->st_stateowner);
 	struct nfs4_client *cl = oo->oo_owner.so_client;
+	struct inode *inode = cstate->current_fh.fh_dentry->d_inode;
 	struct nfs4_lockowner *lo;
 	unsigned int strhashval;
 	struct nfsd_net *nn = net_generic(cl->net, nfsd_net_id);
@@ -4743,7 +4741,7 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate, s
 
 	*lst = find_lock_stateid(lo, fi);
 	if (*lst == NULL) {
-		*lst = alloc_init_lock_stateid(lo, fi, ost);
+		*lst = alloc_init_lock_stateid(lo, fi, inode, ost);
 		if (*lst == NULL) {
 			release_lockowner_if_empty(lo);
 			return nfserr_jukebox;
@@ -5092,25 +5090,34 @@ out_nfserr:
 
 /*
  * returns
- * 	1: locks held by lockowner
- * 	0: no locks held by lockowner
+ * 	true:  locks held by lockowner
+ * 	false: no locks held by lockowner
  */
-static int
-check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner)
+static bool
+check_for_locks(struct nfs4_file *fp, struct nfs4_lockowner *lowner)
 {
 	struct file_lock **flpp;
-	struct inode *inode = filp->fi_inode;
-	int status = 0;
+	int status = false;
+	struct file *filp = find_any_file(fp);
+	struct inode *inode;
+
+	if (!filp) {
+		/* Any valid lock stateid should have some sort of access */
+		WARN_ON_ONCE(1);
+		return status;
+	}
+
+	inode = file_inode(filp);
 
 	spin_lock(&inode->i_lock);
 	for (flpp = &inode->i_flock; *flpp != NULL; flpp = &(*flpp)->fl_next) {
 		if ((*flpp)->fl_owner == (fl_owner_t)lowner) {
-			status = 1;
-			goto out;
+			status = true;
+			break;
 		}
 	}
-out:
 	spin_unlock(&inode->i_lock);
+	fput(filp);
 	return status;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 33cf950b3873..0097d4771521 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -397,7 +397,6 @@ struct nfs4_file {
 	struct file_lock	*fi_lease;
 	atomic_t		fi_delegees;
 	struct knfsd_fh		fi_fhandle;
-	struct inode		*fi_inode;
 	bool			fi_had_conflict;
 };
 
-- 
1.9.3

