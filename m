Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:8909 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932809Ab0I0KCl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 06:02:41 -0400
Message-ID: <4CA06BB5.2080808@parallels.com>
Date: Mon, 27 Sep 2010 14:02:29 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 9/9] sunrpc: Make the ip_map_cache be per-net
References: <4CA06A63.6090507@parallels.com>
In-Reply-To: <4CA06A63.6090507@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Everything that is required for that already exists:
* the per-net cache registration with respective proc entries
* the context (struct net) is available in all the users

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/netns.h        |    6 ++
 net/sunrpc/sunrpc_syms.c  |   11 +++-
 net/sunrpc/svcauth_unix.c |  122 ++++++++++++++++++++++++++++++++++----------
 3 files changed, 108 insertions(+), 31 deletions(-)

diff --git a/net/sunrpc/netns.h b/net/sunrpc/netns.h
index e52ce89..d013bf2 100644
--- a/net/sunrpc/netns.h
+++ b/net/sunrpc/netns.h
@@ -4,10 +4,16 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
+struct cache_detail;
+
 struct sunrpc_net {
 	struct proc_dir_entry *proc_net_rpc;
+	struct cache_detail *ip_map_cache;
 };
 
 extern int sunrpc_net_id;
 
+int ip_map_cache_create(struct net *);
+void ip_map_cache_destroy(struct net *);
+
 #endif
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index c076af8..9d08091 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -34,14 +34,21 @@ static __net_init int sunrpc_init_net(struct net *net)
 	if (err)
 		goto err_proc;
 
+	err = ip_map_cache_create(net);
+	if (err)
+		goto err_ipmap;
+
 	return 0;
 
+err_ipmap:
+	rpc_proc_exit(net);
 err_proc:
 	return err;
 }
 
 static __net_exit void sunrpc_exit_net(struct net *net)
 {
+	ip_map_cache_destroy(net);
 	rpc_proc_exit(net);
 }
 
@@ -52,7 +59,7 @@ static struct pernet_operations sunrpc_net_ops = {
 	.size = sizeof(struct sunrpc_net),
 };
 
-extern struct cache_detail ip_map_cache, unix_gid_cache;
+extern struct cache_detail unix_gid_cache;
 
 extern void cleanup_rpcb_clnt(void);
 
@@ -77,7 +84,6 @@ init_sunrpc(void)
 #ifdef RPC_DEBUG
 	rpc_register_sysctl();
 #endif
-	cache_register(&ip_map_cache);
 	cache_register(&unix_gid_cache);
 	svc_init_xprt_sock();	/* svc sock transport */
 	init_socket_xprt();	/* clnt sock transport */
@@ -102,7 +108,6 @@ cleanup_sunrpc(void)
 	svc_cleanup_xprt_sock();
 	unregister_rpc_pipefs();
 	rpc_destroy_mempool();
-	cache_unregister(&ip_map_cache);
 	cache_unregister(&unix_gid_cache);
 	unregister_pernet_subsys(&sunrpc_net_ops);
 #ifdef RPC_DEBUG
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 2a76c7c..8b378f9 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -18,6 +18,8 @@
 
 #include <linux/sunrpc/clnt.h>
 
+#include "netns.h"
+
 /*
  * AUTHUNIX and AUTHNULL credentials are both handled here.
  * AUTHNULL is treated just like AUTHUNIX except that the uid/gid
@@ -92,7 +94,6 @@ struct ip_map {
 	struct unix_domain	*m_client;
 	int			m_add_change;
 };
-static struct cache_head	*ip_table[IP_HASHMAX];
 
 static void ip_map_put(struct kref *kref)
 {
@@ -294,21 +295,6 @@ static int ip_map_show(struct seq_file *m,
 }
 
 
-struct cache_detail ip_map_cache = {
-	.owner		= THIS_MODULE,
-	.hash_size	= IP_HASHMAX,
-	.hash_table	= ip_table,
-	.name		= "auth.unix.ip",
-	.cache_put	= ip_map_put,
-	.cache_upcall	= ip_map_upcall,
-	.cache_parse	= ip_map_parse,
-	.cache_show	= ip_map_show,
-	.match		= ip_map_match,
-	.init		= ip_map_init,
-	.update		= update,
-	.alloc		= ip_map_alloc,
-};
-
 static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
 		struct in6_addr *addr)
 {
@@ -330,7 +316,10 @@ static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
 static inline struct ip_map *ip_map_lookup(struct net *net, char *class,
 		struct in6_addr *addr)
 {
-	return __ip_map_lookup(&ip_map_cache, class, addr);
+	struct sunrpc_net *sn;
+
+	sn = net_generic(net, sunrpc_net_id);
+	return __ip_map_lookup(sn->ip_map_cache, class, addr);
 }
 
 static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
@@ -364,7 +353,10 @@ static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
 static inline int ip_map_update(struct net *net, struct ip_map *ipm,
 		struct unix_domain *udom, time_t expiry)
 {
-	return __ip_map_update(&ip_map_cache, ipm, udom, expiry);
+	struct sunrpc_net *sn;
+
+	sn = net_generic(net, sunrpc_net_id);
+	return __ip_map_update(sn->ip_map_cache, ipm, udom, expiry);
 }
 
 int auth_unix_add_addr(struct net *net, struct in6_addr *addr, struct auth_domain *dom)
@@ -400,12 +392,14 @@ struct auth_domain *auth_unix_lookup(struct net *net, struct in6_addr *addr)
 {
 	struct ip_map *ipm;
 	struct auth_domain *rv;
+	struct sunrpc_net *sn;
 
+	sn = net_generic(net, sunrpc_net_id);
 	ipm = ip_map_lookup(net, "nfsd", addr);
 
 	if (!ipm)
 		return NULL;
-	if (cache_check(&ip_map_cache, &ipm->h, NULL))
+	if (cache_check(sn->ip_map_cache, &ipm->h, NULL))
 		return NULL;
 
 	if ((ipm->m_client->addr_changes - ipm->m_add_change) >0) {
@@ -416,14 +410,21 @@ struct auth_domain *auth_unix_lookup(struct net *net, struct in6_addr *addr)
 		rv = &ipm->m_client->h;
 		kref_get(&rv->ref);
 	}
-	cache_put(&ipm->h, &ip_map_cache);
+	cache_put(&ipm->h, sn->ip_map_cache);
 	return rv;
 }
 EXPORT_SYMBOL_GPL(auth_unix_lookup);
 
 void svcauth_unix_purge(void)
 {
-	cache_purge(&ip_map_cache);
+	struct net *net;
+
+	for_each_net(net) {
+		struct sunrpc_net *sn;
+
+		sn = net_generic(net, sunrpc_net_id);
+		cache_purge(sn->ip_map_cache);
+	}
 }
 EXPORT_SYMBOL_GPL(svcauth_unix_purge);
 
@@ -431,6 +432,7 @@ static inline struct ip_map *
 ip_map_cached_get(struct svc_xprt *xprt)
 {
 	struct ip_map *ipm = NULL;
+	struct sunrpc_net *sn;
 
 	if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags)) {
 		spin_lock(&xprt->xpt_lock);
@@ -442,9 +444,10 @@ ip_map_cached_get(struct svc_xprt *xprt)
 				 * remembered, e.g. by a second mount from the
 				 * same IP address.
 				 */
+				sn = net_generic(xprt->xpt_net, sunrpc_net_id);
 				xprt->xpt_auth_cache = NULL;
 				spin_unlock(&xprt->xpt_lock);
-				cache_put(&ipm->h, &ip_map_cache);
+				cache_put(&ipm->h, sn->ip_map_cache);
 				return NULL;
 			}
 			cache_get(&ipm->h);
@@ -466,8 +469,12 @@ ip_map_cached_put(struct svc_xprt *xprt, struct ip_map *ipm)
 		}
 		spin_unlock(&xprt->xpt_lock);
 	}
-	if (ipm)
-		cache_put(&ipm->h, &ip_map_cache);
+	if (ipm) {
+		struct sunrpc_net *sn;
+
+		sn = net_generic(xprt->xpt_net, sunrpc_net_id);
+		cache_put(&ipm->h, sn->ip_map_cache);
+	}
 }
 
 void
@@ -476,8 +483,12 @@ svcauth_unix_info_release(struct svc_xprt *xpt)
 	struct ip_map *ipm;
 
 	ipm = xpt->xpt_auth_cache;
-	if (ipm != NULL)
-		cache_put(&ipm->h, &ip_map_cache);
+	if (ipm != NULL) {
+		struct sunrpc_net *sn;
+
+		sn = net_generic(xpt->xpt_net, sunrpc_net_id);
+		cache_put(&ipm->h, sn->ip_map_cache);
+	}
 }
 
 /****************************************************************************
@@ -707,6 +718,8 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 	struct group_info *gi;
 	struct svc_cred *cred = &rqstp->rq_cred;
 	struct svc_xprt *xprt = rqstp->rq_xprt;
+	struct net *net = xprt->xpt_net;
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
 	switch (rqstp->rq_addr.ss_family) {
 	case AF_INET:
@@ -727,13 +740,13 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 
 	ipm = ip_map_cached_get(xprt);
 	if (ipm == NULL)
-		ipm = ip_map_lookup(&init_net, rqstp->rq_server->sv_program->pg_class,
+		ipm = __ip_map_lookup(sn->ip_map_cache, rqstp->rq_server->sv_program->pg_class,
 				    &sin6->sin6_addr);
 
 	if (ipm == NULL)
 		return SVC_DENIED;
 
-	switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
+	switch (cache_check(sn->ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
 		default:
 			BUG();
 		case -ETIMEDOUT:
@@ -905,3 +918,56 @@ struct auth_ops svcauth_unix = {
 	.set_client	= svcauth_unix_set_client,
 };
 
+int ip_map_cache_create(struct net *net)
+{
+	int err = -ENOMEM;
+	struct cache_detail *cd;
+	struct cache_head **tbl;
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+
+	cd = kzalloc(sizeof(struct cache_detail), GFP_KERNEL);
+	if (cd == NULL)
+		goto err_cd;
+
+	tbl = kzalloc(IP_HASHMAX * sizeof(struct cache_head *), GFP_KERNEL);
+	if (tbl == NULL)
+		goto err_tbl;
+
+	cd->owner = THIS_MODULE,
+	cd->hash_size = IP_HASHMAX,
+	cd->hash_table = tbl,
+	cd->name = "auth.unix.ip",
+	cd->cache_put = ip_map_put,
+	cd->cache_upcall = ip_map_upcall,
+	cd->cache_parse = ip_map_parse,
+	cd->cache_show = ip_map_show,
+	cd->match = ip_map_match,
+	cd->init = ip_map_init,
+	cd->update = update,
+	cd->alloc = ip_map_alloc,
+
+	err = cache_register_net(cd, net);
+	if (err)
+		goto err_reg;
+
+	sn->ip_map_cache = cd;
+	return 0;
+
+err_reg:
+	kfree(tbl);
+err_tbl:
+	kfree(cd);
+err_cd:
+	return err;
+}
+
+void ip_map_cache_destroy(struct net *net)
+{
+	struct sunrpc_net *sn;
+
+	sn = net_generic(net, sunrpc_net_id);
+	cache_purge(sn->ip_map_cache);
+	cache_unregister_net(sn->ip_map_cache, net);
+	kfree(sn->ip_map_cache->hash_table);
+	kfree(sn->ip_map_cache);
+}
-- 
1.5.5.6

