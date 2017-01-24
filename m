Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:48264 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbdAXIWx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 03:22:53 -0500
From: Christoph Hellwig <hch@lst.de>
To: bfields@fieldses.org, jlayton@poochiereds.net
Cc: trondmy@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2] nfsd: special case truncates some more
Date: Tue, 24 Jan 2017 09:22:41 +0100
Message-Id: <1485246161-20874-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both the NFS protocols and the Linux VFS use a setattr operation with a
bitmap of attributs to set to set various file attributes including the
file size and the uid/gid.

The Linux syscalls never mixe size updates with unrelated updates like
the uid/gid, and some file systems like XFS and GFS2 rely on the fact
that truncates might not update random other attributes, and many
other file systems handle the case but do not update the different
attributes in the same transaction.  NFSD on the other hand passes
the attributes it gets on the wire more or less directly through to
the VFS, leading to updates the file systems don't expect.  XFS at
least has an assert on the allowed attributes, which cought an NFS
client sets the size and group at the same time.

To handles this issue properly this switches nfsd to call vfs_truncate
for size changes, and then handling all other attributes through
notify_change.  As a side effect this also means less boilerplace
code around the size change as we can now reuse the VFS code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---

Changes since V1:
 - avoid an extra setattr just for a MTIME attribute on the wire

 fs/nfsd/vfs.c | 97 +++++++++++++++++++++++------------------------------------
 1 file changed, 37 insertions(+), 60 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 26c6fdb..e91107a 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -332,37 +332,6 @@ nfsd_sanitize_attrs(struct inode *inode, struct iattr *iap)
 	}
 }
 
-static __be32
-nfsd_get_write_access(struct svc_rqst *rqstp, struct svc_fh *fhp,
-		struct iattr *iap)
-{
-	struct inode *inode = d_inode(fhp->fh_dentry);
-	int host_err;
-
-	if (iap->ia_size < inode->i_size) {
-		__be32 err;
-
-		err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
-				NFSD_MAY_TRUNC | NFSD_MAY_OWNER_OVERRIDE);
-		if (err)
-			return err;
-	}
-
-	host_err = get_write_access(inode);
-	if (host_err)
-		goto out_nfserrno;
-
-	host_err = locks_verify_truncate(inode, NULL, iap->ia_size);
-	if (host_err)
-		goto out_put_write_access;
-	return 0;
-
-out_put_write_access:
-	put_write_access(inode);
-out_nfserrno:
-	return nfserrno(host_err);
-}
-
 /*
  * Set various file attributes.  After this call fhp needs an fh_put.
  */
@@ -377,7 +346,6 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	__be32		err;
 	int		host_err;
 	bool		get_write_count;
-	int		size_change = 0;
 
 	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
 		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
@@ -390,11 +358,11 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	/* Get inode */
 	err = fh_verify(rqstp, fhp, ftype, accmode);
 	if (err)
-		goto out;
+		return err;
 	if (get_write_count) {
 		host_err = fh_want_write(fhp);
 		if (host_err)
-			return nfserrno(host_err);
+			goto out_host_err;
 	}
 
 	dentry = fhp->fh_dentry;
@@ -405,50 +373,59 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 		iap->ia_valid &= ~ATTR_MODE;
 
 	if (!iap->ia_valid)
-		goto out;
+		return 0;
 
 	nfsd_sanitize_attrs(inode, iap);
 
+	if (check_guard && guardtime != inode->i_ctime.tv_sec)
+		return nfserr_notsync;
+
 	/*
 	 * The size case is special, it changes the file in addition to the
-	 * attributes.
+	 * attributes, and file systems don't expect it to be mixed with
+	 * "random" attribute changes.  We thus split out the size change
+	 * into a separate calo for vfs_truncate, and do the rest as a
+	 * a separate setattr call.
 	 */
 	if (iap->ia_valid & ATTR_SIZE) {
-		err = nfsd_get_write_access(rqstp, fhp, iap);
-		if (err)
-			goto out;
-		size_change = 1;
+		struct path path = {
+			.mnt	= fhp->fh_export->ex_path.mnt,
+			.dentry	= dentry,
+		};
+		bool implicit_mtime = false;
 
 		/*
-		 * RFC5661, Section 18.30.4:
-		 *   Changing the size of a file with SETATTR indirectly
-		 *   changes the time_modify and change attributes.
-		 *
-		 * (and similar for the older RFCs)
+		 * vfs_truncate implicity updates the mtime IFF the file size
+		 * actually changes.  Avoid the additional seattr call below if
+		 * the only other attribute that the client sends is the mtime.
 		 */
-		if (iap->ia_size != i_size_read(inode))
-			iap->ia_valid |= ATTR_MTIME;
-	}
+		if (iap->ia_size != i_size_read(inode) &&
+		    ((iap->ia_valid & ~(ATTR_SIZE | ATTR_MTIME)) == 0))
+			implicit_mtime = true;
 
-	iap->ia_valid |= ATTR_CTIME;
+		host_err = vfs_truncate(&path, iap->ia_size);
+		if (host_err)
+			goto out_host_err;
 
-	if (check_guard && guardtime != inode->i_ctime.tv_sec) {
-		err = nfserr_notsync;
-		goto out_put_write_access;
+		iap->ia_valid &= ~ATTR_SIZE;
+		if (implicit_mtime)
+			iap->ia_valid &= ~ATTR_MTIME;
+		if (!iap->ia_valid)
+			goto done;
 	}
 
+	iap->ia_valid |= ATTR_CTIME;
+
 	fh_lock(fhp);
 	host_err = notify_change(dentry, iap, NULL);
 	fh_unlock(fhp);
-	err = nfserrno(host_err);
+	if (host_err)
+		goto out_host_err;
 
-out_put_write_access:
-	if (size_change)
-		put_write_access(inode);
-	if (!err)
-		err = nfserrno(commit_metadata(fhp));
-out:
-	return err;
+done:
+	host_err = commit_metadata(fhp);
+out_host_err:
+	return nfserrno(host_err);
 }
 
 #if defined(CONFIG_NFSD_V4)
-- 
2.1.4

