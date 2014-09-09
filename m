Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:61806 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047AbaIIVvv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 17:51:51 -0400
Received: by mail-ig0-f181.google.com with SMTP id h15so5342080igd.2
        for <linux-nfs@vger.kernel.org>; Tue, 09 Sep 2014 14:51:51 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH] pnfs: fix filelayout_retry_commit when idx > 0
Date: Tue,  9 Sep 2014 17:51:47 -0400
Message-Id: <1410299507-10339-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

filelayout_retry_commit was recently split out from alloc_ds_commits,
but was done in such a way that the bucket pointer always starts at
index 0 no matter what the @idx argument is set to.

The intention of the @idx argument is to retry commits starting at
bucket @idx. This is called when alloc_ds_commits fails for a bucket.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 1359c4a27393..90978075f730 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -1269,11 +1269,12 @@ filelayout_search_commit_reqs(struct nfs_commit_info *cinfo, struct page *page)
 static void filelayout_retry_commit(struct nfs_commit_info *cinfo, int idx)
 {
 	struct pnfs_ds_commit_info *fl_cinfo = cinfo->ds;
-	struct pnfs_commit_bucket *bucket = fl_cinfo->buckets;
+	struct pnfs_commit_bucket *bucket;
 	struct pnfs_layout_segment *freeme;
 	int i;
 
-	for (i = idx; i < fl_cinfo->nbuckets; i++, bucket++) {
+	for (i = idx; i < fl_cinfo->nbuckets; i++) {
+		bucket = &fl_cinfo->buckets[i];
 		if (list_empty(&bucket->committing))
 			continue;
 		nfs_retry_commit(&bucket->committing, bucket->clseg, cinfo);
-- 
1.8.5.2 (Apple Git-48)

