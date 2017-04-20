Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34161 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946724AbdDTSmi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Apr 2017 14:42:38 -0400
Received: by mail-io0-f194.google.com with SMTP id h41so19371476ioi.1
        for <linux-nfs@vger.kernel.org>; Thu, 20 Apr 2017 11:42:38 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH] pNFS/flexfiles: Check the result of nfs4_pnfs_ds_connect
Date: Thu, 20 Apr 2017 14:42:34 -0400
Message-Id: <20170420184234.5218-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The check in nfs4_ff_layout_prepare_ds() seems to be missing.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Fixes: a33e4b036d461 ("pNFS: return status from nfs4_pnfs_ds_connect")
Cc: Weston Andros Adamson <dros@primarydata.com>
Cc: stable@vger.kernel.org # v4.11
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 8ca9cc665561..6df7a0cf5660 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -421,7 +421,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 			     mirror->mirror_ds->ds_versions[0].minor_version);
 
 	/* connect success, check rsize/wsize limit */
-	if (ds->ds_clp) {
+	if (!status) {
 		max_payload =
 			nfs_block_size(rpc_max_payload(ds->ds_clp->cl_rpcclient),
 				       NULL);
-- 
2.9.3

