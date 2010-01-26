From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] SUNRPC: Use rpc_pton() in ip_map_parse()
Date: Tue, 26 Jan 2010 14:03:47 -0500
Message-ID: <20100126190347.3368.44031.stgit@localhost.localdomain>
References: <20100126190214.3368.89388.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:19905 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754921Ab0AZTEK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jan 2010 14:04:10 -0500
In-Reply-To: <20100126190214.3368.89388.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The existing logic in ip_map_parse() can not currently parse
shorthanded IPv6 addresses (anything with a double colon), nor can
it parse an IPv6 presentation address with a scope ID.  An
IPv6-enabled mountd can pass down both.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcauth_unix.c |   47 +++++++++++++++++++++++++--------------------
 1 files changed, 26 insertions(+), 21 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index d8c0411..97f0e9e 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -15,6 +15,7 @@
 #include <linux/kernel.h>
 #define RPCDBG_FACILITY	RPCDBG_AUTH
 
+#include <linux/sunrpc/clnt.h>
 
 /*
  * AUTHUNIX and AUTHNULL credentials are both handled here.
@@ -187,10 +188,13 @@ static int ip_map_parse(struct cache_detail *cd,
 	 * for scratch: */
 	char *buf = mesg;
 	int len;
-	int b1, b2, b3, b4, b5, b6, b7, b8;
-	char c;
 	char class[8];
-	struct in6_addr addr;
+	union {
+		struct sockaddr		sa;
+		struct sockaddr_in	s4;
+		struct sockaddr_in6	s6;
+	} address;
+	struct sockaddr_in6 sin6;
 	int err;
 
 	struct ip_map *ipmp;
@@ -209,24 +213,24 @@ static int ip_map_parse(struct cache_detail *cd,
 	len = qword_get(&mesg, buf, mlen);
 	if (len <= 0) return -EINVAL;
 
-	if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) == 4) {
-		addr.s6_addr32[0] = 0;
-		addr.s6_addr32[1] = 0;
-		addr.s6_addr32[2] = htonl(0xffff);
-		addr.s6_addr32[3] =
-			htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
-       } else if (sscanf(buf, "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x%c",
-			&b1, &b2, &b3, &b4, &b5, &b6, &b7, &b8, &c) == 8) {
-		addr.s6_addr16[0] = htons(b1);
-		addr.s6_addr16[1] = htons(b2);
-		addr.s6_addr16[2] = htons(b3);
-		addr.s6_addr16[3] = htons(b4);
-		addr.s6_addr16[4] = htons(b5);
-		addr.s6_addr16[5] = htons(b6);
-		addr.s6_addr16[6] = htons(b7);
-		addr.s6_addr16[7] = htons(b8);
-       } else
+	if (rpc_pton(buf, len, &address.sa, sizeof(address)) == 0)
 		return -EINVAL;
+	switch (address.sa.sa_family) {
+	case AF_INET:
+		/* Form a mapped IPv4 address in sin6 */
+		memset(&sin6, 0, sizeof(sin6));
+		sin6.sin6_family = AF_INET6;
+		sin6.sin6_addr.s6_addr32[2] = htonl(0xffff);
+		sin6.sin6_addr.s6_addr32[3] = address.s4.sin_addr.s_addr;
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		memcpy(&sin6, &address.s6, sizeof(sin6));
+		break;
+#endif
+	default:
+		return -EINVAL;
+	}
 
 	expiry = get_expiry(&mesg);
 	if (expiry ==0)
@@ -243,7 +247,8 @@ static int ip_map_parse(struct cache_detail *cd,
 	} else
 		dom = NULL;
 
-	ipmp = ip_map_lookup(class, &addr);
+	/* IPv6 scope IDs are ignored for now */
+	ipmp = ip_map_lookup(class, &sin6.sin6_addr);
 	if (ipmp) {
 		err = ip_map_update(ipmp,
 			     container_of(dom, struct unix_domain, h),

