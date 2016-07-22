Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40090 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753183AbcGVRtG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2016 13:49:06 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/7] nfsd: remove unnecessary positive-dentry check
Date: Fri, 22 Jul 2016 13:48:54 -0400
Message-Id: <1469209736-6490-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1469209736-6490-1-git-send-email-bfields@redhat.com>
References: <1469209736-6490-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

vfs_{create,mkdir,mknod} each begin with a call to may_create(), which
returns EEXIST if the object already exists.

This check is therefore unnecessary.

(In the NFSv2 case, nfsd_proc_create also has such a check.  Contrary to
RFC 1094, our code seems to believe that a CREATE of an existing file
should succeed.  I'm leaving that behavior alone.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 9c7830cdaeda..d45b39b408a1 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1157,17 +1157,7 @@ nfsd_create_locked(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		err = nfserr_io;
 		goto out;
 	}
-	/*
-	 * Make sure the child dentry is still negative ...
-	 */
-	err = nfserr_exist;
-	if (d_really_is_positive(dchild)) {
-		dprintk("nfsd_create: dentry %pd/%pd not negative!\n",
-			dentry, dchild);
-		goto out; 
-	}
 
-	/* Now let's see if we actually have permissions to create */
 	err = nfsd_permission(rqstp, fhp->fh_export, dentry, NFSD_MAY_CREATE);
 	if (err)
 		goto out;
-- 
2.7.4

