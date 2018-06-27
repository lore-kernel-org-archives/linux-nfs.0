Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:41979 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965736AbeF0SSy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jun 2018 14:18:54 -0400
Received: by mail-io0-f196.google.com with SMTP id k16-v6so2759239ioa.8
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jun 2018 11:18:54 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([50.105.87.45])
        by smtp.gmail.com with ESMTPSA id x5-v6sm2105233ioa.65.2018.06.27.11.18.52
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Jun 2018 11:18:53 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] pNFS/flexfiles: Ensure we always return a layout if it has layoutstats
Date: Wed, 27 Jun 2018 14:18:27 -0400
Message-Id: <20180627181828.27680-4-trond.myklebust@hammerspace.com>
In-Reply-To: <20180627181828.27680-3-trond.myklebust@hammerspace.com>
References: <20180627181828.27680-1-trond.myklebust@hammerspace.com>
 <20180627181828.27680-2-trond.myklebust@hammerspace.com>
 <20180627181828.27680-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a layout segment is carrying layoutstats or layout error information,
then we always want to return it rather than using a forgetful model.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 8f003792ccde..280b6b060d53 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1323,6 +1323,7 @@ static void ff_layout_read_record_layoutstats_done(struct rpc_task *task,
 			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
 			hdr->args.count,
 			hdr->res.count);
+	set_bit(NFS_LSEG_LAYOUTRETURN, &hdr->lseg->pls_flags);
 }
 
 static int ff_layout_read_prepare_common(struct rpc_task *task,
@@ -1507,6 +1508,7 @@ static void ff_layout_write_record_layoutstats_done(struct rpc_task *task,
 			FF_LAYOUT_COMP(hdr->lseg, hdr->pgio_mirror_idx),
 			hdr->args.count, hdr->res.count,
 			hdr->res.verf->committed);
+	set_bit(NFS_LSEG_LAYOUTRETURN, &hdr->lseg->pls_flags);
 }
 
 static int ff_layout_write_prepare_common(struct rpc_task *task,
@@ -1615,6 +1617,7 @@ static void ff_layout_commit_record_layoutstats_done(struct rpc_task *task,
 	nfs4_ff_layout_stat_io_end_write(task,
 			FF_LAYOUT_COMP(cdata->lseg, cdata->ds_commit_index),
 			count, count, NFS_FILE_SYNC);
+	set_bit(NFS_LSEG_LAYOUTRETURN, &cdata->lseg->pls_flags);
 }
 
 static void ff_layout_commit_prepare_common(struct rpc_task *task,
-- 
2.17.1

