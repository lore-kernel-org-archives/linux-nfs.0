Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gateway32.websitewelcome.com ([192.185.145.1]:43128 "EHLO
        gateway32.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726828AbeHBDGd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 23:06:33 -0400
Received: from cm17.websitewelcome.com (cm17.websitewelcome.com [100.42.49.20])
        by gateway32.websitewelcome.com (Postfix) with ESMTP id E395D2873CB
        for <linux-nfs@vger.kernel.org>; Wed,  1 Aug 2018 19:55:52 -0500 (CDT)
Date: Wed, 1 Aug 2018 19:55:51 -0500
From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] pnfs: Use true and false for boolean values
Message-ID: <20180802005551.GA27876@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return statements in functions returning bool should use true or false
instead of an integer value.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 fs/nfs/pnfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7020f72..5513dda 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1628,7 +1628,7 @@ pnfs_lseg_range_match(const struct pnfs_layout_range *ls_range,
 	    (range->iomode != ls_range->iomode &&
 	     strict_iomode) ||
 	    !pnfs_lseg_range_intersecting(ls_range, range))
-		return 0;
+		return false;
 
 	/* range1 covers only the first byte in the range */
 	range1 = *range;
-- 
2.7.4

