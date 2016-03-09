Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34716 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676AbcCIOnb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Mar 2016 09:43:31 -0500
From: Christoph Hellwig <hch@lst.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: block and scsi layout drivers need to depend on CONFIG_BLOCK
Date: Wed,  9 Mar 2016 15:43:27 +0100
Message-Id: <1457534607-6925-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reported-by: Randy Dunlap <rdunlap@infradead.org>
---
 fs/nfsd/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index a30a313..c9f583d 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -88,7 +88,7 @@ config NFSD_PNFS
 
 config NFSD_BLOCKLAYOUT
 	bool "NFSv4.1 server support for pNFS block layouts"
-	depends on NFSD_V4
+	depends on NFSD_V4 && BLOCK
 	select NFSD_PNFS
 	help
 	  This option enables support for the exporting pNFS block layouts
@@ -100,7 +100,7 @@ config NFSD_BLOCKLAYOUT
 
 config NFSD_SCSILAYOUT
 	bool "NFSv4.1 server support for pNFS SCSI layouts"
-	depends on NFSD_V4
+	depends on NFSD_V4 && BLOCK
 	select NFSD_PNFS
 	help
 	  This option enables support for the exporting pNFS SCSI layouts
-- 
2.1.4

