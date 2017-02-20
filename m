Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:56566 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750871AbdBTGVp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Feb 2017 01:21:45 -0500
From: Christoph Hellwig <hch@lst.de>
To: bfields@redhat.com, jlayton@poochiereds.net
Cc: linux-nfs@vger.kernel.org, stable@kernel.org
Subject: [PATCH] nfsd: special case truncates some more
Date: Mon, 20 Feb 2017 07:21:33 +0100
Message-Id: <20170220062133.26607-2-hch@lst.de>
In-Reply-To: <20170220062133.26607-1-hch@lst.de>
References: <20170220062133.26607-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both the NFS protocols and the Linux VFS use a setattr operation with a
bitmap of attributs to set to set various file attributes including the
file size and the uid/gid.

The Linux syscalls never mixes size updates with unrelated updates like
the uid/gid, and some file systems like XFS and GFS2 rely on the fact
that truncates might not update random other attributes, and many other
file systems handle the case but do not update the different attributes
in the same transaction.  NFSD on the other hand passes the attributes
it gets on the wire more or less directly through to the VFS, leading to
updates the file systems don't expect.  XFS at least has an assert on
the allowed attributes, which caught an unusual NFS client setting the
size and group at the same time.

To handle this issue properly this splits the notify_change call in
nfsd_setattr into two separate ones.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Cc: stable@kernel.org
---
 fs/nfsd/vfs.c | 59 +++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 37 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 26c6fdb4bf67..3c36ed5a1f07 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -377,7 +377,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	__be32		err;
 	int		host_err;
 	bool		get_write_count;
-	int		size_change = 0;
+	bool		size_change = (iap->ia_valid & ATTR_SIZE);
 
 	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
 		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
@@ -390,11 +390,11 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	/* Get inode */
 	err = fh_verify(rqstp, fhp, ftype, accmode);
 	if (err)
-		goto out;
+		return err;
 	if (get_write_count) {
 		host_err = fh_want_write(fhp);
 		if (host_err)
-			return nfserrno(host_err);
+			goto out;
 	}
 
 	dentry = fhp->fh_dentry;
@@ -405,20 +405,28 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
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
+	 * into a separate call to ->setattr, and do the rest as a separate
+	 * setattr call.
 	 */
-	if (iap->ia_valid & ATTR_SIZE) {
+	if (size_change) {
 		err = nfsd_get_write_access(rqstp, fhp, iap);
 		if (err)
-			goto out;
-		size_change = 1;
+			return err;
+	}
 
+	fh_lock(fhp);
+	if (size_change) {
 		/*
 		 * RFC5661, Section 18.30.4:
 		 *   Changing the size of a file with SETATTR indirectly
@@ -426,29 +434,36 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 		 *
 		 * (and similar for the older RFCs)
 		 */
-		if (iap->ia_size != i_size_read(inode))
-			iap->ia_valid |= ATTR_MTIME;
-	}
+		struct iattr size_attr = {
+			.ia_valid	= ATTR_SIZE | ATTR_CTIME | ATTR_MTIME,
+			.ia_size	= iap->ia_size,
+		};
 
-	iap->ia_valid |= ATTR_CTIME;
+		host_err = notify_change(dentry, &size_attr, NULL);
+		if (host_err)
+			goto out_unlock;
+		iap->ia_valid &= ~ATTR_SIZE;
 
-	if (check_guard && guardtime != inode->i_ctime.tv_sec) {
-		err = nfserr_notsync;
-		goto out_put_write_access;
+		/*
+		 * Avoid the additional setattr call below if the only other
+		 * attribute that the client sends is the mtime, as we update
+		 * it as part of the size change above.
+		 */
+		if ((iap->ia_valid & ~ATTR_MTIME) == 0)
+			goto out_unlock;
 	}
 
-	fh_lock(fhp);
+	iap->ia_valid |= ATTR_CTIME;
 	host_err = notify_change(dentry, iap, NULL);
-	fh_unlock(fhp);
-	err = nfserrno(host_err);
 
-out_put_write_access:
+out_unlock:
+	fh_unlock(fhp);
 	if (size_change)
 		put_write_access(inode);
-	if (!err)
-		err = nfserrno(commit_metadata(fhp));
 out:
-	return err;
+	if (!host_err)
+		host_err = commit_metadata(fhp);
+	return nfserrno(host_err);
 }
 
 #if defined(CONFIG_NFSD_V4)
-- 
2.11.0

