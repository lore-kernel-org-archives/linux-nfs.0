From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 7/7] SQUASHME: pnfsd-exofs: use only pnfs_layoutreturn_type
Date: Wed,  9 Dec 2009 12:28:24 +0200
Message-ID: <1260354504-12333-1-git-send-email-bhalevy@panasas.com>
References: <4B1F7AF6.2080305@panasas.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:8798 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754397AbZLIK2U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2009 05:28:20 -0500
In-Reply-To: <4B1F7AF6.2080305@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/exofs/export.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 4c1c7e3..9a27673 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -343,7 +343,7 @@ static int is_layout_returned(struct exofs_i_info *oi)
 	}
 
 	memset(&cbl, 0, sizeof(cbl));
-	cbl.cbl_recall_type = RECALL_FILE;
+	cbl.cbl_recall_type = RETURN_FILE;
 	cbl.cbl_seg.layout_type = LAYOUT_OSD2_OBJECTS;
 	cbl.cbl_seg.iomode = IOMODE_RW;
 	cbl.cbl_seg.length = NFS4_MAX_UINT64;
@@ -401,7 +401,7 @@ int exofs_inode_recall_layout(struct inode *inode, exofs_recall_fn todo)
 		goto err;
 
 	memset(&cbl, 0, sizeof(cbl));
-	cbl.cbl_recall_type = RECALL_FILE;
+	cbl.cbl_recall_type = RETURN_FILE;
 	cbl.cbl_seg.layout_type = LAYOUT_OSD2_OBJECTS;
 	cbl.cbl_seg.iomode = IOMODE_ANY;
 	cbl.cbl_seg.length = NFS4_MAX_UINT64;
-- 
1.6.5.1

