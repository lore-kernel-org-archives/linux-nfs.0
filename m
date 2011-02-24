Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:44239 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125Ab1BXThp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 14:37:45 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: put_lseg_common should use list_del_init
Date: Thu, 24 Feb 2011 11:37:41 -0800
Message-Id: <1298576261-3174-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The lseg can be added to a tmp list after put_lseg

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 47f2057..e2adcaa 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -311,7 +311,7 @@ put_lseg_common(struct pnfs_layout_segment *lseg)
 	struct inode *inode = lseg->pls_layout->plh_inode;
 
 	BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
-	list_del(&lseg->pls_list);
+	list_del_init(&lseg->pls_list);
 	if (list_empty(&lseg->pls_layout->plh_segs)) {
 		set_bit(NFS_LAYOUT_DESTROYED, &lseg->pls_layout->plh_flags);
 		/* Matched by initial refcount set in alloc_init_layout_hdr */
-- 
1.7.3.4

