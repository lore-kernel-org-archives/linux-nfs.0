Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:58098 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261AbaDXSPj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 14:15:39 -0400
Received: by mail-ie0-f176.google.com with SMTP id rd18so2773098iec.35
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 11:15:38 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 02/18 v2] nfs: clean up PG_* flags
Date: Thu, 24 Apr 2014 14:15:12 -0400
Message-Id: <1398363328-7100-3-git-send-email-dros@primarydata.com>
In-Reply-To: <1398363328-7100-1-git-send-email-dros@primarydata.com>
References: <1398363328-7100-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove unused flags PG_NEED_COMMIT and PG_NEED_RESCHED.
Add comments describing how each flag is used.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 include/linux/nfs_page.h | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index dc5e71c..91ac4d4 100644
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

