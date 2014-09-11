Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:53134 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbaIKAeU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 20:34:20 -0400
Received: from ip-64-134-224-54.public.wayport.net ([64.134.224.54] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XRsL4-000832-Sr
	for linux-nfs@vger.kernel.org; Thu, 11 Sep 2014 00:34:19 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] pnfs/objlayout: fix endianess annotation in objio_alloc_deviceid_node
Date: Wed, 10 Sep 2014 17:36:29 -0700
Message-Id: <1410395791-2385-3-git-send-email-hch@lst.de>
In-Reply-To: <1410395791-2385-1-git-send-email-hch@lst.de>
References: <1410395791-2385-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kbuild test robot complained about a new sparse warning in
objio_alloc_deviceid_node, but it turns out that this was just a moved
reference to an existing variable.  Fix it to have the right big endian
annotated type.

Note that there are some other endianess issues in this file that I didn't
bother to sort out as they involve global headers.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/objlayout/objio_osd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index c502f64..c6e4bda 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -93,7 +93,7 @@ objio_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 	struct osd_dev *od;
 	struct osd_dev_info odi;
 	bool retry_flag = true;
-	u32 *p;
+	__be32 *p;
 	int err;
 
 	deviceaddr = kzalloc(sizeof(*deviceaddr), gfp_flags);
-- 
1.9.1

