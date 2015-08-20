Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:36792 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699AbbHTXC6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 19:02:58 -0400
Received: by pdbmi9 with SMTP id mi9so19101382pdb.3
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 16:02:57 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1/pnfs Ensure flexfiles reports all connection related errors
Date: Thu, 20 Aug 2015 18:02:55 -0500
Message-Id: <1440111775-10196-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure that we also handle RPC level connection and protocol
negotiation errors.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 48 +++++++++++++++++++++++++---------
 1 file changed, 35 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 0fcb8670f25f..7e4cbdfb3713 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -967,11 +967,36 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 
 static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 					int idx, u64 offset, u64 length,
-					u32 status, int opnum)
+					u32 status, int opnum, int error)
 {
 	struct nfs4_ff_layout_mirror *mirror;
 	int err;
 
+	if (status == 0) {
+		switch (error) {
+		case -ETIMEDOUT:
+		case -EPFNOSUPPORT:
+		case -EPROTONOSUPPORT:
+		case -EOPNOTSUPP:
+		case -ECONNREFUSED:
+		case -ECONNRESET:
+		case -EHOSTDOWN:
+		case -EHOSTUNREACH:
+		case -ENETUNREACH:
+		case -EADDRINUSE:
+		case -ENOBUFS:
+		case -EPIPE:
+		case -EPERM:
+			status = NFS4ERR_NXIO;
+			break;
+		case -EACCES:
+			status = NFS4ERR_ACCESS;
+			break;
+		default:
+			return;
+		}
+	}
+
 	mirror = FF_LAYOUT_COMP(lseg, idx);
 	err = ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
 				       mirror, offset, length, status, opnum,
@@ -988,12 +1013,11 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 	int err;
 
 	trace_nfs4_pnfs_read(hdr, task->tk_status);
-	if (task->tk_status == -ETIMEDOUT && !hdr->res.op_status)
-		hdr->res.op_status = NFS4ERR_NXIO;
-	if (task->tk_status < 0 && hdr->res.op_status)
+	if (task->tk_status < 0)
 		ff_layout_io_track_ds_error(hdr->lseg, hdr->pgio_mirror_idx,
 					    hdr->args.offset, hdr->args.count,
-					    hdr->res.op_status, OP_READ);
+					    hdr->res.op_status, OP_READ,
+					    task->tk_status);
 	err = ff_layout_async_handle_error(task, hdr->args.context->state,
 					   hdr->ds_clp, hdr->lseg,
 					   hdr->pgio_mirror_idx);
@@ -1163,12 +1187,11 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 	int err;
 
 	trace_nfs4_pnfs_write(hdr, task->tk_status);
-	if (task->tk_status == -ETIMEDOUT && !hdr->res.op_status)
-		hdr->res.op_status = NFS4ERR_NXIO;
-	if (task->tk_status < 0 && hdr->res.op_status)
+	if (task->tk_status < 0)
 		ff_layout_io_track_ds_error(hdr->lseg, hdr->pgio_mirror_idx,
 					    hdr->args.offset, hdr->args.count,
-					    hdr->res.op_status, OP_WRITE);
+					    hdr->res.op_status, OP_WRITE,
+					    task->tk_status);
 	err = ff_layout_async_handle_error(task, hdr->args.context->state,
 					   hdr->ds_clp, hdr->lseg,
 					   hdr->pgio_mirror_idx);
@@ -1208,12 +1231,11 @@ static int ff_layout_commit_done_cb(struct rpc_task *task,
 	int err;
 
 	trace_nfs4_pnfs_commit_ds(data, task->tk_status);
-	if (task->tk_status == -ETIMEDOUT && !data->res.op_status)
-		data->res.op_status = NFS4ERR_NXIO;
-	if (task->tk_status < 0 && data->res.op_status)
+	if (task->tk_status < 0)
 		ff_layout_io_track_ds_error(data->lseg, data->ds_commit_index,
 					    data->args.offset, data->args.count,
-					    data->res.op_status, OP_COMMIT);
+					    data->res.op_status, OP_COMMIT,
+					    task->tk_status);
 	err = ff_layout_async_handle_error(task, NULL, data->ds_clp,
 					   data->lseg, data->ds_commit_index);
 
-- 
2.4.3

