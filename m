Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34618 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574AbbLZXVp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 26 Dec 2015 18:21:45 -0500
Received: by mail-io0-f171.google.com with SMTP id e126so280362205ioa.1
        for <linux-nfs@vger.kernel.org>; Sat, 26 Dec 2015 15:21:45 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/14] pnfs/flexfiles: count io stat in rpc_count_stats callback
Date: Sat, 26 Dec 2015 18:20:55 -0500
Message-Id: <1451172060-28238-9-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451172060-28238-8-git-send-email-trond.myklebust@primarydata.com>
References: <1451172060-28238-1-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-2-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-3-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-4-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-5-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-6-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-7-git-send-email-trond.myklebust@primarydata.com>
 <1451172060-28238-8-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

If client ever restarts IO due to some errors, we'll endup
mis-counting IO stats if we do the counting in .rpc_done
callback. Move it to .rpc_count_stats callback that is only
called when releasing RPC.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index b392156e6743..5ede5c26c757 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1516,11 +1516,6 @@ static void ff_layout_write_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs_pgio_header *hdr = data;
 
-	nfs4_ff_layout_stat_io_end_write(task,
-			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
-			hdr->args.count, hdr->res.count,
-			hdr->res.verf->committed);
-
 	if (test_bit(NFS_IOHDR_REDO, &hdr->flags) &&
 	    task->tk_status == 0) {
 		nfs4_sequence_done(task, &hdr->res.seq_res);
@@ -1535,6 +1530,11 @@ static void ff_layout_write_count_stats(struct rpc_task *task, void *data)
 {
 	struct nfs_pgio_header *hdr = data;
 
+	nfs4_ff_layout_stat_io_end_write(task,
+			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
+			hdr->args.count, hdr->res.count,
+			hdr->res.verf->committed);
+
 	rpc_count_iostats_metrics(task,
 	    &NFS_CLIENT(hdr->inode)->cl_metrics[NFSPROC4_CLNT_WRITE]);
 }
@@ -1567,6 +1567,11 @@ static void ff_layout_commit_prepare_v4(struct rpc_task *task, void *data)
 
 static void ff_layout_commit_done(struct rpc_task *task, void *data)
 {
+	pnfs_generic_write_commit_done(task, data);
+}
+
+static void ff_layout_commit_count_stats(struct rpc_task *task, void *data)
+{
 	struct nfs_commit_data *cdata = data;
 	struct nfs_page *req;
 	__u64 count = 0;
@@ -1580,13 +1585,6 @@ static void ff_layout_commit_done(struct rpc_task *task, void *data)
 			FF_LAYOUT_COMP(cdata->lseg, cdata->ds_commit_index),
 			count, count, NFS_FILE_SYNC);
 
-	pnfs_generic_write_commit_done(task, data);
-}
-
-static void ff_layout_commit_count_stats(struct rpc_task *task, void *data)
-{
-	struct nfs_commit_data *cdata = data;
-
 	rpc_count_iostats_metrics(task,
 	    &NFS_CLIENT(cdata->inode)->cl_metrics[NFSPROC4_CLNT_COMMIT]);
 }
-- 
2.5.0

