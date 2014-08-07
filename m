Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:45760 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753145AbaHGHVb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Aug 2014 03:21:31 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 01/17] nfs: cap request size to fit a kmalloced page array
Date: Thu,  7 Aug 2014 09:23:33 +0200
Message-Id: <1407396229-4785-2-git-send-email-hch@lst.de>
In-Reply-To: <1407396229-4785-1-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

pNFS servers may return arbitrarily large layouts.  Trim back the I/O size
to one that we can at least allocate the page array for.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/pagelist.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 9425118..23471b1 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -466,6 +466,14 @@ size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
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

