Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45894 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757230AbaIIQjB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 12:39:01 -0400
Received: from [50.247.105.171] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XRORX-00081Z-Vq
	for linux-nfs@vger.kernel.org; Tue, 09 Sep 2014 16:39:00 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 8/9] pnfs/blocklayout: return layouts on setattr
Date: Tue,  9 Sep 2014 09:40:52 -0700
Message-Id: <1410280853-3964-9-git-send-email-hch@lst.de>
In-Reply-To: <1410280853-3964-1-git-send-email-hch@lst.de>
References: <1410280853-3964-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This speads up truncate-heavy workloads like fsx by multiple orders of
magnitude.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index a7524c4..d5a2b87 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -799,7 +799,8 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.id				= LAYOUT_BLOCK_VOLUME,
 	.name				= "LAYOUT_BLOCK_VOLUME",
 	.owner				= THIS_MODULE,
-	.flags				= PNFS_READ_WHOLE_PAGE,
+	.flags				= PNFS_LAYOUTRET_ON_SETATTR |
+					  PNFS_READ_WHOLE_PAGE,
 	.read_pagelist			= bl_read_pagelist,
 	.write_pagelist			= bl_write_pagelist,
 	.alloc_layout_hdr		= bl_alloc_layout_hdr,
-- 
1.9.1

