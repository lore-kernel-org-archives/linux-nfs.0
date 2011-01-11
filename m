Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56628 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932191Ab1AKTWg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 14:22:36 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1Pcjnf-0007Sa-1Z
	for linux-nfs@vger.kernel.org; Tue, 11 Jan 2011 14:22:35 -0500
Date: Tue, 11 Jan 2011 14:22:32 -0500
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: don't support msnfs export option
Message-ID: <20110111192232.GA28537@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

We've long had these pointless #ifdef MSNFS's sprinkled throughout the
code--pointless because MSNFS is always defined (and we give no config
option to make that easy to change).  So we could just remove the
ifdef's and compile the resulting code unconditionally.

But as long as we're there: why not just rip out this code entirely?
The only purpose is to implement the "msnfs" export option which turns
on Windows-like behavior in some cases, and:

	- the export option isn't documented anywhere;
	- the userland utilities (which would need to be able to parse
	  "msnfs" in /etc/exports) don't support it;
	- I don't know how to maintain this, as I don't know what the
	  proper behavior for a Windows-like NFS server is; and
	- I can't get google to turn up any evidence that anyone has ever
	  used this.

?

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/export.c            |    4 ----
 fs/nfsd/vfs.c               |   39 ++-------------------------------------
 include/linux/nfsd/export.h |    2 +-
 3 files changed, 3 insertions(+), 42 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c0fcb7a..8b31e5f 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1,4 +1,3 @@
-#define MSNFS	/* HACK HACK */
 /*
  * NFS exporting and validation.
  *
@@ -1444,9 +1443,6 @@ static struct flags {
 	{ NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
 	{ NFSEXP_V4ROOT, {"v4root", ""}},
-#ifdef MSNFS
-	{ NFSEXP_MSNFS, {"msnfs", ""}},
-#endif
 	{ 0, {"", ""}}
 };
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b991125..f8919f5 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1,4 +1,3 @@
-#define MSNFS	/* HACK HACK */
 /*
  * File operations used by nfsd. Some of these have been ripped from
  * other parts of the kernel because they weren't exported, others
@@ -875,15 +874,6 @@ static int nfsd_direct_splice_actor(struct pipe_inode_info *pipe,
 	return __splice_from_pipe(pipe, sd, nfsd_splice_actor);
 }
 
-static inline int svc_msnfs(struct svc_fh *ffhp)
-{
-#ifdef MSNFS
-	return (ffhp->fh_export->ex_flags & NFSEXP_MSNFS);
-#else
-	return 0;
-#endif
-}
-
 static __be32
 nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
               loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
@@ -896,9 +886,6 @@ nfsd_vfs_read(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	err = nfserr_perm;
 	inode = file->f_path.dentry->d_inode;
 
-	if (svc_msnfs(fhp) && !lock_may_read(inode, offset, *count))
-		goto out;
-
 	if (file->f_op->splice_read && rqstp->rq_splice_ok) {
 		struct splice_desc sd = {
 			.len		= 0,
@@ -988,14 +975,6 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	int			stable = *stablep;
 	int			use_wgather;
 
-#ifdef MSNFS
-	err = nfserr_perm;
-
-	if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
-		(!lock_may_write(file->f_path.dentry->d_inode, offset, *cnt)))
-		goto out;
-#endif
-
 	dentry = file->f_path.dentry;
 	inode = dentry->d_inode;
 	exp   = fhp->fh_export;
@@ -1751,13 +1730,6 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	if (ndentry == trap)
 		goto out_dput_new;
 
-	if (svc_msnfs(ffhp) &&
-		((atomic_read(&odentry->d_count) > 1)
-		 || (atomic_read(&ndentry->d_count) > 1))) {
-			host_err = -EPERM;
-			goto out_dput_new;
-	}
-
 	host_err = -EXDEV;
 	if (ffhp->fh_export->ex_path.mnt != tfhp->fh_export->ex_path.mnt)
 		goto out_dput_new;
@@ -1836,17 +1808,10 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	if (host_err)
 		goto out_nfserr;
 
-	if (type != S_IFDIR) { /* It's UNLINK */
-#ifdef MSNFS
-		if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&
-			(atomic_read(&rdentry->d_count) > 1)) {
-			host_err = -EPERM;
-		} else
-#endif
+	if (type != S_IFDIR)
 		host_err = vfs_unlink(dirp, rdentry);
-	} else { /* It's RMDIR */
+	else
 		host_err = vfs_rmdir(dirp, rdentry);
-	}
 
 	dput(rdentry);
 
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 8ae78a6..bd31615 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -35,7 +35,7 @@
 #define NFSEXP_NOHIDE		0x0200
 #define NFSEXP_NOSUBTREECHECK	0x0400
 #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
-#define NFSEXP_MSNFS		0x1000	/* do silly things that MS clients expect */
+#define NFSEXP_MSNFS		0x1000	/* do silly things that MS clients expect; no longer supported */
 #define NFSEXP_FSID		0x2000
 #define	NFSEXP_CROSSMOUNT	0x4000
 #define	NFSEXP_NOACL		0x8000	/* reserved for possible ACL related use */
-- 
1.7.1

