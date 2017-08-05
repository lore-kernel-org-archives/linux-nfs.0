Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:55413 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdHEI7S (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Aug 2017 04:59:18 -0400
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] =?UTF-8?q?pnfs/blocklayout:=20require=2064-bit=20=D1=95ec?= =?UTF-8?q?tor=5Ft?=
Date: Sat,  5 Aug 2017 10:59:14 +0200
Message-Id: <20170805085914.3188-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The blocklayout code does not compile cleanly for a 32-bit sector_t,
and also has no reliable checks for devices sizes, which makes it
unsafe to use with a kernel that doesn't support large block devices.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reported-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 5c83746a0cf2 ("pnfs/blocklayout: in-kernel GETDEVICEINFO XDR parsing")
---
 fs/nfs/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 69d02cf8cf37..5f93cfacb3d1 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -121,6 +121,7 @@ config PNFS_FILE_LAYOUT
 config PNFS_BLOCK
 	tristate
 	depends on NFS_V4_1 && BLK_DEV_DM
+	depends on 64BIT || LBDAF
 	default NFS_V4
 
 config PNFS_FLEXFILE_LAYOUT
-- 
2.11.0

