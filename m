From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/3] SQUASHME: pnfsd: unify enum pnfs_layout{return,recall}_type
Date: Wed,  9 Dec 2009 12:27:07 +0200
Message-ID: <1260354427-12038-1-git-send-email-bhalevy@panasas.com>
References: <4B1F7AF6.2080305@panasas.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:61261 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753739AbZLIK1D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2009 05:27:03 -0500
In-Reply-To: <4B1F7AF6.2080305@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use only layoutreturn constant for both returns and recalls.
(return_* works better for recall_type rather the other way around)

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs4.h |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index a899cff..8a53213 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -554,13 +554,7 @@ enum pnfs_layouttype {
 	LAYOUT_BLOCK_VOLUME = 3,
 };
 
-/* FIXME: should recall and return types be combined? */
-enum pnfs_layoutrecall_type {
-	RECALL_FILE = 1,
-	RECALL_FSID = 2,
-	RECALL_ALL  = 3
-};
-
+/* used for both layout return and recall */
 enum pnfs_layoutreturn_type {
 	RETURN_FILE = 1,
 	RETURN_FSID = 2,
-- 
1.6.5.1

