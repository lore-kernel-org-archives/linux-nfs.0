From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 052/112] SUNRPC: rpc_create() default hostname should
	support AF_INET6 addresses
Date: Fri, 25 Jan 2008 11:37:40 -0500
Message-ID: <20080125163740.31887.14697.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14415 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756377AbYAYRA0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:26 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH09Uc010371
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:25 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

If the ULP doesn't pass a hostname string to rpc_create(), it manufactures
one based on the passed-in address.  Be smart enough to handle an AF_INET6
address properly in this case.

Move the default servername logic before the xprt_create_transport() call
to simplify error handling in rpc_create().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/clnt.c |   32 +++++++++++++++++++++++++++-----
 1 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e0a5e47..3af35ab 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -30,6 +30,7 @@
 #include <linux/smp_lock.h>
 #include <linux/utsname.h>
 #include <linux/workqueue.h>
+#include <linux/in6.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
@@ -247,7 +248,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		.addrlen = args->addrsize,
 		.timeout = args->timeout
 	};
-	char servername[20];
+	char servername[48];
 
 	xprt = xprt_create_transport(&xprtargs);
 	if (IS_ERR(xprt))
@@ -258,13 +259,34 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	 * up a string representation of the passed-in address.
 	 */
 	if (args->servername == NULL) {
-		struct sockaddr_in *addr =
-					(struct sockaddr_in *) args->address;
-		snprintf(servername, sizeof(servername), NIPQUAD_FMT,
-			NIPQUAD(addr->sin_addr.s_addr));
+		servername[0] = '\0';
+		switch (args->address->sa_family) {
+		case AF_INET: {
+			struct sockaddr_in *sin =
+					(struct sockaddr_in *)args->address;
+			snprintf(servername, sizeof(servername), NIPQUAD_FMT,
+				 NIPQUAD(sin->sin_addr.s_addr));
+			break;
+		}
+		case AF_INET6: {
+			struct sockaddr_in6 *sin =
+					(struct sockaddr_in6 *)args->address;
+			snprintf(servername, sizeof(servername), NIP6_FMT,
+				 NIP6(sin->sin6_addr));
+			break;
+		}
+		default:
+			/* caller wants default server name, but
+			 * address family isn't recognized. */
+			return ERR_PTR(-EINVAL);
+		}
 		args->servername = servername;
 	}
 
+	xprt = xprt_create_transport(&xprtargs);
+	if (IS_ERR(xprt))
+		return (struct rpc_clnt *)xprt;
+
 	/*
 	 * By default, kernel RPC client connects from a reserved port.
 	 * CAP_NET_BIND_SERVICE will not be set for unprivileged requesters,
