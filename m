Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34723 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344Ab3HSKP2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Aug 2013 06:15:28 -0400
From: Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>, Steve French <sfrench@samba.org>,
        Christine Caulfield <ccaulfie@redhat.com>,
        David Teigland <teigland@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3 7/9] fs: use generic union inet_addr and helper functions
Date: Mon, 19 Aug 2013 18:14:36 +0800
Message-Id: <1376907278-26377-8-git-send-email-amwang@redhat.com>
In-Reply-To: <1376907278-26377-1-git-send-email-amwang@redhat.com>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

nfs and cifs define some helper functions for sockaddr,
they can use the generic functions for union inet_addr/struct sockaddr
too.

Since some dlm code needs to compare ->sin_port, introduce a
generic function inet_addr_equal_strict() for it.

Cc: Steve French <sfrench@samba.org>
Cc: Christine Caulfield <ccaulfie@redhat.com>
Cc: David Teigland <teigland@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-cifs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: cluster-devel@redhat.com
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 fs/cifs/connect.c          |   54 +++++---------------
 fs/dlm/lowcomms.c          |   24 ++-------
 fs/nfs/client.c            |  113 +-------------------------------------------
 fs/nfs/nfs4client.c        |    2 +-
 fs/nfs/nfs4filelayoutdev.c |   37 ++-------------
 fs/nfs/super.c             |   31 +-----------
 include/net/inet_addr.h    |    8 +++
 net/core/utils.c           |   23 +++++++++
 8 files changed, 60 insertions(+), 232 deletions(-)

diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index d67c550..081cb6c 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -40,6 +40,7 @@
 #include <linux/module.h>
 #include <keys/user-type.h>
 #include <net/ipv6.h>
+#include <net/inet_addr.h>
 #include <linux/parser.h>
 
 #include "cifspdu.h"
@@ -1900,17 +1901,9 @@ srcip_matches(struct sockaddr *srcaddr, struct sockaddr *rhs)
 {
 	switch (srcaddr->sa_family) {
 	case AF_UNSPEC:
-		return (rhs->sa_family == AF_UNSPEC);
-	case AF_INET: {
-		struct sockaddr_in *saddr4 = (struct sockaddr_in *)srcaddr;
-		struct sockaddr_in *vaddr4 = (struct sockaddr_in *)rhs;
-		return (saddr4->sin_addr.s_addr == vaddr4->sin_addr.s_addr);
-	}
-	case AF_INET6: {
-		struct sockaddr_in6 *saddr6 = (struct sockaddr_in6 *)srcaddr;
-		struct sockaddr_in6 *vaddr6 = (struct sockaddr_in6 *)rhs;
-		return ipv6_addr_equal(&saddr6->sin6_addr, &vaddr6->sin6_addr);
-	}
+	case AF_INET:
+	case AF_INET6:
+		return sockaddr_equal(srcaddr, rhs);
 	default:
 		WARN_ON(1);
 		return false; /* don't expect to be here */
@@ -1925,16 +1918,13 @@ srcip_matches(struct sockaddr *srcaddr, struct sockaddr *rhs)
 static bool
 match_port(struct TCP_Server_Info *server, struct sockaddr *addr)
 {
-	__be16 port, *sport;
+	unsigned short port, sport;
 
 	switch (addr->sa_family) {
 	case AF_INET:
-		sport = &((struct sockaddr_in *) &server->dstaddr)->sin_port;
-		port = ((struct sockaddr_in *) addr)->sin_port;
-		break;
 	case AF_INET6:
-		sport = &((struct sockaddr_in6 *) &server->dstaddr)->sin6_port;
-		port = ((struct sockaddr_in6 *) addr)->sin6_port;
+		sport = sockaddr_get_port((struct sockaddr *)&server->dstaddr);
+		port = sockaddr_get_port(addr);
 		break;
 	default:
 		WARN_ON(1);
@@ -1942,14 +1932,14 @@ match_port(struct TCP_Server_Info *server, struct sockaddr *addr)
 	}
 
 	if (!port) {
-		port = htons(CIFS_PORT);
-		if (port == *sport)
+		port = CIFS_PORT;
+		if (port == sport)
 			return true;
 
-		port = htons(RFC1001_PORT);
+		port = RFC1001_PORT;
 	}
 
-	return port == *sport;
+	return port == sport;
 }
 
 static bool
@@ -1957,27 +1947,11 @@ match_address(struct TCP_Server_Info *server, struct sockaddr *addr,
 	      struct sockaddr *srcaddr)
 {
 	switch (addr->sa_family) {
-	case AF_INET: {
-		struct sockaddr_in *addr4 = (struct sockaddr_in *)addr;
-		struct sockaddr_in *srv_addr4 =
-					(struct sockaddr_in *)&server->dstaddr;
-
-		if (addr4->sin_addr.s_addr != srv_addr4->sin_addr.s_addr)
-			return false;
-		break;
-	}
-	case AF_INET6: {
-		struct sockaddr_in6 *addr6 = (struct sockaddr_in6 *)addr;
-		struct sockaddr_in6 *srv_addr6 =
-					(struct sockaddr_in6 *)&server->dstaddr;
-
-		if (!ipv6_addr_equal(&addr6->sin6_addr,
-				     &srv_addr6->sin6_addr))
-			return false;
-		if (addr6->sin6_scope_id != srv_addr6->sin6_scope_id)
+	case AF_INET:
+	case AF_INET6:
+		if (!sockaddr_equal(addr, (struct sockaddr *)&server->dstaddr))
 			return false;
 		break;
-	}
 	default:
 		WARN_ON(1);
 		return false; /* don't expect to be here */
diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index d90909e..c051237 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -54,6 +54,7 @@
 #include <linux/slab.h>
 #include <net/sctp/sctp.h>
 #include <net/ipv6.h>
+#include <net/inet_addr.h>
 
 #include "dlm_internal.h"
 #include "lowcomms.h"
@@ -286,28 +287,13 @@ static struct dlm_node_addr *find_node_addr(int nodeid)
 static int addr_compare(struct sockaddr_storage *x, struct sockaddr_storage *y)
 {
 	switch (x->ss_family) {
-	case AF_INET: {
-		struct sockaddr_in *sinx = (struct sockaddr_in *)x;
-		struct sockaddr_in *siny = (struct sockaddr_in *)y;
-		if (sinx->sin_addr.s_addr != siny->sin_addr.s_addr)
-			return 0;
-		if (sinx->sin_port != siny->sin_port)
-			return 0;
-		break;
-	}
-	case AF_INET6: {
-		struct sockaddr_in6 *sinx = (struct sockaddr_in6 *)x;
-		struct sockaddr_in6 *siny = (struct sockaddr_in6 *)y;
-		if (!ipv6_addr_equal(&sinx->sin6_addr, &siny->sin6_addr))
-			return 0;
-		if (sinx->sin6_port != siny->sin6_port)
-			return 0;
-		break;
-	}
+	case AF_INET:
+	case AF_INET6:
+		return inet_addr_equal_strict((union inet_addr *)x,
+					      (union inet_addr *)y);
 	default:
 		return 0;
 	}
-	return 1;
 }
 
 static int nodeid_to_addr(int nodeid, struct sockaddr_storage *sas_out,
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 340b1ef..708dc96 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -38,6 +38,7 @@
 #include <linux/slab.h>
 #include <linux/idr.h>
 #include <net/ipv6.h>
+#include <net/inet_addr.h>
 #include <linux/nfs_xdr.h>
 #include <linux/sunrpc/bc_xprt.h>
 #include <linux/nsproxy.h>
@@ -283,116 +284,6 @@ void nfs_put_client(struct nfs_client *clp)
 }
 EXPORT_SYMBOL_GPL(nfs_put_client);
 
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-/*
- * Test if two ip6 socket addresses refer to the same socket by
- * comparing relevant fields. The padding bytes specifically, are not
- * compared. sin6_flowinfo is not compared because it only affects QoS
- * and sin6_scope_id is only compared if the address is "link local"
- * because "link local" addresses need only be unique to a specific
- * link. Conversely, ordinary unicast addresses might have different
- * sin6_scope_id.
- *
- * The caller should ensure both socket addresses are AF_INET6.
- */
-static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
-				      const struct sockaddr *sa2)
-{
-	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
-	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
-
-	if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
-		return 0;
-	else if (ipv6_addr_type(&sin1->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		return sin1->sin6_scope_id == sin2->sin6_scope_id;
-
-	return 1;
-}
-#else	/* !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE) */
-static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
-				      const struct sockaddr *sa2)
-{
-	return 0;
-}
-#endif
-
-/*
- * Test if two ip4 socket addresses refer to the same socket, by
- * comparing relevant fields. The padding bytes specifically, are
- * not compared.
- *
- * The caller should ensure both socket addresses are AF_INET.
- */
-static int nfs_sockaddr_match_ipaddr4(const struct sockaddr *sa1,
-				      const struct sockaddr *sa2)
-{
-	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sa1;
-	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sa2;
-
-	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
-}
-
-static int nfs_sockaddr_cmp_ip6(const struct sockaddr *sa1,
-				const struct sockaddr *sa2)
-{
-	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
-	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
-
-	return nfs_sockaddr_match_ipaddr6(sa1, sa2) &&
-		(sin1->sin6_port == sin2->sin6_port);
-}
-
-static int nfs_sockaddr_cmp_ip4(const struct sockaddr *sa1,
-				const struct sockaddr *sa2)
-{
-	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sa1;
-	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sa2;
-
-	return nfs_sockaddr_match_ipaddr4(sa1, sa2) &&
-		(sin1->sin_port == sin2->sin_port);
-}
-
-#if defined(CONFIG_NFS_V4_1)
-/*
- * Test if two socket addresses represent the same actual socket,
- * by comparing (only) relevant fields, excluding the port number.
- */
-int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
-			      const struct sockaddr *sa2)
-{
-	if (sa1->sa_family != sa2->sa_family)
-		return 0;
-
-	switch (sa1->sa_family) {
-	case AF_INET:
-		return nfs_sockaddr_match_ipaddr4(sa1, sa2);
-	case AF_INET6:
-		return nfs_sockaddr_match_ipaddr6(sa1, sa2);
-	}
-	return 0;
-}
-EXPORT_SYMBOL_GPL(nfs_sockaddr_match_ipaddr);
-#endif /* CONFIG_NFS_V4_1 */
-
-/*
- * Test if two socket addresses represent the same actual socket,
- * by comparing (only) relevant fields, including the port number.
- */
-static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
-			    const struct sockaddr *sa2)
-{
-	if (sa1->sa_family != sa2->sa_family)
-		return 0;
-
-	switch (sa1->sa_family) {
-	case AF_INET:
-		return nfs_sockaddr_cmp_ip4(sa1, sa2);
-	case AF_INET6:
-		return nfs_sockaddr_cmp_ip6(sa1, sa2);
-	}
-	return 0;
-}
-
 /*
  * Find an nfs_client on the list that matches the initialisation data
  * that is supplied.
@@ -419,7 +310,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 		if (clp->cl_minorversion != data->minorversion)
 			continue;
 		/* Match the full socket address */
-		if (!nfs_sockaddr_cmp(sap, clap))
+		if (!sockaddr_equal_strict(sap, clap))
 			continue;
 
 		atomic_inc(&clp->cl_count);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 90dce91..383b97a 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -552,7 +552,7 @@ static bool nfs4_cb_match_client(const struct sockaddr *addr,
 		return false;
 
 	/* Match only the IP address, not the port number */
-	if (!nfs_sockaddr_match_ipaddr(addr, clap))
+	if (!sockaddr_equal(addr, clap))
 		return false;
 
 	return true;
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 95604f6..955494cb 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -32,6 +32,7 @@
 #include <linux/vmalloc.h>
 #include <linux/module.h>
 #include <linux/sunrpc/addr.h>
+#include <net/inet_addr.h>
 
 #include "internal.h"
 #include "nfs4session.h"
@@ -74,44 +75,14 @@ print_ds(struct nfs4_pnfs_ds *ds)
 static bool
 same_sockaddr(struct sockaddr *addr1, struct sockaddr *addr2)
 {
-	struct sockaddr_in *a, *b;
-	struct sockaddr_in6 *a6, *b6;
-
-	if (addr1->sa_family != addr2->sa_family)
-		return false;
-
-	switch (addr1->sa_family) {
-	case AF_INET:
-		a = (struct sockaddr_in *)addr1;
-		b = (struct sockaddr_in *)addr2;
-
-		if (a->sin_addr.s_addr == b->sin_addr.s_addr &&
-		    a->sin_port == b->sin_port)
-			return true;
-		break;
-
-	case AF_INET6:
-		a6 = (struct sockaddr_in6 *)addr1;
-		b6 = (struct sockaddr_in6 *)addr2;
-
-		/* LINKLOCAL addresses must have matching scope_id */
-		if (ipv6_addr_scope(&a6->sin6_addr) ==
-		    IPV6_ADDR_SCOPE_LINKLOCAL &&
-		    a6->sin6_scope_id != b6->sin6_scope_id)
-			return false;
-
-		if (ipv6_addr_equal(&a6->sin6_addr, &b6->sin6_addr) &&
-		    a6->sin6_port == b6->sin6_port)
-			return true;
-		break;
-
-	default:
+	if (addr1->sa_family != AF_INET && addr1->sa_family != AF_INET6) {
 		dprintk("%s: unhandled address family: %u\n",
 			__func__, addr1->sa_family);
 		return false;
 	}
 
-	return false;
+	return inet_addr_equal_strict((union inet_addr *)addr1,
+				      (union inet_addr *)addr2);
 }
 
 static bool
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ac7c359..0744abb 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -49,6 +49,7 @@
 #include <linux/in6.h>
 #include <linux/slab.h>
 #include <net/ipv6.h>
+#include <net/inet_addr.h>
 #include <linux/netdevice.h>
 #include <linux/nfs_xdr.h>
 #include <linux/magic.h>
@@ -2335,34 +2336,8 @@ static int nfs_compare_super_address(struct nfs_server *server1,
 
 	sap1 = (struct sockaddr *)&server1->nfs_client->cl_addr;
 	sap2 = (struct sockaddr *)&server2->nfs_client->cl_addr;
-
-	if (sap1->sa_family != sap2->sa_family)
-		return 0;
-
-	switch (sap1->sa_family) {
-	case AF_INET: {
-		struct sockaddr_in *sin1 = (struct sockaddr_in *)sap1;
-		struct sockaddr_in *sin2 = (struct sockaddr_in *)sap2;
-		if (sin1->sin_addr.s_addr != sin2->sin_addr.s_addr)
-			return 0;
-		if (sin1->sin_port != sin2->sin_port)
-			return 0;
-		break;
-	}
-	case AF_INET6: {
-		struct sockaddr_in6 *sin1 = (struct sockaddr_in6 *)sap1;
-		struct sockaddr_in6 *sin2 = (struct sockaddr_in6 *)sap2;
-		if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
-			return 0;
-		if (sin1->sin6_port != sin2->sin6_port)
-			return 0;
-		break;
-	}
-	default:
-		return 0;
-	}
-
-	return 1;
+	return inet_addr_equal_strict((union inet_addr *)sap1,
+				      (union inet_addr *)sap2);
 }
 
 static int nfs_compare_super(struct super_block *sb, void *data)
diff --git a/include/net/inet_addr.h b/include/net/inet_addr.h
index 44179c8..f317f0f 100644
--- a/include/net/inet_addr.h
+++ b/include/net/inet_addr.h
@@ -122,6 +122,7 @@ void inet_addr_set_port(union inet_addr *sap,
 }
 
 bool inet_addr_equal(const union inet_addr *a, const union inet_addr *b);
+bool inet_addr_equal_strict(const union inet_addr *a, const union inet_addr *b);
 int simple_inet_pton(const char *str, union inet_addr *addr);
 
 static inline bool sockaddr_equal(const struct sockaddr *sap1,
@@ -131,6 +132,13 @@ static inline bool sockaddr_equal(const struct sockaddr *sap1,
 			       (const union inet_addr *)sap2);
 }
 
+static inline int sockaddr_equal_strict(const struct sockaddr *sa1,
+					const struct sockaddr *sa2)
+{
+	return inet_addr_equal_strict((union inet_addr *)sa1,
+				      (union inet_addr *)sa2);
+}
+
 static inline bool sockaddr_copy(struct sockaddr *dst,
 				 const struct sockaddr *src)
 {
diff --git a/net/core/utils.c b/net/core/utils.c
index 837bb18..489bc8d 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -380,6 +380,8 @@ bool inet_addr_equal(const union inet_addr *a, const union inet_addr *b)
 {
 	if (a->sa.sa_family != b->sa.sa_family)
 		return false;
+	if (a->sa.sa_family == AF_UNSPEC)
+		return true;
 	else if (a->sa.sa_family == AF_INET6) {
 		if (!ipv6_addr_equal(&a->sin6.sin6_addr, &b->sin6.sin6_addr))
 			return false;
@@ -399,3 +401,24 @@ bool inet_addr_equal(const union inet_addr *a, const union inet_addr *b)
 }
 #endif
 EXPORT_SYMBOL(inet_addr_equal);
+
+/*
+ * Unlike inet_addr_equal(), this function compares ->sin_port too.
+ */
+bool inet_addr_equal_strict(const union inet_addr *a, const union inet_addr *b)
+{
+	if (inet_addr_equal(a, b)) {
+		switch (a->sa.sa_family) {
+#if IS_ENABLED(CONFIG_IPV6)
+		case AF_INET6:
+			return a->sin6.sin6_port == b->sin6.sin6_port;
+#endif
+		case AF_INET:
+			return a->sin.sin_port == b->sin.sin_port;
+		default:
+			return true;
+		}
+	} else
+		return false;
+}
+EXPORT_SYMBOL(inet_addr_equal_strict);
-- 
1.7.7.6

