Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:56601 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414AbaIOSOy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 14:14:54 -0400
Received: by mail-ie0-f172.google.com with SMTP id tr6so5078521ieb.31
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 11:14:53 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: stable@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 05/14] nfs: check wait_on_bit_lock err in page_group_lock
Date: Mon, 15 Sep 2014 14:14:36 -0400
Message-Id: <1410804885-17228-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1410804885-17228-5-git-send-email-trond.myklebust@primarydata.com>
References: <1410804885-17228-1-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-2-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-3-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-4-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

commit e7029206ff43f6cf7d6fcb741adb126f47200516 upstream.

Return errors from wait_on_bit_lock from nfs_page_group_lock.

Add a bool argument @wait to nfs_page_group_lock. If true, loop over
wait_on_bit_lock until it returns cleanly. If false, return the error
from wait_on_bit_lock.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c        | 29 +++++++++++++++++++++++------
 fs/nfs/write.c           |  6 ++++--
 include/linux/nfs_page.h |  2 +-
 3 files changed, 28 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 653017909e97..6a6fd0532664 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -147,17 +147,25 @@ static int nfs_wait_bit_uninterruptible(void *word)
  * @req - request in group that is to be locked
  *
  * this lock must be held if modifying the page group list
+ *
+ * returns result from wait_on_bit_lock: 0 on success, < 0 on error
  */
-void
-nfs_page_group_lock(struct nfs_page *req)
+int
+nfs_page_group_lock(struct nfs_page *req, bool wait)
 {
 	struct nfs_page *head = req->wb_head;
+	int ret;
 
 	WARN_ON_ONCE(head != head->wb_head);
 
-	wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
+	do {
+		ret = wait_on_bit_lock(&head->wb_flags, PG_HEADLOCK,
 			nfs_wait_bit_uninterruptible,
 			TASK_UNINTERRUPTIBLE);
+	} while (wait && ret != 0);
+
+	WARN_ON_ONCE(ret > 0);
+	return ret;
 }
 
 /*
@@ -218,7 +226,7 @@ bool nfs_page_group_sync_on_bit(struct nfs_page *req, unsigned int bit)
 {
 	bool ret;
 
-	nfs_page_group_lock(req);
+	nfs_page_group_lock(req, true);
 	ret = nfs_page_group_sync_on_bit_locked(req, bit);
 	nfs_page_group_unlock(req);
 
@@ -859,8 +867,13 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 	struct nfs_page *subreq;
 	unsigned int bytes_left = 0;
 	unsigned int offset, pgbase;
+	int ret;
 
-	nfs_page_group_lock(req);
+	ret = nfs_page_group_lock(req, false);
+	if (ret < 0) {
+		desc->pg_error = ret;
+		return 0;
+	}
 
 	subreq = req;
 	bytes_left = subreq->wb_bytes;
@@ -882,7 +895,11 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			if (desc->pg_recoalesce)
 				return 0;
 			/* retry add_request for this subreq */
-			nfs_page_group_lock(req);
+			ret = nfs_page_group_lock(req, false);
+			if (ret < 0) {
+				desc->pg_error = ret;
+				return 0;
+			}
 			continue;
 		}
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index cbd1f6402f3a..2ed54b224bf2 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -216,7 +216,7 @@ static bool nfs_page_group_covers_page(struct nfs_page *req)
 	unsigned int pos = 0;
 	unsigned int len = nfs_page_length(req->wb_page);
 
-	nfs_page_group_lock(req);
+	nfs_page_group_lock(req, true);
 
 	do {
 		tmp = nfs_page_group_search_locked(req->wb_head, pos);
@@ -456,7 +456,9 @@ try_again:
 	}
 
 	/* lock each request in the page group */
-	nfs_page_group_lock(head);
+	ret = nfs_page_group_lock(head, false);
+	if (ret < 0)
+		return ERR_PTR(ret);
 	subreq = head;
 	do {
 		/*
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index d0fae7b78252..c18c315db126 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -120,7 +120,7 @@ extern size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
 extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
 extern	void nfs_unlock_and_release_request(struct nfs_page *);
-extern void nfs_page_group_lock(struct nfs_page *);
+extern int nfs_page_group_lock(struct nfs_page *, bool);
 extern void nfs_page_group_unlock(struct nfs_page *);
 extern bool nfs_page_group_sync_on_bit(struct nfs_page *, unsigned int);
 
-- 
1.9.3

