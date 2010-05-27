From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/5] pnfs-submit: send layoutcommit until IO completed when return layout
Date: Thu, 27 May 2010 21:13:00 +0300
Message-ID: <1274983980-26477-1-git-send-email-bhalevy@panasas.com>
References: <4BFEB5D4.30608@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16220 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756947Ab0E0SND (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 May 2010 14:13:03 -0400
In-Reply-To: <4BFEB5D4.30608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>

If we call layoutcommit before IO completed, then some extents we are
writing may not be in the commit list. When we return layout, they
may not get a chance to be committed to server.

Signed-off-by: Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b4aed4e..6819509 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -731,16 +731,6 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 		arg.length = ~0;
 	}
 	if (type == RETURN_FILE) {
-		if (nfsi->layoutcommit_ctx) {
-			status = pnfs_layoutcommit_inode(ino, 1);
-			if (status) {
-				dprintk("%s: layoutcommit failed, status=%d. "
-					"Returning layout anyway\n",
-					__func__, status);
-				status = 0;
-			}
-		}
-
 		lo = get_lock_current_layout(nfsi);
 		if (lo && !has_layout_to_return(lo, &arg)) {
 			put_unlock_current_layout(lo);
@@ -768,6 +758,16 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 			wait_event(nfsi->lo_waitq,
 				!pnfs_return_layout_barrier(nfsi, &arg));
 		}
+
+		if (nfsi->layoutcommit_ctx) {
+			status = pnfs_layoutcommit_inode(ino, 1);
+			if (status) {
+				dprintk("%s: layoutcommit failed, status=%d. "
+					"Returning layout anyway\n",
+					__func__, status);
+				status = 0;
+			}
+		}
 	}
 send_return:
 	status = return_layout(ino, &arg, stateid, type, lo);
-- 
1.6.6.1

