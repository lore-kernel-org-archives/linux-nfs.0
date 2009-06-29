From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/31] getport: Remove AI_ADDRCONFIG from
	nfs_gp_loopback_address()
Date: Mon, 29 Jun 2009 13:35:17 -0400
Message-ID: <20090629173516.2076.8213.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:54286 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758242AbZF2Rfq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:35:46 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

AI_ADDRCONFIG was used ostensibly to figure out if the local system
had IPv6 available when generating a loopback address.

A legacy version of nfs_gp_loopback_address() was created to handle
ANYADDR address generation for old versions of glibc where
AI_ADDRCONFIG doesn't exist.  This means we have to be careful to
test both the normal and legacy versions when committing changes in
this area.

But it turns out that even contemporary versions of glibc ignore
AI_ADDRCONFIG when the hostname string is NULL.  getaddrinfo(3)
always returns an AF_INET and an AF_INET6 loopback address in this
case, no matter how the system is configured.

Change nfs_gp_loopback_address() to have one version that simply looks
up "localhost" instead of doing anything fancy.  If "localhost" is an
IPv6 address, we'll use that.  Otherwise, it should nearly always be
an AF_INET loopback address.

This eliminates the need for AI_ADDRCONFIG, and removes the duplicate
version of nfs_gp_loopback_address().  Note that callers never used
the port number in the returned socket address, so get rid of the
"sunrpc" service string too.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/getport.c |   54 +++++++++----------------------------------------
 1 files changed, 10 insertions(+), 44 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 2b80dce..9d85e89 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -65,59 +65,32 @@ static const rpcvers_t default_rpcb_version = RPCBVERS_4;
 static const rpcvers_t default_rpcb_version = PMAPVERS;
 #endif	/* !HAVE_LIBTIRPC */
 
-#ifdef HAVE_DECL_AI_ADDRCONFIG
 /*
- * getaddrinfo(3) generates a usable loopback address based on how the
- * local network interfaces are configured.  RFC 3484 requires that the
- * results are sorted so that the first result has the best likelihood
- * of working, so we try just that first result.
+ * There's no easy way to tell how the local system's networking
+ * and rpcbind is configured (ie. whether we want to use IPv6 or
+ * IPv4 loopback to contact RPC services on the local host).  We
+ * punt and simply try to look up "localhost".
  *
  * Returns TRUE on success.
  */
 static int nfs_gp_loopback_address(struct sockaddr *sap, socklen_t *salen)
 {
 	struct addrinfo *gai_results;
-	struct addrinfo gai_hint = {
-		.ai_flags	= AI_ADDRCONFIG,
-	};
-	socklen_t len = *salen;
 	int ret = 0;
 
-	if (getaddrinfo(NULL, "sunrpc", &gai_hint, &gai_results))
+	if (getaddrinfo("localhost", NULL, NULL, &gai_results))
 		return 0;
 
-	switch (gai_results->ai_addr->sa_family) {
-	case AF_INET:
-	case AF_INET6:
-		if (len >= gai_results->ai_addrlen) {
-			memcpy(sap, gai_results->ai_addr,
-					gai_results->ai_addrlen);
-			*salen = gai_results->ai_addrlen;
-			ret = 1;
-		}
+	if (*salen >= gai_results->ai_addrlen) {
+		memcpy(sap, gai_results->ai_addr,
+				gai_results->ai_addrlen);
+		*salen = gai_results->ai_addrlen;
+		ret = 1;
 	}
 
 	freeaddrinfo(gai_results);
 	return ret;
 }
-#else
-/*
- * Old versions of getaddrinfo(3) don't support AI_ADDRCONFIG, so we
- * have a fallback for building on legacy systems.
- */
-static int nfs_gp_loopback_address(struct sockaddr *sap, socklen_t *salen)
-{
-	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-
-	memset(sin, 0, sizeof(*sin));
-
-	sin->sin_family = AF_INET;
-	sin->sin_addr.s_addr = htonl(INADDR_LOOPBACK);
-	*salen = sizeof(*sin);
-
-	return 1;
-}
-#endif
 
 /*
  * Plant port number in @sap.  @port is already in network byte order.
@@ -839,13 +812,6 @@ int nfs_getport_ping(struct sockaddr *sap, const socklen_t salen,
  * isn't listening on /var/run/rpcbind.sock), send a query via UDP to localhost
  * (UDP doesn't leave a socket in TIME_WAIT, and the timeout is a relatively
  * short 3 seconds).
- *
- * getaddrinfo(3) generates a usable loopback address.  RFC 3484 requires that
- * the results are sorted so that the first result has the best likelihood of
- * working, so we try just that first result.  If IPv6 is all that is
- * available, we are sure to generate an AF_INET6 loopback address and use
- * rpcbindv4/v3 GETADDR.  AF_INET6 requests go via rpcbind v4/3 in order to
- * detect if the requested RPC service supports AF_INET6 or not.
  */
 unsigned short nfs_getlocalport(const rpcprot_t program,
 				const rpcvers_t version,

