Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:37537 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758643AbaDVV3T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 17:29:19 -0400
Received: by mail-ig0-f175.google.com with SMTP id h3so3558293igd.8
        for <linux-nfs@vger.kernel.org>; Tue, 22 Apr 2014 14:29:18 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH 14/17] pnfs: support multiple verfs per direct req
Date: Tue, 22 Apr 2014 17:29:22 -0400
Message-Id: <1398202165-78897-15-git-send-email-dros@primarydata.com>
In-Reply-To: <1398202165-78897-1-git-send-email-dros@primarydata.com>
References: <1398202165-78897-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support direct requests that span multiple pnfs data servers by
comparing nfs_pgio_header->verf to a cached verf in pnfs_commit_bucket.
Continue to use dreq->verf if the MDS is used / non-pNFS.

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 fs/nfs/direct.c         | 84 ++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfs/nfs4filelayout.c |  3 ++
 include/linux/nfs.h     |  5 ++-
 include/linux/nfs_xdr.h |  2 ++
 4 files changed, 82 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 9d968ca..53b86e6 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -90,7 +90,7 @@ struct nfs_direct_req {
 	int			flags;
 #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
 #define NFS_ODIRECT_RESCHED_WRITES	(2)	/* write verification failed */
-	struct nfs_writeverf	verf;		/* unstable write verifier */
+	struct nfs_writeverf    verf;		/* unstable write verifier */
 };
 
 static const struct nfs_pgio_completion_ops nfs_direct_write_completion_ops;
@@ -108,6 +108,70 @@ static inline int put_dreq(struct nfs_direct_req *dreq)
 	return atomic_dec_and_test(&dreq->io_count);
 }
 
+/*
+ * nfs_direct_set_or_cmp_hdr_verf - ensure that the same verifier is used
+ *				    for all requests (to each sever) in a
+ *				    direct io request.
+ * @dreq - direct request possibly spanning multiple servers
+ * @hdr - pageio header to validate against previously seen verfs
+ *
+ * If a verf has yet to be seen for the server associated with @hdr, set
+ * the verf for that server and return 0.
+ * If a verf has been seen for this server, compare @hdr->verf to it and
+ * return the result.
+ */
+static int nfs_direct_set_or_cmp_hdr_verf(struct nfs_direct_req *dreq,
+					  struct nfs_pgio_header *hdr)
+{
+	struct nfs_writeverf *ds_verf = &dreq->verf;
+	struct nfs_client *ds_clp = hdr->data.write->ds_clp;
+	int ds_idx = hdr->data.write->ds_idx;
+
+	if (ds_clp) {
+		/* pNFS is in use, use the DS verf */
+		if (ds_idx > dreq->ds_cinfo.nbuckets)
+			WARN_ON_ONCE(1);
+		else
+			ds_verf = &dreq->ds_cinfo.buckets[ds_idx].direct_verf;
+	}
+	if (ds_verf->committed < 0) {
+		memcpy(ds_verf, hdr->verf, sizeof(struct nfs_writeverf));
+		WARN_ON_ONCE(ds_verf->committed < 0);
+		return 0;
+	}
+	return memcmp(ds_verf, hdr->verf, sizeof(struct nfs_writeverf));
+}
+
+/*
+ * nfs_direct_cmp_commit_data_verf - check that a write verifier from a commit
+ *				     matches the verifier seen on write from
+ *				     the same server.
+ * @dreq - direct request possibly spanning multiple servers
+ * @hdr - pageio header to validate against previously seen verfs
+ *
+ * This function relies on nfs_direct_set_or_cmp_hdr_verf being called at least
+ * once to set the verf for this server - this is OK because both called (and
+ * only called) in the unstable write path.
+ *
+ * Compare @hdr->verf to it and return the result.
+ */
+static int nfs_direct_cmp_commit_data_verf(struct nfs_direct_req *dreq,
+					   struct nfs_commit_data *data)
+{
+	struct nfs_writeverf *ds_verf = &dreq->verf;
+	int ds_idx = data->ds_commit_index;
+
+	if (data->ds_clp) {
+		/* pNFS is in use, use the DS verf */
+		if (ds_idx > dreq->ds_cinfo.nbuckets)
+			WARN_ON_ONCE(1);
+		else
+			ds_verf = &dreq->ds_cinfo.buckets[ds_idx].direct_verf;
+	}
+	WARN_ON_ONCE(ds_verf->committed < 0);
+	return memcmp(ds_verf, &data->verf, sizeof(struct nfs_writeverf));
+}
+
 /**
  * nfs_direct_IO - NFS address space operation for direct I/O
  * @rw: direction (read or write)
@@ -168,6 +232,7 @@ static inline struct nfs_direct_req *nfs_direct_req_alloc(void)
 	kref_get(&dreq->kref);
 	init_completion(&dreq->completion);
 	INIT_LIST_HEAD(&dreq->mds_cinfo.list);
+	dreq->verf.committed = NFS_INVALID_STABLE_HOW;	/* not set yet */
 	INIT_WORK(&dreq->work, nfs_direct_write_schedule_work);
 	spin_lock_init(&dreq->lock);
 
@@ -602,7 +667,7 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 		dprintk("NFS: %5u commit failed with error %d.\n",
 			data->task.tk_pid, status);
 		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
-	} else if (memcmp(&dreq->verf, &data->verf, sizeof(data->verf))) {
+	} else if (nfs_direct_cmp_commit_data_verf(dreq, data)) {
 		dprintk("NFS: %5u commit verify failed\n", data->task.tk_pid);
 		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
 	}
@@ -810,16 +875,13 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 		} else if (test_bit(NFS_IOHDR_NEED_COMMIT, &hdr->flags)) {
 			if (dreq->flags == NFS_ODIRECT_RESCHED_WRITES)
 				bit = NFS_IOHDR_NEED_RESCHED;
-			else if (dreq->flags == 0) {
-				memcpy(&dreq->verf, hdr->verf,
-				       sizeof(dreq->verf));
-				bit = NFS_IOHDR_NEED_COMMIT;
-				dreq->flags = NFS_ODIRECT_DO_COMMIT;
-			} else if (dreq->flags == NFS_ODIRECT_DO_COMMIT) {
-				if (memcmp(&dreq->verf, hdr->verf, sizeof(dreq->verf))) {
-					dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
+			else {
+				if (dreq->flags == 0)
+					dreq->flags = NFS_ODIRECT_DO_COMMIT;
+
+				if (nfs_direct_set_or_cmp_hdr_verf(dreq, hdr))
 					bit = NFS_IOHDR_NEED_RESCHED;
-				} else
+				else
 					bit = NFS_IOHDR_NEED_COMMIT;
 			}
 		}
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index cfd76bd..9a91f4f 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -603,6 +603,7 @@ filelayout_write_pagelist(struct nfs_write_data *data, int sync)
 	data->write_done_cb = filelayout_write_done_cb;
 	atomic_inc(&ds->ds_clp->cl_count);
 	data->ds_clp = ds->ds_clp;
+	data->ds_idx = idx;
 	fh = nfs4_fl_select_ds_fh(lseg, j);
 	if (fh)
 		data->args.fh = fh;
@@ -875,6 +876,8 @@ filelayout_alloc_commit_info(struct pnfs_layout_segment *lseg,
 	for (i = 0; i < size; i++) {
 		INIT_LIST_HEAD(&buckets[i].written);
 		INIT_LIST_HEAD(&buckets[i].committing);
+		/* mark direct verifier as unset */
+		buckets[i].direct_verf.committed = NFS_INVALID_STABLE_HOW;
 	}
 
 	spin_lock(cinfo->lock);
diff --git a/include/linux/nfs.h b/include/linux/nfs.h
index 3e794c1..610af51 100644
--- a/include/linux/nfs.h
+++ b/include/linux/nfs.h
@@ -46,6 +46,9 @@ static inline void nfs_copy_fh(struct nfs_fh *target, const struct nfs_fh *sourc
 enum nfs3_stable_how {
 	NFS_UNSTABLE = 0,
 	NFS_DATA_SYNC = 1,
-	NFS_FILE_SYNC = 2
+	NFS_FILE_SYNC = 2,
+
+	/* used by direct.c to mark verf as invalid */
+	NFS_INVALID_STABLE_HOW = -1
 };
 #endif /* _LINUX_NFS_H */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 239274d..f94d804 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1129,6 +1129,7 @@ struct pnfs_commit_bucket {
 	struct list_head committing;
 	struct pnfs_layout_segment *wlseg;
 	struct pnfs_layout_segment *clseg;
+	struct nfs_writeverf direct_verf;
 };
 
 struct pnfs_ds_commit_info {
@@ -1289,6 +1290,7 @@ struct nfs_write_data {
 	__u64			mds_offset;	/* Filelayout dense stripe */
 	struct nfs_page_array	pages;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
+	int			ds_idx;		/* ds index if ds_clp is set */
 };
 
 /* used as flag bits in nfs_pgio_header */
-- 
1.8.5.2 (Apple Git-48)

