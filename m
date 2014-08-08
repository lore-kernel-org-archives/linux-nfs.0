Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:61388 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756256AbaHHPO7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Aug 2014 11:14:59 -0400
Received: by mail-ig0-f181.google.com with SMTP id h3so1175763igd.14
        for <linux-nfs@vger.kernel.org>; Fri, 08 Aug 2014 08:14:59 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 2/5] nfs: fix comment and add warn_on for PG_INODE_REF
Date: Fri,  8 Aug 2014 11:13:33 -0400
Message-Id: <1407510816-7002-3-git-send-email-dros@primarydata.com>
In-Reply-To: <1407510816-7002-1-git-send-email-dros@primarydata.com>
References: <1407510816-7002-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix the comment in nfs_page.h for PG_INODE_REF to reflect that it's no longer
set only on head requests. Also add a WARN_ON_ONCE in nfs_inode_remove_request
as PG_INODE_REF should always be set.

Suggested-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/write.c           | 2 ++
 include/linux/nfs_page.h | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 8d1ed2b..e6bc5b5 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -707,6 +707,8 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 
 	if (test_and_clear_bit(PG_INODE_REF, &req->wb_flags))
 		nfs_release_request(req);
+	else
+		WARN_ON_ONCE(1);
 }
 
 static void
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 291924c..6ad2bbc 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -26,7 +26,7 @@ enum {
 	PG_MAPPED,		/* page private set for buffered io */
 	PG_CLEAN,		/* write succeeded */
 	PG_COMMIT_TO_DS,	/* used by pnfs layouts */
-	PG_INODE_REF,		/* extra ref held by inode (head req only) */
+	PG_INODE_REF,		/* extra ref held by inode when in writeback */
 	PG_HEADLOCK,		/* page group lock of wb_head */
 	PG_TEARDOWN,		/* page group sync for destroy */
 	PG_UNLOCKPAGE,		/* page group sync bit in read path */
-- 
1.8.5.2 (Apple Git-48)

