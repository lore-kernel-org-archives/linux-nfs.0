From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 3/7] SQUASHME: pnfsblock: write_end adjust for removed ok_to_use_pnfs
Date: Fri, 11 Jun 2010 03:40:35 -0400
Message-ID: <1276242039-18649-4-git-send-email-iisaman@netapp.com>
References: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
 <1276242039-18649-2-git-send-email-iisaman@netapp.com>
 <1276242039-18649-3-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32582 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755194Ab0FKHkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:40:55 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7eoVd027834
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:40:54 -0700 (PDT)
In-Reply-To: <1276242039-18649-3-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index eb5760f..b1df445 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1027,17 +1027,12 @@ bl_write_begin(struct pnfs_layout_segment *lseg, struct page *page, loff_t pos,
 /* CAREFUL - what happens if copied < count??? */
 static int
 bl_write_end(struct inode *inode, struct page *page, loff_t pos,
-	     unsigned count, unsigned copied, struct pnfs_fsdata *fsdata)
+	     unsigned count, unsigned copied, struct pnfs_layout_segment *lseg)
 {
-	dprintk("%s enter, %u@%lld, %i\n", __func__, count, pos,
-		fsdata ? fsdata->ok_to_use_pnfs : -1);
+	dprintk("%s enter, %u@%lld, lseg=%p\n", __func__, count, pos, lseg);
 	print_page(page);
-	if (fsdata) {
-		if (fsdata->ok_to_use_pnfs) {
-			dprintk("%s using pnfs\n", __func__);
-			SetPageUptodate(page);
-		}
-	}
+	if (lseg)
+		SetPageUptodate(page);
 	return 0;
 }
 
-- 
1.6.6.1

