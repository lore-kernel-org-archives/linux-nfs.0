From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 10/26] pnfs_submit: mandate basic io path operations for layout drivers
Date: Fri, 11 Jun 2010 03:31:37 -0400
Message-ID: <1276241513-17942-11-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
 <1276241513-17942-2-git-send-email-iisaman@netapp.com>
 <1276241513-17942-3-git-send-email-iisaman@netapp.com>
 <1276241513-17942-4-git-send-email-iisaman@netapp.com>
 <1276241513-17942-5-git-send-email-iisaman@netapp.com>
 <1276241513-17942-6-git-send-email-iisaman@netapp.com>
 <1276241513-17942-7-git-send-email-iisaman@netapp.com>
 <1276241513-17942-8-git-send-email-iisaman@netapp.com>
 <1276241513-17942-9-git-send-email-iisaman@netapp.com>
 <1276241513-17942-10-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30552 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757682Ab0FKHcV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:21 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3u3024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:15 -0700 (PDT)
In-Reply-To: <1276241513-17942-10-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mandate read_pagelist, write_pagelist, and commit.  This will help
void needless checks in the io path.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c73ab80..a82eac7 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -270,6 +270,14 @@ pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 		return NULL;
 	}
 
+	if (!io_ops->read_pagelist || !io_ops->write_pagelist ||
+	    !io_ops->commit) {
+		printk(KERN_ERR "%s Layout driver must provide "
+		       "read_pagelist, write_pagelist, and commit.\n",
+		       __func__);
+		return NULL;
+	}
+
 	pnfs_mod = kmalloc(sizeof(struct pnfs_module), GFP_KERNEL);
 	if (pnfs_mod != NULL) {
 		dprintk("%s Registering id:%u name:%s\n",
-- 
1.6.6.1

