Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.mpynet.fi ([82.197.21.85]:28056 "EHLO mx2.mpynet.fi"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751531AbdB1U3n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Feb 2017 15:29:43 -0500
From: Tomohiro Kusumi <tkusumi@tuxera.com>
To: <viro@zeniv.linux.org.uk>, <linux-fsdevel@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>
CC: Tomohiro Kusumi <tkusumi@tuxera.com>
Subject: [PATCH 3/3] fs/mpage: fix a comment "get_blocks" to "get_block"
Date: Tue, 28 Feb 2017 21:45:23 +0200
Message-ID: <20170228194523.2054-3-tkusumi@tuxera.com>
In-Reply-To: <20170228194523.2054-1-tkusumi@tuxera.com>
References: <20170228194523.2054-1-tkusumi@tuxera.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's a get_block_t argument get_block being called here.

Signed-off-by: Tomohiro Kusumi <tkusumi@tuxera.com>
---
 fs/mpage.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/mpage.c b/fs/mpage.c
index 28af984..67e9492 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -173,7 +173,7 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 	page_block = 0;
 
 	/*
-	 * Map blocks using the result from the previous get_blocks call first.
+	 * Map blocks using the result from the previous get_block call first.
 	 */
 	nblocks = map_bh->b_size >> blkbits;
 	if (buffer_mapped(map_bh) && block_in_file > *first_logical_block &&
@@ -197,7 +197,7 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 	}
 
 	/*
-	 * Then do more get_blocks calls until we are done with this page.
+	 * Then do more get_block calls until we are done with this page.
 	 */
 	map_bh->b_page = page;
 	while (page_block < blocks_per_page) {
-- 
2.9.3

