Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32145 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752523Ab3F0Go0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Jun 2013 02:44:26 -0400
From: Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Cc: Daniel Borkmann <dborkman@redhat.com>,
        "David S. Miller" <davem@davemloft.net>, Cong Wang <amwang@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [RFC Patch net-next 4/5] sunrpc: use generic union inet_addr
Date: Thu, 27 Jun 2013 14:43:17 +0800
Message-Id: <1372315398-19683-5-git-send-email-amwang@redhat.com>
In-Reply-To: <1372315398-19683-1-git-send-email-amwang@redhat.com>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/linux/sunrpc/addr.h |  119 +++----------------------------------------
 include/net/inet_addr.h     |   56 ++++++++++++++++++++
 2 files changed, 64 insertions(+), 111 deletions(-)

diff --git a/include/linux/sunrpc/addr.h b/include/linux/sunrpc/addr.h
index 07d8e53..4c3602e 100644
--- a/include/linux/sunrpc/addr.h
+++ b/include/linux/sunrpc/addr.h
@@ -11,6 +11,7 @@
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <net/ipv6.h>
+#include <net/inet_addr.h>
 
 size_t		rpc_ntop(const struct sockaddr *, char *, const size_t);
 size_t		rpc_pton(struct net *, const char *, const size_t,
@@ -21,137 +22,33 @@ size_t		rpc_uaddr2sockaddr(struct net *, const char *, const size_t,
 
 static inline unsigned short rpc_get_port(const struct sockaddr *sap)
 {
-	switch (sap->sa_family) {
-	case AF_INET:
-		return ntohs(((struct sockaddr_in *)sap)->sin_port);
-	case AF_INET6:
-		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
-	}
-	return 0;
+	return inet_addr_get_port((const union inet_addr *)sap);
 }
 
 static inline void rpc_set_port(struct sockaddr *sap,
 				const unsigned short port)
 {
-	switch (sap->sa_family) {
-	case AF_INET:
-		((struct sockaddr_in *)sap)->sin_port = htons(port);
-		break;
-	case AF_INET6:
-		((struct sockaddr_in6 *)sap)->sin6_port = htons(port);
-		break;
-	}
+	inet_addr_set_port((union inet_addr *)sap, port);
 }
 
 #define IPV6_SCOPE_DELIMITER		'%'
 #define IPV6_SCOPE_ID_LEN		sizeof("%nnnnnnnnnn")
 
-static inline bool __rpc_cmp_addr4(const struct sockaddr *sap1,
-				   const struct sockaddr *sap2)
-{
-	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sap1;
-	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sap2;
-
-	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
-}
-
-static inline bool __rpc_copy_addr4(struct sockaddr *dst,
-				    const struct sockaddr *src)
-{
-	const struct sockaddr_in *ssin = (struct sockaddr_in *) src;
-	struct sockaddr_in *dsin = (struct sockaddr_in *) dst;
-
-	dsin->sin_family = ssin->sin_family;
-	dsin->sin_addr.s_addr = ssin->sin_addr.s_addr;
-	return true;
-}
-
-#if IS_ENABLED(CONFIG_IPV6)
-static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
-				   const struct sockaddr *sap2)
-{
-	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sap1;
-	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
-
-	if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
-		return false;
-	else if (ipv6_addr_type(&sin1->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		return sin1->sin6_scope_id == sin2->sin6_scope_id;
-
-	return true;
-}
-
-static inline bool __rpc_copy_addr6(struct sockaddr *dst,
-				    const struct sockaddr *src)
-{
-	const struct sockaddr_in6 *ssin6 = (const struct sockaddr_in6 *) src;
-	struct sockaddr_in6 *dsin6 = (struct sockaddr_in6 *) dst;
-
-	dsin6->sin6_family = ssin6->sin6_family;
-	dsin6->sin6_addr = ssin6->sin6_addr;
-	dsin6->sin6_scope_id = ssin6->sin6_scope_id;
-	return true;
-}
-#else	/* !(IS_ENABLED(CONFIG_IPV6) */
-static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
-				   const struct sockaddr *sap2)
-{
-	return false;
-}
-
-static inline bool __rpc_copy_addr6(struct sockaddr *dst,
-				    const struct sockaddr *src)
-{
-	return false;
-}
-#endif	/* !(IS_ENABLED(CONFIG_IPV6) */
-
-/**
- * rpc_cmp_addr - compare the address portion of two sockaddrs.
- * @sap1: first sockaddr
- * @sap2: second sockaddr
- *
- * Just compares the family and address portion. Ignores port, but
- * compares the scope if it's a link-local address.
- *
- * Returns true if the addrs are equal, false if they aren't.
- */
 static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
 				const struct sockaddr *sap2)
 {
-	if (sap1->sa_family == sap2->sa_family) {
-		switch (sap1->sa_family) {
-		case AF_INET:
-			return __rpc_cmp_addr4(sap1, sap2);
-		case AF_INET6:
-			return __rpc_cmp_addr6(sap1, sap2);
-		}
-	}
-	return false;
+	return inet_addr_equal((const union inet_addr *)sap1,
+			       (const union inet_addr *)sap2);
 }
 
-/**
- * rpc_copy_addr - copy the address portion of one sockaddr to another
- * @dst: destination sockaddr
- * @src: source sockaddr
- *
- * Just copies the address portion and family. Ignores port, scope, etc.
- * Caller is responsible for making certain that dst is large enough to hold
- * the address in src. Returns true if address family is supported. Returns
- * false otherwise.
- */
 static inline bool rpc_copy_addr(struct sockaddr *dst,
 				 const struct sockaddr *src)
 {
-	switch (src->sa_family) {
-	case AF_INET:
-		return __rpc_copy_addr4(dst, src);
-	case AF_INET6:
-		return __rpc_copy_addr6(dst, src);
-	}
-	return false;
+	return inet_addr_copy((union inet_addr *)dst,
+			      (const union inet_addr *)src);
 }
 
+
 /**
  * rpc_get_scope_id - return scopeid for a given sockaddr
  * @sa: sockaddr to get scopeid from
diff --git a/include/net/inet_addr.h b/include/net/inet_addr.h
index 1379287..683e904 100644
--- a/include/net/inet_addr.h
+++ b/include/net/inet_addr.h
@@ -60,6 +60,62 @@ static inline bool inet_addr_multicast(const union inet_addr *ipa)
 }
 #endif
 
+/**
+ * inet_addr_copy - copy the address portion of one sockaddr to another
+ * @dst: destination sockaddr
+ * @src: source sockaddr
+ *
+ * Just copies the address portion and family. Ignores port, scope, etc.
+ * Caller is responsible for making certain that dst is large enough to hold
+ * the address in src. Returns true if address family is supported. Returns
+ * false otherwise.
+ */
+static inline bool inet_addr_copy(union inet_addr *dst,
+				  const union inet_addr *src)
+{
+	dst->sa.sa_family = src->sa.sa_family;
+
+	switch (src->sa.sa_family) {
+	case AF_INET:
+		dst->sin.sin_addr.s_addr = src->sin.sin_addr.s_addr;
+		return true;
+#if IS_ENABLED(CONFIG_IPV6)
+	case AF_INET6:
+		dst->sin6.sin6_addr = src->sin6.sin6_addr;
+		dst->sin6.sin6_scope_id = src->sin6.sin6_scope_id;
+		return true;
+#endif
+	}
+
+	return false;
+}
+
+static inline
+unsigned short inet_addr_get_port(const union inet_addr *sap)
+{
+	switch (sap->sa.sa_family) {
+	case AF_INET:
+		return ntohs(sap->sin.sin_port);
+	case AF_INET6:
+		return ntohs(sap->sin6.sin6_port);
+	}
+	return 0;
+}
+
+static inline
+void inet_addr_set_port(union inet_addr *sap,
+			const unsigned short port)
+{
+	switch (sap->sa.sa_family) {
+	case AF_INET:
+		sap->sin.sin_port = htons(port);
+		break;
+	case AF_INET6:
+		sap->sin6.sin6_port = htons(port);
+		break;
+	}
+}
+
 static inline int inet_pton(const char *str, union inet_addr *addr)
 {
 	const char *end;
-- 
1.7.7.6

