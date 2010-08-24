Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:51211 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755733Ab0HXQfq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Aug 2010 12:35:46 -0400
Received: by gxk23 with SMTP id 23so2602827gxk.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2010 09:35:45 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] libexport.a: Prepare init_subnetwork() for IPv6 support
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 24 Aug 2010 12:35:42 -0400
Message-ID: <20100824163542.2433.28219.stgit@matisse.1015granger.net>
In-Reply-To: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
References: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Retire the slash32 logic in inet_netmask() in favor of a more generic
netmask parser that can support IPv6 addresses.

If an invalid IP address string is given to inet_addr(3), it returns
INADDR_NONE, which is actually a "valid" address (255.255.255.255).
We're none the wiser to the substitution until something breaks later.

This patch provides better sanity checking of the parsed address, now
that such an error can be reported to client_init()'s callers.
We can also check the prefixlen value a little more carefully as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   81 ++++++++++++++++++++++++++++++++++-------------
 1 files changed, 59 insertions(+), 22 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index a89142d..780c74d 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -17,6 +17,7 @@
 #include <string.h>
 #include <ctype.h>
 #include <netdb.h>
+#include <errno.h>
 
 #include "misc.h"
 #include "nfslib.h"
@@ -58,25 +59,58 @@ client_free(nfs_client *clp)
 }
 
 static int
-init_netmask(nfs_client *clp, const char *slash)
+init_netmask(nfs_client *clp, const char *slash, const sa_family_t family)
 {
 	struct sockaddr_in sin = {
 		.sin_family		= AF_INET,
 	};
+	unsigned long prefixlen;
+	uint32_t shift;
 
-	if (strchr(slash + 1, '.') != NULL)
-		sin.sin_addr.s_addr = inet_addr(slash + 1);
-	else {
-		int prefixlen = atoi(slash + 1);
-		if (0 < prefixlen && prefixlen <= 32)
-			sin.sin_addr.s_addr =
-					htonl((uint32_t)~0 << (32 - prefixlen));
-		else
+	/* No slash present; assume netmask is all ones */
+	if (slash == NULL) {
+		switch (family) {
+		case AF_INET:
+			prefixlen = 32;
+			break;
+		default:
+			goto out_badfamily;
+		}
+	} else {
+		char *endptr;
+
+		/* A spelled out netmask address, perhaps? */
+		if (strchr(slash + 1, '.') != NULL) {
+			if (inet_pton(AF_INET, slash + 1,
+						&sin.sin_addr.s_addr) == 0)
+				goto out_badmask;
+			set_addrlist_in(clp, 1, &sin);
+			return 1;
+		}
+
+		/* A prefixlen was given */
+		prefixlen = strtoul(slash + 1, &endptr, 10);
+		if (*endptr != '\0' && prefixlen != ULONG_MAX && errno != ERANGE)
 			goto out_badprefix;
 	}
 
-	set_addrlist_in(clp, 1, &sin);
-	return 1;
+	switch (family) {
+	case AF_INET:
+		if (prefixlen > 32)
+			goto out_badprefix;
+		shift = 32 - (uint32_t)prefixlen;
+		sin.sin_addr.s_addr = htonl((uint32_t)~0 << shift);
+		set_addrlist_in(clp, 1, &sin);
+		return 1;
+	}
+
+out_badfamily:
+	xlog(L_ERROR, "Unsupported address family for %s", clp->m_hostname);
+	return 0;
+
+out_badmask:
+	xlog(L_ERROR, "Invalid netmask `%s' for %s", slash + 1, clp->m_hostname);
+	return 0;
 
 out_badprefix:
 	xlog(L_ERROR, "Invalid prefix `%s' for %s", slash + 1, clp->m_hostname);
@@ -86,25 +120,28 @@ out_badprefix:
 static int
 init_subnetwork(nfs_client *clp)
 {
-	static char slash32[] = "/32";
 	struct addrinfo *ai;
-	char *cp;
-
-	cp = strchr(clp->m_hostname, '/');
-	if (cp == NULL)
-		cp = slash32;
-
-	*cp = '\0';
-	ai = host_pton(clp->m_hostname);
-	*cp = '/';
+	sa_family_t family;
+	char *slash;
+
+	slash = strchr(clp->m_hostname, '/');
+	if (slash != NULL) {
+		*slash = '\0';
+		ai = host_pton(clp->m_hostname);
+		*slash = '/';
+	} else
+		ai = host_pton(clp->m_hostname);
 	if (ai == NULL) {
 		xlog(L_ERROR, "Invalid IP address %s", clp->m_hostname);
 		return false;
 	}
+
 	set_addrlist(clp, 0, ai->ai_addr);
+	family = ai->ai_addr->sa_family;
+
 	freeaddrinfo(ai);
 
-	return init_netmask(clp, cp);
+	return init_netmask(clp, slash, family);
 }
 
 static int

