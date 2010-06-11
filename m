From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 05/26] SQUASHME: pnfs-submit: ensure pnfs_update_layout clears lsegp on error
Date: Fri, 11 Jun 2010 03:31:32 -0400
Message-ID: <1276241513-17942-6-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
 <1276241513-17942-2-git-send-email-iisaman@netapp.com>
 <1276241513-17942-3-git-send-email-iisaman@netapp.com>
 <1276241513-17942-4-git-send-email-iisaman@netapp.com>
 <1276241513-17942-5-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30552 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757280Ab0FKHcU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:20 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3tw024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:07 -0700 (PDT)
In-Reply-To: <1276241513-17942-5-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Compensate for pnfs_update_layout returning error but assigning lseg.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6717a9d..c73ab80 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1042,6 +1042,8 @@ pnfs_update_layout(struct inode *ino,
 	DEFINE_WAIT(__wait);
 	int result = 0;
 
+	if (take_ref)
+		*lsegpp = NULL;
 	lo = get_lock_alloc_layout(ino);
 	if (IS_ERR(lo)) {
 		dprintk("%s ERROR: can't get pnfs_layout_type\n", __func__);
@@ -1056,6 +1058,7 @@ pnfs_update_layout(struct inode *ino,
 			put_lseg(lseg);
 
 		/* someone is cleaning the layout */
+		lseg = NULL;
 		result = -EAGAIN;
 		goto out_put;
 	}
-- 
1.6.6.1

