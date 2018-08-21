Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:51413 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726743AbeHURqU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Aug 2018 13:46:20 -0400
Received: by mail-it0-f65.google.com with SMTP id e14-v6so4383927itf.1
        for <linux-nfs@vger.kernel.org>; Tue, 21 Aug 2018 07:25:58 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pNFS: Remove unwanted optimisation of layoutget
Date: Tue, 21 Aug 2018 10:25:34 -0400
Message-Id: <20180821142534.32039-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180821142534.32039-1-trond.myklebust@hammerspace.com>
References: <20180821142534.32039-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we knew that the file was empty, we wouldn't be asking for a layout.
Any optimisation here is already done before calling pnfs_update_layout().
As it stands, we sometimes end up doing an unnecessary inband read to
the MDS even when holding a layout.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 269b5147d0e3..05efd94f612a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1823,12 +1823,6 @@ pnfs_update_layout(struct inode *ino,
 		goto out;
 	}
 
-	if (iomode == IOMODE_READ && i_size_read(ino) == 0) {
-		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
-				 PNFS_UPDATE_LAYOUT_RD_ZEROLEN);
-		goto out;
-	}
-
 	if (pnfs_within_mdsthreshold(ctx, ino, iomode)) {
 		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				 PNFS_UPDATE_LAYOUT_MDSTHRESH);
-- 
2.17.1
