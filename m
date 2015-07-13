Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:35302 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbbGMSIt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 14:08:49 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [PATCH v2 05/10] NFS: Use RPC functions for matching sockaddrs
Date: Mon, 13 Jul 2015 14:01:28 -0400
Message-ID: <1436810493-22806-6-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1436810493-22806-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

They already exist and do the exact same thing.  Let's save ourselves
several lines of code!

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/client.c     | 113 +---------------------------------------------------
 fs/nfs/internal.h   |   4 --
 fs/nfs/nfs4client.c |   5 +--
 3 files changed, 3 insertions(+), 119 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ecebb40..61bfec2 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -20,6 +20,7 @@
 #include <linux/stat.h>
 #include <linux/errno.h>
 #include <linux/unistd.h>
+#include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/metrics.h>
@@ -285,116 +286,6 @@ void nfs_put_client(struct nfs_client *clp)
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
@@ -421,7 +312,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 		if (clp->cl_minorversion != data->minorversion)
 			continue;
 		/* Match the full socket address */
-		if (!nfs_sockaddr_cmp(sap, clap))
+		if (!rpc_cmp_addr_port(sap, clap))
 			continue;
 
 		atomic_inc(&clp->cl_count);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9e6475b..b27e81f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -219,10 +219,6 @@ static inline void nfs_fs_proc_exit(void)
 }
 #endif
 
-#ifdef CONFIG_NFS_V4_1
-int nfs_sockaddr_match_ipaddr(const struct sockaddr *, const struct sockaddr *);
-#endif
-
 /* callback_xdr.c */
 extern struct svc_version nfs4_callback_version1;
 extern struct svc_version nfs4_callback_version4;
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 3aa6a9b..223bedd 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -729,10 +729,7 @@ static bool nfs4_cb_match_client(const struct sockaddr *addr,
 		return false;
 
 	/* Match only the IP address, not the port number */
-	if (!nfs_sockaddr_match_ipaddr(addr, clap))
-		return false;
-
-	return true;
+	return rpc_cmp_addr(addr, clap);
 }
 
 /*
-- 
2.4.5

