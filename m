Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:51437 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaGLVht (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Jul 2014 17:37:49 -0400
Received: by mail-qg0-f49.google.com with SMTP id 63so2116863qgz.22
        for <linux-nfs@vger.kernel.org>; Sat, 12 Jul 2014 14:37:48 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH] NFS: Remove 2 unused variables
Date: Sat, 12 Jul 2014 17:37:44 -0400
Message-Id: <1405201064-45906-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cc: Weston Andros Adamson <dros@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/direct.c | 2 --
 fs/nfs/write.c  | 2 --
 2 files changed, 4 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 8f98138cbc43..f11b9eed0de1 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -756,7 +756,6 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 	spin_unlock(&dreq->lock);
 
 	while (!list_empty(&hdr->pages)) {
-		bool do_destroy = true;
 
 		req = nfs_list_entry(hdr->pages.next);
 		nfs_list_remove_request(req);
@@ -765,7 +764,6 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 		case NFS_IOHDR_NEED_COMMIT:
 			kref_get(&req->wb_kref);
 			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
-			do_destroy = false;
 		}
 		nfs_unlock_and_release_request(req);
 	}
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index bdc4db23951e..5e2f10304548 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -868,7 +868,6 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 {
 	struct nfs_commit_info cinfo;
 	unsigned long bytes = 0;
-	bool do_destroy;
 
 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
 		goto out;
@@ -898,7 +897,6 @@ remove_req:
 next:
 		nfs_unlock_request(req);
 		nfs_end_page_writeback(req);
-		do_destroy = !test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags);
 		nfs_release_request(req);
 	}
 out:
-- 
1.9.3

