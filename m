From: Ben Myers <bpm@sgi.com>
Subject: [RFC PATCH 1/2] commit_metadata export operation and nfsd_sync2
Date: Tue, 09 Feb 2010 18:33:32 -0600
Message-ID: <20100210003331.6021.55867.stgit@case>
References: <20100210003220.6021.74943.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:36929 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751672Ab0BJAdd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 19:33:33 -0500
Received: from snoot.americas.sgi.com (case.americas.sgi.com [128.162.244.182])
	by relay2.corp.sgi.com (Postfix) with ESMTP id 8A52030408B
	for <linux-nfs@vger.kernel.org>; Tue,  9 Feb 2010 16:33:32 -0800 (PST)
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by snoot.americas.sgi.com (Postfix) with ESMTP id 0359648F3C1A
	for <linux-nfs@vger.kernel.org>; Tue,  9 Feb 2010 18:33:32 -0600 (CST)
In-Reply-To: <20100210003220.6021.74943.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

- Add an new export_operation 'commit_metadata' used to commit two inodes to
stable storage.

- Combine usage of nfsd_sync_dir and write_inode_now into nfsd_sync2 taking
parent and child dentries to be committed.

- Add an arg to nfsd_setattr so that we can delay commiting changes in
situations where it might be beneficial for the caller to do so instead.
---
 fs/nfsd/nfs3proc.c       |    2 -
 fs/nfsd/nfs4proc.c       |    2 -
 fs/nfsd/nfs4recover.c    |    2 -
 fs/nfsd/nfs4state.c      |    2 -
 fs/nfsd/nfsproc.c        |    4 +-
 fs/nfsd/vfs.c            |  113 ++++++++++++++++++++++++++++++----------------
 fs/nfsd/vfs.h            |    4 +-
 include/linux/exportfs.h |    6 ++
 8 files changed, 87 insertions(+), 48 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 3d68f45..fe3af23 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -76,7 +76,7 @@ nfsd3_proc_setattr(struct svc_rqst *rqstp, struct nfsd3_sattrargs *argp,
 
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = nfsd_setattr(rqstp, &resp->fh, &argp->attrs,
-			      argp->check_guard, argp->guardtime);
+			      argp->check_guard, argp->guardtime, 0);
 	RETURN_STATUS(nfserr);
 }
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 37514c4..b6baf30 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -803,7 +803,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto out;
 	status = nfsd_setattr(rqstp, &cstate->current_fh, &setattr->sa_iattr,
-				0, (time_t)0);
+				0, (time_t)0, 0);
 out:
 	mnt_drop_write(cstate->current_fh.fh_export->ex_path.mnt);
 	return status;
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 5a754f7..4c8e1d8 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -120,7 +120,7 @@ static void
 nfsd4_sync_rec_dir(void)
 {
 	mutex_lock(&rec_dir.dentry->d_inode->i_mutex);
-	nfsd_sync_dir(rec_dir.dentry);
+	nfsd_sync2(rec_dir.dentry, NULL);
 	mutex_unlock(&rec_dir.dentry->d_inode->i_mutex);
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3a20c09..e4490b5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2290,7 +2290,7 @@ nfsd4_truncate(struct svc_rqst *rqstp, struct svc_fh *fh,
 		return 0;
 	if (!(open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
 		return nfserr_inval;
-	return nfsd_setattr(rqstp, fh, &iattr, 0, (time_t)0);
+	return nfsd_setattr(rqstp, fh, &iattr, 0, (time_t)0, 0);
 }
 
 static __be32
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index a047ad6..3ea44a3 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -69,7 +69,7 @@ nfsd_proc_setattr(struct svc_rqst *rqstp, struct nfsd_sattrargs *argp,
 		argp->attrs.ia_valid, (long) argp->attrs.ia_size);
 
 	fh_copy(&resp->fh, &argp->fh);
-	nfserr = nfsd_setattr(rqstp, &resp->fh, &argp->attrs,0, (time_t)0);
+	nfserr = nfsd_setattr(rqstp, &resp->fh, &argp->attrs,0, (time_t)0, 0);
 	return nfsd_return_attrs(nfserr, resp);
 }
 
@@ -326,7 +326,7 @@ nfsd_proc_create(struct svc_rqst *rqstp, struct nfsd_createargs *argp,
 		 */
 		attr->ia_valid &= ATTR_SIZE;
 		if (attr->ia_valid)
-			nfserr = nfsd_setattr(rqstp, newfhp, attr, 0, (time_t)0);
+			nfserr = nfsd_setattr(rqstp, newfhp, attr, 0, (time_t)0, 0);
 	}
 
 out_unlock:
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 79d216f..7ee928b 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -27,6 +27,7 @@
 #include <linux/jhash.h>
 #include <linux/ima.h>
 #include <asm/uaccess.h>
+#include <linux/exportfs.h>
 
 #ifdef CONFIG_NFSD_V3
 #include "xdr3.h"
@@ -278,7 +279,7 @@ out:
  */
 __be32
 nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
-	     int check_guard, time_t guardtime)
+	     int check_guard, time_t guardtime, int delay_sync)
 {
 	struct dentry	*dentry;
 	struct inode	*inode;
@@ -415,9 +416,10 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	}
 	if (size_change)
 		put_write_access(inode);
-	if (!err)
-		if (EX_ISSYNC(fhp->fh_export))
-			write_inode_now(inode, 1);
+	if (!err) {
+		if (EX_ISSYNC(fhp->fh_export) && !delay_sync)
+			err = nfsd_sync2(NULL, dentry);
+	}
 out:
 	return err;
 
@@ -769,24 +771,54 @@ nfsd_close(struct file *filp)
 }
 
 /*
- * Sync a directory to disk.
- *
- * We can't just call vfs_fsync because our requirements are slightly odd:
- *
- *  a) we do not have a file struct available
- *  b) we expect to have i_mutex already held by the caller
+ * Commit parent and child to stable storage.  You may pass NULL for parent or
+ * child.  This expects i_mutex to be held on the parent and not to be held on
+ * the child.
  */
 int
-nfsd_sync_dir(struct dentry *dentry)
+nfsd_sync2(struct dentry *parent, struct dentry *child)
 {
-	struct inode *inode = dentry->d_inode;
-	int error;
+	const struct export_operations *export_ops = NULL;
+	struct inode *p_inode = NULL, *c_inode = NULL;
+	int error = 0, error2 = 0;
+
+	if (parent) {
+		p_inode = parent->d_inode;
+		WARN_ON(!mutex_is_locked(&p_inode->i_mutex));
+		export_ops = parent->d_sb->s_export_op;
+	}
+	if (child) {
+		c_inode = child->d_inode;
+		WARN_ON(mutex_is_locked(&c_inode->i_mutex));
+		export_ops = child->d_sb->s_export_op;
+	}
 
-	WARN_ON(!mutex_is_locked(&inode->i_mutex));
+	if (export_ops->commit_metadata) {
+		if (parent) 
+			error = filemap_write_and_wait(p_inode->i_mapping);
+		if (child) 
+		       	error2 = filemap_write_and_wait(c_inode->i_mapping);
+
+		if (error2)
+			error = error2;
+
+		if (!error) {
+			if (child)
+				mutex_lock(&c_inode->i_mutex);
+			error = export_ops->commit_metadata(parent, child);
+			if (child)
+				mutex_unlock(&c_inode->i_mutex);
+		}
+	} else {
+		if (parent) {
+			error = filemap_write_and_wait(p_inode->i_mapping);
+			if (!error && p_inode->i_fop->fsync) 
+				error = p_inode->i_fop->fsync(NULL, parent, 0);
+		}
+		if (child)
+			write_inode_now(c_inode, 1);
+	}
 
-	error = filemap_write_and_wait(inode->i_mapping);
-	if (!error && inode->i_fop->fsync)
-		error = inode->i_fop->fsync(NULL, dentry, 0);
 	return error;
 }
 
@@ -1188,8 +1220,10 @@ nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *resfhp,
 	 */
 	if (current_fsuid() != 0)
 		iap->ia_valid &= ~(ATTR_UID|ATTR_GID);
-	if (iap->ia_valid)
-		return nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
+	if (iap->ia_valid) {
+		return nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0,
+				1 /* delay the sync. our caller does it. */);
+	}
 	return 0;
 }
 
@@ -1321,14 +1355,14 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		goto out_nfserr;
 	}
 
+	err = nfsd_create_setattr(rqstp, resfhp, iap);
 	if (EX_ISSYNC(fhp->fh_export)) {
-		err = nfserrno(nfsd_sync_dir(dentry));
-		write_inode_now(dchild->d_inode, 1);
+		err2 = nfserrno(nfsd_sync2(dentry,
+					IS_ERR(dchild) ? NULL : dchild));
+		if (err2)
+			err = err2;
 	}
 
-	err2 = nfsd_create_setattr(rqstp, resfhp, iap);
-	if (err2)
-		err = err2;
 	mnt_drop_write(fhp->fh_export->ex_path.mnt);
 	/*
 	 * Update the file handle to get the new inode info.
@@ -1358,7 +1392,6 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct dentry	*dentry, *dchild = NULL;
 	struct inode	*dirp;
 	__be32		err;
-	__be32		err2;
 	int		host_err;
 	__u32		v_mtime=0, v_atime=0;
 
@@ -1453,11 +1486,6 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (created)
 		*created = 1;
 
-	if (EX_ISSYNC(fhp->fh_export)) {
-		err = nfserrno(nfsd_sync_dir(dentry));
-		/* setattr will sync the child (or not) */
-	}
-
 	nfsd_check_ignore_resizing(iap);
 
 	if (createmode == NFS3_CREATE_EXCLUSIVE) {
@@ -1472,9 +1500,7 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
  set_attr:
-	err2 = nfsd_create_setattr(rqstp, resfhp, iap);
-	if (err2)
-		err = err2;
+	err = nfsd_create_setattr(rqstp, resfhp, iap);
 
 	mnt_drop_write(fhp->fh_export->ex_path.mnt);
 	/*
@@ -1484,6 +1510,14 @@ nfsd_create_v3(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		err = fh_update(resfhp);
 
  out:
+	if (!err) {
+		if (EX_ISSYNC(fhp->fh_export)) {
+			host_err = nfsd_sync2(created ? dentry : NULL,
+				       	!IS_ERR(dchild) ? dchild : NULL);
+			err = nfserrno(host_err);
+		}
+	}
+
 	fh_unlock(fhp);
 	if (dchild && !IS_ERR(dchild))
 		dput(dchild);
@@ -1592,7 +1626,7 @@ nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	if (!host_err) {
 		if (EX_ISSYNC(fhp->fh_export))
-			host_err = nfsd_sync_dir(dentry);
+			host_err = nfsd_sync2(dentry, NULL);
 	}
 	err = nfserrno(host_err);
 	fh_unlock(fhp);
@@ -1656,11 +1690,10 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	}
 	host_err = vfs_link(dold, dirp, dnew);
 	if (!host_err) {
+		err = 0;
 		if (EX_ISSYNC(ffhp->fh_export)) {
-			err = nfserrno(nfsd_sync_dir(ddir));
-			write_inode_now(dest, 1);
+			err = nfserrno(nfsd_sync2(ddir, dold));
 		}
-		err = 0;
 	} else {
 		if (host_err == -EXDEV && rqstp->rq_vers == 2)
 			err = nfserr_acces;
@@ -1757,9 +1790,9 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 
 	host_err = vfs_rename(fdir, odentry, tdir, ndentry);
 	if (!host_err && EX_ISSYNC(tfhp->fh_export)) {
-		host_err = nfsd_sync_dir(tdentry);
+		host_err = nfsd_sync2(tdentry, NULL);
 		if (!host_err)
-			host_err = nfsd_sync_dir(fdentry);
+			host_err = nfsd_sync2(fdentry, NULL);
 	}
 
 	mnt_drop_write(ffhp->fh_export->ex_path.mnt);
@@ -1843,7 +1876,7 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	if (host_err)
 		goto out_drop;
 	if (EX_ISSYNC(fhp->fh_export))
-		host_err = nfsd_sync_dir(dentry);
+		host_err = nfsd_sync2(dentry, NULL);
 
 out_drop:
 	mnt_drop_write(fhp->fh_export->ex_path.mnt);
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 4b1de0a..3a439da 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -41,7 +41,7 @@ __be32		 nfsd_lookup_dentry(struct svc_rqst *, struct svc_fh *,
 				const char *, unsigned int,
 				struct svc_export **, struct dentry **);
 __be32		nfsd_setattr(struct svc_rqst *, struct svc_fh *,
-				struct iattr *, int, time_t);
+				struct iattr *, int, time_t, int);
 int nfsd_mountpoint(struct dentry *, struct svc_export *);
 #ifdef CONFIG_NFSD_V4
 __be32          nfsd4_set_nfs4_acl(struct svc_rqst *, struct svc_fh *,
@@ -91,7 +91,7 @@ __be32		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
 int		nfsd_notify_change(struct inode *, struct iattr *);
 __be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
 				struct dentry *, int);
-int		nfsd_sync_dir(struct dentry *dp);
+int		nfsd_sync2(struct dentry *parent, struct dentry *child);
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 struct posix_acl *nfsd_get_posix_acl(struct svc_fh *, int);
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index dc12f41..d30dbe1 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -96,6 +96,7 @@ struct fid {
  * @fh_to_parent:   find the implied object's parent and get a dentry for it
  * @get_name:       find the name for a given inode in a given directory
  * @get_parent:     find the parent of a given directory
+ * @commit_metadata: commit metadata changes to stable storage
  *
  * See Documentation/filesystems/nfs/Exporting for details on how to use
  * this interface correctly.
@@ -137,6 +138,10 @@ struct fid {
  *    is also a directory.  In the event that it cannot be found, or storage
  *    space cannot be allocated, a %ERR_PTR should be returned.
  *
+ * commit_metadata:
+ *    @commit_metadata should commit metadata changes to stable storage.
+ *    Parent or child can be NULL.
+ *
  * Locking rules:
  *    get_parent is called with child->d_inode->i_mutex down
  *    get_name is not (which is possibly inconsistent)
@@ -152,6 +157,7 @@ struct export_operations {
 	int (*get_name)(struct dentry *parent, char *name,
 			struct dentry *child);
 	struct dentry * (*get_parent)(struct dentry *child);
+	int (*commit_metadata)(struct dentry *parent, struct dentry *child);
 };
 
 extern int exportfs_encode_fh(struct dentry *dentry, struct fid *fid,

