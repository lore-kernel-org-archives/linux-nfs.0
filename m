Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:47229 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbaHHPBK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Aug 2014 11:01:10 -0400
Received: by mail-ie0-f169.google.com with SMTP id rd18so6636125iec.28
        for <linux-nfs@vger.kernel.org>; Fri, 08 Aug 2014 08:01:09 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 1/5] nfs: change nfs_page_group_lock argument
Date: Fri,  8 Aug 2014 11:00:53 -0400
Message-Id: <1407510057-6881-2-git-send-email-dros@primarydata.com>
In-Reply-To: <1407510057-6881-1-git-send-email-dros@primarydata.com>
References: <1407510057-6881-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Flip the meaning of the second argument from 'wait' to 'nonblock' to
match related functions. Update all five calls to reflect this change.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Reviewed-by: Peng Tao <tao.peng@primarydata.com>

---
 fs/nfs/pagelist.c | 11 ++++++-----
 fs/nfs/write.c    |  4 ++--
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 9425118..38eaf83 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -145,13 +145,14 @@ static int nfs_wait_bit_uninterruptible(void *word)
 /*
  * nfs_page_group_lock - lock the head of the page group
  * @req - request in group that is to be locked
+ * @nonblock - if true don't block waiting for lock
  *
  * this lock must be held if modifying the page group list
  *
  * returns result from wait_on_bit_lock: 0 on success, < 0 on error
  */
 int
-nfs_page_group_lock(struct nfs_page *req, bool wait)
+nfs_page_group_lock(struct nfs_page *req, bool nonblock)
 {
 	struct nfs_page *head = req->wb_head;
 	int ret;
@@ -162,7 +163,7 @@ nfs_page_group_lock(struct nfs_page *req, bool wait)
 		ret = wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
 			nfs_wait_bit_uninterruptible,
 			TASK_UNINTERRUPTIBLE);
-	} while (wait && ret != 0);
+	} while (!nonblock && ret != 0);
 
 	WARN_ON_ONCE(ret > 0);
 	return ret;
@@ -226,7 +227,7 @@ bool nfs_page_group_sync_on_bit(struct nfs_page *req, unsigned int bit)
 {
 	bool ret;
 
-	nfs_page_group_lock(req, true);
+	nfs_page_group_lock(req, false);
 	ret = nfs_page_group_sync_on_bit_locked(req, bit);
 	nfs_page_group_unlock(req);
 
@@ -868,7 +869,7 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	unsigned int offset, pgbase;
 	int ret;
 
-	ret = nfs_page_group_lock(req, false);
+	ret = nfs_page_group_lock(req, true);
 	if (ret < 0) {
 		desc->pg_error = ret;
 		return 0;
@@ -894,7 +895,7 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			if (desc->pg_recoalesce)
 				return 0;
 			/* retry add_request for this subreq */
-			ret = nfs_page_group_lock(req, false);
+			ret = nfs_page_group_lock(req, true);
 			if (ret < 0) {
 				desc->pg_error = ret;
 				return 0;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 1065de2..321e561 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -241,7 +241,7 @@ static bool nfs_page_group_covers_page(struct nfs_page *req)
 	unsigned int pos = 0;
 	unsigned int len = nfs_page_length(req->wb_page);
 
-	nfs_page_group_lock(req, true);
+	nfs_page_group_lock(req, false);
 
 	do {
 		tmp = nfs_page_group_search_locked(req->wb_head, pos);
@@ -479,7 +479,7 @@ try_again:
 	}
 
 	/* lock each request in the page group */
-	ret = nfs_page_group_lock(head, false);
+	ret = nfs_page_group_lock(head, true);
 	if (ret < 0)
 		return ERR_PTR(ret);
 	subreq = head;
-- 
1.8.5.2 (Apple Git-48)

