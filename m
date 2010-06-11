From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 6/7] SQUASHME: pnfsblock: bl_write_pagelist adjust for missing PG_USE_PNFS
Date: Fri, 11 Jun 2010 03:40:38 -0400
Message-ID: <1276242039-18649-7-git-send-email-iisaman@netapp.com>
References: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
 <1276242039-18649-2-git-send-email-iisaman@netapp.com>
 <1276242039-18649-3-git-send-email-iisaman@netapp.com>
 <1276242039-18649-4-git-send-email-iisaman@netapp.com>
 <1276242039-18649-5-git-send-email-iisaman@netapp.com>
 <1276242039-18649-6-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32582 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753188Ab0FKHk6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:40:58 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7eoVg027834
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:40:57 -0700 (PDT)
In-Reply-To: <1276242039-18649-6-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 77e9512..92f0b4b 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -448,8 +448,8 @@ bl_write_pagelist(struct pnfs_layout_type *lo,
 	int pg_index = pgbase >> PAGE_CACHE_SHIFT;
 
 	dprintk("%s enter, %Zu@%lld\n", __func__, count, offset);
-	if (!test_bit(PG_USE_PNFS, &wdata->req->wb_flags)) {
-		dprintk("PG_USE_PNFS not set\n");
+	if (!wdata->req->wb_lseg) {
+		dprintk("%s no lseg, falling back to MDS\n", __func__);
 		return PNFS_NOT_ATTEMPTED;
 	}
 	if (dont_like_caller(wdata->req)) {
-- 
1.6.6.1

