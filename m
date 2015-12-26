Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:35190 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753827AbbLZXVt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:21:49 -0500
Received: by mail-io0-f175.google.com with SMTP id q126so279967032iof.2
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:21:48 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 13/14] pNFS: Add flag to track if we've called nfs4_ff_layout_stat_io_start_read/write
Date: Sat, 26 Dec 2015 18:20:59 -0500
Message-Id: <1451172060-28238-13-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451172060-28238-12-git-send-email-trond.myklebust@primarydata.com>
References: <1451172060-28238-1-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-4-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-5-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-6-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-7-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-8-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-9-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-10-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-11-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-12-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 95 +++++++++++++++++++++++++---------
 include/linux/nfs_xdr.h                |  1 +
 2 files changed, 71 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 14109a82ce84..9257679a15ba 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1279,14 +1279,31 @@ ff_layout_reset_to_mds(struct pnfs_layout_segment *lseg, int idx)
 	return ff_layout_test_devid_unavailable(node);
 }
 
-static int ff_layout_read_prepare_common(struct rpc_task *task,
-					 struct nfs_pgio_header *hdr)
+static void ff_layout_read_record_layoutstats_start(struct rpc_task *task,
+		struct nfs_pgio_header *hdr)
 {
+	if (test_and_set_bit(NFS_IOHDR_STAT, &hdr->flags))
+		return;
 	nfs4_ff_layout_stat_io_start_read(hdr->inode,
 			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
 			hdr->args.count,
 			task->tk_start);
+}
+
+static void ff_layout_read_record_layoutstats_done(struct rpc_task *task,
+		struct nfs_pgio_header *hdr)
+{
+	if (!test_and_clear_bit(NFS_IOHDR_STAT, &hdr->flags))
+		return;
+	nfs4_ff_layout_stat_io_end_read(task,
+			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
+			hdr->args.count,
+			hdr->res.count);
+}
 
+static int ff_layout_read_prepare_common(struct rpc_task *task,
+					 struct nfs_pgio_header *hdr)
+{
 	if (unlikely(test_bit(NFS_CONTEXT_BAD, &hdr->args.context->flags))) {
 		rpc_exit(task, -EIO);
 		return -EIO;
@@ -1302,6 +1319,7 @@ static int ff_layout_read_prepare_common(struct rpc_task *task,
 	}
 	hdr->pgio_done_cb = ff_layout_read_done_cb;
 
+	ff_layout_read_record_layoutstats_start(task, hdr);
 	return 0;
 }
 
@@ -1360,10 +1378,6 @@ static void ff_layout_read_call_done(struct rpc_task *task, void *data)
 
 	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
 
-	nfs4_ff_layout_stat_io_end_read(task,
-			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
-			hdr->args.count, hdr->res.count);
-
 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags) &&
 	    task->tk_status == 0) {
 		nfs4_sequence_done(task, &hdr->res.seq_res);
@@ -1378,6 +1392,7 @@ static void ff_layout_read_count_stats(struct rpc_task *task, void *data)
 {
 	struct nfs_pgio_header *hdr = data;
 
+	ff_layout_read_record_layoutstats_done(task, hdr);
 	rpc_count_iostats_metrics(task,
 	    &NFS_CLIENT(hdr->inode)->cl_metrics[NFSPROC4_CLNT_READ]);
 }
@@ -1453,14 +1468,31 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 	return 0;
 }
 
-static int ff_layout_write_prepare_common(struct rpc_task *task,
-					  struct nfs_pgio_header *hdr)
+static void ff_layout_write_record_layoutstats_start(struct rpc_task *task,
+		struct nfs_pgio_header *hdr)
 {
+	if (test_and_set_bit(NFS_IOHDR_STAT, &hdr->flags))
+		return;
 	nfs4_ff_layout_stat_io_start_write(hdr->inode,
 			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
 			hdr->args.count,
 			task->tk_start);
+}
+
+static void ff_layout_write_record_layoutstats_done(struct rpc_task *task,
+		struct nfs_pgio_header *hdr)
+{
+	if (!test_and_clear_bit(NFS_IOHDR_STAT, &hdr->flags))
+		return;
+	nfs4_ff_layout_stat_io_end_write(task,
+			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
+			hdr->args.count, hdr->res.count,
+			hdr->res.verf->committed);
+}
 
+static int ff_layout_write_prepare_common(struct rpc_task *task,
+					  struct nfs_pgio_header *hdr)
+{
 	if (unlikely(test_bit(NFS_CONTEXT_BAD, &hdr->args.context->flags))) {
 		rpc_exit(task, -EIO);
 		return -EIO;
@@ -1477,6 +1509,7 @@ static int ff_layout_write_prepare_common(struct rpc_task *task,
 		return -EAGAIN;
 	}
 
+	ff_layout_write_record_layoutstats_start(task, hdr);
 	return 0;
 }
 
@@ -1526,23 +1559,45 @@ static void ff_layout_write_count_stats(struct rpc_task *task, void *data)
 {
 	struct nfs_pgio_header *hdr = data;
 
-	nfs4_ff_layout_stat_io_end_write(task,
-			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
-			hdr->args.count, hdr->res.count,
-			hdr->res.verf->committed);
-
+	ff_layout_write_record_layoutstats_done(task, hdr);
 	rpc_count_iostats_metrics(task,
 	    &NFS_CLIENT(hdr->inode)->cl_metrics[NFSPROC4_CLNT_WRITE]);
 }
 
-static void ff_layout_commit_prepare_common(struct rpc_task *task,
+static void ff_layout_commit_record_layoutstats_start(struct rpc_task *task,
 		struct nfs_commit_data *cdata)
 {
+	if (test_and_set_bit(NFS_IOHDR_STAT, &cdata->flags))
+		return;
 	nfs4_ff_layout_stat_io_start_write(cdata->inode,
 			FF_LAYOUT_COMP(cdata->lseg, cdata->ds_commit_index),
 			0, task->tk_start);
 }
 
+static void ff_layout_commit_record_layoutstats_done(struct rpc_task *task,
+		struct nfs_commit_data *cdata)
+{
+	struct nfs_page *req;
+	__u64 count = 0;
+
+	if (!test_and_clear_bit(NFS_IOHDR_STAT, &cdata->flags))
+		return;
+
+	if (task->tk_status == 0) {
+		list_for_each_entry(req, &cdata->pages, wb_list)
+			count += req->wb_bytes;
+	}
+	nfs4_ff_layout_stat_io_end_write(task,
+			FF_LAYOUT_COMP(cdata->lseg, cdata->ds_commit_index),
+			count, count, NFS_FILE_SYNC);
+}
+
+static void ff_layout_commit_prepare_common(struct rpc_task *task,
+		struct nfs_commit_data *cdata)
+{
+	ff_layout_commit_record_layoutstats_start(task, cdata);
+}
+
 static void ff_layout_commit_prepare_v3(struct rpc_task *task, void *data)
 {
 	ff_layout_commit_prepare_common(task, data);
@@ -1569,18 +1624,8 @@ static void ff_layout_commit_done(struct rpc_task *task, void *data)
 static void ff_layout_commit_count_stats(struct rpc_task *task, void *data)
 {
 	struct nfs_commit_data *cdata = data;
-	struct nfs_page *req;
-	__u64 count = 0;
-
-	if (task->tk_status == 0) {
-		list_for_each_entry(req, &cdata->pages, wb_list)
-			count += req->wb_bytes;
-	}
-
-	nfs4_ff_layout_stat_io_end_write(task,
-			FF_LAYOUT_COMP(cdata->lseg, cdata->ds_commit_index),
-			count, count, NFS_FILE_SYNC);
 
+	ff_layout_commit_record_layoutstats_done(task, cdata);
 	rpc_count_iostats_metrics(task,
 	    &NFS_CLIENT(cdata->inode)->cl_metrics[NFSPROC4_CLNT_COMMIT]);
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 29c949bd4462..77b5bc8b5b2b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1375,6 +1375,7 @@ enum {
 	NFS_IOHDR_ERROR = 0,
 	NFS_IOHDR_EOF,
 	NFS_IOHDR_REDO,
+	NFS_IOHDR_STAT,
 };
 
 struct nfs_pgio_header {
-- 
2.5.0

