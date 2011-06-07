Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53700 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755722Ab1FGR3Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:29:25 -0400
Date: Tue, 7 Jun 2011 13:29:22 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 30/88] pnfsblock: write_end
Message-ID: <33457eaede5912d7802ba8e3c5fd843c110b69d9.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Implements bl_write_end, which basically just calls SetPageUptodate.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index b3ad99d..f4851c1 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -818,6 +818,23 @@ bl_write_begin(struct pnfs_layout_segment *lseg, struct page *page, loff_t pos,
 	return ret;
 }
 
+/* CAREFUL - what happens if copied < count??? */
+static int
+bl_write_end(struct inode *inode, struct page *page, loff_t pos,
+	     unsigned count, unsigned copied, struct pnfs_fsdata *fsdata)
+{
+	dprintk("%s enter, %u@%lld, %i\n", __func__, count, pos,
+		fsdata ? fsdata->ok_to_use_pnfs : -1);
+	print_page(page);
+	if (fsdata) {
+		if (fsdata->ok_to_use_pnfs) {
+			dprintk("%s using pnfs\n", __func__);
+			SetPageUptodate(page);
+		}
+	}
+	return 0;
+}
+
 static ssize_t
 bl_get_stripesize(struct pnfs_layout_type *lo)
 {
@@ -862,6 +879,7 @@ static struct layoutdriver_io_operations blocklayout_io_operations = {
 	.read_pagelist			= bl_read_pagelist,
 	.write_pagelist			= bl_write_pagelist,
 	.write_begin			= bl_write_begin,
+	.write_end			= bl_write_end,
 	.alloc_layout			= bl_alloc_layout,
 	.free_layout			= bl_free_layout,
 	.alloc_lseg			= bl_alloc_lseg,
-- 
1.7.4.1

