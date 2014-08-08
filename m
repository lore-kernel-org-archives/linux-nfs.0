Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:35873 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663AbaHHPBL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Aug 2014 11:01:11 -0400
Received: by mail-ie0-f178.google.com with SMTP id rd18so6533789iec.9
        for <linux-nfs@vger.kernel.org>; Fri, 08 Aug 2014 08:01:10 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 2/5] nfs: fix nonblocking calls to nfs_page_group_lock
Date: Fri,  8 Aug 2014 11:00:54 -0400
Message-Id: <1407510057-6881-3-git-send-email-dros@primarydata.com>
In-Reply-To: <1407510057-6881-1-git-send-email-dros@primarydata.com>
References: <1407510057-6881-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs_page_group_lock was calling wait_on_bit_lock even when told not to
block. Fix by first trying test_and_set_bit, followed by wait_on_bit_lock
if and only if blocking is allowed.  Return -EAGAIN if nonblocking and the
test_and_set of the bit was already locked.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Reviewed-by: Peng Tao <tao.peng@primarydata.com>

---
 fs/nfs/pagelist.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 38eaf83..f393c72 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -149,24 +149,29 @@ static int nfs_wait_bit_uninterruptible(void *word)
  *
  * this lock must be held if modifying the page group list
  *
- * returns result from wait_on_bit_lock: 0 on success, < 0 on error
+ * return 0 on success, < 0 on error: -EDELAY if nonblocking or the
+ * result from wait_on_bit_lock
+ *
+ * NOTE: calling with nonblock=false should always have set the
+ *       lock bit (see fs/buffer.c and other uses of wait_on_bit_lock
+ *       with TASK_UNINTERRUPTIBLE), so there is no need to check the result.
  */
 int
 nfs_page_group_lock(struct nfs_page *req, bool nonblock)
 {
 	struct nfs_page *head = req->wb_head;
-	int ret;
 
 	WARN_ON_ONCE(head != head->wb_head);
 
-	do {
-		ret = wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
-			nfs_wait_bit_uninterruptible,
-			TASK_UNINTERRUPTIBLE);
-	} while (!nonblock && ret != 0);
+	if (!test_and_set_bit(PG_HEADLOCK, &head->wb_flags))
+		return 0;
 
-	WARN_ON_ONCE(ret > 0);
-	return ret;
+	if (!nonblock)
+		return wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
+				nfs_wait_bit_uninterruptible,
+				TASK_UNINTERRUPTIBLE);
+
+	return -EAGAIN;
 }
 
 /*
-- 
1.8.5.2 (Apple Git-48)

