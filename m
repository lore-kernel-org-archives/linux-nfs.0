Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40028 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751690AbcGVRtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2016 13:49:05 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/7] nfsd: remove redundant i_lookup check
Date: Fri, 22 Jul 2016 13:48:52 -0400
Message-Id: <1469209736-6490-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1469209736-6490-1-git-send-email-bfields@redhat.com>
References: <1469209736-6490-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I'm not sure why this was added.  It doesn't seem necessary, and no
other caller does this.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index fba8e7e521e0..7ae3b5a72a4d 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1169,9 +1169,6 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	dentry = fhp->fh_dentry;
 	dirp = d_inode(dentry);
 
-	err = nfserr_notdir;
-	if (!dirp->i_op->lookup)
-		goto out;
 	/*
 	 * Check whether the response file handle has been verified yet.
 	 * If it has, the parent directory should already be locked.
-- 
2.7.4

