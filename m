Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:24544 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752705Ab1LGI6D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Dec 2011 03:58:03 -0500
Subject: [PATCH v2] NFSd: use network-namespace-aware cache registering
 routines
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 07 Dec 2011 12:57:56 +0300
Message-ID: <20111207085741.7867.57700.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2: cache_register_net() and cache_unregister_net() GPL exports added

This is a cleanup patch. Hope, some day generic cache_register() and
cache_unregister() will be removed.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/export.c    |   10 +++++-----
 fs/nfsd/nfs4idmap.c |   11 ++++++-----
 net/sunrpc/cache.c  |    2 ++
 3 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 62f3b90..d1feeef 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1226,12 +1226,12 @@ nfsd_export_init(void)
 	int rv;
 	dprintk("nfsd: initializing export module.\n");
 
-	rv = cache_register(&svc_export_cache);
+	rv = cache_register_net(&svc_export_cache, &init_net);
 	if (rv)
 		return rv;
-	rv = cache_register(&svc_expkey_cache);
+	rv = cache_register_net(&svc_expkey_cache, &init_net);
 	if (rv)
-		cache_unregister(&svc_export_cache);
+		cache_unregister_net(&svc_export_cache, &init_net);
 	return rv;
 
 }
@@ -1255,8 +1255,8 @@ nfsd_export_shutdown(void)
 
 	dprintk("nfsd: shutting down export module.\n");
 
-	cache_unregister(&svc_expkey_cache);
-	cache_unregister(&svc_export_cache);
+	cache_unregister_net(&svc_expkey_cache, &init_net);
+	cache_unregister_net(&svc_export_cache, &init_net);
 	svcauth_unix_purge();
 
 	dprintk("nfsd: export shutdown complete.\n");
diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index 55780a2..9409627 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -36,6 +36,7 @@
 #include <linux/seq_file.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include <net/net_namespace.h>
 #include "idmap.h"
 #include "nfsd.h"
 
@@ -466,20 +467,20 @@ nfsd_idmap_init(void)
 {
 	int rv;
 
-	rv = cache_register(&idtoname_cache);
+	rv = cache_register_net(&idtoname_cache, &init_net);
 	if (rv)
 		return rv;
-	rv = cache_register(&nametoid_cache);
+	rv = cache_register_net(&nametoid_cache, &init_net);
 	if (rv)
-		cache_unregister(&idtoname_cache);
+		cache_unregister_net(&idtoname_cache, &init_net);
 	return rv;
 }
 
 void
 nfsd_idmap_shutdown(void)
 {
-	cache_unregister(&idtoname_cache);
-	cache_unregister(&nametoid_cache);
+	cache_unregister_net(&idtoname_cache, &init_net);
+	cache_unregister_net(&nametoid_cache, &init_net);
 }
 
 static int
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 72ad836..b8daa57 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1641,6 +1641,7 @@ int cache_register_net(struct cache_detail *cd, struct net *net)
 		sunrpc_destroy_cache_detail(cd);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(cache_register_net);
 
 int cache_register(struct cache_detail *cd)
 {
@@ -1653,6 +1654,7 @@ void cache_unregister_net(struct cache_detail *cd, struct net *net)
 	remove_cache_proc_entries(cd, net);
 	sunrpc_destroy_cache_detail(cd);
 }
+EXPORT_SYMBOL_GPL(cache_unregister_net);
 
 void cache_unregister(struct cache_detail *cd)
 {

