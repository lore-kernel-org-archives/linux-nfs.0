Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:60449
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753912AbbIMM0H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Sep 2015 08:26:07 -0400
From: Julia Lawall <Julia.Lawall@lip6.fr>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: sergey.senozhatsky@gmail.com, kernel-janitors@vger.kernel.org,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 22/39] nfsd: drop null test before destroy functions
Date: Sun, 13 Sep 2015 14:15:15 +0200
Message-Id: <1442146532-9100-23-git-send-email-Julia.Lawall@lip6.fr>
In-Reply-To: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
References: <1442146532-9100-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove unneeded NULL test.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@ expression x; @@
-if (x != NULL) {
  \(kmem_cache_destroy\|mempool_destroy\|dma_pool_destroy\)(x);
  x = NULL;
-}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 fs/nfsd/nfscache.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 46ec934..116940c 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -217,10 +217,8 @@ void nfsd_reply_cache_shutdown(void)
 	drc_hashtbl = NULL;
 	drc_hashsize = 0;
 
-	if (drc_slab) {
-		kmem_cache_destroy(drc_slab);
-		drc_slab = NULL;
-	}
+	kmem_cache_destroy(drc_slab);
+	drc_slab = NULL;
 }
 
 /*

