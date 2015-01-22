Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:41443 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751979AbbAVLL1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 06:11:27 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 17/20] xfs: update the superblock using a synchronous transaction in growfs
Date: Thu, 22 Jan 2015 12:10:03 +0100
Message-Id: <1421925006-24231-18-git-send-email-hch@lst.de>
In-Reply-To: <1421925006-24231-1-git-send-email-hch@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Growfs updates the secondary superblocks using synchronous unlogged
buffer writes after committing the updates to the primary superblock.

Mark the transaction to the primary superblock as synchronous so that
we guarantee it is committed to disk before we update the secondary
superblocks.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/xfs/xfs_fsops.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/xfs/xfs_fsops.c b/fs/xfs/xfs_fsops.c
index fdc6422..74c6211 100644
--- a/fs/xfs/xfs_fsops.c
+++ b/fs/xfs/xfs_fsops.c
@@ -488,6 +488,7 @@ xfs_growfs_data_private(
 		xfs_trans_mod_sb(tp, XFS_TRANS_SB_FDBLOCKS, nfree);
 	if (dpct)
 		xfs_trans_mod_sb(tp, XFS_TRANS_SB_IMAXPCT, dpct);
+	xfs_trans_set_sync(tp);
 	error = xfs_trans_commit(tp, 0);
 	if (error)
 		return error;
-- 
1.9.1

