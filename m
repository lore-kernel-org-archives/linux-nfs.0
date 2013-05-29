Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:4891 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933570Ab3E2UF2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 May 2013 16:05:28 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] NFSv4: Remove redundant check for FMODE_EXEC in nfs_finish_open
Date: Wed, 29 May 2013 16:05:21 -0400
Message-Id: <1369857925-42068-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We already check the EXEC access mode in the lower layers.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e093e73..bf4e5f4 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1362,13 +1362,6 @@ static int nfs_finish_open(struct nfs_open_context *ctx,
 		ctx->dentry = dget(dentry);
 	}
 
-	/* If the open_intent is for execute, we have an extra check to make */
-	if (ctx->mode & FMODE_EXEC) {
-		err = nfs_may_open(dentry->d_inode, ctx->cred, open_flags);
-		if (err < 0)
-			goto out;
-	}
-
 	err = finish_open(file, dentry, do_open, opened);
 	if (err)
 		goto out;
-- 
1.8.1.4

