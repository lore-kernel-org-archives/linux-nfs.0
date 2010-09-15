Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20983 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753567Ab0IONFF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 09:05:05 -0400
Message-ID: <4C90BB7D.5070208@parallels.com>
Date: Wed, 15 Sep 2010 16:26:37 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 4/9] sunrpc: Add net to pure API calls
References: <4C90BADB.10700@parallels.com>
In-Reply-To: <4C90BADB.10700@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

There are two calls that operate on ip_map_cache and are
directly called from the nfsd code. Other places will be
handled in a different way.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 fs/nfsd/export.c               |    2 +-
 fs/nfsd/nfsctl.c               |    4 ++--
 include/linux/sunrpc/svcauth.h |    4 ++--
 net/sunrpc/svcauth_unix.c      |   18 ++++++++++--------
 4 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index c2a4f71..3195e8b 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1563,7 +1563,7 @@ exp_addclient(struct nfsctl_client *ncp)
 	/* Insert client into hashtable. */
 	for (i = 0; i < ncp->cl_naddr; i++) {
 		ipv6_addr_set_v4mapped(ncp->cl_addrlist[i].s_addr, &addr6);
-		auth_unix_add_addr(&addr6, dom);
+		auth_unix_add_addr(&init_net, &addr6, dom);
 	}
 	auth_unix_forget_old(dom);
 	auth_domain_put(dom);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index b53b1d0..b31fe5a 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -401,7 +401,7 @@ static ssize_t write_getfs(struct file *file, char *buf, size_t size)
 
 	ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
 
-	clp = auth_unix_lookup(&in6);
+	clp = auth_unix_lookup(&init_net, &in6);
 	if (!clp)
 		err = -EPERM;
 	else {
@@ -464,7 +464,7 @@ static ssize_t write_getfd(struct file *file, char *buf, size_t size)
 
 	ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &in6);
 
-	clp = auth_unix_lookup(&in6);
+	clp = auth_unix_lookup(&init_net, &in6);
 	if (!clp)
 		err = -EPERM;
 	else {
diff --git a/include/linux/sunrpc/svcauth.h b/include/linux/sunrpc/svcauth.h
index f656667..fb1bb2c 100644
--- a/include/linux/sunrpc/svcauth.h
+++ b/include/linux/sunrpc/svcauth.h
@@ -122,10 +122,10 @@ extern void	svc_auth_unregister(rpc_authflavor_t flavor);
 
 extern struct auth_domain *unix_domain_find(char *name);
 extern void auth_domain_put(struct auth_domain *item);
-extern int auth_unix_add_addr(struct in6_addr *addr, struct auth_domain *dom);
+extern int auth_unix_add_addr(struct net *net, struct in6_addr *addr, struct auth_domain *dom);
 extern struct auth_domain *auth_domain_lookup(char *name, struct auth_domain *new);
 extern struct auth_domain *auth_domain_find(char *name);
-extern struct auth_domain *auth_unix_lookup(struct in6_addr *addr);
+extern struct auth_domain *auth_unix_lookup(struct net *net, struct in6_addr *addr);
 extern int auth_unix_forget_old(struct auth_domain *dom);
 extern void svcauth_unix_purge(void);
 extern void svcauth_unix_info_release(struct svc_xprt *xpt);
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index f0017ca..4500fd8 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -327,7 +327,8 @@ static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
 		return NULL;
 }
 
-static inline struct ip_map *ip_map_lookup(char *class, struct in6_addr *addr)
+static inline struct ip_map *ip_map_lookup(struct net *net, char *class,
+		struct in6_addr *addr)
 {
 	return __ip_map_lookup(&ip_map_cache, class, addr);
 }
@@ -360,12 +361,13 @@ static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
 	return 0;
 }
 
-static inline int ip_map_update(struct ip_map *ipm, struct unix_domain *udom, time_t expiry)
+static inline int ip_map_update(struct net *net, struct ip_map *ipm,
+		struct unix_domain *udom, time_t expiry)
 {
 	return __ip_map_update(&ip_map_cache, ipm, udom, expiry);
 }
 
-int auth_unix_add_addr(struct in6_addr *addr, struct auth_domain *dom)
+int auth_unix_add_addr(struct net *net, struct in6_addr *addr, struct auth_domain *dom)
 {
 	struct unix_domain *udom;
 	struct ip_map *ipmp;
@@ -373,10 +375,10 @@ int auth_unix_add_addr(struct in6_addr *addr, struct auth_domain *dom)
 	if (dom->flavour != &svcauth_unix)
 		return -EINVAL;
 	udom = container_of(dom, struct unix_domain, h);
-	ipmp = ip_map_lookup("nfsd", addr);
+	ipmp = ip_map_lookup(net, "nfsd", addr);
 
 	if (ipmp)
-		return ip_map_update(ipmp, udom, NEVER);
+		return ip_map_update(net, ipmp, udom, NEVER);
 	else
 		return -ENOMEM;
 }
@@ -394,12 +396,12 @@ int auth_unix_forget_old(struct auth_domain *dom)
 }
 EXPORT_SYMBOL_GPL(auth_unix_forget_old);
 
-struct auth_domain *auth_unix_lookup(struct in6_addr *addr)
+struct auth_domain *auth_unix_lookup(struct net *net, struct in6_addr *addr)
 {
 	struct ip_map *ipm;
 	struct auth_domain *rv;
 
-	ipm = ip_map_lookup("nfsd", addr);
+	ipm = ip_map_lookup(net, "nfsd", addr);
 
 	if (!ipm)
 		return NULL;
@@ -723,7 +725,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 
 	ipm = ip_map_cached_get(xprt);
 	if (ipm == NULL)
-		ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
+		ipm = ip_map_lookup(&init_net, rqstp->rq_server->sv_program->pg_class,
 				    &sin6->sin6_addr);
 
 	if (ipm == NULL)
-- 
1.5.5.6

