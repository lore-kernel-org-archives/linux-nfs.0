Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:37151 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754440AbaIOSPE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 14:15:04 -0400
Received: by mail-ig0-f182.google.com with SMTP id h18so4436171igc.15
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 11:15:03 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: stable@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 12/14] nfs: don't sleep with inode lock in lock_and_join_requests
Date: Mon, 15 Sep 2014 14:14:43 -0400
Message-Id: <1410804885-17228-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1410804885-17228-12-git-send-email-trond.myklebust@primarydata.com>
References: <1410804885-17228-1-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-2-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-3-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-4-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-5-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-6-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-7-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-8-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-9-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-10-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-11-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

commit 7c3af975257383ece54b83c0505d3e0656cb7daf upstream.

This handles the 'nonblock=false' case in nfs_lock_and_join_requests.
If the group is already locked and blocking is allowed, drop the inode lock
and wait for the group lock to be cleared before trying it all again.
This should fix warnings found in peterz's tree (sched/wait branch), where
might_sleep() checks are added to wait.[ch].

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Reviewed-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c        | 18 ++++++++++++++++++
 fs/nfs/write.c           | 12 +++++++++++-
 include/linux/nfs_page.h |  1 +
 3 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ab96711d518f..f56b6351b660 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -175,6 +175,24 @@ nfs_page_group_lock(struct nfs_page *req, bool nonblock)
 }
 
 /*
+ * nfs_page_group_lock_wait - wait for the lock to clear, but don't grab it
+ * @req - a request in the group
+ *
+ * This is a blocking call to wait for the group lock to be cleared.
+ */
+void
+nfs_page_group_lock_wait(struct nfs_page *req)
+{
+	struct nfs_page *head = req->wb_head;
+
+	WARN_ON_ONCE(head != head->wb_head);
+
+	wait_on_bit(&head->wb_flags, PG_HEADLOCK,
+		nfs_wait_bit_uninterruptible,
+		TASK_UNINTERRUPTIBLE);
+}
+
+/*
  * nfs_page_group_unlock - unlock the head of the page group
  * @req - request in group that is to be unlocked
  */
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 014d23c7d16e..ecb0f9fd5632 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -453,13 +453,23 @@ try_again:
 		return NULL;
 	}
 
-	/* lock each request in the page group */
+	/* holding inode lock, so always make a non-blocking call to try the
+	 * page group lock */
 	ret = nfs_page_group_lock(head, true);
 	if (ret < 0) {
 		spin_unlock(&inode->i_lock);
+
+		if (!nonblock && ret == -EAGAIN) {
+			nfs_page_group_lock_wait(head);
+			nfs_release_request(head);
+			goto try_again;
+		}
+
 		nfs_release_request(head);
 		return ERR_PTR(ret);
 	}
+
+	/* lock each request in the page group */
 	subreq = head;
 	do {
 		/*
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index c18c315db126..55a486421fdd 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -121,6 +121,7 @@ extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
 extern	void nfs_unlock_and_release_request(struct nfs_page *);
 extern int nfs_page_group_lock(struct nfs_page *, bool);
+extern void nfs_page_group_lock_wait(struct nfs_page *);
 extern void nfs_page_group_unlock(struct nfs_page *);
 extern bool nfs_page_group_sync_on_bit(struct nfs_page *, unsigned int);
 
-- 
1.9.3

