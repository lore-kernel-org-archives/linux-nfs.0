Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:57194 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170Ab1FSV60 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Jun 2011 17:58:26 -0400
Received: by pvg12 with SMTP id 12so266604pvg.19
        for <linux-nfs@vger.kernel.org>; Sun, 19 Jun 2011 14:58:26 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: file layout must consider pg_bsize for coalescing
Date: Sun, 19 Jun 2011 17:58:13 -0400
Message-Id: <1308520693-31114-1-git-send-email-benny@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Otherwise we end up overflowing the rpc buffer size on the receive end.
This bug was introduced in v3.0.

Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfs/nfs4filelayout.c |    4 +++-
 fs/nfs/pagelist.c       |    1 +
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 472f81f..51c1909 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -30,6 +30,7 @@
  */
 
 #include <linux/nfs_fs.h>
+#include <linux/nfs_page.h>
 
 #include "internal.h"
 #include "nfs4filelayout.h"
@@ -672,7 +673,8 @@ filelayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	u64 p_stripe, r_stripe;
 	u32 stripe_unit;
 
-	if (!pnfs_generic_pg_test(pgio, prev, req))
+	if (!pnfs_generic_pg_test(pgio, prev, req) ||
+	    !nfs_generic_pg_test(pgio, prev, req))
 		return false;
 
 	p_stripe = (u64)prev->wb_index << PAGE_CACHE_SHIFT;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index a46d827..d421e19 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -218,6 +218,7 @@ bool nfs_generic_pg_test(struct nfs_pageio_descriptor *desc, struct nfs_page *pr
 
 	return desc->pg_count + req->wb_bytes <= desc->pg_bsize;
 }
+EXPORT_SYMBOL_GPL(nfs_generic_pg_test);
 
 /**
  * nfs_pageio_init - initialise a page io descriptor
-- 
1.7.4.4

