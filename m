Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40088 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753366AbcGVRtG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2016 13:49:06 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/7] nfsd: clean up bad-type check in nfsd_create_locked
Date: Fri, 22 Jul 2016 13:48:55 -0400
Message-Id: <1469209736-6490-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1469209736-6490-1-git-send-email-bfields@redhat.com>
References: <1469209736-6490-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Minor cleanup, no change in behavior.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index d45b39b408a1..cd06c6511cfc 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1166,13 +1166,6 @@ nfsd_create_locked(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		iap->ia_mode = 0;
 	iap->ia_mode = (iap->ia_mode & S_IALLUGO) | type;
 
-	err = nfserr_inval;
-	if (!S_ISREG(type) && !S_ISDIR(type) && !special_file(type)) {
-		printk(KERN_WARNING "nfsd: bad file type %o in nfsd_create\n",
-		       type);
-		goto out;
-	}
-
 	err = 0;
 	host_err = 0;
 	switch (type) {
@@ -1190,6 +1183,10 @@ nfsd_create_locked(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	case S_IFSOCK:
 		host_err = vfs_mknod(dirp, dchild, iap->ia_mode, rdev);
 		break;
+	default:
+		printk(KERN_WARNING "nfsd: bad file type %o in nfsd_create\n",
+		       type);
+		host_err = -EINVAL;
 	}
 	if (host_err < 0)
 		goto out_nfserr;
-- 
2.7.4

