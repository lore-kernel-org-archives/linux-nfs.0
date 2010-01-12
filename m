From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] SUNRPC: Deprecate support for site-local addresses
Date: Tue, 12 Jan 2010 17:41:10 -0500
Message-ID: <20100112224110.3167.90802.stgit@localhost.localdomain>
References: <20100112223826.3167.13900.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:47193 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560Ab0ALWmg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Jan 2010 17:42:36 -0500
In-Reply-To: <20100112223826.3167.13900.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC 3879 "formally deprecates" site-local IPv6 addresses.  We
interpret that to mean that the scope ID is ignored for all but
link-local addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Jeff Layton <jlayton@redhat.com>
---

 net/sunrpc/addr.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index 6dcdd25..0756c5d 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -71,8 +71,7 @@ static size_t rpc_ntop6(const struct sockaddr *sap,
 	if (unlikely(len == 0))
 		return len;
 
-	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL) &&
-	    !(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_SITELOCAL))
+	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
 		return len;
 
 	rc = snprintf(scopebuf, sizeof(scopebuf), "%c%u",
@@ -165,8 +164,7 @@ static int rpc_parse_scope_id(const char *buf, const size_t buflen,
 	if (*delim != IPV6_SCOPE_DELIMITER)
 		return 0;
 
-	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL) &&
-	    !(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_SITELOCAL))
+	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL))
 		return 0;
 
 	len = (buf + buflen) - delim - 1;

