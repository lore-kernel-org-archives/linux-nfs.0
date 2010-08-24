Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:46753 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664Ab0HXQgG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Aug 2010 12:36:06 -0400
Received: by ywe9 with SMTP id 9so1938184ywe.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2010 09:36:05 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] libexport.a: IPv6 support in client_check()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 24 Aug 2010 12:36:02 -0400
Message-ID: <20100824163602.2433.28552.stgit@matisse.1015granger.net>
In-Reply-To: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
References: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Introduce support for IPv6 in client_check()'s helpers.  The local
addrs_match() twins are no longer needed since we can use
nfs_compare_addrs() now.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   65 +++++++++++++++++++++++++++++++----------------
 1 files changed, 43 insertions(+), 22 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 4c6cd69..c74961e 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -19,6 +19,7 @@
 #include <netdb.h>
 #include <errno.h>
 
+#include "sockaddr.h"
 #include "misc.h"
 #include "nfslib.h"
 #include "exportfs.h"
@@ -444,27 +445,6 @@ add_name(char *old, const char *add)
 	return new;
 }
 
-static _Bool
-addrs_match4(const struct sockaddr *sa1, const struct sockaddr *sa2)
-{
-	const struct sockaddr_in *si1 = (const struct sockaddr_in *)sa1;
-	const struct sockaddr_in *si2 = (const struct sockaddr_in *)sa2;
-
-	return si1->sin_addr.s_addr == si2->sin_addr.s_addr;
-}
-
-static _Bool
-addrs_match(const struct sockaddr *sa1, const struct sockaddr *sa2)
-{
-	if (sa1->sa_family == sa2->sa_family)
-		switch (sa1->sa_family) {
-		case AF_INET:
-			return addrs_match4(sa1, sa2);
-		}
-
-	return false;
-}
-
 /*
  * Check each address listed in @ai against each address
  * stored in @clp.  Return 1 if a match is found, otherwise
@@ -477,7 +457,8 @@ check_fqdn(const nfs_client *clp, const struct addrinfo *ai)
 
 	for (; ai; ai = ai->ai_next)
 		for (i = 0; i < clp->m_naddr; i++)
-			if (addrs_match(ai->ai_addr, get_addrlist(clp, i)))
+			if (nfs_compare_sockaddr(ai->ai_addr,
+							get_addrlist(clp, i)))
 				return 1;
 
 	return 0;
@@ -507,6 +488,43 @@ check_subnet_v4(const struct sockaddr_in *address,
 	return 0;
 }
 
+#ifdef IPV6_SUPPORTED
+static int
+check_subnet_v6(const struct sockaddr_in6 *address,
+		const struct sockaddr_in6 *mask, const struct addrinfo *ai)
+{
+	for (; ai; ai = ai->ai_next) {
+		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)ai->ai_addr;
+
+		if (sin6->sin6_family != AF_INET6)
+			continue;
+
+		if (mask_match(address->sin6_addr.s6_addr32[0],
+				sin6->sin6_addr.s6_addr32[0],
+				mask->sin6_addr.s6_addr32[0]) &&
+		    mask_match(address->sin6_addr.s6_addr32[1],
+				sin6->sin6_addr.s6_addr32[1],
+				mask->sin6_addr.s6_addr32[1]) &&
+		    mask_match(address->sin6_addr.s6_addr32[2],
+				sin6->sin6_addr.s6_addr32[2],
+				mask->sin6_addr.s6_addr32[2]) &&
+		    mask_match(address->sin6_addr.s6_addr32[3],
+				sin6->sin6_addr.s6_addr32[3],
+				mask->sin6_addr.s6_addr32[3]))
+			return 1;
+	}
+	return 0;
+}
+#else	/* !IPV6_SUPPORTED */
+static int
+check_subnet_v6(const struct sockaddr_in6 *UNUSED(address),
+		const struct sockaddr_in6 *UNUSED(mask),
+		const struct addrinfo *UNUSED(ai))
+{
+	return 0;
+}
+#endif	/* !IPV6_SUPPORTED */
+
 /*
  * Check each address listed in @ai against the subnetwork or
  * host address stored in @clp.  Return 1 if an address in @hp
@@ -519,6 +537,9 @@ check_subnetwork(const nfs_client *clp, const struct addrinfo *ai)
 	case AF_INET:
 		return check_subnet_v4(get_addrlist_in(clp, 0),
 				get_addrlist_in(clp, 1), ai);
+	case AF_INET6:
+		return check_subnet_v6(get_addrlist_in6(clp, 0),
+				get_addrlist_in6(clp, 1), ai);
 	}
 
 	return 0;

