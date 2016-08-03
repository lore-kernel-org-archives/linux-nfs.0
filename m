Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35395 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758133AbcHCTFN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2016 15:05:13 -0400
Date: Wed, 3 Aug 2016 22:05:00 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] nfsd: remove some dead code in nfsd_create_locked()
Message-ID: <20160803190500.GE775@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We changed this around in f13058a93484 ('nfsd: reorganize nfsd_create')
so "dchild" can't be an error pointer any more.  Also we don't need to
test if dchild is NULL because dput has a check built-in.  Can it even
be NULL?

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c844fd6..cd628ce 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1141,7 +1141,7 @@ nfsd_create_locked(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		char *fname, int flen, struct iattr *iap,
 		int type, dev_t rdev, struct svc_fh *resfhp)
 {
-	struct dentry	*dentry, *dchild = NULL;
+	struct dentry	*dentry, *dchild;
 	struct inode	*dirp;
 	__be32		err;
 	__be32		err2;
@@ -1208,8 +1208,7 @@ nfsd_create_locked(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (!err)
 		err = fh_update(resfhp);
 out:
-	if (dchild && !IS_ERR(dchild))
-		dput(dchild);
+	dput(dchild);
 	return err;
 
 out_nfserr:
