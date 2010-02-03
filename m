From: Ben Myers <bpm@sgi.com>
Subject: [RFC PATCH 4/4] If 'wsync' pass datasync=1 to vfs_fsync().
Date: Wed, 03 Feb 2010 17:44:44 -0600
Message-ID: <20100203234444.17677.32390.stgit@case>
References: <20100203233755.17677.96582.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:35572 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757779Ab0BCXoq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 18:44:46 -0500
Received: from snoot.americas.sgi.com (case.americas.sgi.com [128.162.244.182])
	by relay3.corp.sgi.com (Postfix) with ESMTP id BF648AC036
	for <linux-nfs@vger.kernel.org>; Wed,  3 Feb 2010 15:44:45 -0800 (PST)
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by snoot.americas.sgi.com (Postfix) with ESMTP id BEA9348D6BF8
	for <linux-nfs@vger.kernel.org>; Wed,  3 Feb 2010 17:44:44 -0600 (CST)
In-Reply-To: <20100203233755.17677.96582.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


---
 fs/nfsd/vfs.c |   39 +++++++++++++++++++++++++--------------
 1 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 89eb1b2..4b1973b 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -418,7 +418,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	if (!err) {
 		if (EX_ISSYNC(fhp->fh_export)) {
 			if (EX_ISWSYNC(fhp->fh_export)) {
-				vfs_fsync(NULL, dentry, 0);
+				vfs_fsync(NULL, dentry, 1);
 			} else {
 				write_inode_now(inode, 1);
 			}
@@ -1169,7 +1169,8 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		return err;
 	if (EX_ISSYNC(fhp->fh_export)) {
 		if (file->f_op && file->f_op->fsync) {
-			err = nfserrno(vfs_fsync(file, file->f_path.dentry, 0));
+			err = nfserrno(vfs_fsync(file, file->f_path.dentry,
+				       EX_ISWSYNC(fhp->fh_export) ? 1 :	0));
 		} else {
 			err = nfserr_notsupp;
 		}
@@ -1329,9 +1330,10 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
 	if (EX_ISSYNC(fhp->fh_export)) {
-		err = nfserrno(nfsd_sync_dir(dentry, 0));
+		err = nfserrno(nfsd_sync_dir(dentry,
+					EX_ISWSYNC(fhp->fh_export) ? 1 : 0));
 		if (EX_ISWSYNC(fhp->fh_export)) {
-			vfs_fsync(NULL, dchild, 0);
+			vfs_fsync(NULL, dchild, 1);
 		} else {
 			write_inode_now(dchild->d_inode, 1);
 		}
@@ -1465,7 +1467,8 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		*created = 1;
 
 	if (EX_ISSYNC(fhp->fh_export)) {
-		err = nfserrno(nfsd_sync_dir(dentry, 0));
+		err = nfserrno(nfsd_sync_dir(dentry,
+					EX_ISWSYNC(fhp->fh_export) ? 1 : 0));
 		/* setattr will sync the child (or not) */
 	}
 
@@ -1602,8 +1605,10 @@ nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		host_err = vfs_symlink(dentry->d_inode, dnew, path);
 
 	if (!host_err) {
-		if (EX_ISSYNC(fhp->fh_export))
-			host_err = nfsd_sync_dir(dentry, 0);
+		if (EX_ISSYNC(fhp->fh_export)) {
+			host_err = nfsd_sync_dir(dentry,
+					EX_ISWSYNC(fhp->fh_export) ? 1 : 0);
+		}
 	}
 	err = nfserrno(host_err);
 	fh_unlock(fhp);
@@ -1668,9 +1673,10 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	host_err = vfs_link(dold, dirp, dnew);
 	if (!host_err) {
 		if (EX_ISSYNC(ffhp->fh_export)) {
-			err = nfserrno(nfsd_sync_dir(ddir, 0));
+			err = nfserrno(nfsd_sync_dir(ddir,
+					EX_ISWSYNC(ffhp->fh_export) ? 1 : 0));
 			if (EX_ISWSYNC(ffhp->fh_export)) {
-				vfs_fsync(NULL, dold, 0);
+				vfs_fsync(NULL, dold, 1);
 			} else {
 				write_inode_now(dest, 1);
 			}
@@ -1772,9 +1778,12 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 
 	host_err = vfs_rename(fdir, odentry, tdir, ndentry);
 	if (!host_err && EX_ISSYNC(tfhp->fh_export)) {
-		host_err = nfsd_sync_dir(tdentry, 0);
-		if (!host_err)
-			host_err = nfsd_sync_dir(fdentry, 0);
+		host_err = nfsd_sync_dir(tdentry,
+				EX_ISWSYNC(tfhp->fh_export) ? 1 : 0);
+		if (!host_err) {
+			host_err = nfsd_sync_dir(fdentry,
+					EX_ISWSYNC(tfhp->fh_export) ? 1 : 0);
+		}
 	}
 
 	mnt_drop_write(ffhp->fh_export->ex_path.mnt);
@@ -1857,8 +1866,10 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 
 	if (host_err)
 		goto out_drop;
-	if (EX_ISSYNC(fhp->fh_export))
-		host_err = nfsd_sync_dir(dentry, 0);
+	if (EX_ISSYNC(fhp->fh_export)) {
+		host_err = nfsd_sync_dir(dentry,
+				EX_ISWSYNC(fhp->fh_export) ? 1 : 0);
+	}
 
 out_drop:
 	mnt_drop_write(fhp->fh_export->ex_path.mnt);

