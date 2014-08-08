Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:51969 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756622AbaHHPPC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Aug 2014 11:15:02 -0400
Received: by mail-ig0-f176.google.com with SMTP id hn18so1176069igb.9
        for <linux-nfs@vger.kernel.org>; Fri, 08 Aug 2014 08:15:01 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 5/5] nfs: clear_request_commit while holding i_lock
Date: Fri,  8 Aug 2014 11:13:36 -0400
Message-Id: <1407510816-7002-6-git-send-email-dros@primarydata.com>
In-Reply-To: <1407510816-7002-1-git-send-email-dros@primarydata.com>
References: <1407510816-7002-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c |  5 ++---
 fs/nfs/write.c                 | 15 ++++-----------
 2 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 524e66f..1359c4a 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -1009,6 +1009,7 @@ static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
 
 /* The generic layer is about to remove the req from the commit list.
  * If this will make the bucket empty, it will need to put the lseg reference.
+ * Note this is must be called holding the inode (/cinfo) lock
  */
 static void
 filelayout_clear_request_commit(struct nfs_page *req,
@@ -1016,7 +1017,6 @@ filelayout_clear_request_commit(struct nfs_page *req,
 {
 	struct pnfs_layout_segment *freeme = NULL;
 
-	spin_lock(cinfo->lock);
 	if (!test_and_clear_bit(PG_COMMIT_TO_DS, &req->wb_flags))
 		goto out;
 	cinfo->ds->nwritten--;
@@ -1031,8 +1031,7 @@ filelayout_clear_request_commit(struct nfs_page *req,
 	}
 out:
 	nfs_request_remove_commit_list(req, cinfo);
-	spin_unlock(cinfo->lock);
-	pnfs_put_lseg(freeme);
+	pnfs_put_lseg_async(freeme);
 }
 
 static void
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ba41769..1065de2 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -404,8 +404,6 @@ nfs_destroy_unlinked_subrequests(struct nfs_page *destroy_list,
 		subreq->wb_head = subreq;
 		subreq->wb_this_page = subreq;
 
-		nfs_clear_request_commit(subreq);
-
 		/* subreq is now totally disconnected from page group or any
 		 * write / commit lists. last chance to wake any waiters */
 		nfs_unlock_request(subreq);
@@ -515,7 +513,7 @@ try_again:
 	 * Commit list removal accounting is done after locks are dropped */
 	subreq = head;
 	do {
-		nfs_list_remove_request(subreq);
+		nfs_clear_request_commit(subreq);
 		subreq = subreq->wb_this_page;
 	} while (subreq != head);
 
@@ -545,15 +543,11 @@ try_again:
 
 	nfs_page_group_unlock(head);
 
-	/* drop lock to clear_request_commit the head req and clean up
-	 * requests on destroy list */
+	/* drop lock to clean uprequests on destroy list */
 	spin_unlock(&inode->i_lock);
 
 	nfs_destroy_unlinked_subrequests(destroy_list, head);
 
-	/* clean up commit list state */
-	nfs_clear_request_commit(head);
-
 	/* still holds ref on head from nfs_page_find_head_request_locked
 	 * and still has lock on head from lock loop */
 	return head;
@@ -837,6 +831,7 @@ nfs_clear_page_commit(struct page *page)
 	dec_bdi_stat(page_file_mapping(page)->backing_dev_info, BDI_RECLAIMABLE);
 }
 
+/* Called holding inode (/cinfo) lock */
 static void
 nfs_clear_request_commit(struct nfs_page *req)
 {
@@ -846,9 +841,7 @@ nfs_clear_request_commit(struct nfs_page *req)
 
 		nfs_init_cinfo_from_inode(&cinfo, inode);
 		if (!pnfs_clear_request_commit(req, &cinfo)) {
-			spin_lock(cinfo.lock);
 			nfs_request_remove_commit_list(req, &cinfo);
-			spin_unlock(cinfo.lock);
 		}
 		nfs_clear_page_commit(req->wb_page);
 	}
@@ -1061,9 +1054,9 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 	else
 		req->wb_bytes = rqend - req->wb_offset;
 out_unlock:
-	spin_unlock(&inode->i_lock);
 	if (req)
 		nfs_clear_request_commit(req);
+	spin_unlock(&inode->i_lock);
 	return req;
 out_flushme:
 	spin_unlock(&inode->i_lock);
-- 
1.8.5.2 (Apple Git-48)

