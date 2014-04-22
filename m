Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:56235 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758649AbaDVV27 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 17:28:59 -0400
Received: by mail-ie0-f176.google.com with SMTP id rd18so68115iec.35
        for <linux-nfs@vger.kernel.org>; Tue, 22 Apr 2014 14:28:57 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 01/17] nfs: clean up PG_* flags
Date: Tue, 22 Apr 2014 17:29:09 -0400
Message-Id: <1398202165-78897-2-git-send-email-dros@primarydata.com>
In-Reply-To: <1398202165-78897-1-git-send-email-dros@primarydata.com>
References: <1398202165-78897-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove unused flags PG_NEED_COMMIT and PG_NEED_RESCHED.
Add comments describing how each flag is used.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 include/linux/nfs_page.h | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 92ce578..93c7293 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -22,12 +22,10 @@
  * Valid flags for a dirty buffer
  */
 enum {
-	PG_BUSY = 0,
-	PG_MAPPED,
-	PG_CLEAN,
-	PG_NEED_COMMIT,
-	PG_NEED_RESCHED,
-	PG_COMMIT_TO_DS,
+	PG_BUSY = 0,		/* nfs_{un}lock_request */
+	PG_MAPPED,		/* page private set for buffered io */
+	PG_CLEAN,		/* write succeeded */
+	PG_COMMIT_TO_DS,	/* used by pnfs layouts */
 };
 
 struct nfs_inode;
-- 
1.8.5.2 (Apple Git-48)

