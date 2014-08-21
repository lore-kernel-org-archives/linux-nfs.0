Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:51172 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbaHUQHU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 12:07:20 -0400
Received: from ip-64-134-168-64.public.wayport.net ([64.134.168.64] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XKUtT-00008p-1Y
	for linux-nfs@vger.kernel.org; Thu, 21 Aug 2014 16:07:19 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/19] nfs: cap request size to fit a kmalloced page array
Date: Thu, 21 Aug 2014 11:09:17 -0500
Message-Id: <1408637375-11343-2-git-send-email-hch@lst.de>
In-Reply-To: <1408637375-11343-1-git-send-email-hch@lst.de>
References: <pnfs block layout driver fixes V2>
 <1408637375-11343-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pNFS servers may return arbitrarily large layouts.  Trim back the I/O size
to one that we can at least allocate the page array for.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/pagelist.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ba49192..74a4ff9 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -458,6 +458,14 @@ size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
 		return 0;
 	}
 
+	/*
+	 * Limit the request size so that we can still allocate a page array
+	 * for it without upsetting the slab allocator.
+	 */
+	if (((desc->pg_count + req->wb_bytes) >> PAGE_SHIFT) *
+			sizeof(struct page) > PAGE_SIZE)
+		return 0;
+
 	return min(desc->pg_bsize - desc->pg_count, (size_t)req->wb_bytes);
 }
 EXPORT_SYMBOL_GPL(nfs_generic_pg_test);
-- 
1.9.1

