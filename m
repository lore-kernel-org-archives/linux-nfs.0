Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51686 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756768Ab1FGRdD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:33:03 -0400
Date: Tue, 7 Jun 2011 13:33:01 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 59/88] SQUASHME: pnfsblock: bl_write_pagelist adjust for
 missing PG_USE_PNFS
Message-ID: <6448ac4ae068b71c6eec04d86198966a1eb33029.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

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
1.7.4.1

