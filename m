Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:52071 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab1FNCdL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:33:11 -0400
Message-Id: <e3771933360e9908f19853ed70c74eafb361d7d3.1308017749.git.rees@umich.edu>
In-Reply-To: <cover.1308017749.git.rees@umich.edu>
References: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 27/33] pnfsblock: write_end
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:33:09 -0400
From: Jim Rees <rees@umich.edu>
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
index b9b961f..dff5e69 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -772,10 +772,15 @@ bl_write_begin(struct pnfs_layout_segment *lseg, struct page *page, loff_t pos,
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

