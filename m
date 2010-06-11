From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 5/7] SQUASHME: pnfsblock: bl_write_pagelist support functions adjust for missing PG_USE_PNFS
Date: Fri, 11 Jun 2010 03:40:37 -0400
Message-ID: <1276242039-18649-6-git-send-email-iisaman@netapp.com>
References: <1276242039-18649-1-git-send-email-iisaman@netapp.com>
 <1276242039-18649-2-git-send-email-iisaman@netapp.com>
 <1276242039-18649-3-git-send-email-iisaman@netapp.com>
 <1276242039-18649-4-git-send-email-iisaman@netapp.com>
 <1276242039-18649-5-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32582 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752869Ab0FKHk5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:40:57 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7eoVf027834
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:40:56 -0700 (PDT)
In-Reply-To: <1276242039-18649-5-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 43a5617..77e9512 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -1115,12 +1115,10 @@ bl_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	   struct nfs_page *req)
 {
 	dprintk("%s enter\n", __func__);
-	if (pgio->pg_iswrite) {
-		return test_bit(PG_USE_PNFS, &prev->wb_flags) ==
-			test_bit(PG_USE_PNFS, &req->wb_flags);
-	} else {
+	if (pgio->pg_iswrite)
+		return prev->wb_lseg == req->wb_lseg;
+	else
 		return 1;
-	}
 }
 
 static struct layoutdriver_io_operations blocklayout_io_operations = {
-- 
1.6.6.1

