Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:40715 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbaEOP5T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2014 11:57:19 -0400
Received: by mail-ig0-f173.google.com with SMTP id hn18so8099883igb.12
        for <linux-nfs@vger.kernel.org>; Thu, 15 May 2014 08:57:18 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v3 08/18] nfs: page group syncing in write path
Date: Thu, 15 May 2014 11:56:47 -0400
Message-Id: <1400169417-28245-9-git-send-email-dros@primarydata.com>
In-Reply-To: <1400169417-28245-1-git-send-email-dros@primarydata.com>
References: <1400169417-28245-1-git-send-email-dros@primarydata.com>
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
 fs/nfs/pagelist.c        |  2 ++
 fs/nfs/write.c           | 32 ++++++++++++++++++++------------
 include/linux/nfs_page.h |  2 ++
 3 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 87cdb4b..ce3faad 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -397,6 +397,8 @@ static void nfs_free_request(struct nfs_page *req)
 	WARN_ON_ONCE(test_bit(PG_TEARDOWN, &req->wb_flags));
 	WARN_ON_ONCE(test_bit(PG_UNLOCKPAGE, &req->wb_flags));
 	WARN_ON_ONCE(test_bit(PG_UPTODATE, &req->wb_flags));
+	WARN_ON_ONCE(test_bit(PG_WB_END, &req->wb_flags));
+	WARN_ON_ONCE(test_bit(PG_REMOVE, &req->wb_flags));
 
 	/* Release struct file and open context */
 	nfs_clear_request(req);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d0f30f1..5d75276 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -201,12 +201,15 @@ static void nfs_set_page_writeback(struct page *page)
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
@@ -397,15 +400,20 @@ static void nfs_inode_remove_request(struct nfs_page *req)
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_page *head;
 
-	spin_lock(&inode->i_lock);
-	if (likely(!PageSwapCache(req->wb_page))) {
-		set_page_private(req->wb_page, 0);
-		ClearPagePrivate(req->wb_page);
-		clear_bit(PG_MAPPED, &req->wb_flags);
+	if (nfs_page_group_sync_on_bit(req, PG_REMOVE)) {
+		head = req->wb_head;
+
+		spin_lock(&inode->i_lock);
+		if (likely(!PageSwapCache(head->wb_page))) {
+			set_page_private(head->wb_page, 0);
+			ClearPagePrivate(head->wb_page);
+			clear_bit(PG_MAPPED, &head->wb_flags);
+		}
+		nfsi->npages--;
+		spin_unlock(&inode->i_lock);
 	}
-	nfsi->npages--;
-	spin_unlock(&inode->i_lock);
 	nfs_release_request(req);
 }
 
@@ -599,7 +607,7 @@ remove_req:
 		nfs_inode_remove_request(req);
 next:
 		nfs_unlock_request(req);
-		nfs_end_page_writeback(req->wb_page);
+		nfs_end_page_writeback(req);
 		do_destroy = !test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags);
 		nfs_release_request(req);
 	}
@@ -964,7 +972,7 @@ static void nfs_redirty_request(struct nfs_page *req)
 {
 	nfs_mark_request_dirty(req);
 	nfs_unlock_request(req);
-	nfs_end_page_writeback(req->wb_page);
+	nfs_end_page_writeback(req);
 	nfs_release_request(req);
 }
 
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 6385175..7d9096d 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -31,6 +31,8 @@ enum {
 	PG_TEARDOWN,		/* page group sync for destroy */
 	PG_UNLOCKPAGE,		/* page group sync bit in read path */
 	PG_UPTODATE,		/* page group sync bit in read path */
+	PG_WB_END,		/* page group sync bit in write path */
+	PG_REMOVE,		/* page group sync bit in write path */
 };
 
 struct nfs_inode;
-- 
1.8.5.2 (Apple Git-48)

