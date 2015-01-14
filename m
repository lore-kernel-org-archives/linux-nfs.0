Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:57625 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858AbbANJAk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jan 2015 04:00:40 -0500
Received: from 213162068068.public.t-mobile.at ([213.162.68.68] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1YBJod-00070r-2Z
	for linux-nfs@vger.kernel.org; Wed, 14 Jan 2015 09:00:39 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfs/objlayout: wire up .alloc_device_id_node
Date: Wed, 14 Jan 2015 09:59:43 +0100
Message-Id: <1421225983-16583-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This fixes commit 661373b1 ("pnfs: factor GETDEVICEINFO implementations"),
which forgot to wire up the new method for the objlayout driver.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/objlayout/objio_osd.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 9e5bc42..ef2057f 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -634,6 +634,7 @@ static struct pnfs_layoutdriver_type objlayout_type = {
 	.pg_read_ops             = &objio_pg_read_ops,
 	.pg_write_ops            = &objio_pg_write_ops,
 
+	.alloc_deviceid_node	 = objio_alloc_deviceid_node,
 	.free_deviceid_node	 = objio_free_deviceid_node,
 
 	.encode_layoutcommit	 = objlayout_encode_layoutcommit,
-- 
1.9.1

