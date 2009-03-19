From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/23] NFS: Simplify logic to compare socket addresses in
	client.c
Date: Wed, 18 Mar 2009 20:48:14 -0400
Message-ID: <20090319004813.32404.90805.stgit@ingres.1015granger.net>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:26664 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754383AbZCSAsm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 20:48:42 -0400
In-Reply-To: <20090319004024.32404.68289.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Callback requests from IPv4 servers are now always guaranteed to be
AF_INET, and never mapped IPv4 AF_INET6 addresses.  Both
nfs_match_client() and nfs_find_client() can now share the same
address comparison logic, so fold them together.

We can also dispense with of most of the conditional compilation
in here.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c |  116 +++++++++++++++++++++++++------------------------------
 1 files changed, 52 insertions(+), 64 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 574158a..855daac 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -224,38 +224,6 @@ void nfs_put_client(struct nfs_client *clp)
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static const struct in6_addr *nfs_map_ipv4_addr(const struct sockaddr *sa, struct in6_addr *addr_mapped)
-{
-	switch (sa->sa_family) {
-		default:
-			return NULL;
-		case AF_INET6:
-			return &((const struct sockaddr_in6 *)sa)->sin6_addr;
-			break;
-		case AF_INET:
-			ipv6_addr_set_v4mapped(((const struct sockaddr_in *)sa)->sin_addr.s_addr,
-					addr_mapped);
-			return addr_mapped;
-	}
-}
-
-static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
-		const struct sockaddr *sa2)
-{
-	const struct in6_addr *addr1;
-	const struct in6_addr *addr2;
-	struct in6_addr addr1_mapped;
-	struct in6_addr addr2_mapped;
-
-	addr1 = nfs_map_ipv4_addr(sa1, &addr1_mapped);
-	if (likely(addr1 != NULL)) {
-		addr2 = nfs_map_ipv4_addr(sa2, &addr2_mapped);
-		if (likely(addr2 != NULL))
-			return ipv6_addr_equal(addr1, addr2);
-	}
-	return 0;
-}
-
 /*
  * Test if two ip6 socket addresses refer to the same socket by
  * comparing relevant fields. The padding bytes specifically, are not
@@ -267,38 +235,21 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
  *
  * The caller should ensure both socket addresses are AF_INET6.
  */
-static int nfs_sockaddr_cmp_ip6(const struct sockaddr *sa1,
-				const struct sockaddr *sa2)
+static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
+				      const struct sockaddr *sa2)
 {
-	const struct sockaddr_in6 *saddr1 = (const struct sockaddr_in6 *)sa1;
-	const struct sockaddr_in6 *saddr2 = (const struct sockaddr_in6 *)sa2;
+	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
+	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
 
-	if (!ipv6_addr_equal(&saddr1->sin6_addr,
-			     &saddr1->sin6_addr))
+	if (ipv6_addr_scope(&sin1->sin6_addr) == IPV6_ADDR_SCOPE_LINKLOCAL &&
+	    sin1->sin6_scope_id != sin2->sin6_scope_id)
 		return 0;
-	if (ipv6_addr_scope(&saddr1->sin6_addr) == IPV6_ADDR_SCOPE_LINKLOCAL &&
-	    saddr1->sin6_scope_id != saddr2->sin6_scope_id)
-		return 0;
-	return saddr1->sin6_port == saddr2->sin6_port;
-}
-#else
-static int nfs_sockaddr_match_ipaddr4(const struct sockaddr_in *sa1,
-				 const struct sockaddr_in *sa2)
-{
-	return sa1->sin_addr.s_addr == sa2->sin_addr.s_addr;
-}
 
-static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
-				 const struct sockaddr *sa2)
-{
-	if (unlikely(sa1->sa_family != AF_INET || sa2->sa_family != AF_INET))
-		return 0;
-	return nfs_sockaddr_match_ipaddr4((const struct sockaddr_in *)sa1,
-			(const struct sockaddr_in *)sa2);
+	return ipv6_addr_equal(&sin1->sin6_addr, &sin1->sin6_addr);
 }
-
-static int nfs_sockaddr_cmp_ip6(const struct sockaddr * sa1,
-				const struct sockaddr * sa2)
+#else	/* !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE) */
+static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
+				      const struct sockaddr *sa2)
 {
 	return 0;
 }
@@ -311,20 +262,57 @@ static int nfs_sockaddr_cmp_ip6(const struct sockaddr * sa1,
  *
  * The caller should ensure both socket addresses are AF_INET.
  */
+static int nfs_sockaddr_match_ipaddr4(const struct sockaddr *sa1,
+				      const struct sockaddr *sa2)
+{
+	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sa1;
+	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sa2;
+
+	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
+}
+
+static int nfs_sockaddr_cmp_ip6(const struct sockaddr *sa1,
+				const struct sockaddr *sa2)
+{
+	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
+	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
+
+	return nfs_sockaddr_match_ipaddr6(sa1, sa2) &&
+		(sin1->sin6_port == sin2->sin6_port);
+}
+
 static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
 				const struct sockaddr *sa2)
 {
-	const struct sockaddr_in *saddr1 = (const struct sockaddr_in *)sa1;
-	const struct sockaddr_in *saddr2 = (const struct sockaddr_in *)sa2;
+	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sa1;
+	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sa2;
 
-	if (saddr1->sin_addr.s_addr != saddr2->sin_addr.s_addr)
+	return nfs_sockaddr_match_ipaddr4(sa1, sa2) &&
+		(sin1->sin_port == sin2->sin_port);
+}
+
+/*
+ * Test if two socket addresses represent the same actual socket,
+ * by comparing (only) relevant fields, excluding the port number.
+ */
+static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
+				     const struct sockaddr *sa2)
+{
+	if (sa1->sa_family != sa2->sa_family)
 		return 0;
-	return saddr1->sin_port == saddr2->sin_port;
+
+	switch (sa1->sa_family) {
+	case AF_INET:
+		return nfs_sockaddr_match_ipaddr4(sa1, sa2);
+	case AF_INET6:
+		return nfs_sockaddr_match_ipaddr6(sa1, sa2);
+	}
+	return 0;
 }
 
 /*
  * Test if two socket addresses represent the same actual socket,
- * by comparing (only) relevant fields.
+ * by comparing (only) relevant fields, including the port number.
  */
 static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 			    const struct sockaddr *sa2)

