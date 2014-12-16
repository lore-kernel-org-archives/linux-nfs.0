Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:47100 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbaLPTCI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:08 -0500
Received: by mail-pd0-f170.google.com with SMTP id v10so14398492pde.15
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:08 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 02/50] pnfs: Do not grab the commit_info lock twice when rescheduling writes
Date: Tue, 16 Dec 2014 11:01:05 -0800
Message-Id: <1418756513-95187-3-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Acked-by: Jeff Layton <jlayton@primarydata.com>
Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/direct.c     | 19 +++++++++++++++----
 fs/nfs/pnfs.h       | 15 ---------------
 fs/nfs/pnfs_nfsio.c | 15 ++++++++-------
 3 files changed, 23 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 10bf072..e84f764 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -573,6 +573,20 @@ out:
 	return result;
 }
 
+static void
+nfs_direct_write_scan_commit_list(struct inode *inode,
+				  struct list_head *list,
+				  struct nfs_commit_info *cinfo)
+{
+	spin_lock(cinfo->lock);
+#ifdef CONFIG_NFS_V4_1
+	if (cinfo->ds != NULL && cinfo->ds->nwritten != 0)
+		NFS_SERVER(inode)->pnfs_curr_ld->recover_commit_reqs(list, cinfo);
+#endif
+	nfs_scan_commit_list(&cinfo->mds->list, list, cinfo, 0);
+	spin_unlock(cinfo->lock);
+}
+
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 {
 	struct nfs_pageio_descriptor desc;
@@ -582,10 +596,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	LIST_HEAD(failed);
 
 	nfs_init_cinfo_from_dreq(&cinfo, dreq);
-	pnfs_recover_commit_reqs(dreq->inode, &reqs, &cinfo);
-	spin_lock(cinfo.lock);
-	nfs_scan_commit_list(&cinfo.mds->list, &reqs, &cinfo, 0);
-	spin_unlock(cinfo.lock);
+	nfs_direct_write_scan_commit_list(dreq->inode, &reqs, &cinfo);
 
 	dreq->count = 0;
 	get_dreq(dreq);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 88eede0..f666bc6 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -375,15 +375,6 @@ pnfs_scan_commit_lists(struct inode *inode, struct nfs_commit_info *cinfo,
 		return NFS_SERVER(inode)->pnfs_curr_ld->scan_commit_lists(cinfo, max);
 }
 
-static inline void
-pnfs_recover_commit_reqs(struct inode *inode, struct list_head *list,
-			 struct nfs_commit_info *cinfo)
-{
-	if (cinfo->ds == NULL || cinfo->ds->nwritten == 0)
-		return;
-	NFS_SERVER(inode)->pnfs_curr_ld->recover_commit_reqs(list, cinfo);
-}
-
 static inline struct nfs_page *
 pnfs_search_commit_reqs(struct inode *inode, struct nfs_commit_info *cinfo,
 			struct page *page)
@@ -554,12 +545,6 @@ pnfs_scan_commit_lists(struct inode *inode, struct nfs_commit_info *cinfo,
 	return 0;
 }
 
-static inline void
-pnfs_recover_commit_reqs(struct inode *inode, struct list_head *list,
-			 struct nfs_commit_info *cinfo)
-{
-}
-
 static inline struct nfs_page *
 pnfs_search_commit_reqs(struct inode *inode, struct nfs_commit_info *cinfo,
 			struct page *page)
diff --git a/fs/nfs/pnfs_nfsio.c b/fs/nfs/pnfs_nfsio.c
index e5f841c..fd2a2f0 100644
--- a/fs/nfs/pnfs_nfsio.c
+++ b/fs/nfs/pnfs_nfsio.c
@@ -66,7 +66,7 @@ EXPORT_SYMBOL_GPL(pnfs_generic_commit_release);
 
 /* The generic layer is about to remove the req from the commit list.
  * If this will make the bucket empty, it will need to put the lseg reference.
- * Note this is must be called holding the inode (/cinfo) lock
+ * Note this must be called holding the inode (/cinfo) lock
  */
 void
 pnfs_generic_clear_request_commit(struct nfs_page *req,
@@ -115,7 +115,6 @@ pnfs_generic_transfer_commit_list(struct list_head *src, struct list_head *dst,
 	return ret;
 }
 
-/* Note called with cinfo->lock held. */
 static int
 pnfs_generic_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
 				 struct nfs_commit_info *cinfo,
@@ -125,6 +124,7 @@ pnfs_generic_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
 	struct list_head *dst = &bucket->committing;
 	int ret;
 
+	lockdep_assert_held(cinfo->lock);
 	ret = pnfs_generic_transfer_commit_list(src, dst, cinfo, max);
 	if (ret) {
 		cinfo->ds->nwritten -= ret;
@@ -138,14 +138,15 @@ pnfs_generic_scan_ds_commit_list(struct pnfs_commit_bucket *bucket,
 	return ret;
 }
 
-/* Move reqs from written to committing lists, returning count of number moved.
- * Note called with cinfo->lock held.
+/* Move reqs from written to committing lists, returning count
+ * of number moved.
  */
 int pnfs_generic_scan_commit_lists(struct nfs_commit_info *cinfo,
 				   int max)
 {
 	int i, rv = 0, cnt;
 
+	lockdep_assert_held(cinfo->lock);
 	for (i = 0; i < cinfo->ds->nbuckets && max != 0; i++) {
 		cnt = pnfs_generic_scan_ds_commit_list(&cinfo->ds->buckets[i],
 						       cinfo, max);
@@ -156,7 +157,7 @@ int pnfs_generic_scan_commit_lists(struct nfs_commit_info *cinfo,
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_scan_commit_lists);
 
-/* Pull everything off the committing lists and dump into @dst */
+/* Pull everything off the committing lists and dump into @dst.  */
 void pnfs_generic_recover_commit_reqs(struct list_head *dst,
 				      struct nfs_commit_info *cinfo)
 {
@@ -164,8 +165,8 @@ void pnfs_generic_recover_commit_reqs(struct list_head *dst,
 	struct pnfs_layout_segment *freeme;
 	int i;
 
+	lockdep_assert_held(cinfo->lock);
 restart:
-	spin_lock(cinfo->lock);
 	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
 		if (pnfs_generic_transfer_commit_list(&b->written, dst,
 						      cinfo, 0)) {
@@ -173,11 +174,11 @@ restart:
 			b->wlseg = NULL;
 			spin_unlock(cinfo->lock);
 			pnfs_put_lseg(freeme);
+			spin_lock(cinfo->lock);
 			goto restart;
 		}
 	}
 	cinfo->ds->nwritten = 0;
-	spin_unlock(cinfo->lock);
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_recover_commit_reqs);
 
-- 
1.9.3

