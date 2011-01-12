Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47788 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750741Ab1ALRgx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jan 2011 12:36:53 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] nfsd4: break lease on nfsd setattr
Date: Wed, 12 Jan 2011 12:36:48 -0500
Message-Id: <1294853809-10732-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1294853809-10732-1-git-send-email-bfields@redhat.com>
References: <1294853809-10732-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Leases (delegations) should really be broken on any metadata change, not
just on size change.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f8919f5..839ed88 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -374,14 +374,6 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 				goto out;
 		}
 
-		/*
-		 * If we are changing the size of the file, then
-		 * we need to break all leases.
-		 */
-		host_err = break_lease(inode, O_WRONLY | O_NONBLOCK);
-		if (host_err) /* ENOMEM or EWOULDBLOCK */
-			goto out_nfserr;
-
 		host_err = get_write_access(inode);
 		if (host_err)
 			goto out_nfserr;
@@ -422,7 +414,11 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 
 	err = nfserr_notsync;
 	if (!check_guard || guardtime == inode->i_ctime.tv_sec) {
+		host_err = break_lease(inode, O_WRONLY | O_NONBLOCK);
+		if (host_err)
+			goto out_nfserr;
 		fh_lock(fhp);
+
 		host_err = notify_change(dentry, iap);
 		err = nfserrno(host_err);
 		fh_unlock(fhp);
-- 
1.7.1

