Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 206.83.70.73.ptr.us.xo.net ([206.83.70.73]:29681 "EHLO
	king.tilera.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab1HJSVs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2011 14:21:48 -0400
Message-Id: <201108101803.p7AI36eV008484@farm-0023.internal.tilera.com>
From: Chris Metcalf <cmetcalf@tilera.com>
Date: Wed, 10 Aug 2011 13:56:28 -0400
Subject: [PATCH] nfs: fix a couple of minor portability issues
To: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Building on tilepro revealed two minor portability issues: the
blocklayout.c file used prefetchw() without #include <linux/prefetch.h>,
and the nfs4filelayout.c file used do_div() on an s64 not a u64.
This change fixes those two issues so the NFS code builds on tilepro.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 fs/nfs/blocklayout/blocklayout.c |    1 +
 fs/nfs/nfs4filelayout.c          |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index e56564d..9561c8f 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -36,6 +36,7 @@
 #include <linux/namei.h>
 #include <linux/bio.h>		/* struct bio */
 #include <linux/buffer_head.h>	/* various write calls */
+#include <linux/prefetch.h>
 
 #include "blocklayout.h"
 
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e8915d4..6976a72 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -48,13 +48,13 @@ filelayout_get_dense_offset(struct nfs4_filelayout_segment *flseg,
 			    loff_t offset)
 {
 	u32 stripe_width = flseg->stripe_unit * flseg->dsaddr->stripe_count;
-	u64 tmp;
+	u64 tmp, uoff;
 
 	offset -= flseg->pattern_offset;
-	tmp = offset;
+	tmp = uoff = offset;
 	do_div(tmp, stripe_width);
 
-	return tmp * flseg->stripe_unit + do_div(offset, flseg->stripe_unit);
+	return tmp * flseg->stripe_unit + do_div(uoff, flseg->stripe_unit);
 }
 
 /* This function is used by the layout driver to calculate the
-- 
1.6.5.2

