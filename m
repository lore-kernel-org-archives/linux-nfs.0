Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:60536 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758700AbaDVV3J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 17:29:09 -0400
Received: by mail-ig0-f172.google.com with SMTP id hn18so3549806igb.17
        for <linux-nfs@vger.kernel.org>; Tue, 22 Apr 2014 14:29:08 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 07/17] nfs: page group syncing in write path
Date: Tue, 22 Apr 2014 17:29:15 -0400
Message-Id: <1398202165-78897-8-git-send-email-dros@primarydata.com>
In-Reply-To: <1398202165-78897-1-git-send-email-dros@primarydata.com>
References: <1398202165-78897-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Operations that modify state for a whole page must be syncronized across
all requests within a page group. In the write path, this is calling
end_page_writeback and removing the head request from an inode.
Both of these operations should not be called until all requests
in a page group have reached the point where they would call them.

This patch should have no effect yet since all page groups currently
have one request, but will come into play when pg_test functions are
modified to split pages into sub-page regions.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/write.c           | 29 ++++++++++++++++++++---------
 include/linux/nfs_page.h |  2 ++
 2 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d1453f2..c6f6449 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -258,12 +258,15 @@ static void nfs_set_page_writeback(struct page *page)
 	}
 }
 
-static void nfs_end_page_writeback(struct page *page)
+static void nfs_end_page_writeback(struct nfs_page *req)
 {
-	struct inode *inode = page_file_mapping(page)->host;
+	struct inode *inode = page_file_mapping(req->wb_page)->host;
 	struct nfs_server *nfss = NFS_SERVER(inode);
 
-	end_page_writeback(page);
+	if (!nfs_page_group_sync_on_bit(req, PG_WB_END))
+		return;
+
+	end_page_writeback(req->wb_page);
 	if (atomic_long_dec_return(&nfss->writeback) < NFS_CONGESTION_OFF_THRESH)
 		clear_bdi_congested(&nfss->backing_dev_info, BLK_RW_ASYNC);
 }
@@ -452,12 +455,20 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_page *head;
+
+	if (!nfs_page_group_sync_on_bit(req, PG_REMOVE))
+		return;
+
+	/* always operate on the *head* of the page group (it's what was
+	   referenced in _add_request) */
+	head = req->wb_head;
 
 	spin_lock(&inode->i_lock);
-	if (likely(!PageSwapCache(req->wb_page))) {
-		set_page_private(req->wb_page, 0);
-		ClearPagePrivate(req->wb_page);
-		clear_bit(PG_MAPPED, &req->wb_flags);
+	if (likely(!PageSwapCache(head->wb_page))) {
+		set_page_private(head->wb_page, 0);
+		ClearPagePrivate(head->wb_page);
+		clear_bit(PG_MAPPED, &head->wb_flags);
 	}
 	nfsi->npages--;
 	spin_unlock(&inode->i_lock);
@@ -654,7 +665,7 @@ remove_req:
 		nfs_inode_remove_request(req);
 next:
 		nfs_unlock_request(req);
-		nfs_end_page_writeback(req->wb_page);
+		nfs_end_page_writeback(req);
 		do_destroy = !test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags);
 		nfs_release_request(req);
 	}
@@ -1128,7 +1139,7 @@ static void nfs_redirty_request(struct nfs_page *req)
 {
 	nfs_mark_request_dirty(req);
 	nfs_unlock_request(req);
-	nfs_end_page_writeback(req->wb_page);
+	nfs_end_page_writeback(req);
 	nfs_release_request(req);
 }
 
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 56b1f1c..41ce262 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -30,6 +30,8 @@ enum {
 	PG_TEARDOWN,		/* page group sync for destroy */
 	PG_UNLOCKPAGE,		/* page group sync bit in read path */
 	PG_UPTODATE,		/* page group sync bit in read path */
+	PG_WB_END,		/* page group sync bit in write path */
+	PG_REMOVE,		/* page group sync bit in write path */
 };
 
 struct nfs_inode;
-- 
1.8.5.2 (Apple Git-48)

