From: Ben Myers <bpm@sgi.com>
Subject: [RFC PATCH 2/4] Add datasync argument to nfsd_sync_dir().
Date: Wed, 03 Feb 2010 17:44:34 -0600
Message-ID: <20100203234434.17677.60881.stgit@case>
References: <20100203233755.17677.96582.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:35567 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756585Ab0BCXog (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 18:44:36 -0500
Received: from snoot.americas.sgi.com (case.americas.sgi.com [128.162.244.182])
	by relay3.corp.sgi.com (Postfix) with ESMTP id A42E7AC036
	for <linux-nfs@vger.kernel.org>; Wed,  3 Feb 2010 15:44:35 -0800 (PST)
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by snoot.americas.sgi.com (Postfix) with ESMTP id 9EDD848D6BF8
	for <linux-nfs@vger.kernel.org>; Wed,  3 Feb 2010 17:44:34 -0600 (CST)
In-Reply-To: <20100203233755.17677.96582.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


---
 fs/nfsd/nfs4recover.c |    2 +-
 fs/nfsd/vfs.c         |   18 +++++++++---------
 fs/nfsd/vfs.h         |    2 +-
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 5a754f7..e8c5938 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -120,7 +120,7 @@ static void
 nfsd4_sync_rec_dir(void)
 {
 	mutex_lock(&rec_dir.dentry->d_inode->i_mutex);
-	nfsd_sync_dir(rec_dir.dentry);
+	nfsd_sync_dir(rec_dir.dentry, 0);
 	mutex_unlock(&rec_dir.dentry->d_inode->i_mutex);
 }
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 79d216f..1a64fb6 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -777,7 +777,7 @@ nfsd_close(struct file *filp)
  *  b) we expect to have i_mutex already held by the caller
  */
 int
-nfsd_sync_dir(struct dentry *dentry)
+nfsd_sync_dir(struct dentry *dentry, int datasync)
 {
 	struct inode *inode = dentry->d_inode;
 	int error;
@@ -786,7 +786,7 @@ nfsd_sync_dir(struct dentry *dentry)
 
 	error = filemap_write_and_wait(inode->i_mapping);
 	if (!error && inode->i_fop->fsync)
-		error = inode->i_fop->fsync(NULL, dentry, 0);
+		error = inode->i_fop->fsync(NULL, dentry, datasync);
 	return error;
 }
 
@@ -1322,7 +1322,7 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
 	if (EX_ISSYNC(fhp->fh_export)) {
-		err = nfserrno(nfsd_sync_dir(dentry));
+		err = nfserrno(nfsd_sync_dir(dentry, 0));
 		write_inode_now(dchild->d_inode, 1);
 	}
 
@@ -1454,7 +1454,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		*created = 1;
 
 	if (EX_ISSYNC(fhp->fh_export)) {
-		err = nfserrno(nfsd_sync_dir(dentry));
+		err = nfserrno(nfsd_sync_dir(dentry, 0));
 		/* setattr will sync the child (or not) */
 	}
 
@@ -1592,7 +1592,7 @@ nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	if (!host_err) {
 		if (EX_ISSYNC(fhp->fh_export))
-			host_err = nfsd_sync_dir(dentry);
+			host_err = nfsd_sync_dir(dentry, 0);
 	}
 	err = nfserrno(host_err);
 	fh_unlock(fhp);
@@ -1657,7 +1657,7 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	host_err = vfs_link(dold, dirp, dnew);
 	if (!host_err) {
 		if (EX_ISSYNC(ffhp->fh_export)) {
-			err = nfserrno(nfsd_sync_dir(ddir));
+			err = nfserrno(nfsd_sync_dir(ddir, 0));
 			write_inode_now(dest, 1);
 		}
 		err = 0;
@@ -1757,9 +1757,9 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 
 	host_err = vfs_rename(fdir, odentry, tdir, ndentry);
 	if (!host_err && EX_ISSYNC(tfhp->fh_export)) {
-		host_err = nfsd_sync_dir(tdentry);
+		host_err = nfsd_sync_dir(tdentry, 0);
 		if (!host_err)
-			host_err = nfsd_sync_dir(fdentry);
+			host_err = nfsd_sync_dir(fdentry, 0);
 	}
 
 	mnt_drop_write(ffhp->fh_export->ex_path.mnt);
@@ -1843,7 +1843,7 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	if (host_err)
 		goto out_drop;
 	if (EX_ISSYNC(fhp->fh_export))
-		host_err = nfsd_sync_dir(dentry);
+		host_err = nfsd_sync_dir(dentry, 0);
 
 out_drop:
 	mnt_drop_write(fhp->fh_export->ex_path.mnt);
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 4b1de0a..89154a5 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -91,7 +91,7 @@ __be32		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
 int		nfsd_notify_change(struct inode *, struct iattr *);
 __be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
 				struct dentry *, int);
-int		nfsd_sync_dir(struct dentry *dp);
+int		nfsd_sync_dir(struct dentry *dp, int datasync);
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 struct posix_acl *nfsd_get_posix_acl(struct svc_fh *, int);

