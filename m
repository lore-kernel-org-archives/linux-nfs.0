Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51590 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752470AbdF3NYt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:24:49 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 14/14] SUNRPC: add AF_VSOCK support to auth.unix.ip
Date: Fri, 30 Jun 2017 14:23:52 +0100
Message-Id: <20170630132352.32133-15-stefanha@redhat.com>
In-Reply-To: <20170630132352.32133-1-stefanha@redhat.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The ip_map currently supports AF_INET and AF_INET6.  It actually
converts IPv4 to IPv6 addresses.  We can't do that for AF_VSOCK but a
union will allow both IPv6 and vsock sockaddr structs to be used.

The cache userspace interface now supports 'vsock:CID' syntax for
AF_VSOCK addresses.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/svcauth_unix.c | 146 ++++++++++++++++++++++++++++++++++++----------
 1 file changed, 115 insertions(+), 31 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index f81eaa8..b33ea0b 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -89,7 +89,15 @@ EXPORT_SYMBOL_GPL(unix_domain_find);
 struct ip_map {
 	struct cache_head	h;
 	char			m_class[8]; /* e.g. "nfsd" */
-	struct in6_addr		m_addr;
+	union {
+		struct sockaddr		m_sa;
+
+		/* For AF_INET6 and AF_INET (we map to IPv6) */
+		struct sockaddr_in6	m_sin6;
+
+		/* For AF_VSOCK */
+		struct sockaddr_vm	m_svm;
+	};
 	struct unix_domain	*m_client;
 };
 
@@ -112,8 +120,22 @@ static int ip_map_match(struct cache_head *corig, struct cache_head *cnew)
 {
 	struct ip_map *orig = container_of(corig, struct ip_map, h);
 	struct ip_map *new = container_of(cnew, struct ip_map, h);
-	return strcmp(orig->m_class, new->m_class) == 0 &&
-	       ipv6_addr_equal(&orig->m_addr, &new->m_addr);
+
+	if (strcmp(orig->m_class, new->m_class) != 0)
+		return 0;
+
+	if (orig->m_sa.sa_family != new->m_sa.sa_family)
+		return 0;
+
+	switch (orig->m_sa.sa_family) {
+	case AF_INET6:
+		return ipv6_addr_equal(&orig->m_sin6.sin6_addr,
+				       &new->m_sin6.sin6_addr);
+
+	case AF_VSOCK:
+		return orig->m_svm.svm_cid == new->m_svm.svm_cid;
+	}
+	return 0;
 }
 static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -121,7 +143,14 @@ static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
 	struct ip_map *item = container_of(citem, struct ip_map, h);
 
 	strcpy(new->m_class, item->m_class);
-	new->m_addr = item->m_addr;
+	switch (item->m_sa.sa_family) {
+	case AF_INET6:
+		new->m_sin6 = item->m_sin6;
+		break;
+	case AF_VSOCK:
+		new->m_svm = item->m_svm;
+		break;
+	}
 }
 static void update(struct cache_head *cnew, struct cache_head *citem)
 {
@@ -145,19 +174,30 @@ static void ip_map_request(struct cache_detail *cd,
 				  char **bpp, int *blen)
 {
 	char text_addr[40];
+	struct in6_addr *addr;
 	struct ip_map *im = container_of(h, struct ip_map, h);
 
-	if (ipv6_addr_v4mapped(&(im->m_addr))) {
-		snprintf(text_addr, 20, "%pI4", &im->m_addr.s6_addr32[3]);
-	} else {
-		snprintf(text_addr, 40, "%pI6", &im->m_addr);
+	switch (im->m_sa.sa_family) {
+	case AF_INET6:
+		addr = &im->m_sin6.sin6_addr;
+		if (ipv6_addr_v4mapped(addr)) {
+			snprintf(text_addr, 20, "%pI4", &addr->s6_addr32[3]);
+		} else {
+			snprintf(text_addr, 40, "%pI6", addr);
+		}
+		break;
+
+	case AF_VSOCK:
+		snprintf(text_addr, 10, "vsock:%u", im->m_svm.svm_cid);
+		break;
 	}
+
 	qword_add(bpp, blen, im->m_class);
 	qword_add(bpp, blen, text_addr);
 	(*bpp)[-1] = '\n';
 }
 
-static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class, struct in6_addr *addr);
+static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class, struct sockaddr *sap);
 static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm, struct unix_domain *udom, time_t expiry);
 
 static int ip_map_parse(struct cache_detail *cd,
@@ -173,6 +213,7 @@ static int ip_map_parse(struct cache_detail *cd,
 		struct sockaddr		sa;
 		struct sockaddr_in	s4;
 		struct sockaddr_in6	s6;
+		struct sockaddr_vm	svm;
 	} address;
 	struct sockaddr_in6 sin6;
 	int err;
@@ -201,11 +242,15 @@ static int ip_map_parse(struct cache_detail *cd,
 		sin6.sin6_family = AF_INET6;
 		ipv6_addr_set_v4mapped(address.s4.sin_addr.s_addr,
 				&sin6.sin6_addr);
+		address.s6 = sin6;
 		break;
 #if IS_ENABLED(CONFIG_IPV6)
 	case AF_INET6:
-		memcpy(&sin6, &address.s6, sizeof(sin6));
-		break;
+		break; /* Do nothing */
+#endif
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+	case AF_VSOCK:
+		break; /* Do nothing */
 #endif
 	default:
 		return -EINVAL;
@@ -227,7 +272,7 @@ static int ip_map_parse(struct cache_detail *cd,
 		dom = NULL;
 
 	/* IPv6 scope IDs are ignored for now */
-	ipmp = __ip_map_lookup(cd, class, &sin6.sin6_addr);
+	ipmp = __ip_map_lookup(cd, class, &address.sa);
 	if (ipmp) {
 		err = __ip_map_update(cd, ipmp,
 			     container_of(dom, struct unix_domain, h),
@@ -247,7 +292,7 @@ static int ip_map_show(struct seq_file *m,
 		       struct cache_head *h)
 {
 	struct ip_map *im;
-	struct in6_addr addr;
+	struct in6_addr *addr;
 	char *dom = "-no-domain-";
 
 	if (h == NULL) {
@@ -256,33 +301,67 @@ static int ip_map_show(struct seq_file *m,
 	}
 	im = container_of(h, struct ip_map, h);
 	/* class addr domain */
-	addr = im->m_addr;
-
+	addr = &im->m_sin6.sin6_addr;
 	if (test_bit(CACHE_VALID, &h->flags) &&
 	    !test_bit(CACHE_NEGATIVE, &h->flags))
 		dom = im->m_client->h.name;
 
-	if (ipv6_addr_v4mapped(&addr)) {
-		seq_printf(m, "%s %pI4 %s\n",
-			im->m_class, &addr.s6_addr32[3], dom);
-	} else {
-		seq_printf(m, "%s %pI6 %s\n", im->m_class, &addr, dom);
+	switch (im->m_sa.sa_family) {
+	case AF_INET6:
+		if (ipv6_addr_v4mapped(addr)) {
+			seq_printf(m, "%s %pI4 %s\n",
+				im->m_class,
+				&addr->s6_addr32[3],
+				dom);
+		} else {
+			seq_printf(m, "%s %pI6 %s\n", im->m_class, addr, dom);
+		}
+		break;
+
+	case AF_VSOCK:
+		seq_printf(m, "%s %u %s\n",
+			im->m_class, im->m_svm.svm_cid, dom);
+		break;
 	}
 	return 0;
 }
 
+static int __ip_map_hash(struct ip_map *ipm)
+{
+	int hash;
+
+	switch (ipm->m_sa.sa_family) {
+	case AF_INET6:
+		hash = hash_ip6(&ipm->m_sin6.sin6_addr);
+		break;
+	case AF_VSOCK:
+		hash = hash_32(ipm->m_svm.svm_cid, IP_HASHBITS);
+		break;
+	default:
+		BUG();
+	}
+
+	return hash_str(ipm->m_class, IP_HASHBITS) ^ hash;
+}
 
 static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
-		struct in6_addr *addr)
+		struct sockaddr *sap)
 {
 	struct ip_map ip;
 	struct cache_head *ch;
 
 	strcpy(ip.m_class, class);
-	ip.m_addr = *addr;
-	ch = sunrpc_cache_lookup(cd, &ip.h,
-				 hash_str(class, IP_HASHBITS) ^
-				 hash_ip6(addr));
+	switch (sap->sa_family) {
+	case AF_INET6:
+		ip.m_sin6 = *(struct sockaddr_in6 *)sap;
+		break;
+	case AF_VSOCK:
+		ip.m_svm = *(struct sockaddr_vm *)sap;
+		break;
+	default:
+		return NULL;
+	}
+	ch = sunrpc_cache_lookup(cd, &ip.h, __ip_map_hash(&ip));
 
 	if (ch)
 		return container_of(ch, struct ip_map, h);
@@ -291,12 +370,12 @@ static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
 }
 
 static inline struct ip_map *ip_map_lookup(struct net *net, char *class,
-		struct in6_addr *addr)
+		struct sockaddr *sap)
 {
 	struct sunrpc_net *sn;
 
 	sn = net_generic(net, sunrpc_net_id);
-	return __ip_map_lookup(sn->ip_map_cache, class, addr);
+	return __ip_map_lookup(sn->ip_map_cache, class, sap);
 }
 
 static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
@@ -311,8 +390,7 @@ static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
 		set_bit(CACHE_NEGATIVE, &ip.h.flags);
 	ip.h.expiry_time = expiry;
 	ch = sunrpc_cache_update(cd, &ip.h, &ipm->h,
-				 hash_str(ipm->m_class, IP_HASHBITS) ^
-				 hash_ip6(&ipm->m_addr));
+				 __ip_map_hash(ipm));
 	if (!ch)
 		return -ENOMEM;
 	cache_put(ch, cd);
@@ -654,6 +732,7 @@ static struct group_info *unix_gid_find(kuid_t uid, struct svc_rqst *rqstp)
 int
 svcauth_unix_set_client(struct svc_rqst *rqstp)
 {
+	struct sockaddr *sap;
 	struct sockaddr_in *sin;
 	struct sockaddr_in6 *sin6, sin6_storage;
 	struct ip_map *ipm;
@@ -667,10 +746,15 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 	case AF_INET:
 		sin = svc_addr_in(rqstp);
 		sin6 = &sin6_storage;
+		sin6->sin6_family = AF_INET6;
 		ipv6_addr_set_v4mapped(sin->sin_addr.s_addr, &sin6->sin6_addr);
+		sap = (struct sockaddr *)sin6;
 		break;
 	case AF_INET6:
-		sin6 = svc_addr_in6(rqstp);
+		sap = svc_addr(rqstp);
+		break;
+	case AF_VSOCK:
+		sap = svc_addr(rqstp);
 		break;
 	default:
 		BUG();
@@ -683,7 +767,7 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 	ipm = ip_map_cached_get(xprt);
 	if (ipm == NULL)
 		ipm = __ip_map_lookup(sn->ip_map_cache, rqstp->rq_server->sv_program->pg_class,
-				    &sin6->sin6_addr);
+				    sap);
 
 	if (ipm == NULL)
 		return SVC_DENIED;
-- 
2.9.4

