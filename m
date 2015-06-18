Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:3493 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753726AbbFRLlZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 07:41:25 -0400
From: Yijing Wang <wangyijing@huawei.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH] nfs: Fix comment for nfs_pageio_init() and nfs_pageio_complete_mirror()
Date: Thu, 18 Jun 2015 19:37:13 +0800
Message-ID: <1434627433-3154-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 fs/nfs/pagelist.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 282b393..20d0c1a 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -711,7 +711,9 @@ static void nfs_pageio_mirror_init(struct nfs_pgio_mirror *mirror,
  * nfs_pageio_init - initialise a page io descriptor
  * @desc: pointer to descriptor
  * @inode: pointer to inode
- * @doio: pointer to io function
+ * @pg_ops: pointer to pageio operations
+ * @compl_ops: pointer to pageio completion operations
+ * @rw_ops: pointer to nfs read/write operations
  * @bsize: io block size
  * @io_flags: extra parameters for the io function
  */
@@ -1186,6 +1188,7 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
  * nfs_pageio_complete_mirror - Complete I/O on the current mirror of an
  *				nfs_pageio_descriptor
  * @desc: pointer to io descriptor
+ * @mirror_idx: pointer to mirror index
  */
 static void nfs_pageio_complete_mirror(struct nfs_pageio_descriptor *desc,
 				       u32 mirror_idx)
-- 
1.7.1

