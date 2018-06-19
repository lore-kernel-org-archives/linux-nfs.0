Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:51309 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750805AbeFSXUI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jun 2018 19:20:08 -0400
Received: by mail-it0-f67.google.com with SMTP id n7-v6so2889633itn.1
        for <linux-nfs@vger.kernel.org>; Tue, 19 Jun 2018 16:20:07 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (50-124-245-47.alma.mi.frontiernet.net. [50.124.245.47])
        by smtp.gmail.com with ESMTPSA id 192-v6sm630771itl.41.2018.06.19.16.20.06
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Jun 2018 16:20:06 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pNFS/flexfiles: Process writeback resends from nfsiod context as well
Date: Tue, 19 Jun 2018 19:19:43 -0400
Message-Id: <20180619231943.105925-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180619231943.105925-1-trond.myklebust@hammerspace.com>
References: <20180619231943.105925-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Although the writeback resends are more robust than the reads, since they
are not immediately rescheduled by the same thread, we are better off
processing them in the same place as the reads.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 336b4d560e2c..1386b774ec95 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1428,12 +1428,14 @@ static int ff_layout_write_done_cb(struct rpc_task *task,
 					   hdr->ds_clp, hdr->lseg,
 					   hdr->pgio_mirror_idx);
 
+	clear_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
+	clear_bit(NFS_IOHDR_RESEND_MDS, &hdr->flags);
 	switch (err) {
 	case -NFS4ERR_RESET_TO_PNFS:
-		ff_layout_reset_write(hdr, true);
+		set_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags);
 		return task->tk_status;
 	case -NFS4ERR_RESET_TO_MDS:
-		ff_layout_reset_write(hdr, false);
+		set_bit(NFS_IOHDR_RESEND_MDS, &hdr->flags);
 		return task->tk_status;
 	case -EAGAIN:
 		return -EAGAIN;
@@ -1580,6 +1582,10 @@ static void ff_layout_write_release(void *data)
 	struct nfs_pgio_header *hdr = data;
 
 	ff_layout_write_record_layoutstats_done(&hdr->task, hdr);
+	if (test_bit(NFS_IOHDR_RESEND_PNFS, &hdr->flags))
+		ff_layout_reset_write(hdr, true);
+	else if (test_bit(NFS_IOHDR_RESEND_MDS, &hdr->flags))
+		ff_layout_reset_write(hdr, false);
 	pnfs_generic_rw_release(data);
 }
 
-- 
2.17.1

