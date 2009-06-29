From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/31] getport: replace getnameinfo(NI_NUMERICHOST) with
	inet_ntop(3)
Date: Mon, 29 Jun 2009 13:35:26 -0400
Message-ID: <20090629173525.2076.67115.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:56611 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758436AbZF2Rfv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:35:51 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

getnameinfo(3) with the NI_NUMERICHOST flag is used in
support/nfs/getport.c to convert socket addresses to universal address
strings.

Older versions of glibc do not have getnameinfo(3), however.  In order
for nfs-utils to build on older systems we switch in legacy code via
HAVE_GETNAMEINFO and use inet_ntoa(3).

A problem with this is that we have to double our test matrix to be
sure that both versions of these routines build and operate correctly.
Another minor problem is that inet_ntoa(3) is officially deprecated.

So let's always use a single implementation based on inet_ntop(3).
Universal address strings do not support link-local / scope IDs, so we
don't lose any functionality by using inet_ntop(3) here.

This means we open code a bit of logic that is available in most
modern versions of glibc, but in return we can use exactly the same
code for all builds (on systems with getnameinfo(3) and without).

An additional benefit is we can avoid using NI_MAXHOST for character
buffers that live on the stack: it's 1025 bytes.  Instead,
INET6_ADDRSTRLEN is used, which is just 46 bytes, plus an additional
eight bytes for the port information.  We add beefier buffer overflow
detection logic as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/getport.c |   70 ++++++++++++++++---------------------------------
 1 files changed, 23 insertions(+), 47 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 9d85e89..056d3c7 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -330,81 +330,57 @@ int nfs_universal2port(const char *uaddr)
  * the returned string.  Otherwise NULL is returned and
  * rpc_createerr.cf_stat is set to reflect the error.
  *
+ * inet_ntop(3) is used here, since getnameinfo(3) is not available
+ * in some earlier glibc releases, and we don't require support for
+ * scope IDs for universal addresses.
  */
-#ifdef HAVE_GETNAMEINFO
-
 char *nfs_sockaddr2universal(const struct sockaddr *sap,
 			     const socklen_t salen)
 {
-	struct sockaddr_un *sun = (struct sockaddr_un *)sap;
-	char buf[NI_MAXHOST];
+	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
+	const struct sockaddr_un *sun = (const struct sockaddr_un *)sap;
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+	char buf[INET6_ADDRSTRLEN + 8 /* for port information */];
 	uint16_t port;
+	size_t count;
+	char *result;
+	int len;
 
 	switch (sap->sa_family) {
 	case AF_LOCAL:
 		return strndup(sun->sun_path, sizeof(sun->sun_path));
 	case AF_INET:
-		if (getnameinfo(sap, salen, buf, (socklen_t)sizeof(buf),
-					NULL, 0, NI_NUMERICHOST) != 0)
+		if (inet_ntop(AF_INET, (const void *)&sin->sin_addr.s_addr,
+					buf, (socklen_t)sizeof(buf)) == NULL)
 			goto out_err;
-		port = ntohs(((struct sockaddr_in *)sap)->sin_port);
+		port = ntohs(sin->sin_port);
 		break;
 	case AF_INET6:
-		if (getnameinfo(sap, salen, buf, (socklen_t)sizeof(buf),
-					NULL, 0, NI_NUMERICHOST) != 0)
+		if (inet_ntop(AF_INET6, (const void *)&sin6->sin6_addr,
+					buf, (socklen_t)sizeof(buf)) == NULL)
 			goto out_err;
-		port = ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
+		port = ntohs(sin6->sin6_port);
 		break;
 	default:
 		goto out_err;
 	}
 
-	(void)snprintf(buf + strlen(buf), sizeof(buf) - strlen(buf), ".%u.%u",
+	count = sizeof(buf) - strlen(buf);
+	len = snprintf(buf + strlen(buf), count, ".%u.%u",
 			(unsigned)(port >> 8), (unsigned)(port & 0xff));
-
-	return strdup(buf);
-
-out_err:
-	rpc_createerr.cf_stat = RPC_N2AXLATEFAILURE;
-	return NULL;
-}
-
-#else	/* HAVE_GETNAMEINFO */
-
-char *nfs_sockaddr2universal(const struct sockaddr *sap,
-			     const socklen_t salen)
-{
-	struct sockaddr_un *sun = (struct sockaddr_un *)sap;
-	char buf[NI_MAXHOST];
-	uint16_t port;
-	char *addr;
-
-	switch (sap->sa_family) {
-	case AF_LOCAL:
-		return strndup(sun->sun_path, sizeof(sun->sun_path));
-	case AF_INET:
-		addr = inet_ntoa(((struct sockaddr_in *)sap)->sin_addr);
-		if (addr != NULL && strlen(addr) > sizeof(buf))
-			goto out_err;
-		strcpy(buf, addr);
-		port = ntohs(((struct sockaddr_in *)sap)->sin_port);
-		break;
-	default:
+	/* before glibc 2.0.6, snprintf(3) could return -1 */
+	if (len < 0 || (size_t)len > count)
 		goto out_err;
-	}
 
-	(void)snprintf(buf + strlen(buf), sizeof(buf) - strlen(buf), ".%u.%u",
-			(unsigned)(port >> 8), (unsigned)(port & 0xff));
-
-	return strdup(buf);
+	result = strdup(buf);
+	if (result != NULL)
+		return result;
 
 out_err:
 	rpc_createerr.cf_stat = RPC_N2AXLATEFAILURE;
 	return NULL;
 }
 
-#endif	/* HAVE_GETNAMEINFO */
-
 /*
  * Send a NULL request to the indicated RPC service.
  *

