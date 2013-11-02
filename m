Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59452 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab3KBKWO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Nov 2013 06:22:14 -0400
Date: Sat, 2 Nov 2013 03:22:01 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix pnfs Kconfig defaults
Message-ID: <20131102102201.GA3860@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Defaulting to m seem to prevent building the pnfs layout modules into the
kernel.  Default to the value of CONFIG_NFS_FS make sure they are
built in for a built-in NFS and modular for a modular NFS.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/Kconfig |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index b5e80b0..f731180 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -116,17 +116,17 @@ config NFS_V4_2
 config PNFS_FILE_LAYOUT
 	tristate
 	depends on NFS_V4_1
-	default m
+	default NFS_FS
 
 config PNFS_BLOCK
 	tristate
 	depends on NFS_V4_1 && BLK_DEV_DM
-	default m
+	default NFS_FS
 
 config PNFS_OBJLAYOUT
 	tristate
 	depends on NFS_V4_1 && SCSI_OSD_ULD
-	default m
+	default NFS_FS
 
 config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
 	string "NFSv4.1 Implementation ID Domain"
-- 
1.7.10.4

