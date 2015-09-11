Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33676 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbbIKDOp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2015 23:14:45 -0400
Received: by pacex6 with SMTP id ex6so61477869pac.0
        for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2015 20:14:45 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Peng Tao <tao.peng@primarydata.com>, Christoph Hellwig <hch@lst.de>
Subject: [PATCH] nfs: fix pg_test page count calculation
Date: Fri, 11 Sep 2015 11:14:06 +0800
Message-Id: <1441941246-52981-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We really want sizeof(struct page *) instead. Otherwise we limit
maximum IO size to 64 pages rather than 512 pages on a 64bit system.

Fixes 2e11f829(nfs: cap request size to fit a kmalloced page array).

Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/pagelist.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 7c5718b..fe3ddd2 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -508,7 +508,7 @@ size_t nfs_generic_pg_test(struct nfs_pageio_descriptor *desc,
 	 * for it without upsetting the slab allocator.
 	 */
 	if (((mirror->pg_count + req->wb_bytes) >> PAGE_SHIFT) *
-			sizeof(struct page) > PAGE_SIZE)
+			sizeof(struct page *) > PAGE_SIZE)
 		return 0;
 
 	return min(mirror->pg_bsize - mirror->pg_count, (size_t)req->wb_bytes);
-- 
1.8.3.1

