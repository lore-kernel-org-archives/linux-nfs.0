Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:44669 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084AbaDXSPw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2014 14:15:52 -0400
Received: by mail-ig0-f170.google.com with SMTP id uq10so1356687igb.3
        for <linux-nfs@vger.kernel.org>; Thu, 24 Apr 2014 11:15:51 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 10/18 v2] pnfs: clean up filelayout_alloc_commit_info
Date: Thu, 24 Apr 2014 14:15:20 -0400
Message-Id: <1398363328-7100-11-git-send-email-dros@primarydata.com>
In-Reply-To: <1398363328-7100-1-git-send-email-dros@primarydata.com>
References: <1398363328-7100-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove unneeded else statement and clean up how commit info
dataserver buckets are replaced.

Suggested-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/nfs4filelayout.c | 46 ++++++++++++++++++++++++++--------------------
 1 file changed, 26 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9319427..9cea935 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -850,11 +850,15 @@ filelayout_alloc_commit_info(struct pnfs_layout_segment *lseg,
 {
 	struct nfs4_filelayout_segment *fl = FILELAYOUT_LSEG(lseg);
 	struct pnfs_commit_bucket *buckets;
-	int size;
+	int size, i;
 
 	if (fl->commit_through_mds)
 		return 0;
-	if (cinfo->ds->nbuckets != 0) {
+
+	size = (fl->stripe_type == STRIPE_SPARSE) ?
+		fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
+
+	if (cinfo->ds->nbuckets >= size) {
 		/* This assumes there is only one IOMODE_RW lseg.  What
 		 * we really want to do is have a layout_hdr level
 		 * dictionary of <multipath_list4, fh> keys, each
@@ -864,30 +868,32 @@ filelayout_alloc_commit_info(struct pnfs_layout_segment *lseg,
 		return 0;
 	}
 
-	size = (fl->stripe_type == STRIPE_SPARSE) ?
-		fl->dsaddr->ds_num : fl->dsaddr->stripe_count;
-
 	buckets = kcalloc(size, sizeof(struct pnfs_commit_bucket),
 			  gfp_flags);
 	if (!buckets)
 		return -ENOMEM;
-	else {
-		int i;
+	for (i = 0; i < size; i++) {
+		INIT_LIST_HEAD(&buckets[i].written);
+		INIT_LIST_HEAD(&buckets[i].committing);
+	}
 
-		spin_lock(cinfo->lock);
-		if (cinfo->ds->nbuckets != 0)
-			kfree(buckets);
-		else {
-			cinfo->ds->buckets = buckets;
-			cinfo->ds->nbuckets = size;
-			for (i = 0; i < size; i++) {
-				INIT_LIST_HEAD(&buckets[i].written);
-				INIT_LIST_HEAD(&buckets[i].committing);
-			}
-		}
-		spin_unlock(cinfo->lock);
-		return 0;
+	spin_lock(cinfo->lock);
+	if (cinfo->ds->nbuckets >= size)
+		goto out;
+	for (i = 0; i < cinfo->ds->nbuckets; i++) {
+		list_splice(&cinfo->ds->buckets[i].written,
+			    &buckets[i].written);
+		list_splice(&cinfo->ds->buckets[i].committing,
+			    &buckets[i].committing);
+		buckets[i].wlseg = cinfo->ds->buckets[i].wlseg;
+		buckets[i].clseg = cinfo->ds->buckets[i].clseg;
 	}
+	swap(cinfo->ds->buckets, buckets);
+	cinfo->ds->nbuckets = size;
+out:
+	spin_unlock(cinfo->lock);
+	kfree(buckets);
+	return 0;
 }
 
 static struct pnfs_layout_segment *
-- 
1.8.5.2 (Apple Git-48)

