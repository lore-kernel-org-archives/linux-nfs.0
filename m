Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f43.google.com ([209.85.220.43]:55148 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754432AbbAVXiF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 18:38:05 -0500
Received: by mail-pa0-f43.google.com with SMTP id eu11so4904353pac.2
        for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2015 15:38:04 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v5 36/51] nfs: mirroring support for direct io
Date: Thu, 22 Jan 2015 15:36:08 -0800
Message-Id: <1421969783-92997-37-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
References: <1421969783-92997-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Weston Andros Adamson <dros@primarydata.com>

The current mirroring code only notices short writes to the first
mirror. This patch keeps per-mirror byte counts and only considers
a byte to be written once all mirrors report so.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/direct.c | 71 +++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 57 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 0178d4f..651387b 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -66,6 +66,10 @@ static struct kmem_cache *nfs_direct_cachep;
 /*
  * This represents a set of asynchronous requests that we're waiting on
  */
+struct nfs_direct_mirror {
+	ssize_t count;
+};
+
 struct nfs_direct_req {
 	struct kref		kref;		/* release manager */
 
@@ -78,6 +82,10 @@ struct nfs_direct_req {
 	/* completion state */
 	atomic_t		io_count;	/* i/os we're waiting for */
 	spinlock_t		lock;		/* protect completion state */
+
+	struct nfs_direct_mirror mirrors[NFS_PAGEIO_DESCRIPTOR_MIRROR_MAX];
+	int			mirror_count;
+
 	ssize_t			count,		/* bytes actually processed */
 				bytes_left,	/* bytes left to be sent */
 				error;		/* any reported error */
@@ -108,6 +116,29 @@ static inline int put_dreq(struct nfs_direct_req *dreq)
 	return atomic_dec_and_test(&dreq->io_count);
 }
 
+static void
+nfs_direct_good_bytes(struct nfs_direct_req *dreq, struct nfs_pgio_header *hdr)
+{
+	int i;
+	ssize_t count;
+
+	WARN_ON_ONCE(hdr->pgio_mirror_idx >= dreq->mirror_count);
+
+	dreq->mirrors[hdr->pgio_mirror_idx].count += hdr->good_bytes;
+
+	if (hdr->pgio_mirror_idx == 0)
+		dreq->count += hdr->good_bytes;
+
+	/* update the dreq->count by finding the minimum agreed count from all
+	 * mirrors */
+	count = dreq->mirrors[0].count;
+
+	for (i = 1; i < dreq->mirror_count; i++)
+		count = min(count, dreq->mirrors[i].count);
+
+	dreq->count = count;
+}
+
 /*
  * nfs_direct_select_verf - select the right verifier
  * @dreq - direct request possibly spanning multiple servers
@@ -241,6 +272,18 @@ void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 	cinfo->completion_ops = &nfs_direct_commit_completion_ops;
 }
 
+static inline void nfs_direct_setup_mirroring(struct nfs_direct_req *dreq,
+					     struct nfs_pageio_descriptor *pgio,
+					     struct nfs_page *req)
+{
+	int mirror_count = 1;
+
+	if (pgio->pg_ops->pg_get_mirror_count)
+		mirror_count = pgio->pg_ops->pg_get_mirror_count(pgio, req);
+
+	dreq->mirror_count = mirror_count;
+}
+
 static inline struct nfs_direct_req *nfs_direct_req_alloc(void)
 {
 	struct nfs_direct_req *dreq;
@@ -255,6 +298,7 @@ static inline struct nfs_direct_req *nfs_direct_req_alloc(void)
 	INIT_LIST_HEAD(&dreq->mds_cinfo.list);
 	dreq->verf.committed = NFS_INVALID_STABLE_HOW;	/* not set yet */
 	INIT_WORK(&dreq->work, nfs_direct_write_schedule_work);
+	dreq->mirror_count = 1;
 	spin_lock_init(&dreq->lock);
 
 	return dreq;
@@ -360,14 +404,9 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 	spin_lock(&dreq->lock);
 	if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) && (hdr->good_bytes == 0))
 		dreq->error = hdr->error;
-	else {
-		/*
-		 * FIXME: right now this only accounts for bytes written
-		 *        to the first mirror
-		 */
-		if (hdr->pgio_mirror_idx == 0)
-			dreq->count += hdr->good_bytes;
-	}
+	else
+		nfs_direct_good_bytes(dreq, hdr);
+
 	spin_unlock(&dreq->lock);
 
 	while (!list_empty(&hdr->pages)) {
@@ -598,17 +637,23 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	LIST_HEAD(reqs);
 	struct nfs_commit_info cinfo;
 	LIST_HEAD(failed);
+	int i;
 
 	nfs_init_cinfo_from_dreq(&cinfo, dreq);
 	nfs_direct_write_scan_commit_list(dreq->inode, &reqs, &cinfo);
 
 	dreq->count = 0;
+	for (i = 0; i < dreq->mirror_count; i++)
+		dreq->mirrors[i].count = 0;
 	get_dreq(dreq);
 
 	nfs_pageio_init_write(&desc, dreq->inode, FLUSH_STABLE, false,
 			      &nfs_direct_write_completion_ops);
 	desc.pg_dreq = dreq;
 
+	req = nfs_list_entry(reqs.next);
+	nfs_direct_setup_mirroring(dreq, &desc, req);
+
 	list_for_each_entry_safe(req, tmp, &reqs, wb_list) {
 		if (!nfs_pageio_add_request(&desc, req)) {
 			nfs_list_remove_request(req);
@@ -730,12 +775,7 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 		dreq->error = hdr->error;
 	}
 	if (dreq->error == 0) {
-		/*
-		 * FIXME: right now this only accounts for bytes written
-		 *        to the first mirror
-		 */
-		if (hdr->pgio_mirror_idx == 0)
-			dreq->count += hdr->good_bytes;
+		nfs_direct_good_bytes(dreq, hdr);
 		if (nfs_write_need_commit(hdr)) {
 			if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES)
 				request_commit = true;
@@ -841,6 +881,9 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 				result = PTR_ERR(req);
 				break;
 			}
+
+			nfs_direct_setup_mirroring(dreq, &desc, req);
+
 			nfs_lock_request(req);
 			req->wb_index = pos >> PAGE_SHIFT;
 			req->wb_offset = pos & ~PAGE_MASK;
-- 
1.9.3

