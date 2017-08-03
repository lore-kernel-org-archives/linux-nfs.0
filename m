Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:37652 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751944AbdHCNqG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:46:06 -0400
Received: by mail-it0-f68.google.com with SMTP id 77so1307905itj.4
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:46:06 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 26/28] NFS: Wait for requests that are locked on the commit list
Date: Thu,  3 Aug 2017 09:45:21 -0400
Message-Id: <20170803134523.4922-27-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-26-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
 <20170803134523.4922-3-trond.myklebust@primarydata.com>
 <20170803134523.4922-4-trond.myklebust@primarydata.com>
 <20170803134523.4922-5-trond.myklebust@primarydata.com>
 <20170803134523.4922-6-trond.myklebust@primarydata.com>
 <20170803134523.4922-7-trond.myklebust@primarydata.com>
 <20170803134523.4922-8-trond.myklebust@primarydata.com>
 <20170803134523.4922-9-trond.myklebust@primarydata.com>
 <20170803134523.4922-10-trond.myklebust@primarydata.com>
 <20170803134523.4922-11-trond.myklebust@primarydata.com>
 <20170803134523.4922-12-trond.myklebust@primarydata.com>
 <20170803134523.4922-13-trond.myklebust@primarydata.com>
 <20170803134523.4922-14-trond.myklebust@primarydata.com>
 <20170803134523.4922-15-trond.myklebust@primarydata.com>
 <20170803134523.4922-16-trond.myklebust@primarydata.com>
 <20170803134523.4922-17-trond.myklebust@primarydata.com>
 <20170803134523.4922-18-trond.myklebust@primarydata.com>
 <20170803134523.4922-19-trond.myklebust@primarydata.com>
 <20170803134523.4922-20-trond.myklebust@primarydata.com>
 <20170803134523.4922-21-trond.myklebust@primarydata.com>
 <20170803134523.4922-22-trond.myklebust@primarydata.com>
 <20170803134523.4922-23-trond.myklebust@primarydata.com>
 <20170803134523.4922-24-trond.myklebust@primarydata.com>
 <20170803134523.4922-25-trond.myklebust@primarydata.com>
 <20170803134523.4922-26-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a request is on the commit list, but is locked, we will currently skip
it, which can lead to livelocking when the commit count doesn't reduce
to zero.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c |  2 ++
 fs/nfs/pnfs_nfs.c | 18 ++++++++++++++----
 fs/nfs/write.c    | 17 +++++++++++++----
 3 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ec97c301899b..548ebc7256ff 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -434,6 +434,7 @@ void nfs_release_request(struct nfs_page *req)
 {
 	kref_put(&req->wb_kref, nfs_page_group_destroy);
 }
+EXPORT_SYMBOL_GPL(nfs_release_request);
 
 /**
  * nfs_wait_on_request - Wait for a request to complete.
@@ -452,6 +453,7 @@ nfs_wait_on_request(struct nfs_page *req)
 	return wait_on_bit_io(&req->wb_flags, PG_BUSY,
 			      TASK_UNINTERRUPTIBLE);
 }
+EXPORT_SYMBOL_GPL(nfs_wait_on_request);
 
 /*
  * nfs_generic_pg_test - determine if requests can be coalesced
diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 4b0a809653d1..303ff171cb5d 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -91,13 +91,23 @@ static int
 pnfs_generic_transfer_commit_list(struct list_head *src, struct list_head *dst,
 				  struct nfs_commit_info *cinfo, int max)
 {
-	struct nfs_page *req, *tmp;
+	struct nfs_page *req;
 	int ret = 0;
 
-	list_for_each_entry_safe(req, tmp, src, wb_list) {
-		if (!nfs_lock_request(req))
-			continue;
+	while(!list_empty(src)) {
+		req = list_first_entry(src, struct nfs_page, wb_list);
+
 		kref_get(&req->wb_kref);
+		if (!nfs_lock_request(req)) {
+			int status;
+			mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
+			status = nfs_wait_on_request(req);
+			nfs_release_request(req);
+			mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
+			if (status < 0)
+				break;
+			continue;
+		}
 		nfs_request_remove_commit_list(req, cinfo);
 		clear_bit(PG_COMMIT_TO_DS, &req->wb_flags);
 		nfs_list_add_request(req, dst);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 866702823869..5dd3b212376e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1030,13 +1030,22 @@ int
 nfs_scan_commit_list(struct list_head *src, struct list_head *dst,
 		     struct nfs_commit_info *cinfo, int max)
 {
-	struct nfs_page *req, *tmp;
+	struct nfs_page *req;
 	int ret = 0;
 
-	list_for_each_entry_safe(req, tmp, src, wb_list) {
-		if (!nfs_lock_request(req))
-			continue;
+	while(!list_empty(src)) {
+		req = list_first_entry(src, struct nfs_page, wb_list);
 		kref_get(&req->wb_kref);
+		if (!nfs_lock_request(req)) {
+			int status;
+			mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
+			status = nfs_wait_on_request(req);
+			nfs_release_request(req);
+			mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
+			if (status < 0)
+				break;
+			continue;
+		}
 		nfs_request_remove_commit_list(req, cinfo);
 		nfs_list_add_request(req, dst);
 		ret++;
-- 
2.13.3

