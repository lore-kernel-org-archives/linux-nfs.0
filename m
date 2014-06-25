Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37584 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756853AbaFYOMb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jun 2014 10:12:31 -0400
Received: by mail-ig0-f174.google.com with SMTP id l13so6037851iga.7
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jun 2014 07:12:30 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH] nfs: get rid of duplicate dprintk
Date: Wed, 25 Jun 2014 10:12:22 -0400
Message-Id: <1403705542-8623-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This was introduced by a merge error with my recent pgio patchset.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/read.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index b1532b7..beff276 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -115,12 +115,6 @@ static void nfs_readpage_release(struct nfs_page *req)
 
 		unlock_page(req->wb_page);
 	}
-
-	dprintk("NFS: read done (%s/%Lu %d@%Ld)\n",
-			req->wb_context->dentry->d_inode->i_sb->s_id,
-			(unsigned long long)NFS_FILEID(req->wb_context->dentry->d_inode),
-			req->wb_bytes,
-			(long long)req_offset(req));
 	nfs_release_request(req);
 }
 
-- 
1.8.5.2 (Apple Git-48)

