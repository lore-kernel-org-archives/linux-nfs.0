Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49535 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760411Ab0JGNLA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 09:11:00 -0400
Received: from localhost.localdomain (laino1-lxp.hq.netapp.com [10.58.48.170])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o97DAgW9017616
	for <linux-nfs@vger.kernel.org>; Thu, 7 Oct 2010 06:10:45 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] pnfs_submit: Remove nonsensical check
Date: Wed,  6 Oct 2010 16:35:14 -0400
Message-Id: <1286397317-17881-2-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286397317-17881-1-git-send-email-iisaman@netapp.com>
References: <1286397317-17881-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Only a buggy server would return a zero iomode with roc set.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4b33cde..39bce9b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -935,12 +935,8 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		/* FI: This needs to be re-examined.  At lo level,
 		 * all it needs is a bit indicating whether any of
 		 * the lsegs in the list have the flags set.
-		 *
-		 * The IOMODE_ANY line just seems nonsensical.
 		 */
 		lo->roc_iomode |= res->range.iomode;
-		if (!lo->roc_iomode)
-			lo->roc_iomode = IOMODE_ANY;
 	}
 
 	/* Done processing layoutget. Set the layout stateid */
-- 
1.7.2.1

