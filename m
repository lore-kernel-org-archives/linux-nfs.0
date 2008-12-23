From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 38/69] NFSv4: Fix up delegation callbacks
Date: Tue, 23 Dec 2008 18:02:16 -0500
Message-ID: <20081223230216.13743.74734.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45954 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbYLWXXr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:47 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7i021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:42 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the callback server is listening on IPv6 if it is enabled. This
means that IPv4 addresses will always be mapped.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |   57 +++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 38 insertions(+), 19 deletions(-)


diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index b643f0e..9b728f3 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -223,31 +223,54 @@ void nfs_put_client(struct nfs_client *clp)
 	}
 }
 
-static int nfs_sockaddr_match_ipaddr4(const struct sockaddr_in *sa1,
-				 const struct sockaddr_in *sa2)
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static const struct in6_addr *nfs_map_ipv4_addr(const struct sockaddr *sa, struct in6_addr *addr_mapped)
 {
-	return sa1->sin_addr.s_addr == sa2->sin_addr.s_addr;
+	switch (sa->sa_family) {
+		default:
+			return NULL;
+		case AF_INET6:
+			return &((const struct sockaddr_in6 *)sa)->sin6_addr;
+			break;
+		case AF_INET:
+			ipv6_addr_set_v4mapped(((const struct sockaddr_in *)sa)->sin_addr.s_addr,
+					addr_mapped);
+			return addr_mapped;
+	}
 }
 
-static int nfs_sockaddr_match_ipaddr6(const struct sockaddr_in6 *sa1,
-				 const struct sockaddr_in6 *sa2)
+static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
+		const struct sockaddr *sa2)
+{
+	const struct in6_addr *addr1;
+	const struct in6_addr *addr2;
+	struct in6_addr addr1_mapped;
+	struct in6_addr addr2_mapped;
+
+	addr1 = nfs_map_ipv4_addr(sa1, &addr1_mapped);
+	if (likely(addr1 != NULL)) {
+		addr2 = nfs_map_ipv4_addr(sa2, &addr2_mapped);
+		if (likely(addr2 != NULL))
+			return ipv6_addr_equal(addr1, addr2);
+	}
+	return 0;
+}
+#else
+static int nfs_sockaddr_match_ipaddr4(const struct sockaddr_in *sa1,
+				 const struct sockaddr_in *sa2)
 {
-	return ipv6_addr_equal(&sa1->sin6_addr, &sa2->sin6_addr);
+	return sa1->sin_addr.s_addr == sa2->sin_addr.s_addr;
 }
 
 static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
 				 const struct sockaddr *sa2)
 {
-	switch (sa1->sa_family) {
-	case AF_INET:
-		return nfs_sockaddr_match_ipaddr4((const struct sockaddr_in *)sa1,
-				(const struct sockaddr_in *)sa2);
-	case AF_INET6:
-		return nfs_sockaddr_match_ipaddr6((const struct sockaddr_in6 *)sa1,
-				(const struct sockaddr_in6 *)sa2);
-	}
-	BUG();
+	if (unlikely(sa1->sa_family != AF_INET || sa2->sa_family != AF_INET))
+		return 0;
+	return nfs_sockaddr_match_ipaddr4((const struct sockaddr_in *)sa1,
+			(const struct sockaddr_in *)sa2);
 }
+#endif
 
 /*
  * Find a client by IP address and protocol version
@@ -269,8 +292,6 @@ struct nfs_client *nfs_find_client(const struct sockaddr *addr, u32 nfsversion)
 		if (clp->rpc_ops->version != nfsversion)
 			continue;
 
-		if (addr->sa_family != clap->sa_family)
-			continue;
 		/* Match only the IP address, not the port number */
 		if (!nfs_sockaddr_match_ipaddr(addr, clap))
 			continue;
@@ -304,8 +325,6 @@ struct nfs_client *nfs_find_client_next(struct nfs_client *clp)
 		if (clp->rpc_ops->version != nfsvers)
 			continue;
 
-		if (sap->sa_family != clap->sa_family)
-			continue;
 		/* Match only the IP address, not the port number */
 		if (!nfs_sockaddr_match_ipaddr(sap, clap))
 			continue;

