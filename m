Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33983 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727870AbeHOAPG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Aug 2018 20:15:06 -0400
Received: by mail-io0-f194.google.com with SMTP id l7-v6so19793798ioj.1
        for <linux-nfs@vger.kernel.org>; Tue, 14 Aug 2018 14:26:00 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Jia-Ju Bai <baijiaju1990@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix locking in pnfs_generic_recover_commit_reqs
Date: Tue, 14 Aug 2018 17:25:37 -0400
Message-Id: <20180814212537.76245-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The use of the inode->i_lock was converted to a mutex, but we forgot
to remove the old inode unlock/lock() pair that allowed the layout
segment to be put inside the loop.

Reported-by: Jia-Ju Bai <baijiaju1990@gmail.com>
Fixes: e824f99adaaf1 ("NFSv4: Use a mutex to protect the per-inode commit...")
Cc: stable@vger.kernel.org # v4.14+
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs_nfs.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 32ba2d471853..d5e4d3cd8c7f 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -61,7 +61,7 @@ EXPORT_SYMBOL_GPL(pnfs_generic_commit_release);
 
 /* The generic layer is about to remove the req from the commit list.
  * If this will make the bucket empty, it will need to put the lseg reference.
- * Note this must be called holding i_lock
+ * Note this must be called holding nfsi->commit_mutex
  */
 void
 pnfs_generic_clear_request_commit(struct nfs_page *req,
@@ -149,9 +149,7 @@ void pnfs_generic_recover_commit_reqs(struct list_head *dst,
 		if (list_empty(&b->written)) {
 			freeme = b->wlseg;
 			b->wlseg = NULL;
-			spin_unlock(&cinfo->inode->i_lock);
 			pnfs_put_lseg(freeme);
-			spin_lock(&cinfo->inode->i_lock);
 			goto restart;
 		}
 	}
@@ -167,7 +165,7 @@ static void pnfs_generic_retry_commit(struct nfs_commit_info *cinfo, int idx)
 	LIST_HEAD(pages);
 	int i;
 
-	spin_lock(&cinfo->inode->i_lock);
+	mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
 	for (i = idx; i < fl_cinfo->nbuckets; i++) {
 		bucket = &fl_cinfo->buckets[i];
 		if (list_empty(&bucket->committing))
@@ -177,12 +175,12 @@ static void pnfs_generic_retry_commit(struct nfs_commit_info *cinfo, int idx)
 		list_for_each(pos, &bucket->committing)
 			cinfo->ds->ncommitting--;
 		list_splice_init(&bucket->committing, &pages);
-		spin_unlock(&cinfo->inode->i_lock);
+		mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
 		nfs_retry_commit(&pages, freeme, cinfo, i);
 		pnfs_put_lseg(freeme);
-		spin_lock(&cinfo->inode->i_lock);
+		mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
 	}
-	spin_unlock(&cinfo->inode->i_lock);
+	mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
 }
 
 static unsigned int
@@ -222,13 +220,13 @@ void pnfs_fetch_commit_bucket_list(struct list_head *pages,
 	struct list_head *pos;
 
 	bucket = &cinfo->ds->buckets[data->ds_commit_index];
-	spin_lock(&cinfo->inode->i_lock);
+	mutex_lock(&NFS_I(cinfo->inode)->commit_mutex);
 	list_for_each(pos, &bucket->committing)
 		cinfo->ds->ncommitting--;
 	list_splice_init(&bucket->committing, pages);
 	data->lseg = bucket->clseg;
 	bucket->clseg = NULL;
-	spin_unlock(&cinfo->inode->i_lock);
+	mutex_unlock(&NFS_I(cinfo->inode)->commit_mutex);
 
 }
 
-- 
2.17.1
