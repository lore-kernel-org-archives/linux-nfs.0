Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:54427 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbaGCLy1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2014 07:54:27 -0400
Received: by mail-qc0-f172.google.com with SMTP id o8so79428qcw.17
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jul 2014 04:54:26 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH] nfsd: properly convert return from commit_metadata to __be32
Date: Thu,  3 Jul 2014 07:54:19 -0400
Message-Id: <1404388459-32288-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 2a7420c03e504 (nfsd: Ensure that nfsd_create_setattr commits
files to stable storage), added a couple of calls to commit_metadata,
but doesn't convert their return codes to __be32 in the appropriate
places.

Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/vfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index e1b792ada45b..f501a9b5c9df 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -463,7 +463,7 @@ out_put_write_access:
 	if (size_change)
 		put_write_access(inode);
 	if (!err)
-		err = commit_metadata(fhp);
+		err = nfserrno(commit_metadata(fhp));
 out:
 	return err;
 }
@@ -1122,7 +1122,7 @@ nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *resfhp,
 	if (iap->ia_valid)
 		return nfsd_setattr(rqstp, resfhp, iap, 0, (time_t)0);
 	/* Callers expect file metadata to be committed here */
-	return commit_metadata(resfhp);
+	return nfserrno(commit_metadata(resfhp));
 }
 
 /* HPUX client sometimes creates a file in mode 000, and sets size to 0.
-- 
1.9.3

