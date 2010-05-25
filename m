From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/3] SQUASHME: spnfs: fixup LAYOUT_NFSV4_1_FILES
Date: Tue, 25 May 2010 08:56:59 +0300
Message-ID: <1274767019-19587-1-git-send-email-bhalevy@panasas.com>
References: <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37289 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756140Ab0EYF5C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 01:57:02 -0400
In-Reply-To: <1274722623-11078-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/spnfs_ops.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/spnfs_ops.c b/fs/nfsd/spnfs_ops.c
index 230fb59..b97a5af 100644
--- a/fs/nfsd/spnfs_ops.c
+++ b/fs/nfsd/spnfs_ops.c
@@ -57,7 +57,7 @@ extern struct spnfs *global_spnfs;
 int
 spnfs_layout_type(struct super_block *sb)
 {
-	return LAYOUT_NFSV4_FILES;
+	return LAYOUT_NFSV4_1_FILES;
 }
 
 enum nfsstat4
@@ -218,7 +218,7 @@ spnfs_layoutrecall(struct inode *inode, int type, u64 offset, u64 len)
 	}
 
 	lr.cbl_recall_type = type;
-	lr.cbl_seg.layout_type = LAYOUT_NFSV4_FILES;
+	lr.cbl_seg.layout_type = LAYOUT_NFSV4_1_FILES;
 	lr.cbl_seg.clientid = 0;
 	lr.cbl_seg.offset = offset;
 	lr.cbl_seg.length = len;
-- 
1.6.6.1

