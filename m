Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:46553 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756900Ab2ASRni (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jan 2012 12:43:38 -0500
Subject: [PATCH v2 5/5] SUNRPC: generic cache register routines removed
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Thu, 19 Jan 2012 21:42:53 +0400
Message-ID: <20120119174253.23767.73033.stgit@localhost6.localdomain6>
In-Reply-To: <20120119173823.23767.91876.stgit@localhost6.localdomain6>
References: <20120119173823.23767.91876.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All cache users now uses network-namespace-aware routines, so generic ones
are obsolete.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 include/linux/sunrpc/cache.h |    2 --
 net/sunrpc/cache.c           |   12 ------------
 2 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 259381c..f5fd616 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -198,9 +198,7 @@ extern void cache_flush(void);
 extern void cache_purge(struct cache_detail *detail);
 #define NEVER (0x7FFFFFFF)
 extern void __init cache_initialize(void);
-extern int cache_register(struct cache_detail *cd);
 extern int cache_register_net(struct cache_detail *cd, struct net *net);
-extern void cache_unregister(struct cache_detail *cd);
 extern void cache_unregister_net(struct cache_detail *cd, struct net *net);
 
 extern struct cache_detail *cache_create_net(struct cache_detail *tmpl, struct net *net);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index a450b8a..f21ece0 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1645,12 +1645,6 @@ int cache_register_net(struct cache_detail *cd, struct net *net)
 }
 EXPORT_SYMBOL_GPL(cache_register_net);
 
-int cache_register(struct cache_detail *cd)
-{
-	return cache_register_net(cd, &init_net);
-}
-EXPORT_SYMBOL_GPL(cache_register);
-
 void cache_unregister_net(struct cache_detail *cd, struct net *net)
 {
 	remove_cache_proc_entries(cd, net);
@@ -1658,12 +1652,6 @@ void cache_unregister_net(struct cache_detail *cd, struct net *net)
 }
 EXPORT_SYMBOL_GPL(cache_unregister_net);
 
-void cache_unregister(struct cache_detail *cd)
-{
-	cache_unregister_net(cd, &init_net);
-}
-EXPORT_SYMBOL_GPL(cache_unregister);
-
 struct cache_detail *cache_create_net(struct cache_detail *tmpl, struct net *net)
 {
 	struct cache_detail *cd;

