From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] pnfs: get open context from nfs_page in pnfs_commit
Date: Thu,  1 Jul 2010 21:17:33 +0300
Message-ID: <1278008253-24666-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:20649 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754538Ab0GASRf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 14:17:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To fix a BUG_ON(!ctx) in pnfs_update_layout

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a4f50f6..784ea80 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2015,7 +2015,7 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 	   before returning it, otherwise the data needs to be rewritten,
 	   either with a new layout or to the MDS */
 	result = pnfs_update_layout(data->inode,
-				    NULL,
+				    first->wb_context,
 				    count,
 				    first->wb_offset,
 				    IOMODE_RW,
-- 
1.6.6.1

