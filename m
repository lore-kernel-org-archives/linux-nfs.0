From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/24] statd: add nsm_present_address() API
Date: Thu, 14 Jan 2010 12:30:28 -0500
Message-ID: <20100114173028.26079.10277.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:32085 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757391Ab0ANRbN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:13 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add an API to convert a socket address to a presentation address
string.  This is used for displaying error messages and the like.

We prefer getnameinfo(3) over inet_?to?(3) as it supports IPv6 scope
IDs.  Since statd has to continue to build correctly on systems whose
glibc does not have getnameinfo(3), an inet_?to?(3) version is also
provided.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/hostname.c |   64 ++++++++++++++++++++++++++++++++++++++++++++++++
 utils/statd/statd.h    |    2 ++
 2 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
index 3d10d6f..7571b6f 100644
--- a/utils/statd/hostname.c
+++ b/utils/statd/hostname.c
@@ -30,13 +30,77 @@
 
 #include <stdlib.h>
 #include <stdbool.h>
+#include <string.h>
 #include <strings.h>
 #include <netdb.h>
+#include <arpa/inet.h>
 
 #include "sockaddr.h"
 #include "statd.h"
 #include "xlog.h"
 
+/**
+ * statd_present_address - convert sockaddr to presentation address
+ * @sap: pointer to socket address to convert
+ * @buf: pointer to buffer to fill in
+ * @buflen: length of buffer
+ *
+ * Convert the passed-in sockaddr-style address to presentation format.
+ * The presentation format address is placed in @buf and is
+ * '\0'-terminated.
+ *
+ * Returns true if successful; otherwise false.
+ *
+ * getnameinfo(3) is preferred, since it can parse IPv6 scope IDs.
+ * An alternate version of statd_present_address() is available to
+ * handle older glibcs that do not have getnameinfo(3).
+ */
+#ifdef HAVE_GETNAMEINFO
+_Bool
+statd_present_address(const struct sockaddr *sap, char *buf, const size_t buflen)
+{
+	socklen_t salen;
+	int error;
+
+	salen = nfs_sockaddr_length(sap);
+	if (salen == 0) {
+		xlog(D_GENERAL, "%s: unsupported address family",
+				__func__);
+		return false;
+	}
+
+	error = getnameinfo(sap, salen, buf, (socklen_t)buflen,
+						NULL, 0, NI_NUMERICHOST);
+	if (error != 0) {
+		xlog(D_GENERAL, "%s: getnameinfo(3): %s",
+				__func__, gai_strerror(error));
+		return false;
+	}
+	return true;
+}
+#else	/* !HAVE_GETNAMEINFO */
+_Bool
+statd_present_address(const struct sockaddr *sap, char *buf, const size_t buflen)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+
+	if (sin->sin_family != AF_INET) {
+		xlog(D_GENERAL, "%s: unsupported address family", __func__);
+		return false;
+	}
+
+	/* ensure '\0' termination */
+	memset(buf, 0, buflen);
+
+	if (inet_ntop(AF_INET, (char *)&sin->sin_addr,
+					buf, (socklen_t)buflen) == NULL) {
+		xlog(D_GENERAL, "%s: inet_ntop(3): %m", __func__);
+		return false;
+	}
+	return true;
+}
+#endif	/* !HAVE_GETNAMEINFO */
+
 /*
  * Look up the hostname; report exceptional errors.  Caller must
  * call freeaddrinfo(3) if a valid addrinfo is returned.
diff --git a/utils/statd/statd.h b/utils/statd/statd.h
index fd6a084..c2d5956 100644
--- a/utils/statd/statd.h
+++ b/utils/statd/statd.h
@@ -23,6 +23,8 @@
  * Function prototypes.
  */
 extern _Bool	statd_matchhostname(const char *hostname1, const char *hostname2);
+extern _Bool	statd_present_address(const struct sockaddr *sap, char *buf,
+					const size_t buflen);
 
 extern void	my_svc_run(void);
 extern void	notify_hosts(void);

