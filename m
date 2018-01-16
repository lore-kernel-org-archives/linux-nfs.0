Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:60653 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751090AbeAPVjZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Jan 2018 16:39:25 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id B7FD0280885
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jan 2018 22:39:23 +0100 (CET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: trond.myklebust@primarydata.com, Anna.Schumaker@Netapp.com,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs41: do not return ENOMEM on LAYOUTUNAVAILABLE
Date: Tue, 16 Jan 2018 22:38:50 +0100
Message-Id: <20180116213850.10323-1-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A pNFS server may return LAYOUTUNAVAILABLE error on LAYOUTGET for files
which don't have any layout. In this situation pnfs_update_layout
currently returns NULL. As this NULL is converted into ENOMEM, IO
requests fails instead of falling back to MDS.

Do not return ENOMEM on LAYOUTUNAVAILABLE and let client retry through
MDS.

Fixes 8d40b0f14846f. I will suggest to backport this fix to affected
stable branches.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/filelayout/filelayout.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 28b72285711e..94f8fc02ea4e 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -895,9 +895,7 @@ fl_pnfs_update_layout(struct inode *ino,
 
 	lseg = pnfs_update_layout(ino, ctx, pos, count, iomode, strict_iomode,
 				  gfp_flags);
-	if (!lseg)
-		lseg = ERR_PTR(-ENOMEM);
-	if (IS_ERR(lseg))
+	if (!lseg || IS_ERR(lseg))
 		goto out;
 
 	lo = NFS_I(ino)->layout;
-- 
2.14.3

