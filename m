From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/9] NLM: Shrink the IPv4-only version of nlm_cmp_addr()
Date: Wed, 11 Mar 2009 14:25:25 -0400
Message-ID: <20090311182525.403.26768.stgit@heimdal.trondhjem.org>
References: <20090311182525.403.42026.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755140AbZCKS3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:29:47 -0400
In-Reply-To: <20090311182525.403.42026.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Clean up/micro-optimatization:  Make the AF_INET-only version of
nlm_cmp_addr() smaller.  This matches the style of
nlm_privileged_requester(), and makes the AF_INET-only version of
nlm_cmp_addr() nearly the same size as it was before IPv6 support.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
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

