Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35872 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567AbbKQLxt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:49 -0500
Received: by qkda6 with SMTP id a6so1677229qkd.3
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:48 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 30/38] nfsd: close cached file when underlying file systems says no such file
Date: Tue, 17 Nov 2015 06:52:52 -0500
Message-Id: <1447761180-4250-31-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Upon setattr, fallocate, read, write, commit, if underlying file system
returns EBADF or ENOENT, we should close the cached file.

This is possible on data portal when remote files are removed by other clients.

Also call .d_weak_revalidate() upon such failures and if we finds out
inode is still valid, retry above operation once. In theory we should
not see the retry but it makes code more robust, in case underlying nfsv4 state
recovery fails badly.

[jlayton: turn retry ints into bools]

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/vfs.c | 105 ++++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 83 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 5293cba6b8f8..ca6896bb25fb 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -333,6 +333,51 @@ out_nfserrno:
 	return nfserrno(host_err);
 }
 
+static void
+nfsd_close_cached_files(struct dentry *dentry)
+{
+	struct inode *inode = d_inode(dentry);
+
+	if (inode && S_ISREG(inode->i_mode))
+		nfsd_file_close_inode_sync(inode);
+}
+
+static bool
+nfsd_has_cached_files(struct dentry *dentry)
+{
+	bool		ret = false;
+	struct inode *inode = d_inode(dentry);
+
+	if (inode && S_ISREG(inode->i_mode))
+		ret = nfsd_file_is_cached(inode);
+	return ret;
+}
+
+static bool
+nfsd_cached_files_handle_vfs_error(struct dentry *dentry, int err)
+{
+	struct inode *inode = d_inode(dentry);
+
+	switch (err) {
+	case -EBADF:
+	case -ENOENT:
+	case -EOPENSTALE:
+		if (inode && S_ISREG(inode->i_mode))
+			nfsd_file_close_inode_sync(inode);
+		if (dentry->d_flags & DCACHE_OP_WEAK_REVALIDATE &&
+		    dentry->d_op->d_weak_revalidate(dentry, LOOKUP_REVAL) > 0) {
+			printk(KERN_NOTICE
+				"%s: file %s still alive!\n", __func__,
+				dentry->d_name.name);
+			return true;
+		}
+	default:
+	      break;
+	}
+
+	return false;
+}
+
 /*
  * Set various file attributes.  After this call fhp needs an fh_put.
  */
@@ -348,12 +393,14 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	int		host_err;
 	bool		get_write_count;
 	int		size_change = 0;
+	bool		retry = false;
 
 	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
 		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
 	if (iap->ia_valid & ATTR_SIZE)
 		ftype = S_IFREG;
 
+try_again:
 	/* Callers that do fh_verify should do the fh_want_write: */
 	get_write_count = !fhp->fh_dentry;
 
@@ -410,6 +457,10 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	fh_lock(fhp);
 	host_err = notify_change(dentry, iap, NULL);
 	fh_unlock(fhp);
+	if (!retry && nfsd_cached_files_handle_vfs_error(dentry, host_err)) {
+		retry = true;
+		goto try_again;
+	}
 	err = nfserrno(host_err);
 
 out_put_write_access:
@@ -466,6 +517,7 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	mutex_lock(&d_inode(dentry)->i_mutex);
 	host_error = security_inode_setsecctx(dentry, label->data, label->len);
 	mutex_unlock(&d_inode(dentry)->i_mutex);
+	nfsd_cached_files_handle_vfs_error(dentry, host_error);
 	return nfserrno(host_error);
 }
 #else
@@ -489,6 +541,7 @@ __be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (!error)
 		error = commit_metadata(fhp);
 
+	nfsd_cached_files_handle_vfs_error(fhp->fh_dentry, error);
 	return nfserrno(error);
 }
 #endif /* defined(CONFIG_NFSD_V4) */
@@ -659,7 +712,8 @@ retry:
 
 	file = dentry_open(&path, flags, current_cred());
 	if (IS_ERR(file)) {
-		if (file == ERR_PTR(-EOPENSTALE) && !retried) {
+		if (nfsd_cached_files_handle_vfs_error(path.dentry, PTR_ERR(file))
+		    && !retried) {
 			retried = true;
 			fh_put(fhp);
 			err = fh_verify(rqstp, fhp, type, may_flags);
@@ -776,7 +830,7 @@ nfsd_finish_read(struct file *file, unsigned long *count, int host_err)
 		*count = host_err;
 		fsnotify_access(file);
 		return 0;
-	} else 
+	} else
 		return nfserrno(host_err);
 }
 
@@ -930,8 +984,10 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 {
 	__be32			err;
 	struct nfsd_file	*nf;
+	int			retry = false;
 
 	trace_read_start(rqstp, fhp, offset, vlen);
+try_again:
 	err = nfsd_file_acquire(rqstp, fhp, NFSD_MAY_READ, &nf);
 	if (err == nfs_ok) {
 		trace_read_opened(rqstp, fhp, offset, vlen);
@@ -939,6 +995,11 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 					count);
 		trace_read_io_done(rqstp, fhp, offset, vlen);
 		nfsd_file_put(nf);
+		if (!retry &&
+		    nfsd_cached_files_handle_vfs_error(fhp->fh_dentry, err)) {
+			retry = true;
+			goto try_again;
+		}
 	}
 	trace_read_done(rqstp, fhp, offset, vlen);
 	return err;
@@ -955,8 +1016,10 @@ nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
 {
 	__be32			err;
 	struct nfsd_file	*nf;
+	bool			retry = false;
 
 	trace_write_start(rqstp, fhp, offset, vlen);
+try_again:
 	err = nfsd_file_acquire(rqstp, fhp, NFSD_MAY_WRITE, &nf);
 	if (err == nfs_ok) {
 		trace_write_opened(rqstp, fhp, offset, vlen);
@@ -964,6 +1027,10 @@ nfsd_write(struct svc_rqst *rqstp, struct svc_fh *fhp, loff_t offset,
 					vlen, cnt, stablep);
 		trace_write_io_done(rqstp, fhp, offset, vlen);
 		nfsd_file_put(nf);
+		if (!retry && nfsd_cached_files_handle_vfs_error(fhp->fh_dentry, err)) {
+			retry = true;
+			goto try_again;
+		}
 	}
 	trace_write_done(rqstp, fhp, offset, vlen);
 	return err;
@@ -986,6 +1053,7 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct nfsd_file	*nf;
 	loff_t			end = LLONG_MAX;
 	__be32			err = nfserr_inval;
+	bool			retry = false;
 
 	if (offset < 0)
 		goto out;
@@ -995,6 +1063,7 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			goto out;
 	}
 
+try_again:
 	err = nfsd_file_acquire(rqstp, fhp,
 			NFSD_MAY_WRITE|NFSD_MAY_NOT_BREAK_LEASE, &nf);
 	if (err)
@@ -1002,6 +1071,11 @@ nfsd_commit(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (EX_ISSYNC(fhp->fh_export)) {
 		int err2 = vfs_fsync_range(nf->nf_file, offset, end, 0);
 
+		if (!retry && nfsd_cached_files_handle_vfs_error(fhp->fh_dentry, err)) {
+			nfsd_file_put(nf);
+			retry = true;
+			goto try_again;
+		}
 		if (err2 != -EINVAL)
 			err = nfserrno(err2);
 		else
@@ -1471,7 +1545,9 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	struct inode	*dirp;
 	__be32		err;
 	int		host_err;
+	int		retry = true;
 
+try_again:
 	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_CREATE);
 	if (err)
 		goto out;
@@ -1524,6 +1600,11 @@ out_dput:
 out_unlock:
 	fh_unlock(ffhp);
 	fh_drop_write(tfhp);
+	if (!retry &&
+	    nfsd_cached_files_handle_vfs_error(tfhp->fh_dentry, host_err)) {
+		retry = true;
+		goto try_again;
+	}
 out:
 	return err;
 
@@ -1532,26 +1613,6 @@ out_nfserr:
 	goto out_unlock;
 }
 
-static void
-nfsd_close_cached_files(struct dentry *dentry)
-{
-	struct inode *inode = d_inode(dentry);
-
-	if (inode && S_ISREG(inode->i_mode))
-		nfsd_file_close_inode_sync(inode);
-}
-
-static bool
-nfsd_has_cached_files(struct dentry *dentry)
-{
-	bool		ret = false;
-	struct inode *inode = d_inode(dentry);
-
-	if (inode && S_ISREG(inode->i_mode))
-		ret = nfsd_file_is_cached(inode);
-	return ret;
-}
-
 /*
  * Rename a file
  * N.B. After this call _both_ ffhp and tfhp need an fh_put
-- 
2.4.3

