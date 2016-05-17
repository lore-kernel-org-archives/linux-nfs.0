Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34421 "EHLO
	mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755827AbcEQQ25 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2016 12:28:57 -0400
Received: by mail-qk0-f194.google.com with SMTP id i7so1933384qkd.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 May 2016 09:28:57 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Thomas Haynes <loghyr@primarydata.com>, linux-nfs@vger.kernel.org,
        hch@lst.de
Subject: [PATCH v4 01/13] pNFS/flexfile: Fix erroneous fall back to read/write through the MDS
Date: Tue, 17 May 2016 12:28:36 -0400
Message-Id: <1463502528-11519-2-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
References: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

This patch fixes a problem whereby the pNFS client falls back to doing
reads and writes through the metadata server even when the layout flag
FF_FLAGS_NO_IO_THRU_MDS is set.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 23 ++++++-----------------
 1 file changed, 6 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 60d690dbc947..51f6660a2247 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1294,7 +1294,7 @@ ff_layout_set_layoutcommit(struct nfs_pgio_header *hdr)
 }
 
 static bool
-ff_layout_reset_to_mds(struct pnfs_layout_segment *lseg, int idx)
+ff_layout_device_unavailable(struct pnfs_layout_segment *lseg, int idx)
 {
 	/* No mirroring for now */
 	struct nfs4_deviceid_node *node = FF_LAYOUT_DEVID_NODE(lseg, idx);
@@ -1331,16 +1331,10 @@ static int ff_layout_read_prepare_common(struct rpc_task *task,
 		rpc_exit(task, -EIO);
 		return -EIO;
 	}
-	if (ff_layout_reset_to_mds(hdr->lseg, hdr->pgio_mirror_idx)) {
-		dprintk("%s task %u reset io to MDS\n", __func__, task->tk_pid);
-		if (ff_layout_has_available_ds(hdr->lseg))
-			pnfs_read_resend_pnfs(hdr);
-		else
-			ff_layout_reset_read(hdr);
-		rpc_exit(task, 0);
+	if (ff_layout_device_unavailable(hdr->lseg, hdr->pgio_mirror_idx)) {
+		rpc_exit(task, -EHOSTDOWN);
 		return -EAGAIN;
 	}
-	hdr->pgio_done_cb = ff_layout_read_done_cb;
 
 	ff_layout_read_record_layoutstats_start(task, hdr);
 	return 0;
@@ -1530,14 +1524,8 @@ static int ff_layout_write_prepare_common(struct rpc_task *task,
 		return -EIO;
 	}
 
-	if (ff_layout_reset_to_mds(hdr->lseg, hdr->pgio_mirror_idx)) {
-		bool retry_pnfs;
-
-		retry_pnfs = ff_layout_has_available_ds(hdr->lseg);
-		dprintk("%s task %u reset io to %s\n", __func__,
-			task->tk_pid, retry_pnfs ? "pNFS" : "MDS");
-		ff_layout_reset_write(hdr, retry_pnfs);
-		rpc_exit(task, 0);
+	if (ff_layout_device_unavailable(hdr->lseg, hdr->pgio_mirror_idx)) {
+		rpc_exit(task, -EHOSTDOWN);
 		return -EAGAIN;
 	}
 
@@ -1754,6 +1742,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	dprintk("%s USE DS: %s cl_count %d vers %d\n", __func__,
 		ds->ds_remotestr, atomic_read(&ds->ds_clp->cl_count), vers);
 
+	hdr->pgio_done_cb = ff_layout_read_done_cb;
 	atomic_inc(&ds->ds_clp->cl_count);
 	hdr->ds_clp = ds->ds_clp;
 	fh = nfs4_ff_layout_select_ds_fh(lseg, idx);
-- 
2.5.5

