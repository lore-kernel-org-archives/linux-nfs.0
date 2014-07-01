Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f180.google.com ([209.85.160.180]:39624 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030325AbaGAW14 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2014 18:27:56 -0400
Received: by mail-yk0-f180.google.com with SMTP id 131so6058350ykp.11
        for <linux-nfs@vger.kernel.org>; Tue, 01 Jul 2014 15:27:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: Ensure that nfsd_create_setattr commits files to stable storage
Date: Tue,  1 Jul 2014 18:27:53 -0400
Message-Id: <1404253673-12676-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since nfsd_create_setattr strips the mode from the struct iattr, it
is quite possible that it will optimise away the call to nfsd_setattr
altogether.
If this is the case, then we never call commit_metadata() on the
newly created file.

Also ensure that both nfsd_setattr() and nfsd_create_setattr() fail
when the call to commit_metadata fails.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/vfs.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 140c496f612c..5fd9095268cb 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -464,7 +464,7 @@ out_put_write_access:
 	if (size_change)
 		put_write_access(inode);
 	if (!err)
-		commit_metadata(fhp);
+		err = commit_metadata(fhp);
 out:
 	return err;
 }
@@ -1121,7 +1121,8 @@ nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *resfhp,
 		iap->ia_valid &= ~(ATTR_UID|ATTR_GID);
 	if (iap->ia_valid)
 		return nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
-	return 0;
+	/* Callers expect file metadata to be committed here */
+	return commit_metadata(resfhp);
 }
 
 /* HPUX client sometimes creates a file in mode 000, and sets size to 0.
@@ -1253,9 +1254,10 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	err = nfsd_create_setattr(rqstp, resfhp, iap);
 
 	/*
-	 * nfsd_setattr already committed the child.  Transactional filesystems
-	 * had a chance to commit changes for both parent and child
-	 * simultaneously making the following commit_metadata a noop.
+	 * nfsd_create_setattr already committed the child.  Transactional
+	 * filesystems had a chance to commit changes for both parent and
+	 * child * simultaneously making the following commit_metadata a
+	 * noop.
 	 */
 	err2 = nfserrno(commit_metadata(fhp));
 	if (err2)
@@ -1426,7 +1428,8 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	err = nfsd_create_setattr(rqstp, resfhp, iap);
 
 	/*
-	 * nfsd_setattr already committed the child (and possibly also the parent).
+	 * nfsd_create_setattr already committed the child
+	 * (and possibly also the parent).
 	 */
 	if (!err)
 		err = nfserrno(commit_metadata(fhp));
-- 
1.9.3

