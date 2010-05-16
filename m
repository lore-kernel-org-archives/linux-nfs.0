From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 09/22] pnfs_submit: mandate basic io path operations for layout drivers
Date: Sat, 15 May 2010 21:23:00 -0400
Message-ID: <1273972993-15369-10-git-send-email-iisaman@netapp.com>
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com>
 <1273972993-15369-2-git-send-email-iisaman@netapp.com>
 <1273972993-15369-3-git-send-email-iisaman@netapp.com>
 <1273972993-15369-4-git-send-email-iisaman@netapp.com>
 <1273972993-15369-5-git-send-email-iisaman@netapp.com>
 <1273972993-15369-6-git-send-email-iisaman@netapp.com>
 <1273972993-15369-7-git-send-email-iisaman@netapp.com>
 <1273972993-15369-8-git-send-email-iisaman@netapp.com>
 <1273972993-15369-9-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668Ab0ETKah (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 06:30:37 -0400
Received: from localhost.localdomain (vpn2ntap-176975.hq.netapp.com [10.58.56.200])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4KAUQbx022655
	for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 03:30:37 -0700 (PDT)
In-Reply-To: <1273972993-15369-9-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mandate read_pagelist, write_pagelist, and commit.  This will help
void needless checks in the io path.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8dbf740..055f040 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -259,6 +259,14 @@ pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
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

