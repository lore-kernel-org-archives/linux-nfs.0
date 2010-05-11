Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [221.122.61.232] ([221.122.61.232]:43739 "EHLO mx.bwstor.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932068Ab0EKJBP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 May 2010 05:01:15 -0400
Date: Tue, 11 May 2010 16:59:44 +0800
From: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
To: linux-nfs@vger.kernel.org
Cc: bhalevy@panasas.com, iisaman@citi.umich.edu
Subject: [PATCH] pnfs: send layoutcommit until IO completed when return
	layout
Message-ID: <20100511085943.GA6822@MDS-78.localdomain>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

If we call layoutcommit before IO completed, then some extents we are
writing may not be in the commit list. When we return layout, they
may not get a chance to be committed to server.

Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
---
 fs/nfs/pnfs.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3739c38..6fa295b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -726,16 +726,6 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
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
@@ -763,6 +753,16 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
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
1.6.2.5

