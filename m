Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54043 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756710Ab1FPPh2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2011 11:37:28 -0400
Message-ID: <4DFA2327.800@panasas.com>
Date: Thu, 16 Jun 2011 11:37:11 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] SQUASHME pnfs-blocks: mds_offset is set in the generic
 layer
References: <4DF9278A.5010103@panasas.com>
In-Reply-To: <4DF9278A.5010103@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 8843df4..8531fd7 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -495,8 +495,6 @@ bl_write_pagelist(struct nfs_write_data *wdata,
 	wdata->res.count = (isect << 9) - (offset);
 	if (count < wdata->res.count)
 		wdata->res.count = count;
-	/* pnfs_set_layoutcommit needs this */
-	wdata->mds_offset = offset;
 	put_extent(be);
 	bl_submit_bio(WRITE, bio);
 	put_parallel(par);
-- 
1.7.3.4


