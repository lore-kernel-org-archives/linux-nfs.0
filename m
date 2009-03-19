From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/23] SUNRPC: Clean up static inline functions in svc_xprt.h
Date: Wed, 18 Mar 2009 20:45:43 -0400
Message-ID: <20090319004543.32404.1557.stgit@ingres.1015granger.net>
References: <20090319004024.32404.68289.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:34422 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754732AbZCSAqf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 20:46:35 -0400
In-Reply-To: <20090319004024.32404.68289.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Enable the use of const arguments in higher level svc_ APIs
by adding const to the arguments of the helper functions in svc_xprt.h

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/svc_xprt.h |   46 ++++++++++++++++++++++-----------------
 1 files changed, 26 insertions(+), 20 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index c2aa8cd..ee21e8a 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -88,29 +88,32 @@ static inline void svc_xprt_get(struct svc_xprt *xprt)
 	kref_get(&xprt->xpt_ref);
 }
 static inline void svc_xprt_set_local(struct svc_xprt *xprt,
-				      struct sockaddr *sa, int salen)
+				      const struct sockaddr *sa,
+				      const size_t salen)
 {
 	memcpy(&xprt->xpt_local, sa, salen);
 	xprt->xpt_locallen = salen;
 }
 static inline void svc_xprt_set_remote(struct svc_xprt *xprt,
-				       struct sockaddr *sa, int salen)
+				       const struct sockaddr *sa,
+				       const size_t salen)
 {
 	memcpy(&xprt->xpt_remote, sa, salen);
 	xprt->xpt_remotelen = salen;
 }
-static inline unsigned short svc_addr_port(struct sockaddr *sa)
+static inline unsigned short svc_addr_port(const struct sockaddr *sa)
 {
-	unsigned short ret = 0;
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sa;
+	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sa;
+
 	switch (sa->sa_family) {
 	case AF_INET:
-		ret = ntohs(((struct sockaddr_in *)sa)->sin_port);
-		break;
+		return ntohs(sin->sin_port);
 	case AF_INET6:
-		ret = ntohs(((struct sockaddr_in6 *)sa)->sin6_port);
-		break;
+		return ntohs(sin6->sin6_port);
 	}
-	return ret;
+
+	return 0;
 }
 
 static inline int svc_addr_len(const struct sockaddr *sa)
@@ -125,36 +128,39 @@ static inline int svc_addr_len(const struct sockaddr *sa)
 	return -EAFNOSUPPORT;
 }
 
-static inline unsigned short svc_xprt_local_port(struct svc_xprt *xprt)
+static inline unsigned short svc_xprt_local_port(const struct svc_xprt *xprt)
 {
-	return svc_addr_port((struct sockaddr *)&xprt->xpt_local);
+	return svc_addr_port((const struct sockaddr *)&xprt->xpt_local);
 }
 
-static inline unsigned short svc_xprt_remote_port(struct svc_xprt *xprt)
+static inline unsigned short svc_xprt_remote_port(const struct svc_xprt *xprt)
 {
-	return svc_addr_port((struct sockaddr *)&xprt->xpt_remote);
+	return svc_addr_port((const struct sockaddr *)&xprt->xpt_remote);
 }
 
-static inline char *__svc_print_addr(struct sockaddr *addr,
-				     char *buf, size_t len)
+static inline char *__svc_print_addr(const struct sockaddr *addr,
+				     char *buf, const size_t len)
 {
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)addr;
+	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)addr;
+
 	switch (addr->sa_family) {
 	case AF_INET:
-		snprintf(buf, len, "%pI4, port=%u",
-			&((struct sockaddr_in *)addr)->sin_addr,
-			ntohs(((struct sockaddr_in *) addr)->sin_port));
+		snprintf(buf, len, "%pI4, port=%u", &sin->sin_addr,
+			ntohs(sin->sin_port));
 		break;
 
 	case AF_INET6:
 		snprintf(buf, len, "%pI6, port=%u",
-			 &((struct sockaddr_in6 *)addr)->sin6_addr,
-			ntohs(((struct sockaddr_in6 *) addr)->sin6_port));
+			 &sin6->sin6_addr,
+			ntohs(sin6->sin6_port));
 		break;
 
 	default:
 		snprintf(buf, len, "unknown address type: %d", addr->sa_family);
 		break;
 	}
+
 	return buf;
 }
 #endif /* SUNRPC_SVC_XPRT_H */

