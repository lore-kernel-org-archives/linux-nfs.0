From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfsd41: gather and report statistics also for v4.1 ops
Date: Fri, 10 Jul 2009 12:37:40 +0300
Message-ID: <1247218660-14084-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:27966
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751049AbZGJJhp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2009 05:37:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs4.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index bd2eba5..aff924a 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -234,7 +234,7 @@ enum nfs_opnum4 {
 Needs to be updated if more operations are defined in future.*/
 
 #define FIRST_NFS4_OP	OP_ACCESS
-#define LAST_NFS4_OP 	OP_RELEASE_LOCKOWNER
+#define LAST_NFS4_OP 	OP_RECLAIM_COMPLETE
 
 enum nfsstat4 {
 	NFS4_OK = 0,
-- 
1.6.3.3

