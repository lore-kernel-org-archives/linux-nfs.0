From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Subject: [PATCH] pnfs: call layoutcommit after flushing inode's data to
 disk.
Date: Thu, 20 May 2010 11:28:08 +0800
Message-ID: <20100520032759.GA26892@vmware>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [221.122.61.232] ([221.122.61.232]:44115 "EHLO mx.bwstor.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753424Ab0ETD2j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 May 2010 23:28:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
---
 fs/nfs/write.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d3e1645..b4f48b2 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1558,6 +1558,7 @@ int nfs_write_inode(struct inode *inode, struct writeback_control *wbc)
  */
 int nfs_wb_all(struct inode *inode)
 {
+	int ret;
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = LONG_MAX,
@@ -1565,7 +1566,12 @@ int nfs_wb_all(struct inode *inode)
 		.range_end = LLONG_MAX,
 	};
 
-	return sync_inode(inode, &wbc);
+	ret = sync_inode(inode, &wbc);
+#ifdef CONFIG_NFS_V4_1
+	if (!ret && NFS_I(inode)->layoutcommit_ctx)
+		ret = pnfs_layoutcommit_inode(inode, 1);
+#endif
+	return ret;
 }
 
 int nfs_wb_page_cancel(struct inode *inode, struct page *page)
-- 
1.6.3.3

