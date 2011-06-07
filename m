Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51554 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755451Ab1FGRcm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:32:42 -0400
Date: Tue, 7 Jun 2011 13:32:41 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 56/88] SQUASHME: pnfsblock: write_end adjust for removed
 ok_to_use_pnfs
Message-ID: <72e4d418bdcfb139793744466fa77b0d77fd10e0.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

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
1.7.4.1

