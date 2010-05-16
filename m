From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 03/22] Revert "pnfs: Enable O_DIRECT read path."
Date: Sat, 15 May 2010 21:22:54 -0400
Message-ID: <1273972993-15369-4-git-send-email-iisaman@netapp.com>
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com>
 <1273972993-15369-2-git-send-email-iisaman@netapp.com>
 <1273972993-15369-3-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668Ab0ETKaa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 06:30:30 -0400
Received: from localhost.localdomain (vpn2ntap-176975.hq.netapp.com [10.58.56.200])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4KAUQbr022655
	for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 03:30:29 -0700 (PDT)
In-Reply-To: <1273972993-15369-3-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit fe1dbd120b6a94bbacec205d0a4ae40d36e314b5.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/direct.c |   26 +-------------------------
 1 files changed, 1 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 1148214..3ef9b0c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -56,7 +56,6 @@
 
 #include "internal.h"
 #include "iostat.h"
-#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -329,17 +328,6 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 	unsigned int pgbase;
 	int result;
 	ssize_t started = 0;
-	size_t pnfs_stripe_rem = count;
-	enum pnfs_try_status trypnfs;
-
-	/* pnfs_stripe_rem will be set to the remaining bytes in
-	 * the first stripe_unit (which for standard nfs is count)
-	 */
-	pnfs_direct_init_io(inode, ctx, count, pos, 0, &rsize,
-			    &pnfs_stripe_rem);
-
-	dprintk("%s: pos %llu count %Zu wsize %Zu\n",
-		__func__, pos, count, rsize);
 
 	do {
 		struct nfs_read_data *data;
@@ -347,12 +335,6 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 
 		pgbase = user_addr & ~PAGE_MASK;
 		bytes = min(rsize,count);
-#if defined(CONFIG_NFS_V4_1)
-		if (pnfs_enabled_sb(NFS_SERVER(inode))) {
-			bytes = min(bytes, pnfs_stripe_rem);
-			pnfs_stripe_rem = rsize;
-		}
-#endif /* CONFIG_NFS_V4_1 */
 
 		result = -ENOMEM;
 		data = nfs_readdata_alloc(nfs_page_array_len(pgbase, bytes));
@@ -393,14 +375,8 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		data->res.eof = 0;
 		data->res.count = bytes;
 
-		trypnfs = pnfs_try_to_read_data(data, &nfs_read_direct_ops);
-		if (trypnfs == PNFS_ATTEMPTED) {
-			result = pnfs_get_read_status(data);
-			if (result)
-				break;
-		} else if (nfs_direct_read_execute(data, &task_setup_data, &msg)) {
+		if (nfs_direct_read_execute(data, &task_setup_data, &msg))
 			break;
-		}
 
 		started += bytes;
 		user_addr += bytes;
-- 
1.6.6.1

