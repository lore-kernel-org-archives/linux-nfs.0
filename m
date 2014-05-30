Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:54687 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaE3A3b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2014 20:29:31 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so204032igb.2
        for <linux-nfs@vger.kernel.org>; Thu, 29 May 2014 17:29:30 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH] pNFS: Handle allocation errors correctly in objlayout_alloc_layout_hdr()
Date: Thu, 29 May 2014 20:29:18 -0400
Message-Id: <1401409758-8035-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return the NULL pointer when the allocation fails.

Cc: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/objlayout/objlayout.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 2f955f671003..765d3f54e986 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -53,10 +53,10 @@ objlayout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
 	struct objlayout *objlay;
 
 	objlay = kzalloc(sizeof(struct objlayout), gfp_flags);
-	if (objlay) {
-		spin_lock_init(&objlay->lock);
-		INIT_LIST_HEAD(&objlay->err_list);
-	}
+	if (!objlay)
+		return NULL;
+	spin_lock_init(&objlay->lock);
+	INIT_LIST_HEAD(&objlay->err_list);
 	dprintk("%s: Return %p\n", __func__, objlay);
 	return &objlay->pnfs_layout;
 }
-- 
1.9.3

