From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfs-submit: __wait no longer used by _pnfs_update_layout
Date: Tue, 29 Jun 2010 14:39:09 +0300
Message-ID: <1277811549-13826-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42891 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751885Ab0F2LjM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 07:39:12 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 379e614..c78e39c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1078,7 +1078,6 @@ _pnfs_update_layout(struct inode *ino,
 	struct pnfs_layout_type *lo;
 	struct pnfs_layout_segment *lseg = NULL;
 	bool take_ref = (lsegpp != NULL);
-	DEFINE_WAIT(__wait);
 
 	if (take_ref)
 		*lsegpp = NULL;
-- 
1.6.6.1

