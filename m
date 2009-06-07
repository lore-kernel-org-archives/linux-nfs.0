From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] SQUASHME: pnfs-block: fix CONFIG_PNFS_BLOCK dependencies
Date: Sun,  7 Jun 2009 18:17:00 +0300
Message-ID: <1244387820-3537-1-git-send-email-bhalevy@panasas.com>
References: <b493f8670906040151w2e0fd2afpd8f645b0a5bfcbc4@mail.gmail.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	bharrosh@panasas.com, Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:24057
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753073AbZFGPRE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Jun 2009 11:17:04 -0400
In-Reply-To: <b493f8670906040151w2e0fd2afpd8f645b0a5bfcbc4-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So that it will conform to CONFIG_NFS_FS's configuration.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/Kconfig |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index b75fab6..beaf1a7 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -102,12 +102,12 @@ config PNFS_PANLAYOUT
 	  If unsure, say N.
 
 config PNFS_BLOCK
-       tristate "Provide a pNFS block client (EXPERIMENTAL)"
-       depends on PNFS
-       help
-         Say Y here if you want your pNfs client to support the block protocol
+	tristate "Provide a pNFS block client (EXPERIMENTAL)"
+	depends on NFS_FS && PNFS
+	help
+	  Say M or y here if you want your pNfs client to support the block protocol
 
-         If unsure, say N.
+	  If unsure, say N.
 
 config ROOT_NFS
 	bool "Root file system on NFS"
-- 
1.6.3

