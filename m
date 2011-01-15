Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48730 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431Ab1AOBEK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 20:04:10 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1PduYr-0007p2-9b
	for linux-nfs@vger.kernel.org; Fri, 14 Jan 2011 20:04:09 -0500
Date: Fri, 14 Jan 2011 20:04:09 -0500
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: don't leak dentry count on mnt_want_write failure
Message-ID: <20110115010409.GE16942@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Just noticed this--seems to be a preexisting problem.

--b.

commit 66b5bec40bae9648277cc1f708b203181065c007
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Jan 14 20:00:02 2011 -0500

    nfsd: don't leak dentry count on mnt_want_write failure
    
    The exit cleanup isn't quite right here.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a110adb..56a2b68 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1816,22 +1816,22 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 
 	host_err = mnt_want_write(fhp->fh_export->ex_path.mnt);
 	if (host_err)
-		goto out_nfserr;
+		goto out_put;
 
 	host_err = nfsd_break_lease(rdentry->d_inode);
 	if (host_err)
-		goto out_put;
+		goto out_drop_write;
 	if (type != S_IFDIR)
 		host_err = vfs_unlink(dirp, rdentry);
 	else
 		host_err = vfs_rmdir(dirp, rdentry);
-out_put:
-	dput(rdentry);
-
 	if (!host_err)
 		host_err = commit_metadata(fhp);
-
+out_drop_write:
 	mnt_drop_write(fhp->fh_export->ex_path.mnt);
+out_put:
+	dput(rdentry);
+
 out_nfserr:
 	err = nfserrno(host_err);
 out:
