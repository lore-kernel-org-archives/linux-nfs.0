From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] NLM: Shrink the IPv4-only version of nlm_cmp_addr()
Date: Fri, 06 Mar 2009 14:08:47 -0500
Message-ID: <20090306190846.17892.37524.stgit@ingres.1015granger.net>
References: <20090306190613.17892.26458.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:57378 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886AbZCFTKF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Mar 2009 14:10:05 -0500
In-Reply-To: <20090306190613.17892.26458.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up/micro-optimatization:  Make the AF_INET-only version of
nlm_cmp_addr() smaller.  This matches the style of
nlm_privileged_requester(), and makes the AF_INET-only version of
nlm_cmp_addr() nearly the same size as it was before IPv6 support.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/lockd/lockd.h |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index aa6fe70..51855df 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -346,6 +346,7 @@ static inline int __nlm_cmp_addr4(const struct sockaddr *sap1,
 	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static inline int __nlm_cmp_addr6(const struct sockaddr *sap1,
 				  const struct sockaddr *sap2)
 {
@@ -353,6 +354,13 @@ static inline int __nlm_cmp_addr6(const struct sockaddr *sap1,
 	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
 	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
 }
+#else	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
+static inline int __nlm_cmp_addr6(const struct sockaddr *sap1,
+				  const struct sockaddr *sap2)
+{
+	return 0;
+}
+#endif	/* !(CONFIG_IPV6 || CONFIG_IPV6_MODULE) */
 
 /*
  * Compare two host addresses

