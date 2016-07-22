Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40066 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751772AbcGVRtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2016 13:49:05 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/7] nfsd: reorganize nfsd_create
Date: Fri, 22 Jul 2016 13:48:53 -0400
Message-Id: <1469209736-6490-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1469209736-6490-1-git-send-email-bfields@redhat.com>
References: <1469209736-6490-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

There's some odd logic in nfsd_create() that allows it to be called with
the parent directory either locked or unlocked.  The only already-locked
caller is NFSv2's nfsd_proc_create().  It's less confusing to split out
the unlocked case into a separate function which the NFSv2 code can call
directly.

Also fix some comments while we're here.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsproc.c |   4 +-
 fs/nfsd/vfs.c     | 109 ++++++++++++++++++++++++++++--------------------------
 fs/nfsd/vfs.h     |   3 ++
 3 files changed, 61 insertions(+), 55 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index c30b12388bf6..8914206c867c 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -358,8 +358,8 @@ nfsd_proc_create(struct svc_rqst *rqstp, struct nfsd_createargs *argp,
 	nfserr = 0;
 	if (!inode) {
 		/* File doesn't exist. Create it and set attrs */
-		nfserr = nfsd_create(rqstp, dirfhp, argp->name, argp->len,
-					attr, type, rdev, newfhp);
+		nfserr = nfsd_create_locked(rqstp, dirfhp, argp->name,
+					argp->len, attr, type, rdev, newfhp);
 	} else if (type == S_IFREG) {
 		dprintk("nfsd:   existing %s, valid=%x, size=%ld\n",
 			argp->name, attr->ia_valid, (long) attr->ia_size);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7ae3b5a72a4d..9c7830cdaeda 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1135,16 +1135,9 @@ nfsd_check_ignore_resizing(struct iattr *iap)
 		iap->ia_valid &= ~ATTR_SIZE;
 }
 
-/*
- * Create a file (regular, directory, device, fifo); UNIX sockets 
- * not yet implemented.
- * If the response fh has been verified, the parent directory should
- * already be locked. Note that the parent directory is left locked.
- *
- * N.B. Every call to nfsd_create needs an fh_put for _both_ fhp and resfhp
- */
+/* The parent directory should already be locked: */
 __be32
-nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
+nfsd_create_locked(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		char *fname, int flen, struct iattr *iap,
 		int type, dev_t rdev, struct svc_fh *resfhp)
 {
@@ -1154,50 +1147,15 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	__be32		err2;
 	int		host_err;
 
-	err = nfserr_exist;
-	if (isdotent(fname, flen))
-		goto out;
-
-	/*
-	 * Even though it is a create, first let's see if we are even allowed
-	 * to peek inside the parent
-	 */
-	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
-	if (err)
-		goto out;
-
 	dentry = fhp->fh_dentry;
 	dirp = d_inode(dentry);
 
-	/*
-	 * Check whether the response file handle has been verified yet.
-	 * If it has, the parent directory should already be locked.
-	 */
-	if (!resfhp->fh_dentry) {
-		host_err = fh_want_write(fhp);
-		if (host_err)
-			goto out_nfserr;
-
-		/* called from nfsd_proc_mkdir, or possibly nfsd3_proc_create */
-		fh_lock_nested(fhp, I_MUTEX_PARENT);
-		dchild = lookup_one_len(fname, dentry, flen);
-		host_err = PTR_ERR(dchild);
-		if (IS_ERR(dchild))
-			goto out_nfserr;
-		err = fh_compose(resfhp, fhp->fh_export, dchild, fhp);
-		if (err)
-			goto out;
-	} else {
-		/* called from nfsd_proc_create */
-		dchild = dget(resfhp->fh_dentry);
-		if (!fhp->fh_locked) {
-			/* not actually possible */
-			printk(KERN_ERR
-				"nfsd_create: parent %pd2 not locked!\n",
+	dchild = dget(resfhp->fh_dentry);
+	if (!fhp->fh_locked) {
+		WARN_ONCE(1, "nfsd_create: parent %pd2 not locked!\n",
 				dentry);
-			err = nfserr_io;
-			goto out;
-		}
+		err = nfserr_io;
+		goto out;
 	}
 	/*
 	 * Make sure the child dentry is still negative ...
@@ -1225,9 +1183,6 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out;
 	}
 
-	/*
-	 * Get the dir op function pointer.
-	 */
 	err = 0;
 	host_err = 0;
 	switch (type) {
@@ -1254,7 +1209,7 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	/*
 	 * nfsd_create_setattr already committed the child.  Transactional
 	 * filesystems had a chance to commit changes for both parent and
-	 * child * simultaneously making the following commit_metadata a
+	 * child simultaneously making the following commit_metadata a
 	 * noop.
 	 */
 	err2 = nfserrno(commit_metadata(fhp));
@@ -1275,6 +1230,54 @@ out_nfserr:
 	goto out;
 }
 
+/*
+ * Create a filesystem object (regular, directory, special).
+ * Note that the parent directory is left locked.
+ *
+ * N.B. Every call to nfsd_create needs an fh_put for _both_ fhp and resfhp
+ */
+__be32
+nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		char *fname, int flen, struct iattr *iap,
+		int type, dev_t rdev, struct svc_fh *resfhp)
+{
+	struct dentry	*dentry, *dchild = NULL;
+	struct inode	*dirp;
+	__be32		err;
+	int		host_err;
+
+	if (isdotent(fname, flen))
+		return nfserr_exist;
+
+	/*
+	 * Even though it is a create, first let's see if we are even allowed
+	 * to peek inside the parent
+	 */
+	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
+	if (err)
+		return err;
+
+	dentry = fhp->fh_dentry;
+	dirp = d_inode(dentry);
+
+	host_err = fh_want_write(fhp);
+	if (host_err)
+		return nfserrno(host_err);
+
+	fh_lock_nested(fhp, I_MUTEX_PARENT);
+	dchild = lookup_one_len(fname, dentry, flen);
+	host_err = PTR_ERR(dchild);
+	if (IS_ERR(dchild))
+		return nfserrno(host_err);
+	err = fh_compose(resfhp, fhp->fh_export, dchild, fhp);
+	if (err) {
+		dput(dchild);
+		return err;
+	}
+	return nfsd_create_locked(rqstp, fhp, fname, flen, iap, type,
+					rdev, resfhp);
+}
+
 #ifdef CONFIG_NFSD_V3
 
 /*
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 2d573ec057f8..3cbb1b33777b 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -59,6 +59,9 @@ __be32		nfsd4_vfs_fallocate(struct svc_rqst *, struct svc_fh *,
 __be32		nfsd4_clone_file_range(struct file *, u64, struct file *,
 			u64, u64);
 #endif /* CONFIG_NFSD_V4 */
+__be32		nfsd_create_locked(struct svc_rqst *, struct svc_fh *,
+				char *name, int len, struct iattr *attrs,
+				int type, dev_t rdev, struct svc_fh *res);
 __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct iattr *attrs,
 				int type, dev_t rdev, struct svc_fh *res);
-- 
2.7.4

