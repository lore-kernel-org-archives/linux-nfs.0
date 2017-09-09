Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35243 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750939AbdIIRcY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Sep 2017 13:32:24 -0400
Received: by mail-io0-f193.google.com with SMTP id d16so585080ioj.2
        for <linux-nfs@vger.kernel.org>; Sat, 09 Sep 2017 10:32:23 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Remove pnfs_generic_transfer_commit_list()
Date: Sat,  9 Sep 2017 13:32:17 -0400
Message-Id: <20170909173217.118251-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170909173217.118251-1-trond.myklebust@primarydata.com>
References: <20170909173217.118251-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's pretty much a duplicate of nfs_scan_commit_list() that also
clears the PG_COMMIT_TO_DS flag.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs_nfs.c | 43 ++-----------------------------------------
 fs/nfs/write.c    |  2 ++
 2 files changed, 4 insertions(+), 41 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index d03d836b6ee0..60da59be83b6 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -88,44 +88,6 @@ pnfs_generic_clear_request_commit(struct nfs_page *req,
 EXPORT_SYMBOL_GPL(pnfs_generic_clear_request_commit);
 
 static int
-pnfs_generic_transfer_commit_list(struct list_head *src, struct list_head *dst,
-				  struct nfs_commit_info *cinfo, int max)
-{
-	struct nfs_page *req, *tmp;
-	int ret = 0;
-
-restart:
-	list_for_each_entry_safe(req, tmp, src, wb_list) {
-		kref_get(&req->wb_kref);
-		if (!nfs_lock_request(req)) {
-			int status;
-
-			/* Prevent deadlock with nfs_lock_and_join_requests */
-			if (!list_empty(dst)) {
-				nfs_release_request(req);
-				continue;
-			}
-			/* Ensure we make progress to prevent livelock */
-			mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
-			status = nfs_wait_on_request(req);
-			nfs_release_request(req);
-			mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
-			if (status < 0)
-				break;
-			goto restart;
-		}
-		nfs_request_remove_commit_list(req, cinfo);
-		clear_bit(PG_COMMIT_TO_DS, &req->wb_flags);
-		nfs_list_add_request(req, dst);
-		ret++;
-		if ((ret == max) && !cinfo->dreq)
-			break;
-		cond_resched();
-	}
-	return ret;
-}
-
-static int
 pnfs_generic_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
 				 struct nfs_commit_info *cinfo,
 				 int max)
@@ -135,7 +97,7 @@ pnfs_generic_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
 	int ret;
 
 	lockdep_assert_held(&NFS_I(cinfo->inode)->commit_mutex);
-	ret = pnfs_generic_transfer_commit_list(src, dst, cinfo, max);
+	ret = nfs_scan_commit_list(src, dst, cinfo, max);
 	if (ret) {
 		cinfo->ds->nwritten -= ret;
 		cinfo->ds->ncommitting += ret;
@@ -180,8 +142,7 @@ void pnfs_generic_recover_commit_reqs(struct list_head *dst,
 	lockdep_assert_held(&NFS_I(cinfo->inode)->commit_mutex);
 restart:
 	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
-		nwritten = pnfs_generic_transfer_commit_list(&b->written,
-				dst, cinfo, 0);
+		nwritten = nfs_scan_commit_list(&b->written, dst, cinfo, 0);
 		if (!nwritten)
 			continue;
 		cinfo->ds->nwritten -= nwritten;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c3f627b08ec6..121218d4e5ed 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1052,6 +1052,7 @@ nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 			goto restart;
 		}
 		nfs_request_remove_commit_list(req, cinfo);
+		clear_bit(PG_COMMIT_TO_DS, &req->wb_flags);
 		nfs_list_add_request(req, dst);
 		ret++;
 		if ((ret == max) && !cinfo->dreq)
@@ -1060,6 +1061,7 @@ nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 	}
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_scan_commit_list);
 
 /*
  * nfs_scan_commit - Scan an inode for commit requests
-- 
2.13.5

