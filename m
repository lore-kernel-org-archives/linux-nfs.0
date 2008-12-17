From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] getport: don't use getaddrinfo(3) on old systems
Date: Wed, 17 Dec 2008 15:37:30 -0500
Message-ID: <20081217203730.14933.16194.stgit@ingres.1015granger.net>
References: <20081217203301.14933.81853.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:26655 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396AbYLQUiZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Dec 2008 15:38:25 -0500
In-Reply-To: <20081217203301.14933.81853.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Older glibc versions have a getaddrinfo(3) that doesn't support
AI_ADDRCONFIG.  Detect that case and build something else for
getport.c that will work adequately on those systems.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/nfs/getport.c |   69 ++++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 59 insertions(+), 10 deletions(-)

diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 25dca6c..47824a2 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -73,6 +73,60 @@ static const char *nfs_gp_rpcb_pgmtbl[] = {
 	NULL,
 };
 
+#ifdef HAVE_DECL_AI_ADDRCONFIG
+/*
+ * getaddrinfo(3) generates a usable loopback address based on how the
+ * local network interfaces are configured.  RFC 3484 requires that the
+ * results are sorted so that the first result has the best likelihood
+ * of working, so we try just that first result.
+ *
+ * Returns TRUE on success.
+ */
+static int nfs_gp_loopback_address(struct sockaddr *sap, socklen_t *salen)
+{
+	struct addrinfo *gai_results;
+	struct addrinfo gai_hint = {
+		.ai_flags	= AI_ADDRCONFIG,
+	};
+	socklen_t len = *salen;
+	int ret = 0;
+
+	if (getaddrinfo(NULL, "sunrpc", &gai_hint, &gai_results))
+		return 0;
+
+	switch (gai_results->ai_addr->sa_family) {
+	case AF_INET:
+	case AF_INET6:
+		if (len >= gai_results->ai_addrlen) {
+			memcpy(sap, gai_results->ai_addr,
+					gai_results->ai_addrlen);
+			*salen = gai_results->ai_addrlen;
+			ret = 1;
+		}
+	}
+
+	freeaddrinfo(gai_results);
+	return ret;
+}
+#else
+/*
+ * Old versions of getaddrinfo(3) don't support AI_ADDRCONFIG, so we
+ * have a fallback for building on legacy systems.
+ */
+static int nfs_gp_loopback_address(struct sockaddr *sap, socklen_t *salen)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+
+	memset(sin, 0, sizeof(*sin));
+
+	sin->sin_family = AF_INET;
+	sin->sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+	*salen = sizeof(*sin);
+
+	return 1;
+}
+#endif
+
 /*
  * Discover the port number that should be used to contact an
  * rpcbind service.  This will detect if the port has a local
@@ -780,12 +834,10 @@ unsigned short nfs_getlocalport(const rpcprot_t program,
 				const rpcvers_t version,
 				const unsigned short protocol)
 {
-	struct addrinfo *gai_results;
-	struct addrinfo gai_hint = {
-		.ai_flags	= AI_ADDRCONFIG,
-	};
+	struct sockaddr_storage address;
+	struct sockaddr *lb_addr = (struct sockaddr *)&address;
+	socklen_t lb_len = sizeof(lb_addr);
 	unsigned short port = 0;
-	int error;
 
 #ifdef NFS_GP_LOCAL
 	const struct sockaddr_un sun = {
@@ -811,12 +863,9 @@ unsigned short nfs_getlocalport(const rpcprot_t program,
 #endif	/* NFS_GP_LOCAL */
 
 	if (port == 0) {
-		error = getaddrinfo(NULL, "sunrpc", &gai_hint, &gai_results);
-		if (error == 0) {
-			port = nfs_getport(gai_results->ai_addr,
-						gai_results->ai_addrlen,
+		if (nfs_gp_loopback_address(lb_addr, &lb_len)) {
+			port = nfs_getport(lb_addr, lb_len,
 						program, version, protocol);
-			freeaddrinfo(gai_results);
 		} else
 			rpc_createerr.cf_stat = RPC_UNKNOWNADDR;
 	}

