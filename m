Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:43995 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763256AbdJQQOe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Oct 2017 12:14:34 -0400
From: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, davem@davemloft.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Cc: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 1/4] sunrpc: make the function arg as const
Date: Tue, 17 Oct 2017 18:14:23 +0200
Message-Id: <1508256866-12798-2-git-send-email-bhumirks@gmail.com>
In-Reply-To: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
References: <1508256866-12798-1-git-send-email-bhumirks@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make the struct cache_detail *tmpl argument of the function
cache_create_net as const as it is only getting passed to kmemup having
the argument as const void *.
Add const to the prototype too.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 include/linux/sunrpc/cache.h | 2 +-
 net/sunrpc/cache.c           | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 270bad0..40d2822 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -213,7 +213,7 @@ extern int cache_check(struct cache_detail *detail,
 extern int cache_register_net(struct cache_detail *cd, struct net *net);
 extern void cache_unregister_net(struct cache_detail *cd, struct net *net);
 
-extern struct cache_detail *cache_create_net(struct cache_detail *tmpl, struct net *net);
+extern struct cache_detail *cache_create_net(const struct cache_detail *tmpl, struct net *net);
 extern void cache_destroy_net(struct cache_detail *cd, struct net *net);
 
 extern void sunrpc_init_cache_detail(struct cache_detail *cd);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 79d55d9..e689438 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1674,7 +1674,7 @@ void cache_unregister_net(struct cache_detail *cd, struct net *net)
 }
 EXPORT_SYMBOL_GPL(cache_unregister_net);
 
-struct cache_detail *cache_create_net(struct cache_detail *tmpl, struct net *net)
+struct cache_detail *cache_create_net(const struct cache_detail *tmpl, struct net *net)
 {
 	struct cache_detail *cd;
 	int i;
-- 
1.9.1

