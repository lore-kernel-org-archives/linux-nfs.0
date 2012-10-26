Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34436 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966494Ab2JZVG6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Oct 2012 17:06:58 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Peter Staubach <pstaubach@exagrid.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] nfsd: assume writeable exportabled filesystems have f_sync
Date: Fri, 26 Oct 2012 17:06:56 -0400
Message-Id: <1351285617-20450-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1351285617-20450-1-git-send-email-bfields@redhat.com>
References: <1351285617-20450-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

I don't really see how you could claim to support nfsd and not support
fsync somehow.

And in practice a quick look through the exportable filesystems suggests
the only ones without an ->fsync are read-only (efs, isofs, squashfs) or
in-memory (shmem).

Also, performing a write and then returning an error if the sync fails
(as we would do here in the wgather case) seems unhelpful to clients.

Also remove an incorrect comment.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c |   13 -------------
 1 file changed, 13 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c120b48..ed3eb59 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1020,21 +1020,8 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
 	inode = dentry->d_inode;
 	exp   = fhp->fh_export;
 
-	/*
-	 * Request sync writes if
-	 *  -	the sync export option has been set, or
-	 *  -	the client requested O_SYNC behavior (NFSv3 feature).
-	 *  -   The file system doesn't support fsync().
-	 * When NFSv2 gathered writes have been configured for this volume,
-	 * flushing the data to disk is handled separately below.
-	 */
 	use_wgather = (rqstp->rq_vers == 2) && EX_WGATHER(exp);
 
-	if (!file->f_op->fsync) {/* COMMIT3 cannot work */
-	       stable = 2;
-	       *stablep = 2; /* FILE_SYNC */
-	}
-
 	if (!EX_ISSYNC(exp))
 		stable = 0;
 	if (stable && !use_wgather) {
-- 
1.7.9.5

