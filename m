Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:59585 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754418AbaIOSO5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 14:14:57 -0400
Received: by mail-ie0-f170.google.com with SMTP id tp5so5136709ieb.1
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 11:14:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: stable@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 07/14] nfs: clear_request_commit while holding i_lock
Date: Mon, 15 Sep 2014 14:14:38 -0400
Message-Id: <1410804885-17228-8-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1410804885-17228-7-git-send-email-trond.myklebust@primarydata.com>
References: <1410804885-17228-1-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-2-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-3-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-4-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-5-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-6-git-send-email-trond.myklebust@primarydata.com>
 <1410804885-17228-7-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

commit 411a99adffb4f993eee29759f744de01487044ac upstream.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c |  5 ++---
 fs/nfs/write.c                 | 15 ++++-----------
 2 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 537e7f7a0b48..a596a1938b52 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -1015,6 +1015,7 @@ static u32 select_bucket_index(struct nfs4_filelayout_segment *fl, u32 j)
 
 /* The generic layer is about to remove the req from the commit list.
  * If this will make the bucket empty, it will need to put the lseg reference.
+ * Note this is must be called holding the inode (/cinfo) lock
  */
 static void
 filelayout_clear_request_commit(struct nfs_page *req,
@@ -1022,7 +1023,6 @@ filelayout_clear_request_commit(struct nfs_page *req,
 {
 	struct pnfs_layout_segment *freeme = NULL;
 
-	spin_lock(cinfo->lock);
 	if (!test_and_clear_bit(PG_COMMIT_TO_DS, &req->wb_flags))
 		goto out;
 	cinfo->ds->nwritten--;
@@ -1037,8 +1037,7 @@ filelayout_clear_request_commit(struct nfs_page *req,
 	}
 out:
 	nfs_request_remove_commit_list(req, cinfo);
-	spin_unlock(cinfo->lock);
-	pnfs_put_lseg(freeme);
+	pnfs_put_lseg_async(freeme);
 }
 
 static struct list_head *
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2ed54b224bf2..e3054af396e9 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -379,8 +379,6 @@ nfs_destroy_unlinked_subrequests(struct nfs_page *destroy_list,
 		subreq->wb_head = subreq;
 		subreq->wb_this_page = subreq;
 
-		nfs_clear_request_commit(subreq);
-
 		/* subreq is now totally disconnected from page group or any
 		 * write / commit lists. last chance to wake any waiters */
 		nfs_unlock_request(subreq);
@@ -490,7 +488,7 @@ try_again:
 	 * Commit list removal accounting is done after locks are dropped */
 	subreq = head;
 	do {
-		nfs_list_remove_request(subreq);
+		nfs_clear_request_commit(subreq);
 		subreq = subreq->wb_this_page;
 	} while (subreq != head);
 
@@ -520,15 +518,11 @@ try_again:
 
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
@@ -810,6 +804,7 @@ nfs_clear_page_commit(struct page *page)
 	dec_bdi_stat(page_file_mapping(page)->backing_dev_info, BDI_RECLAIMABLE);
 }
 
+/* Called holding inode (/cinfo) lock */
 static void
 nfs_clear_request_commit(struct nfs_page *req)
 {
@@ -819,9 +814,7 @@ nfs_clear_request_commit(struct nfs_page *req)
 
 		nfs_init_cinfo_from_inode(&cinfo, inode);
 		if (!pnfs_clear_request_commit(req, &cinfo)) {
-			spin_lock(cinfo.lock);
 			nfs_request_remove_commit_list(req, &cinfo);
-			spin_unlock(cinfo.lock);
 		}
 		nfs_clear_page_commit(req->wb_page);
 	}
@@ -1040,9 +1033,9 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
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
1.9.3

