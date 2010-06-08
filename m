From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 10/24] pnfs_submit: mandate basic io path operations for layout drivers
Date: Tue,  8 Jun 2010 00:19:07 -0400
Message-ID: <1275970761-31806-11-git-send-email-iisaman@netapp.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
 <1275970761-31806-2-git-send-email-iisaman@netapp.com>
 <1275970761-31806-3-git-send-email-iisaman@netapp.com>
 <1275970761-31806-4-git-send-email-iisaman@netapp.com>
 <1275970761-31806-5-git-send-email-iisaman@netapp.com>
 <1275970761-31806-6-git-send-email-iisaman@netapp.com>
 <1275970761-31806-7-git-send-email-iisaman@netapp.com>
 <1275970761-31806-8-git-send-email-iisaman@netapp.com>
 <1275970761-31806-9-git-send-email-iisaman@netapp.com>
 <1275970761-31806-10-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60833 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692Ab0FHETr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:47 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOQ1014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:31 -0700 (PDT)
In-Reply-To: <1275970761-31806-10-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mandate read_pagelist, write_pagelist, and commit.  This will help
void needless checks in the io path.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b990471..836cb0f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -272,6 +272,14 @@ pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
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

