Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:32864 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932561AbcLGUmb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2016 15:42:31 -0500
Received: by mail-io0-f194.google.com with SMTP id j92so16260780ioi.0
        for <linux-nfs@vger.kernel.org>; Wed, 07 Dec 2016 12:42:31 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pNFS: Layoutreturn must free the layout after the layout-private data
Date: Wed,  7 Dec 2016 15:42:26 -0500
Message-Id: <20161207204226.15927-3-trond.myklebust@primarydata.com>
In-Reply-To: <20161207204226.15927-2-trond.myklebust@primarydata.com>
References: <20161207204226.15927-1-trond.myklebust@primarydata.com>
 <20161207204226.15927-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The layout-private data may depend on the layout and/or the inode
still existing when it does post-processing and frees its data, so we
need to free them after calling lrp->ld_private.ops->free().

This fixes a mirror list corruption issue in the flexfiles driver.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d3431ff32662..c5a508669655 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8641,10 +8641,10 @@ static void nfs4_layoutreturn_release(void *calldata)
 	pnfs_layoutreturn_free_lsegs(lo, &lrp->args.stateid, &lrp->args.range,
 			lrp->res.lrs_present ? &lrp->res.stateid : NULL);
 	nfs4_sequence_free_slot(&lrp->res.seq_res);
-	pnfs_put_layout_hdr(lrp->args.layout);
-	nfs_iput_and_deactive(lrp->inode);
 	if (lrp->ld_private.ops && lrp->ld_private.ops->free)
 		lrp->ld_private.ops->free(&lrp->ld_private);
+	pnfs_put_layout_hdr(lrp->args.layout);
+	nfs_iput_and_deactive(lrp->inode);
 	kfree(calldata);
 	dprintk("<-- %s\n", __func__);
 }
-- 
2.9.3

