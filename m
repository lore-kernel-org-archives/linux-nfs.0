Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:38742 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbeFSXUH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jun 2018 19:20:07 -0400
Received: by mail-it0-f66.google.com with SMTP id v83-v6so2922208itc.3
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jun 2018 16:20:07 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (50-124-245-47.alma.mi.frontiernet.net. [50.124.245.47])
        by smtp.gmail.com with ESMTPSA id 192-v6sm630771itl.41.2018.06.19.16.20.05
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 16:20:05 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] pNFS/flexfiles: Don't tie up all the rpciod threads in resends
Date: Tue, 19 Jun 2018 19:19:42 -0400
Message-Id: <20180619231943.105925-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We do not want to have rpciod threads perform recursive calls into the
RPC layer since that can deadlock. In particular, having to wait for
a layoutget can be nasty... We want rather to defer scheduling those
retries until we're in the rpc_release() callback, since that is
called from the nfsiod workqueue.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 11 ++++++++---
 include/linux/nfs_xdr.h                |  2 ++
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 3ae038d9c292..336b4d560e2c 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1243,17 +1243,18 @@ static int ff_layout_read_done_cb(struct rpc_task *task,
 					   hdr->ds_clp, hdr->lseg,
 					   hdr->pgio_mirror_idx);
 
+	clear_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
+	clear_bit(NFS_IOHDR_RESEND_MDS, &hdr->flags);
 	switch (err) {
 	case -NFS4ERR_RESET_TO_PNFS:
 		if (ff_layout_choose_best_ds_for_read(hdr->lseg,
 					hdr->pgio_mirror_idx + 1,
 					&hdr->pgio_mirror_idx))
 			goto out_eagain;
-		ff_layout_read_record_layoutstats_done(task, hdr);
-		pnfs_read_resend_pnfs(hdr);
+		set_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
 		return task->tk_status;
 	case -NFS4ERR_RESET_TO_MDS:
-		ff_layout_reset_read(hdr);
+		set_bit(NFS_IOHDR_RESEND_MDS, &hdr->flags);
 		return task->tk_status;
 	case -EAGAIN:
 		goto out_eagain;
@@ -1403,6 +1404,10 @@ static void ff_layout_read_release(void *data)
 	struct nfs_pgio_header *hdr = data;
 
 	ff_layout_read_record_layoutstats_done(&hdr->task, hdr);
+	if (test_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags))
+		pnfs_read_resend_pnfs(hdr);
+	else if (test_bit(NFS_IOHDR_RESEND_MDS, &hdr->flags))
+		ff_layout_reset_read(hdr);
 	pnfs_generic_rw_release(data);
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9dee3c23895d..712eed156d09 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1438,6 +1438,8 @@ enum {
 	NFS_IOHDR_EOF,
 	NFS_IOHDR_REDO,
 	NFS_IOHDR_STAT,
+	NFS_IOHDR_RESEND_PNFS,
+	NFS_IOHDR_RESEND_MDS,
 };
 
 struct nfs_io_completion;
-- 
2.17.1

