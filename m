Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53671 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757085Ab3GQUu0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jul 2013 16:50:26 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com, Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 16/16] nfsd4: break only delegations when appropriate
Date: Wed, 17 Jul 2013 16:50:17 -0400
Message-Id: <1374094217-31493-18-git-send-email-bfields@redhat.com>
In-Reply-To: <1374094217-31493-1-git-send-email-bfields@redhat.com>
References: <1374094217-31493-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

As a temporary fix, nfsd was breaking all leases on unlink, link,
rename, and setattr.

Now that we can distinguish between leases and delegations, we can be
nicer and break only the delegations, and not bother lease-holders with
operations they don't care about.

And we get to delete some code while we're at it.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c |   27 ---------------------------
 1 file changed, 27 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 2586f6d..51a5ede 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -273,13 +273,6 @@ out:
 	return err;
 }
 
-static int nfsd_break_lease(struct inode *inode)
-{
-	if (!S_ISREG(inode->i_mode))
-		return 0;
-	return break_lease(inode, O_WRONLY | O_NONBLOCK);
-}
-
 /*
  * Commit metadata changes to stable storage.
  */
@@ -422,9 +415,6 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 
 	err = nfserr_notsync;
 	if (!check_guard || guardtime == inode->i_ctime.tv_sec) {
-		host_err = nfsd_break_lease(inode);
-		if (host_err)
-			goto out_nfserr;
 		fh_lock(fhp);
 
 		host_err = notify_change(dentry, iap, NULL);
@@ -1735,11 +1725,6 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	err = nfserr_noent;
 	if (!dold->d_inode)
 		goto out_dput;
-	host_err = nfsd_break_lease(dold->d_inode);
-	if (host_err) {
-		err = nfserrno(host_err);
-		goto out_dput;
-	}
 	host_err = vfs_link(dold, dirp, dnew, NULL);
 	if (!host_err) {
 		err = nfserrno(commit_metadata(ffhp));
@@ -1833,14 +1818,6 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	if (ffhp->fh_export->ex_path.dentry != tfhp->fh_export->ex_path.dentry)
 		goto out_dput_new;
 
-	host_err = nfsd_break_lease(odentry->d_inode);
-	if (host_err)
-		goto out_dput_new;
-	if (ndentry->d_inode) {
-		host_err = nfsd_break_lease(ndentry->d_inode);
-		if (host_err)
-			goto out_dput_new;
-	}
 	host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL);
 	if (!host_err) {
 		host_err = commit_metadata(tfhp);
@@ -1910,16 +1887,12 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	if (!type)
 		type = rdentry->d_inode->i_mode & S_IFMT;
 
-	host_err = nfsd_break_lease(rdentry->d_inode);
-	if (host_err)
-		goto out_put;
 	if (type != S_IFDIR)
 		host_err = vfs_unlink(dirp, rdentry, NULL);
 	else
 		host_err = vfs_rmdir(dirp, rdentry);
 	if (!host_err)
 		host_err = commit_metadata(fhp);
-out_put:
 	dput(rdentry);
 
 out_nfserr:
-- 
1.7.9.5

