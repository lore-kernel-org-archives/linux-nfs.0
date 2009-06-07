From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/2] SQUASHME: panlayout: fix CONFIG_PNFS_PANLAYOUT dependencies
Date: Sun,  7 Jun 2009 18:16:54 +0300
Message-ID: <1244387814-3504-1-git-send-email-bhalevy@panasas.com>
References: <b493f8670906040151w2e0fd2afpd8f645b0a5bfcbc4@mail.gmail.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	bharrosh@panasas.com, Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:24074
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753073AbZFGPQ7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Jun 2009 11:16:59 -0400
In-Reply-To: <b493f8670906040151w2e0fd2afpd8f645b0a5bfcbc4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So that it will conform to CONFIG_NFS_FS's configuration.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 514d2fb..b75fab6 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -95,9 +95,9 @@ config PNFS
 
 config PNFS_PANLAYOUT
 	tristate "Provide support for the Panasas OSD Layout Driver for NFSv4.1 pNFS (EXPERIMENTAL)"
-	depends on PNFS
+	depends on NFS_FS && PNFS
 	help
-	  Say M here if you want your pNFS client to support the Panasas OSD Layout Driver
+	  Say M or y here if you want your pNFS client to support the Panasas OSD Layout Driver.
 
 	  If unsure, say N.
 
-- 
1.6.3

