Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42566 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbbHQQoG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2015 12:44:06 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] pnfs/blocklayout: set up layoutupdate_pages properly
Date: Mon, 17 Aug 2015 18:40:58 +0200
Message-Id: <1439829661-1505-3-git-send-email-hch@lst.de>
In-Reply-To: <1439829661-1505-1-git-send-email-hch@lst.de>
References: <1439829661-1505-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to replace the __be32 with a void pointer to do proper arithmentics
on the virtual addresses so that we can get the right page pointers.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/extent_tree.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/blocklayout/extent_tree.c b/fs/nfs/blocklayout/extent_tree.c
index 7536036..a11b759 100644
--- a/fs/nfs/blocklayout/extent_tree.c
+++ b/fs/nfs/blocklayout/extent_tree.c
@@ -558,14 +558,11 @@ retry:
 	arg->layoutupdate_len = ext_tree_layoutupdate_size(count);
 
 	if (unlikely(arg->layoutupdate_pages != &arg->layoutupdate_page)) {
-		__be32 *p = start_p;
+		void *p = start_p, *end = p + arg->layoutupdate_len;
 		int i = 0;
 
-		for (p = start_p;
-		     p < start_p + arg->layoutupdate_len;
-		     p += PAGE_SIZE) {
+		for ( ; p < end; p += PAGE_SIZE)
 			arg->layoutupdate_pages[i++] = vmalloc_to_page(p);
-		}
 	}
 
 	dprintk("%s found %zu ranges\n", __func__, count);
-- 
1.9.1

