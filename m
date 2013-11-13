Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49096 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757277Ab3KMQud (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 11:50:33 -0500
Date: Wed, 13 Nov 2013 08:50:33 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] nfs: fix pnfs Kconfig defaults
Message-ID: <20131113165033.GA8676@infradead.org>
References: <20131102102201.GA3860@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131102102201.GA3860@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Defaulting to m seem to prevent building the pnfs layout modules into the
kernel.  Default to the value of CONFIG_NFS_V4 make sure they are
built in for built-in NFSv4 support and modular for a modular NFSv4.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/Kconfig |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux/fs/nfs/Kconfig
===================================================================
--- linux.orig/fs/nfs/Kconfig	2013-11-12 18:42:14.952113008 +0100
+++ linux/fs/nfs/Kconfig	2013-11-13 17:35:24.984154196 +0100
@@ -116,17 +116,17 @@ config NFS_V4_2
 config PNFS_FILE_LAYOUT
 	tristate
 	depends on NFS_V4_1
-	default m
+	default NFS_V4
 
 config PNFS_BLOCK
 	tristate
 	depends on NFS_V4_1 && BLK_DEV_DM
-	default m
+	default NFS_V4
 
 config PNFS_OBJLAYOUT
 	tristate
 	depends on NFS_V4_1 && SCSI_OSD_ULD
-	default m
+	default NFS_V4
 
 config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
 	string "NFSv4.1 Implementation ID Domain"
