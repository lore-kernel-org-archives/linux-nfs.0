Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:61438 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755664Ab0HXQf4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Aug 2010 12:35:56 -0400
Received: by yxg6 with SMTP id 6so2593895yxg.19
        for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2010 09:35:55 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] libexport.a: IPv6 support for client_init_subnet()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 24 Aug 2010 12:35:52 -0400
Message-ID: <20100824163552.2433.94979.stgit@matisse.1015granger.net>
In-Reply-To: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
References: <20100824162926.2433.7535.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

To parse and store an IPv6 host or subnet address, init_netmask()
needs to handle 128 bit subnet masks.

Unfortunately what once was a pretty simple little function has grown
much larger.  This logic must now not only parse IPv6 addresses
correctly, but must also distinguish between IPv4 and IPv6.

To avoid code duplication, I'm "bending" the cardinal rule of not
using "#ifdef" inside functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 780c74d..4c6cd69 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -66,6 +66,12 @@ init_netmask(nfs_client *clp, const char *slash, const sa_family_t family)
 	};
 	unsigned long prefixlen;
 	uint32_t shift;
+#ifdef IPV6_SUPPORTED
+	struct sockaddr_in6 sin6 = {
+		.sin6_family		= AF_INET6,
+	};
+	int i;
+#endif
 
 	/* No slash present; assume netmask is all ones */
 	if (slash == NULL) {
@@ -73,6 +79,11 @@ init_netmask(nfs_client *clp, const char *slash, const sa_family_t family)
 		case AF_INET:
 			prefixlen = 32;
 			break;
+#ifdef IPV6_SUPPORTED
+		case AF_INET6:
+			prefixlen = 128;
+			break;
+#endif
 		default:
 			goto out_badfamily;
 		}
@@ -87,6 +98,14 @@ init_netmask(nfs_client *clp, const char *slash, const sa_family_t family)
 			set_addrlist_in(clp, 1, &sin);
 			return 1;
 		}
+#ifdef IPV6_SUPPORTED
+		if (strchr(slash + 1, ':')) {
+			if (!inet_pton(AF_INET6, slash + 1, &sin6.sin6_addr))
+				goto out_badmask;
+			set_addrlist_in6(clp, 1, &sin6);
+			return 1;
+		}
+#endif
 
 		/* A prefixlen was given */
 		prefixlen = strtoul(slash + 1, &endptr, 10);
@@ -102,6 +121,19 @@ init_netmask(nfs_client *clp, const char *slash, const sa_family_t family)
 		sin.sin_addr.s_addr = htonl((uint32_t)~0 << shift);
 		set_addrlist_in(clp, 1, &sin);
 		return 1;
+#ifdef IPV6_SUPPORTED
+	case AF_INET6:
+		if (prefixlen > 128)
+			goto out_badprefix;
+		for (i = 0; prefixlen > 32; i++) {
+			sin6.sin6_addr.s6_addr32[i] = 0xffffffff;
+			prefixlen -= 32;
+		}
+		shift = 32 - (uint32_t)prefixlen;
+		sin6.sin6_addr.s6_addr32[i] = htonl((uint32_t)~0 << shift);
+		set_addrlist_in6(clp, 1, &sin6);
+		return 1;
+#endif
 	}
 
 out_badfamily:

