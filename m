Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:47056 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486Ab0IBTX7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Sep 2010 15:23:59 -0400
Received: by yxp4 with SMTP id 4so313919yxp.19
        for <linux-nfs@vger.kernel.org>; Thu, 02 Sep 2010 12:23:58 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] libexport.a: Refactor init_netmask()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 02 Sep 2010 15:23:53 -0400
Message-ID: <20100902192350.1755.66184.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Instead of a single function that can handle both AF_INET and AF_INET6
addresses, two separate functions might be cleaner.

The original plan was to keep code redundancy at a minimum, but the
resulting code was cumbersome at best.  I think I've traded a little
extra code for something that will be much easier to read, understand,
and maintain.

I've also eliminated the "#if / #endif" instances inside the functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |  163 +++++++++++++++++++++++++++++++----------------
 1 files changed, 106 insertions(+), 57 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index c74961e..dbfc2b1 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -60,86 +60,111 @@ client_free(nfs_client *clp)
 }
 
 static int
-init_netmask(nfs_client *clp, const char *slash, const sa_family_t family)
+init_netmask4(nfs_client *clp, const char *slash)
 {
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
 	};
-	unsigned long prefixlen;
 	uint32_t shift;
-#ifdef IPV6_SUPPORTED
-	struct sockaddr_in6 sin6 = {
-		.sin6_family		= AF_INET6,
-	};
-	int i;
-#endif
 
-	/* No slash present; assume netmask is all ones */
-	if (slash == NULL) {
-		switch (family) {
-		case AF_INET:
-			prefixlen = 32;
-			break;
-#ifdef IPV6_SUPPORTED
-		case AF_INET6:
-			prefixlen = 128;
-			break;
-#endif
-		default:
-			goto out_badfamily;
-		}
-	} else {
-		char *endptr;
+	/*
+	 * Decide what kind of netmask was specified.  If there's
+	 * no '/' present, assume the netmask is all ones.  If
+	 * there is a '/' and at least one '.', look for a spelled-
+	 * out netmask.  Otherwise, assume it was a prefixlen.
+	 */
+	if (slash == NULL)
+		shift = 0;
+	else {
+		unsigned long prefixlen;
 
-		/* A spelled out netmask address, perhaps? */
 		if (strchr(slash + 1, '.') != NULL) {
 			if (inet_pton(AF_INET, slash + 1,
 						&sin.sin_addr.s_addr) == 0)
 				goto out_badmask;
 			set_addrlist_in(clp, 1, &sin);
 			return 1;
+		} else {
+			char *endptr;
+
+			prefixlen = strtoul(slash + 1, &endptr, 10);
+			if (*endptr != '\0' && prefixlen != ULONG_MAX &&
+			    errno != ERANGE)
+				goto out_badprefix;
 		}
+		if (prefixlen > 32)
+			goto out_badprefix;
+		shift = 32 - (uint32_t)prefixlen;
+	}
+
+	/*
+	 * Now construct the full netmask bitmask in a sockaddr_in,
+	 * and plant it in the nfs_client record.
+	 */
+	sin.sin_addr.s_addr = htonl((uint32_t)~0 << shift);
+	set_addrlist_in(clp, 1, &sin);
+
+	return 1;
+
+out_badmask:
+	xlog(L_ERROR, "Invalid netmask `%s' for %s", slash + 1, clp->m_hostname);
+	return 0;
+
+out_badprefix:
+	xlog(L_ERROR, "Invalid prefix `%s' for %s", slash + 1, clp->m_hostname);
+	return 0;
+}
+
 #ifdef IPV6_SUPPORTED
-		if (strchr(slash + 1, ':')) {
+static int
+init_netmask6(nfs_client *clp, const char *slash)
+{
+	struct sockaddr_in6 sin6 = {
+		.sin6_family		= AF_INET6,
+	};
+	unsigned long prefixlen;
+	uint32_t shift;
+	int i;
+
+	/*
+	 * Decide what kind of netmask was specified.  If there's
+	 * no '/' present, assume the netmask is all ones.  If
+	 * there is a '/' and at least one ':', look for a spelled-
+	 * out netmask.  Otherwise, assume it was a prefixlen.
+	 */
+	if (slash == NULL)
+		prefixlen = 128;
+	else {
+		if (strchr(slash + 1, ':') != NULL) {
 			if (!inet_pton(AF_INET6, slash + 1, &sin6.sin6_addr))
 				goto out_badmask;
 			set_addrlist_in6(clp, 1, &sin6);
 			return 1;
-		}
-#endif
+		} else {
+			char *endptr;
 
-		/* A prefixlen was given */
-		prefixlen = strtoul(slash + 1, &endptr, 10);
-		if (*endptr != '\0' && prefixlen != ULONG_MAX && errno != ERANGE)
+			prefixlen = strtoul(slash + 1, &endptr, 10);
+			if (*endptr != '\0' && prefixlen != ULONG_MAX &&
+			    errno != ERANGE)
+				goto out_badprefix;
+		}
+		if (prefixlen > 128)
 			goto out_badprefix;
 	}
 
-	switch (family) {
-	case AF_INET:
-		if (prefixlen > 32)
-			goto out_badprefix;
-		shift = 32 - (uint32_t)prefixlen;
-		sin.sin_addr.s_addr = htonl((uint32_t)~0 << shift);
-		set_addrlist_in(clp, 1, &sin);
-		return 1;
-#ifdef IPV6_SUPPORTED
-	case AF_INET6:
-		if (prefixlen > 128)
-			goto out_badprefix;
-		for (i = 0; prefixlen > 32; i++) {
-			sin6.sin6_addr.s6_addr32[i] = 0xffffffff;
-			prefixlen -= 32;
-		}
-		shift = 32 - (uint32_t)prefixlen;
-		sin6.sin6_addr.s6_addr32[i] = htonl((uint32_t)~0 << shift);
-		set_addrlist_in6(clp, 1, &sin6);
-		return 1;
-#endif
+	/*
+	 * Now construct the full netmask bitmask in a sockaddr_in6,
+	 * and plant it in the nfs_client record.
+	 */
+	for (i = 0; prefixlen > 32; i++) {
+		sin6.sin6_addr.s6_addr32[i] = 0xffffffff;
+		prefixlen -= 32;
 	}
+	shift = 32 - (uint32_t)prefixlen;
+	sin6.sin6_addr.s6_addr32[i] = htonl((uint32_t)~0 << shift);
+	set_addrlist_in6(clp, 1, &sin6);
 
-out_badfamily:
-	xlog(L_ERROR, "Unsupported address family for %s", clp->m_hostname);
-	return 0;
+	return 1;
 
 out_badmask:
 	xlog(L_ERROR, "Invalid netmask `%s' for %s", slash + 1, clp->m_hostname);
@@ -149,12 +174,24 @@ out_badprefix:
 	xlog(L_ERROR, "Invalid prefix `%s' for %s", slash + 1, clp->m_hostname);
 	return 0;
 }
+#else	/* IPV6_SUPPORTED */
+static int
+init_netmask6(nfs_client *UNUSED(clp), const char *UNUSED(slash))
+{
+}
+#endif	/* IPV6_SUPPORTED */
 
+/*
+ * Parse the network mask for M_SUBNETWORK type clients.
+ *
+ * Return TRUE if successful, or FALSE if some error occurred.
+ */
 static int
 init_subnetwork(nfs_client *clp)
 {
 	struct addrinfo *ai;
 	sa_family_t family;
+	int result = 0;
 	char *slash;
 
 	slash = strchr(clp->m_hostname, '/');
@@ -166,7 +203,7 @@ init_subnetwork(nfs_client *clp)
 		ai = host_pton(clp->m_hostname);
 	if (ai == NULL) {
 		xlog(L_ERROR, "Invalid IP address %s", clp->m_hostname);
-		return false;
+		return result;
 	}
 
 	set_addrlist(clp, 0, ai->ai_addr);
@@ -174,7 +211,19 @@ init_subnetwork(nfs_client *clp)
 
 	freeaddrinfo(ai);
 
-	return init_netmask(clp, slash, family);
+	switch (family) {
+	case AF_INET:
+		result = init_netmask4(clp, slash);
+		break;
+	case AF_INET6:
+		result = init_netmask6(clp, slash);
+		break;
+	default:
+		xlog(L_ERROR, "Unsupported address family for %s",
+			clp->m_hostname);
+	}
+
+	return result;
 }
 
 static int

