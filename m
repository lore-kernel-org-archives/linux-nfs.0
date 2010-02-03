From: Ben Myers <bpm@sgi.com>
Subject: [RFC PATCH 3/4] If 'wsync' call vfs_fsync() instead of
	write_inode_now().
Date: Wed, 03 Feb 2010 17:44:39 -0600
Message-ID: <20100203234439.17677.552.stgit@case>
References: <20100203233755.17677.96582.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:60454 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757779Ab0BCXol (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Feb 2010 18:44:41 -0500
Received: from snoot.americas.sgi.com (case.americas.sgi.com [128.162.244.182])
	by relay1.corp.sgi.com (Postfix) with ESMTP id 625CC8F8033
	for <linux-nfs@vger.kernel.org>; Wed,  3 Feb 2010 15:44:40 -0800 (PST)
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by snoot.americas.sgi.com (Postfix) with ESMTP id AE24A48D6BF8
	for <linux-nfs@vger.kernel.org>; Wed,  3 Feb 2010 17:44:39 -0600 (CST)
In-Reply-To: <20100203233755.17677.96582.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


---
 fs/nfsd/vfs.c |   25 ++++++++++++++++++++-----
 1 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 1a64fb6..89eb1b2 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -415,9 +415,16 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 	}
 	if (size_change)
 		put_write_access(inode);
-	if (!err)
-		if (EX_ISSYNC(fhp->fh_export))
-			write_inode_now(inode, 1);
+	if (!err) {
+		if (EX_ISSYNC(fhp->fh_export)) {
+			if (EX_ISWSYNC(fhp->fh_export)) {
+				vfs_fsync(NULL, dentry, 0);
+			} else {
+				write_inode_now(inode, 1);
+			}
+		}
+	}
+
 out:
 	return err;
 
@@ -1323,7 +1330,11 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	if (EX_ISSYNC(fhp->fh_export)) {
 		err = nfserrno(nfsd_sync_dir(dentry, 0));
-		write_inode_now(dchild->d_inode, 1);
+		if (EX_ISWSYNC(fhp->fh_export)) {
+			vfs_fsync(NULL, dchild, 0);
+		} else {
+			write_inode_now(dchild->d_inode, 1);
+		}
 	}
 
 	err2 = nfsd_create_setattr(rqstp, resfhp, iap);
@@ -1658,7 +1669,11 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
 	if (!host_err) {
 		if (EX_ISSYNC(ffhp->fh_export)) {
 			err = nfserrno(nfsd_sync_dir(ddir, 0));
-			write_inode_now(dest, 1);
+			if (EX_ISWSYNC(ffhp->fh_export)) {
+				vfs_fsync(NULL, dold, 0);
+			} else {
+				write_inode_now(dest, 1);
+			}
 		}
 		err = 0;
 	} else {

