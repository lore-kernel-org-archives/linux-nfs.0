From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 25/27] NLM: nlm_privileged_requester() doesn't recognize
	mapped loopback address
Date: Fri, 05 Dec 2008 19:05:02 -0500
Message-ID: <20081206000502.24075.23832.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:50181 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757497AbYLFAGb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:06:31 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit b85e4676 added the nlm_privileged_requester() helper to check
whether an RPC request was sent from a local privileged caller.  It
recognizes IPv4 privileged callers (from "127.0.0.1"), and IPv6
privileged callers (from "::1").

However, IPV6_ADDR_LOOPBACK is not set for the mapped IPv4 loopback
address (::ffff:7f00:0001), so the test breaks when the kernel's RPC
service is IPv6-enabled but user space is calling via the IPv4
loopback address.  This is actually the most common case for IPv6-
enabled RPC services on Linux.

Rewrite the IPv6 check to handle the mapped IPv4 loopback address as
well as a normal IPv6 loopback address.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/lockd/lockd.h |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 6ab0449..80d7e8a 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -299,8 +299,14 @@ static inline int __nlm_privileged_request4(const struct sockaddr *sap)
 static inline int __nlm_privileged_request6(const struct sockaddr *sap)
 {
 	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
-	return (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LOOPBACK) &&
-			(ntohs(sin6->sin6_port) < 1024);
+
+	if (ntohs(sin6->sin6_port) > 1023)
+		return 0;
+
+	if (ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_MAPPED)
+		return ipv4_is_loopback(sin6->sin6_addr.s6_addr32[3]);
+
+	return ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LOOPBACK;
 }
 #else	/* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
 static inline int __nlm_privileged_request6(const struct sockaddr *sap)

