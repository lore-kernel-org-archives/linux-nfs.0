From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 22/29] statd: Support IPv6 in sm_simu_crash_1_svc
Date: Tue, 10 Nov 2009 16:59:47 -0500
Message-ID: <20091110215947.23822.47151.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:21701 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbZKJWAT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 17:00:19 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SM_SIMU_CRASH is not used by the Linux NLM, but for consistency, let's
make similar changes as in utils/statd/monitor.c:caller_is_localhost().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/simu.c |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/utils/statd/simu.c b/utils/statd/simu.c
index 7df04d9..0902b63 100644
--- a/utils/statd/simu.c
+++ b/utils/statd/simu.c
@@ -8,41 +8,40 @@
 #include <config.h>
 #endif
 
+#include <netdb.h>
 #include <arpa/inet.h>
 
 #include "rpcmisc.h"
 #include "statd.h"
 #include "notlist.h"
+#include "nfsrpc.h"
 
 extern void my_svc_exit (void);
 
 
 /*
  * Services SM_SIMU_CRASH requests.
+ *
+ * Although the local NLM contacts statd only via IPv4 transports,
+ * the statd service can receive other requests, such as
+ * SM_NOTIFY, via IPv6.
  */
 void *
-sm_simu_crash_1_svc (void *argp, struct svc_req *rqstp)
+sm_simu_crash_1_svc (__attribute__((unused)) void *argp, struct svc_req *rqstp)
 {
   struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
+  static char buf[NI_MAXHOST];
   static char *result = NULL;
-  struct in_addr caller;
 
   xlog(D_CALL, "Received SM_SIMU_CRASH");
 
-  if (sin->sin_family != AF_INET) {
-    xlog_warn("Call to statd from non-AF_INET address");
-    goto failure;
-  }
+  if (sin->sin_family != AF_INET)
+    goto out_nonlocal;
+  if (sin->sin_addr.s_addr != htonl(INADDR_LOOPBACK))
+    goto out_nonlocal;
 
-  caller = sin->sin_addr;
-  if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-    xlog_warn("Call to statd from non-local host %s",
-      inet_ntoa(caller));
-    goto failure;
-  }
-
-  if (ntohs(sin->sin_port) >= 1024) {
-    xlog_warn("Call to statd-simu-crash from unprivileged port");
+  if (nfs_get_port((struct sockaddr *)sin) >= IPPORT_RESERVED) {
+    xlog_warn("SM_SIMU_CRASH call from unprivileged port");
     goto failure;
   }
 
@@ -54,4 +53,10 @@ sm_simu_crash_1_svc (void *argp, struct svc_req *rqstp)
 
  failure:
   return ((void *)&result);
+
+ out_nonlocal:
+  if (!nsm_present_address((struct sockaddr *)sin, 0, buf, sizeof(buf)))
+    buf[0] = '\0';
+  xlog_warn("SM_SIMU_CRASH call from non-local host %s", buf);
+  goto failure;
 }

