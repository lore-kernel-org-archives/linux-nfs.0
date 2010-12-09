Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from swampdragon.chaosbits.net ([90.184.90.115]:13864 "EHLO
	swampdragon.chaosbits.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757246Ab0LIWXy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Dec 2010 17:23:54 -0500
Date: Thu, 9 Dec 2010 23:17:15 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
To: linux-nfs@vger.kernel.org
cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] nfs: Take advantage of kmem_cache_zalloc() in
 nfs_page_alloc()
Message-ID: <alpine.LNX.2.00.1012092311340.25880@swampdragon.chaosbits.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Take advantage of kmem_cache_zalloc() in nfs_page_alloc(). Save a call to 
memset() and a few bytes.

Before:
 [jj@dragon linux-2.6]$ size fs/nfs/pagelist.o
    text    data     bss     dec     hex filename
    1765       0       8    1773     6ed fs/nfs/pagelist.o
After:
 [jj@dragon linux-2.6]$ size fs/nfs/pagelist.o
    text    data     bss     dec     hex filename
    1749       0       8    1757     6dd fs/nfs/pagelist.o


Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 pagelist.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 137b549..ecd08c3 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -26,12 +26,9 @@ static struct kmem_cache *nfs_page_cachep;
 static inline struct nfs_page *
 nfs_page_alloc(void)
 {
-	struct nfs_page	*p;
-	p = kmem_cache_alloc(nfs_page_cachep, GFP_KERNEL);
-	if (p) {
-		memset(p, 0, sizeof(*p));
+	struct nfs_page	*p = kmem_cache_zalloc(nfs_page_cachep, GFP_KERNEL);
+	if (p)
 		INIT_LIST_HEAD(&p->wb_list);
-	}
 	return p;
 }
 


-- 
Jesper Juhl <jj@chaosbits.net>            http://www.chaosbits.net/
Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please.

