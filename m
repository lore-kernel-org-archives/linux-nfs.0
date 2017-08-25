Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38326 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756604AbdHYVwj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Aug 2017 17:52:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] nfsd: clients don't need to break their own delegations
Date: Fri, 25 Aug 2017 17:52:38 -0400
Message-Id: <1503697958-6122-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1503697958-6122-1-git-send-email-bfields@redhat.com>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We currently revoke read delegations on any write open or any operation
that modifies file data or metadata (including rename, link, and
unlink).  But if the delegation in question is the only read delegation
and is held by the client performing the operation, that's not really
necessary.

It's not always possible to prevent this in the NFSv4.0 case, because
there's not always a way to determine which client an NFSv4.0 delegation
came from.  (In theory we could try to guess this from the transport
layer, e.g., by assuming all traffic on a given TCP connection comes
from the same client.  But that's not really correct.)

In the NFSv4.1 case the session layer always tells us the client.

This patch should remove such self-conflicts in all cases where we can
reliably determine the client from the compound.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 Documentation/filesystems/Locking |  2 ++
 fs/locks.c                        |  7 ++++++-
 fs/nfsd/nfs4state.c               | 40 +++++++++++++++++++++++++++++++++++++++
 fs/nfsd/vfs.c                     | 26 ++++++++++++++++++++-----
 include/linux/fs.h                | 27 ++++++++++++++++----------
 5 files changed, 86 insertions(+), 16 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index fe25787ff6d4..8876a32df5ff 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -366,6 +366,7 @@ prototypes:
 	int (*lm_grant)(struct file_lock *, struct file_lock *, int);
 	void (*lm_break)(struct file_lock *); /* break_lease callback */
 	int (*lm_change)(struct file_lock **, int);
+	bool (*lm_breaker_owns_lease)(void *, struct file_lock *);
 
 locking rules:
 
@@ -376,6 +377,7 @@ lm_notify:		yes		yes			no
 lm_grant:		no		no			no
 lm_break:		yes		no			no
 lm_change		yes		no			no
+lm_breaker_owns_lease:	no		no			no
 
 [1]:	->lm_compare_owner and ->lm_owner_key are generally called with
 *an* inode->i_lock held. It may not be the i_lock of the inode
diff --git a/fs/locks.c b/fs/locks.c
index afefeb4ad6de..a3de5b96c81c 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1404,6 +1404,9 @@ static void time_out_leases(struct inode *inode, struct list_head *dispose)
 
 static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
 {
+	if (lease->fl_lmops->lm_breaker_owns_lease && breaker->fl_owner &&
+	    lease->fl_lmops->lm_breaker_owns_lease(breaker->fl_owner, lease))
+		return false;
 	if ((breaker->fl_flags & FL_LAYOUT) != (lease->fl_flags & FL_LAYOUT))
 		return false;
 	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE))
@@ -1429,6 +1432,7 @@ any_leases_conflict(struct inode *inode, struct file_lock *breaker)
 /**
  *	__break_lease	-	revoke all outstanding leases on file
  *	@inode: the inode of the file to return
+ *	@who: if an nfs client is breaking, which client it is
  *	@mode: O_RDONLY: break only write leases; O_WRONLY or O_RDWR:
  *	    break all leases
  *	@type: FL_LEASE: break leases and delegations; FL_DELEG: break
@@ -1439,7 +1443,7 @@ any_leases_conflict(struct inode *inode, struct file_lock *breaker)
  *	a call to open() or truncate().  This function can sleep unless you
  *	specified %O_NONBLOCK to your open().
  */
-int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
+int __break_lease(struct inode *inode, void *who, unsigned int mode, unsigned int type)
 {
 	int error = 0;
 	struct file_lock_context *ctx;
@@ -1452,6 +1456,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 	if (IS_ERR(new_fl))
 		return PTR_ERR(new_fl);
 	new_fl->fl_flags = type;
+	new_fl->fl_owner = who;
 
 	/* typically we will check that ctx is non-NULL before calling */
 	ctx = smp_load_acquire(&inode->i_flctx);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0c04f81aa63b..fb15efcc4e08 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3825,6 +3825,45 @@ nfsd_break_deleg_cb(struct file_lock *fl)
 	return ret;
 }
 
+static struct nfs4_client *nfsd4_client_from_rqst(struct svc_rqst *rqst)
+{
+	struct nfsd4_compoundres *resp;
+
+	/*
+	 * In case it's possible we could be called from NLM or ACL
+	 * code?:
+	 */
+	if (rqst->rq_prog != NFS_PROGRAM)
+		return NULL;
+	if (rqst->rq_vers != 4)
+		return NULL;
+	resp = rqst->rq_resp;
+	return resp->cstate.clp;
+}
+
+static bool nfsd_breaker_owns_lease(void *who, struct file_lock *fl)
+{
+	struct svc_rqst *rqst = who;
+	struct nfs4_client *cl;
+	struct nfs4_delegation *dl;
+	struct nfs4_file *fi = (struct nfs4_file *)fl->fl_owner;
+	bool ret = true;
+
+	cl = nfsd4_client_from_rqst(rqst);
+	if (!cl)
+		return false;
+
+	spin_lock(&fi->fi_lock);
+	list_for_each_entry(dl, &fi->fi_delegations, dl_perfile) {
+		if (dl->dl_stid.sc_client != cl) {
+			ret = false;
+			break;
+		}
+	}
+	spin_unlock(&fi->fi_lock);
+	return ret;
+}
+
 static int
 nfsd_change_deleg_cb(struct file_lock *onlist, int arg,
 		     struct list_head *dispose)
@@ -3836,6 +3875,7 @@ nfsd_change_deleg_cb(struct file_lock *onlist, int arg,
 }
 
 static const struct lock_manager_operations nfsd_lease_mng_ops = {
+	.lm_breaker_owns_lease = nfsd_breaker_owns_lease,
 	.lm_break = nfsd_break_deleg_cb,
 	.lm_change = nfsd_change_deleg_cb,
 };
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 38d0383dc7f9..fe62bc744143 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -394,6 +394,10 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	int		host_err;
 	bool		get_write_count;
 	bool		size_change = (iap->ia_valid & ATTR_SIZE);
+	struct deleg_break_ctl deleg_break_ctl = {
+			.delegated_inode = DELEG_NO_WAIT,
+			.who = rqstp
+	};
 
 	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
 		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
@@ -455,7 +459,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 			.ia_size	= iap->ia_size,
 		};
 
-		host_err = notify_change(dentry, &size_attr, NULL);
+		host_err = notify_change(dentry, &size_attr, &deleg_break_ctl);
 		if (host_err)
 			goto out_unlock;
 		iap->ia_valid &= ~ATTR_SIZE;
@@ -470,7 +474,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	}
 
 	iap->ia_valid |= ATTR_CTIME;
-	host_err = notify_change(dentry, iap, NULL);
+	host_err = notify_change(dentry, iap, &deleg_break_ctl);
 
 out_unlock:
 	fh_unlock(fhp);
@@ -1553,6 +1557,10 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	struct inode	*dirp;
 	__be32		err;
 	int		host_err;
+	struct deleg_break_ctl deleg_break_ctl = {
+		.delegated_inode = DELEG_NO_WAIT,
+		.who = rqstp
+	};
 
 	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_CREATE);
 	if (err)
@@ -1590,7 +1598,7 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	err = nfserr_noent;
 	if (d_really_is_negative(dold))
 		goto out_dput;
-	host_err = vfs_link(dold, dirp, dnew, NULL);
+	host_err = vfs_link(dold, dirp, dnew, &deleg_break_ctl);
 	if (!host_err) {
 		err = nfserrno(commit_metadata(ffhp));
 		if (!err)
@@ -1626,6 +1634,10 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	struct inode	*fdir, *tdir;
 	__be32		err;
 	int		host_err;
+	struct deleg_break_ctl deleg_break_ctl = {
+		.delegated_inode = DELEG_NO_WAIT,
+		.who = rqstp
+	};
 
 	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_REMOVE);
 	if (err)
@@ -1683,7 +1695,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	if (ffhp->fh_export->ex_path.dentry != tfhp->fh_export->ex_path.dentry)
 		goto out_dput_new;
 
-	host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL, 0);
+	host_err = vfs_rename(fdir, odentry, tdir, ndentry, &deleg_break_ctl, 0);
 	if (!host_err) {
 		host_err = commit_metadata(tfhp);
 		if (!host_err)
@@ -1722,6 +1734,10 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	struct inode	*dirp;
 	__be32		err;
 	int		host_err;
+	struct deleg_break_ctl deleg_break_ctl = {
+		.delegated_inode = DELEG_NO_WAIT,
+		.who = rqstp
+	};
 
 	err = nfserr_acces;
 	if (!flen || isdotent(fname, flen))
@@ -1753,7 +1769,7 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 		type = d_inode(rdentry)->i_mode & S_IFMT;
 
 	if (type != S_IFDIR)
-		host_err = vfs_unlink(dirp, rdentry, NULL);
+		host_err = vfs_unlink(dirp, rdentry, &deleg_break_ctl);
 	else
 		host_err = vfs_rmdir(dirp, rdentry);
 	if (!host_err)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 20a07375e60c..8626071d9b54 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -953,6 +953,7 @@ struct lock_manager_operations {
 	bool (*lm_break)(struct file_lock *);
 	int (*lm_change)(struct file_lock *, int, struct list_head *);
 	void (*lm_setup)(struct file_lock *, void **);
+	bool (*lm_breaker_owns_lease)(void *, struct file_lock *);
 };
 
 struct lock_manager {
@@ -1082,7 +1083,7 @@ extern int vfs_test_lock(struct file *, struct file_lock *);
 extern int vfs_lock_file(struct file *, unsigned int, struct file_lock *, struct file_lock *);
 extern int vfs_cancel_lock(struct file *filp, struct file_lock *fl);
 extern int locks_lock_inode_wait(struct inode *inode, struct file_lock *fl);
-extern int __break_lease(struct inode *inode, unsigned int flags, unsigned int type);
+extern int __break_lease(struct inode *inode, void *who, unsigned int flags, unsigned int type);
 extern void lease_get_mtime(struct inode *, struct timespec *time);
 extern int generic_setlease(struct file *, long, struct file_lock **, void **priv);
 extern int vfs_setlease(struct file *, long, struct file_lock **, void **);
@@ -1193,7 +1194,7 @@ static inline int locks_lock_inode_wait(struct inode *inode, struct file_lock *f
 	return -ENOLCK;
 }
 
-static inline int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
+static inline int __break_lease(struct inode *inode, void *who, unsigned int mode, unsigned int type)
 {
 	return 0;
 }
@@ -1567,6 +1568,7 @@ extern bool inode_owner_or_capable(const struct inode *inode);
 /* Used to pass some information used by NFSv4 delegations */
 struct deleg_break_ctl {
 	struct inode *delegated_inode; /* inode with in-progress break */
+	void *who; /* who is breaking the lease (used by nfsd) */
 };
 
 /*
@@ -2263,11 +2265,11 @@ static inline int break_lease(struct inode *inode, unsigned int mode)
 	 */
 	smp_mb();
 	if (inode->i_flctx && !list_empty_careful(&inode->i_flctx->flc_lease))
-		return __break_lease(inode, mode, FL_LEASE);
+		return __break_lease(inode, NULL, mode, FL_LEASE);
 	return 0;
 }
 
-static inline int break_deleg(struct inode *inode, unsigned int mode)
+static inline int break_deleg(struct inode *inode, void *who, unsigned int mode)
 {
 	/*
 	 * Since this check is lockless, we must ensure that any refcounts
@@ -2277,16 +2279,20 @@ static inline int break_deleg(struct inode *inode, unsigned int mode)
 	 */
 	smp_mb();
 	if (inode->i_flctx && !list_empty_careful(&inode->i_flctx->flc_lease))
-		return __break_lease(inode, mode, FL_DELEG);
+		return __break_lease(inode, who, mode, FL_DELEG);
 	return 0;
 }
 
+#define DELEG_NO_WAIT ((struct inode *)1)
+
 static inline int try_break_deleg(struct inode *inode, struct deleg_break_ctl *deleg_break_ctl)
 {
 	int ret;
+	void *who = deleg_break_ctl ? deleg_break_ctl->who : NULL;
 
-	ret = break_deleg(inode, O_WRONLY|O_NONBLOCK);
-	if (ret == -EWOULDBLOCK && deleg_break_ctl) {
+	ret = break_deleg(inode, who, O_WRONLY|O_NONBLOCK);
+	if (ret == -EWOULDBLOCK && deleg_break_ctl &&
+			deleg_break_ctl->delegated_inode != DELEG_NO_WAIT) {
 		deleg_break_ctl->delegated_inode = inode;
 		ihold(inode);
 	}
@@ -2300,7 +2306,8 @@ static inline int break_deleg_wait(struct deleg_break_ctl *deleg_break_ctl, int
 	if (!deleg_break_ctl->delegated_inode)
 		return error;
 
-	error = break_deleg(deleg_break_ctl->delegated_inode, O_WRONLY);
+	error = break_deleg(deleg_break_ctl->delegated_inode,
+			  deleg_break_ctl->who, O_WRONLY);
 	iput(deleg_break_ctl->delegated_inode);
 	deleg_break_ctl->delegated_inode = NULL;
 	return error ? error : DELEG_RETRY;
@@ -2310,7 +2317,7 @@ static inline int break_layout(struct inode *inode, bool wait)
 {
 	smp_mb();
 	if (inode->i_flctx && !list_empty_careful(&inode->i_flctx->flc_lease))
-		return __break_lease(inode,
+		return __break_lease(inode, NULL,
 				wait ? O_WRONLY : O_WRONLY | O_NONBLOCK,
 				FL_LAYOUT);
 	return 0;
@@ -2322,7 +2329,7 @@ static inline int break_lease(struct inode *inode, unsigned int mode)
 	return 0;
 }
 
-static inline int break_deleg(struct inode *inode, unsigned int mode)
+static inline int break_deleg(struct inode *inode, void *who, unsigned int mode)
 {
 	return 0;
 }
-- 
2.13.5

