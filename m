Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20983 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753524Ab0IONFD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Sep 2010 09:05:03 -0400
Message-ID: <4C90BB0D.40408@parallels.com>
Date: Wed, 15 Sep 2010 16:24:45 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 1/9] sunrpc: Pass the ip_map_parse's cd to lower calls
References: <4C90BADB.10700@parallels.com>
In-Reply-To: <4C90BADB.10700@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The target is to have many ip_map_cache-s in the system. This particular
patch handles its usage by the ip_map_parse callback.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/sunrpc/svcauth_unix.c |   31 +++++++++++++++++++++----------
 1 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 2073116..1fe37be 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -178,8 +178,8 @@ static int ip_map_upcall(struct cache_detail *cd, struct cache_head *h)
 	return sunrpc_cache_pipe_upcall(cd, h, ip_map_request);
 }
 
-static struct ip_map *ip_map_lookup(char *class, struct in6_addr *addr);
-static int ip_map_update(struct ip_map *ipm, struct unix_domain *udom, time_t expiry);
+static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class, struct in6_addr *addr);
+static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm, struct unix_domain *udom, time_t expiry);
 
 static int ip_map_parse(struct cache_detail *cd,
 			  char *mesg, int mlen)
@@ -249,9 +249,9 @@ static int ip_map_parse(struct cache_detail *cd,
 		dom = NULL;
 
 	/* IPv6 scope IDs are ignored for now */
-	ipmp = ip_map_lookup(class, &sin6.sin6_addr);
+	ipmp = __ip_map_lookup(cd, class, &sin6.sin6_addr);
 	if (ipmp) {
-		err = ip_map_update(ipmp,
+		err = __ip_map_update(cd, ipmp,
 			     container_of(dom, struct unix_domain, h),
 			     expiry);
 	} else
@@ -309,14 +309,15 @@ struct cache_detail ip_map_cache = {
 	.alloc		= ip_map_alloc,
 };
 
-static struct ip_map *ip_map_lookup(char *class, struct in6_addr *addr)
+static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
+		struct in6_addr *addr)
 {
 	struct ip_map ip;
 	struct cache_head *ch;
 
 	strcpy(ip.m_class, class);
 	ipv6_addr_copy(&ip.m_addr, addr);
-	ch = sunrpc_cache_lookup(&ip_map_cache, &ip.h,
+	ch = sunrpc_cache_lookup(cd, &ip.h,
 				 hash_str(class, IP_HASHBITS) ^
 				 hash_ip6(*addr));
 
@@ -326,7 +327,13 @@ static struct ip_map *ip_map_lookup(char *class, struct in6_addr *addr)
 		return NULL;
 }
 
-static int ip_map_update(struct ip_map *ipm, struct unix_domain *udom, time_t expiry)
+static inline struct ip_map *ip_map_lookup(char *class, struct in6_addr *addr)
+{
+	return __ip_map_lookup(&ip_map_cache, class, addr);
+}
+
+static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
+		struct unix_domain *udom, time_t expiry)
 {
 	struct ip_map ip;
 	struct cache_head *ch;
@@ -344,16 +351,20 @@ static int ip_map_update(struct ip_map *ipm, struct unix_domain *udom, time_t ex
 			ip.m_add_change++;
 	}
 	ip.h.expiry_time = expiry;
-	ch = sunrpc_cache_update(&ip_map_cache,
-				 &ip.h, &ipm->h,
+	ch = sunrpc_cache_update(cd, &ip.h, &ipm->h,
 				 hash_str(ipm->m_class, IP_HASHBITS) ^
 				 hash_ip6(ipm->m_addr));
 	if (!ch)
 		return -ENOMEM;
-	cache_put(ch, &ip_map_cache);
+	cache_put(ch, cd);
 	return 0;
 }
 
+static inline int ip_map_update(struct ip_map *ipm, struct unix_domain *udom, time_t expiry)
+{
+	return __ip_map_update(&ip_map_cache, ipm, udom, expiry);
+}
+
 int auth_unix_add_addr(struct in6_addr *addr, struct auth_domain *dom)
 {
 	struct unix_domain *udom;
-- 
1.5.5.6

