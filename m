Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:38835 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727575AbeIEX4q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 19:56:46 -0400
Received: by mail-it0-f68.google.com with SMTP id p129-v6so10973150ite.3
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 12:25:11 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id x198-v6sm1459928ite.19.2018.09.05.12.24.53
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 05 Sep 2018 12:25:03 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/7] pNFS: Don't zero out the array in nfs4_alloc_pages()
Date: Wed,  5 Sep 2018 15:23:54 -0400
Message-Id: <20180905192400.107485-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We don't need a zeroed out array, since it is immediately being filled.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7d9a51e6b847..6b5b2d36f502 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -965,7 +965,7 @@ static struct page **nfs4_alloc_pages(size_t size, gfp_t gfp_flags)
 	struct page **pages;
 	int i;
 
-	pages = kcalloc(size, sizeof(struct page *), gfp_flags);
+	pages = kmalloc_array(size, sizeof(struct page *), gfp_flags);
 	if (!pages) {
 		dprintk("%s: can't alloc array of %zu pages\n", __func__, size);
 		return NULL;
@@ -975,7 +975,7 @@ static struct page **nfs4_alloc_pages(size_t size, gfp_t gfp_flags)
 		pages[i] = alloc_page(gfp_flags);
 		if (!pages[i]) {
 			dprintk("%s: failed to allocate page\n", __func__);
-			nfs4_free_pages(pages, size);
+			nfs4_free_pages(pages, i);
 			return NULL;
 		}
 	}
-- 
2.17.1
