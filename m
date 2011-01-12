Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47790 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755396Ab1ALRgx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jan 2011 12:36:53 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd: break lease on unlink, link, and rename
Date: Wed, 12 Jan 2011 12:36:49 -0500
Message-Id: <1294853809-10732-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1294853809-10732-1-git-send-email-bfields@redhat.com>
References: <1294853809-10732-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Any change to any of the links pointing to an entry should also break
delegations.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c |   27 +++++++++++++++++++++++----
 1 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 839ed88..f31321a 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -272,6 +272,13 @@ out:
 	return err;
 }
 
+static int nfsd_break_lease(struct inode *inode)
+{
+	if (!S_ISREG(inode->i_mode))
+		return 0;
+	return break_lease(inode, O_WRONLY | O_NONBLOCK);
+}
+
 /*
  * Commit metadata changes to stable storage.
  */
@@ -414,7 +421,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 
 	err = nfserr_notsync;
 	if (!check_guard || guardtime == inode->i_ctime.tv_sec) {
-		host_err = break_lease(inode, O_WRONLY | O_NONBLOCK);
+		host_err = nfsd_break_lease(inode);
 		if (host_err)
 			goto out_nfserr;
 		fh_lock(fhp);
@@ -1641,6 +1648,12 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 		err = nfserrno(host_err);
 		goto out_dput;
 	}
+	err = nfserr_noent;
+	if (!dold->d_inode)
+		goto out_drop_write;
+	host_err = nfsd_break_lease(dold->d_inode);
+	if (host_err)
+		goto out_drop_write;
 	host_err = vfs_link(dold, dirp, dnew);
 	if (!host_err) {
 		err = nfserrno(commit_metadata(ffhp));
@@ -1652,6 +1665,7 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 		else
 			err = nfserrno(host_err);
 	}
+out_drop_write:
 	mnt_drop_write(tfhp->fh_export->ex_path.mnt);
 out_dput:
 	dput(dnew);
@@ -1733,15 +1747,17 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	if (host_err)
 		goto out_dput_new;
 
+	host_err = nfsd_break_lease(odentry->d_inode);
+	if (host_err)
+		goto out_drop_write;
 	host_err = vfs_rename(fdir, odentry, tdir, ndentry);
 	if (!host_err) {
 		host_err = commit_metadata(tfhp);
 		if (!host_err)
 			host_err = commit_metadata(ffhp);
 	}
-
+out_drop_write:
 	mnt_drop_write(ffhp->fh_export->ex_path.mnt);
-
  out_dput_new:
 	dput(ndentry);
  out_dput_old:
@@ -1804,11 +1820,14 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	if (host_err)
 		goto out_nfserr;
 
+	host_err = nfsd_break_lease(rdentry->d_inode);
+	if (host_err)
+		goto out_put;
 	if (type != S_IFDIR)
 		host_err = vfs_unlink(dirp, rdentry);
 	else
 		host_err = vfs_rmdir(dirp, rdentry);
-
+out_put:
 	dput(rdentry);
 
 	if (!host_err)
-- 
1.7.1

