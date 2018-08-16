Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:43842 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725925AbeHPEbC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2018 00:31:02 -0400
Received: by mail-io0-f193.google.com with SMTP id y10-v6so2576912ioa.10
        for <linux-nfs@vger.kernel.org>; Wed, 15 Aug 2018 18:36:09 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS: Treat RECALLCONFLICT like DELAY...
Date: Wed, 15 Aug 2018 21:35:45 -0400
Message-Id: <20180816013546.118511-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yes, it is possible to get trapped in a loop, but the server should be
administratively revoking the recalled layout if it never gets returned.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8ef3c1feee92..269b5147d0e3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1982,15 +1982,6 @@ pnfs_update_layout(struct inode *ino,
 				lseg = NULL;
 			break;
 		case -ERECALLCONFLICT:
-			/* Huh? We hold no layouts, how is there a recall? */
-			if (first) {
-				lseg = NULL;
-				break;
-			}
-			/* Destroy the existing layout and start over */
-			if (time_after(jiffies, giveup))
-				pnfs_destroy_layout(NFS_I(ino));
-			/* Fallthrough */
 		case -EAGAIN:
 			break;
 		default:
-- 
2.17.1
