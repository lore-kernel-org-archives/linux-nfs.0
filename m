Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2771 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753407Ab0LOQD0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 11:03:26 -0500
Received: from localhost.localdomain (vpn2ntap-71744.hq.netapp.com [10.58.57.236])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBFG3Lox001580
	for <linux-nfs@vger.kernel.org>; Wed, 15 Dec 2010 08:03:26 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/11] wave 2: remove table above should_free_lseg
Date: Wed, 15 Dec 2010 11:03:08 -0500
Message-Id: <1292428991-30788-8-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
References: <1292428991-30788-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The table doesn't add any useful information.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f2360af..f4e618d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -348,17 +348,6 @@ put_lseg(struct pnfs_layout_segment *lseg)
 }
 EXPORT_SYMBOL_GPL(put_lseg);
 
-/*
- * iomode matching rules:
- * range	lseg	match
- * -----	-----	-----
- * ANY		READ	true
- * ANY		RW	true
- * RW		READ	false
- * RW		RW	true
- * READ		READ	true
- * READ		RW	false
- */
 bool
 should_free_lseg(struct pnfs_layout_range *lseg_range,
 		 struct pnfs_layout_range *recall_range)
-- 
1.7.2.1

