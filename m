From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/29] statd: add nsm_present_address() API
Date: Tue, 10 Nov 2009 16:59:20 -0500
Message-ID: <20091110215919.23822.69508.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:25490 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753571AbZKJWBT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 17:01:19 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add an API to convert a socket addres to a presentation address
string.  This is used for displaying error messages and the like.

We prefer getnameinfo(3) over inet_?to?(3) as it supports IPv6 scope
IDs.  Since statd has to build on systems whose glibc does not have
getnameinfo(3), an inet_?to?(3) version is also provided.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/hostname.c |   73 ++++++++++++++++++++++++++++++++++++++++++++++++
 utils/statd/statd.h    |    2 +
 2 files changed, 75 insertions(+), 0 deletions(-)

diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
index cb064fd..6f532b8 100644
--- a/utils/statd/hostname.c
+++ b/utils/statd/hostname.c
@@ -29,6 +29,7 @@
 #include <sys/socket.h>
 
 #include <stdlib.h>
+#include <string.h>
 #include <strings.h>
 #include <netdb.h>
 
@@ -39,6 +40,78 @@
 #define AI_ADDRCONFIG	0
 #endif
 
+/**
+ * nsm_present_address - convert sockaddr to presentation address
+ * @sap: pointer to socket address to convert
+ * @salen: length of socket address
+ * @buf: pointer to buffer to fill in
+ * @buflen: length of buffer
+ *
+ * Convert the passed-in sockaddr-style address to presentation format.
+ * The presentation format address is placed in @buf and is
+ * '\0'-terminated.  Callers who don't know the size of the socket
+ * address can pass a zero.
+ *
+ * Returns 1 if successful; otherwise zero.
+ *
+ * getnameinfo(3) is preferred, since it can parse IPv6 scope IDs.
+ * An alternate version of present_address() is available to deal with
+ * older glibcs that do not have getnameinfo(3).
+ */
+#ifdef IPV6_SUPPORTED
+int
+nsm_present_address(const struct sockaddr *sap, socklen_t salen,
+		char *buf, const size_t buflen)
+{
+	int error;
+
+	if (salen == 0)
+		switch (sap->sa_family) {
+		case AF_INET:
+			salen = sizeof(struct sockaddr_in);
+			break;
+		case AF_INET6:
+			salen = sizeof(struct sockaddr_in6);
+			break;
+		default:
+			xlog(L_ERROR, "%s: Unsupported address family",
+					__func__);
+			return 0;
+		}
+
+	error = getnameinfo(sap, salen, buf, buflen, NULL, 0, NI_NUMERICHOST);
+	if (error) {
+		xlog(L_ERROR, "%s: getnameinfo: %s",
+				__func__, gai_strerror(error));
+		return 0;
+	}
+
+	return 1;
+}
+
+#else	/* !IPV6_SUPPORTED */
+
+#include <arpa/inet.h>
+
+int
+nsm_present_address(const struct sockaddr *sap,
+		__attribute__((unused)) socklen_t salen,
+		char *buf, const size_t buflen)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+
+	if (sin->sin_family != AF_INET) {
+		xlog(L_ERROR, "%s: Unsupported address family", __func__);
+		return 0;
+	}
+
+	memset(buf, 0, buflen);
+	if (!inet_ntop(AF_INET, (char *)&sin->sin_addr, buf, buflen))
+		return 0;
+	return 1;
+}
+#endif	/* !IPV6_SUPPORTED */
+
 /*
  * Look up the hostname; report exceptional errors.  Caller must
  * call freeaddrinfo(3) if a valid addrinfo is returned.
diff --git a/utils/statd/statd.h b/utils/statd/statd.h
index c53b70a..71a77e2 100644
--- a/utils/statd/statd.h
+++ b/utils/statd/statd.h
@@ -23,6 +23,8 @@
  * Function prototypes.
  */
 extern int	nsm_matchhostname(const char *hostname1, const char *hostname2);
+extern int	nsm_present_address(const struct sockaddr *sap, socklen_t salen,
+					char *buf, const size_t buflen);
 extern void	my_svc_run(void);
 extern void	notify_hosts(void);
 extern void	shuffle_dirs(void);

