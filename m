Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:44850 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754416AbaIOSPA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 14:15:00 -0400
Received: by mail-ie0-f169.google.com with SMTP id rl12so5181806iec.28
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 11:14:59 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: stable@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 09/14] nfs: fix nonblocking calls to nfs_page_group_lock
Date: Mon, 15 Sep 2014 14:14:40 -0400
Message-Id: <1410804885-17228-10-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1410804885-17228-9-git-send-email-trond.myklebust@primarydata.com>
References: <1410804885-17228-1-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-2-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-3-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-4-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-5-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-6-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-7-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-8-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-9-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

commit bc8a309e88a86205fc3e17f06e42a2e56fc6f807 upstream.

nfs_page_group_lock was calling wait_on_bit_lock even when told not to
block. Fix by first trying test_and_set_bit, followed by wait_on_bit_lock
if and only if blocking is allowed.  Return -EAGAIN if nonblocking and the
test_and_set of the bit was already locked.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Reviewed-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index b4ebd4d7d976..c27a05c27c11 100644
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
1.9.3

