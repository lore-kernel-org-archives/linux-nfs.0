Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:45673 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754707Ab1FLXo5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:44:57 -0400
Message-Id: <2b17966620201541dee62149d8470e6ddfebf937.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:44:55 -0400
Subject: [PATCH 27/34] pnfsblock: write_end
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Implements bl_write_end, which basically just calls SetPageUptodate.

[pnfsblock: write_end adjust for removed ok_to_use_pnfs]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 5d7cb86..8914143 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -775,10 +775,15 @@ bl_write_begin(struct pnfs_layout_segment *lseg, struct page *page, loff_t pos,
 	return ret;
 }
 
+/* CAREFUL - what happens if copied < count??? */
 static int
 bl_write_end(struct inode *inode, struct page *page, loff_t pos,
 	     unsigned count, unsigned copied, struct pnfs_layout_segment *lseg)
 {
+	dprintk("%s enter, %u@%lld, lseg=%p\n", __func__, count, pos, lseg);
+	print_page(page);
+	if (lseg)
+		SetPageUptodate(page);
 	return 0;
 }
 
-- 
1.7.4.1

