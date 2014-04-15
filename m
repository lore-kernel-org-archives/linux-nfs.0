Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f51.google.com ([209.85.220.51]:42736 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbaDOJOY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2014 05:14:24 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so9422113pab.10
        for <linux-nfs@vger.kernel.org>; Tue, 15 Apr 2014 02:14:24 -0700 (PDT)
Message-ID: <534CF854.30100@gmail.com>
Date: Tue, 15 Apr 2014 17:13:56 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
CC: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] SUNRPC: Fix printk that is not only for nfsd
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/cache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index ae333c1..0663621 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -374,7 +374,7 @@ void sunrpc_destroy_cache_detail(struct cache_detail
*cd)
 	}
 	return;
 out:
-	printk(KERN_ERR "nfsd: failed to unregister %s cache\n", cd->name);
+	printk(KERN_ERR "RPC: failed to unregister %s cache\n", cd->name);
 }
 EXPORT_SYMBOL_GPL(sunrpc_destroy_cache_detail);

-- 
1.9.0

