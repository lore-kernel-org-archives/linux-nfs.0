Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37853 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750939AbdIIRcW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Sep 2017 13:32:22 -0400
Received: by mail-io0-f194.google.com with SMTP id 93so608187iol.4
        for <linux-nfs@vger.kernel.org>; Sat, 09 Sep 2017 10:32:22 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: nfs_lock_and_join_requests and nfs_scan_commit_list can deadlock
Date: Sat,  9 Sep 2017 13:32:16 -0400
Message-Id: <20170909173217.118251-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since the commit list is not ordered, it is possible for nfs_scan_commit_list
to hold a request that nfs_lock_and_join_requests() is waiting for, while
at the same time trying to grab a request that nfs_lock_and_join_requests
already holds.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs_nfs.c | 16 +++++++++++-----
 fs/nfs/write.c    | 15 +++++++++++----
 2 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 303ff171cb5d..d03d836b6ee0 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -91,22 +91,28 @@ static int
 pnfs_generic_transfer_commit_list(struct list_head *src, struct list_head *dst,
 				  struct nfs_commit_info *cinfo, int max)
 {
-	struct nfs_page *req;
+	struct nfs_page *req, *tmp;
 	int ret = 0;
 
-	while(!list_empty(src)) {
-		req = list_first_entry(src, struct nfs_page, wb_list);
-
+restart:
+	list_for_each_entry_safe(req, tmp, src, wb_list) {
 		kref_get(&req->wb_kref);
 		if (!nfs_lock_request(req)) {
 			int status;
+
+			/* Prevent deadlock with nfs_lock_and_join_requests */
+			if (!list_empty(dst)) {
+				nfs_release_request(req);
+				continue;
+			}
+			/* Ensure we make progress to prevent livelock */
 			mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
 			status = nfs_wait_on_request(req);
 			nfs_release_request(req);
 			mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
 			if (status < 0)
 				break;
-			continue;
+			goto restart;
 		}
 		nfs_request_remove_commit_list(req, cinfo);
 		clear_bit(PG_COMMIT_TO_DS, &req->wb_flags);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ae26775b5448..c3f627b08ec6 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1028,21 +1028,28 @@ int
 nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 		     struct nfs_commit_info *cinfo, int max)
 {
-	struct nfs_page *req;
+	struct nfs_page *req, *tmp;
 	int ret = 0;
 
-	while(!list_empty(src)) {
-		req = list_first_entry(src, struct nfs_page, wb_list);
+restart:
+	list_for_each_entry_safe(req, tmp, src, wb_list) {
 		kref_get(&req->wb_kref);
 		if (!nfs_lock_request(req)) {
 			int status;
+
+			/* Prevent deadlock with nfs_lock_and_join_requests */
+			if (!list_empty(dst)) {
+				nfs_release_request(req);
+				continue;
+			}
+			/* Ensure we make progress to prevent livelock */
 			mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
 			status = nfs_wait_on_request(req);
 			nfs_release_request(req);
 			mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
 			if (status < 0)
 				break;
-			continue;
+			goto restart;
 		}
 		nfs_request_remove_commit_list(req, cinfo);
 		nfs_list_add_request(req, dst);
-- 
2.13.5

