Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:60064 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933184AbaFIPso (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jun 2014 11:48:44 -0400
Received: by mail-ig0-f181.google.com with SMTP id h3so3998144igd.8
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jun 2014 08:48:44 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH v3 4/7] nfs: remove unused writeverf code
Date: Mon,  9 Jun 2014 11:48:36 -0400
Message-Id: <1402328919-5065-5-git-send-email-dros@primarydata.com>
In-Reply-To: <1402328919-5065-1-git-send-email-dros@primarydata.com>
References: <1402328919-5065-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove duplicate writeverf structure from merge of nfs_pgio_header and
nfs_pgio_data and remove writeverf related flags and logic to handle
more than one RPC per nfs_pgio_header.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/blocklayout/blocklayout.c |  2 +-
 fs/nfs/direct.c                  | 25 ++++++++-----------------
 fs/nfs/internal.h                |  1 +
 fs/nfs/objlayout/objlayout.c     |  4 ++--
 fs/nfs/pagelist.c                |  2 +-
 fs/nfs/write.c                   | 27 +++++----------------------
 include/linux/nfs_xdr.h          |  3 ---
 7 files changed, 18 insertions(+), 46 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index c3ccfe4..04ac32b 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -445,7 +445,7 @@ static void bl_end_par_io_write(void *data, int num_se)
 	}
 
 	hdr->task.tk_status = hdr->pnfs_error;
-	hdr->writeverf.committed = NFS_FILE_SYNC;
+	hdr->verf.committed = NFS_FILE_SYNC;
 	INIT_WORK(&hdr->task.u.tk_work, bl_write_cleanup);
 	schedule_work(&hdr->task.u.tk_work);
 }
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e4f7f82..2732f49 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -878,7 +878,7 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 {
 	struct nfs_direct_req *dreq = hdr->dreq;
 	struct nfs_commit_info cinfo;
-	int bit = -1;
+	bool request_commit = false;
 	struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 
 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags))
@@ -892,27 +892,20 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 		dreq->flags = 0;
 		dreq->error = hdr->error;
 	}
-	if (dreq->error != 0)
-		bit = NFS_IOHDR_ERROR;
-	else {
+	if (dreq->error == 0) {
 		dreq->count += hdr->good_bytes;
-		if (test_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags)) {
-			dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
-			bit = NFS_IOHDR_NEED_RESCHED;
-		} else if (test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags)) {
+		if (nfs_write_need_commit(hdr)) {
 			if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES)
-				bit = NFS_IOHDR_NEED_RESCHED;
+				request_commit = true;
 			else if (dreq->flags == 0) {
 				nfs_direct_set_hdr_verf(dreq, hdr);
-				bit = NFS_IOHDR_NEED_COMMIT;
+				request_commit = true;
 				dreq->flags = NFS_ODIRECT_DO_COMMIT;
 			} else if (dreq->flags == NFS_ODIRECT_DO_COMMIT) {
-				if (nfs_direct_set_or_cmp_hdr_verf(dreq, hdr)) {
+				request_commit = true;
+				if (nfs_direct_set_or_cmp_hdr_verf(dreq, hdr))
 					dreq->flags =
 						NFS_ODIRECT_RESCHED_WRITES;
-					bit = NFS_IOHDR_NEED_RESCHED;
-				} else
-					bit = NFS_IOHDR_NEED_COMMIT;
 			}
 		}
 	}
@@ -923,9 +916,7 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 
 		req = nfs_list_entry(hdr->pages.next);
 		nfs_list_remove_request(req);
-		switch (bit) {
-		case NFS_IOHDR_NEED_RESCHED:
-		case NFS_IOHDR_NEED_COMMIT:
+		if (request_commit) {
 			kref_get(&req->wb_kref);
 			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
 			do_destroy = false;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8174227..f3b672b 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -443,6 +443,7 @@ int nfs_scan_commit(struct inode *inode, struct list_head *dst,
 void nfs_mark_request_commit(struct nfs_page *req,
 			     struct pnfs_layout_segment *lseg,
 			     struct nfs_commit_info *cinfo);
+int nfs_write_need_commit(struct nfs_pgio_header *);
 int nfs_generic_commit_list(struct inode *inode, struct list_head *head,
 			    int how, struct nfs_commit_info *cinfo);
 void nfs_retry_commit(struct list_head *page_list,
diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
index 8631278..697a16d 100644
--- a/fs/nfs/objlayout/objlayout.c
+++ b/fs/nfs/objlayout/objlayout.c
@@ -328,7 +328,7 @@ objlayout_write_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 	oir->status = hdr->task.tk_status = status;
 	if (status >= 0) {
 		hdr->res.count = status;
-		hdr->writeverf.committed = oir->committed;
+		hdr->verf.committed = oir->committed;
 	} else {
 		hdr->pnfs_error = status;
 	}
@@ -336,7 +336,7 @@ objlayout_write_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
 	/* must not use oir after this point */
 
 	dprintk("%s: Return status %zd committed %d sync=%d\n", __func__,
-		status, hdr->writeverf.committed, sync);
+		status, hdr->verf.committed, sync);
 
 	if (sync)
 		pnfs_ld_write_done(hdr);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 176adfd..6ff7797 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -545,7 +545,7 @@ static void nfs_pgio_rpcsetup(struct nfs_pgio_header *hdr,
 	hdr->res.fattr   = &hdr->fattr;
 	hdr->res.count   = count;
 	hdr->res.eof     = 0;
-	hdr->res.verf    = &hdr->writeverf;
+	hdr->res.verf    = &hdr->verf;
 	nfs_fattr_init(&hdr->fattr);
 }
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0094994..1baca45 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -595,12 +595,11 @@ nfs_clear_request_commit(struct nfs_page *req)
 	}
 }
 
-static inline
 int nfs_write_need_commit(struct nfs_pgio_header *hdr)
 {
-	if (hdr->writeverf.committed == NFS_DATA_SYNC)
+	if (hdr->verf.committed == NFS_DATA_SYNC)
 		return hdr->lseg == NULL;
-	return hdr->writeverf.committed != NFS_FILE_SYNC;
+	return hdr->verf.committed != NFS_FILE_SYNC;
 }
 
 #else
@@ -626,7 +625,6 @@ nfs_clear_request_commit(struct nfs_page *req)
 {
 }
 
-static inline
 int nfs_write_need_commit(struct nfs_pgio_header *hdr)
 {
 	return 0;
@@ -654,11 +652,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 			nfs_context_set_write_error(req->wb_context, hdr->error);
 			goto remove_req;
 		}
-		if (test_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags)) {
-			nfs_mark_request_dirty(req);
-			goto next;
-		}
-		if (test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags)) {
+		if (nfs_write_need_commit(hdr)) {
 			memcpy(&req->wb_verf, &hdr->verf.verifier, sizeof(req->wb_verf));
 			nfs_mark_request_commit(req, hdr->lseg, &cinfo);
 			goto next;
@@ -668,7 +662,7 @@ remove_req:
 next:
 		nfs_unlock_request(req);
 		nfs_end_page_writeback(req);
-		do_destroy = !test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags);
+		do_destroy = !nfs_write_need_commit(hdr);
 		nfs_release_request(req);
 	}
 out:
@@ -1086,18 +1080,7 @@ void nfs_commit_prepare(struct rpc_task *task, void *calldata)
 
 static void nfs_writeback_release_common(struct nfs_pgio_header *hdr)
 {
-	int status = hdr->task.tk_status;
-
-	if ((status >= 0) && nfs_write_need_commit(hdr)) {
-		spin_lock(&hdr->lock);
-		if (test_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags))
-			; /* Do nothing */
-		else if (!test_and_set_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags))
-			memcpy(&hdr->verf, &hdr->writeverf, sizeof(hdr->verf));
-		else if (memcmp(&hdr->verf, &hdr->writeverf, sizeof(hdr->verf)))
-			set_bit(NFS_IOHDR_NEED_RESCHED, &hdr->flags);
-		spin_unlock(&hdr->lock);
-	}
+	/* do nothing! */
 }
 
 /*
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index efeaf76..e1b7b3b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1253,8 +1253,6 @@ enum {
 	NFS_IOHDR_ERROR = 0,
 	NFS_IOHDR_EOF,
 	NFS_IOHDR_REDO,
-	NFS_IOHDR_NEED_COMMIT,
-	NFS_IOHDR_NEED_RESCHED,
 };
 
 struct nfs_pgio_header {
@@ -1284,7 +1282,6 @@ struct nfs_pgio_header {
 	 */
 	struct rpc_task		task;
 	struct nfs_fattr	fattr;
-	struct nfs_writeverf	writeverf;	/* Used for writes */
 	struct nfs_pgio_args	args;		/* argument struct */
 	struct nfs_pgio_res	res;		/* result struct */
 	unsigned long		timestamp;	/* For lease renewal */
-- 
1.8.5.2 (Apple Git-48)

