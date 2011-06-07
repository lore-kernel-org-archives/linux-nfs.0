Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53598 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755865Ab1FGR3G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:29:06 -0400
Date: Tue, 7 Jun 2011 13:29:05 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 27/88] pnfsblock: read path error handling
Message-ID: <8807778f044cea23cfbacbdd3d3277b906cd943f.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Communicate between nfs_readpages and nfs_readpage any pnfs failures,
so that nfs_readpage can immediately default to mds.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 22ea965..99de9e3 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -151,10 +151,12 @@ static inline void
 bl_done_with_rpage(struct page *page, const int ok)
 {
 	if (ok) {
+		ClearPagePnfsErr(page);
 		SetPageUptodate(page);
 	} else {
 		ClearPageUptodate(page);
 		SetPageError(page);
+		SetPagePnfsErr(page);
 	}
 	/* Page is unlocked via rpc_release.  Should really be done here. */
 }
@@ -227,6 +229,13 @@ bl_read_pagelist(struct pnfs_layout_type *lo,
 		dprintk("%s dont_like_caller failed\n", __func__);
 		goto use_mds;
 	}
+	if ((nr_pages == 1) && PagePnfsErr(rdata->req->wb_page)) {
+		/* We want to fall back to mds in case of read_page
+		 * after error on read_pages.
+		 */
+		dprintk("%s PG_pnfserr set\n", __func__);
+		goto use_mds;
+	}
 	par = alloc_parallel(rdata);
 	if (!par)
 		goto use_mds;
-- 
1.7.4.1

