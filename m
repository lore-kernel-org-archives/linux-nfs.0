From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/18] NLM: nlm_privileged_requester() doesn't recognize
	mapped loopback address
Date: Wed, 05 Nov 2008 12:19:27 -0500
Message-ID: <20081105171926.6773.24815.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:35692 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbYKERTw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:19:52 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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
well as a normal IPv6 loopback address. For consistency, rewrite the
IPv4 check to match the same style as the IPv6 check, which is now
somewhat more broad than a strict check for 127.0.0.1.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/lockd/lockd.h |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index b56d5aa..830148e 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -280,16 +280,25 @@ static inline struct inode *nlmsvc_file_inode(struct nlm_file *file)
 static inline int __nlm_privileged_request4(const struct sockaddr *sap)
 {
 	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-	return (sin->sin_addr.s_addr == htonl(INADDR_LOOPBACK)) &&
-			(ntohs(sin->sin_port) < 1024);
+
+	if (ntohs(sin->sin_port) > 1023)
+		return 0;
+
+	return ipv4_is_loopback(sin->sin_addr.s_addr);
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
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

