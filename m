Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:37641 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbaICEgr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 00:36:47 -0400
Received: from [64.134.221.109] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XP2JJ-0003bv-TG
	for linux-nfs@vger.kernel.org; Wed, 03 Sep 2014 04:36:46 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] pnfs/blocklayout: ask for NOTIFY_DEVICEID callbacks
Date: Tue,  2 Sep 2014 21:38:39 -0700
Message-Id: <1409719119-2110-7-git-send-email-hch@lst.de>
In-Reply-To: <1409719119-2110-1-git-send-email-hch@lst.de>
References: <1409719119-2110-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index e92591c..30d6120 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -875,6 +875,8 @@ static struct pnfs_layoutdriver_type blocklayout_type = {
 	.owner				= THIS_MODULE,
 	.flags				= PNFS_LAYOUTRET_ON_SETATTR |
 					  PNFS_READ_WHOLE_PAGE,
+	.notify_types			= NOTIFY_DEVICEID4_CHANGE |
+					  NOTIFY_DEVICEID4_DELETE;
 	.read_pagelist			= bl_read_pagelist,
 	.write_pagelist			= bl_write_pagelist,
 	.alloc_layout_hdr		= bl_alloc_layout_hdr,
-- 
1.9.1

