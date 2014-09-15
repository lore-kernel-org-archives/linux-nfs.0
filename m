Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:62055 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754428AbaIOSO7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 14:14:59 -0400
Received: by mail-ie0-f175.google.com with SMTP id at20so5108779iec.20
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 11:14:58 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: stable@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 08/14] nfs: change nfs_page_group_lock argument
Date: Mon, 15 Sep 2014 14:14:39 -0400
Message-Id: <1410804885-17228-9-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1410804885-17228-8-git-send-email-trond.myklebust@primarydata.com>
References: <1410804885-17228-1-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-2-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-3-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-4-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-5-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-6-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-7-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-8-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

commit fd2f3a06d30c85a17cf035ebc60c88c2a13a8ece upstream.

Flip the meaning of the second argument from 'wait' to 'nonblock' to
match related functions. Update all five calls to reflect this change.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Reviewed-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 11 ++++++-----
 fs/nfs/write.c    |  4 ++--
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 6a6fd0532664..b4ebd4d7d976 100644
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
 
@@ -869,7 +870,7 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	unsigned int offset, pgbase;
 	int ret;
 
-	ret = nfs_page_group_lock(req, false);
+	ret = nfs_page_group_lock(req, true);
 	if (ret < 0) {
 		desc->pg_error = ret;
 		return 0;
@@ -895,7 +896,7 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			if (desc->pg_recoalesce)
 				return 0;
 			/* retry add_request for this subreq */
-			ret = nfs_page_group_lock(req, false);
+			ret = nfs_page_group_lock(req, true);
 			if (ret < 0) {
 				desc->pg_error = ret;
 				return 0;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e3054af396e9..c8eb14eb6659 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -216,7 +216,7 @@ static bool nfs_page_group_covers_page(struct nfs_page *req)
 	unsigned int pos = 0;
 	unsigned int len = nfs_page_length(req->wb_page);
 
-	nfs_page_group_lock(req, true);
+	nfs_page_group_lock(req, false);
 
 	do {
 		tmp = nfs_page_group_search_locked(req->wb_head, pos);
@@ -454,7 +454,7 @@ try_again:
 	}
 
 	/* lock each request in the page group */
-	ret = nfs_page_group_lock(head, false);
+	ret = nfs_page_group_lock(head, true);
 	if (ret < 0)
 		return ERR_PTR(ret);
 	subreq = head;
-- 
1.9.3

