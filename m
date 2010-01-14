From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/24] statd: Support IPv6 in sm_simu_crash_1_svc
Date: Thu, 14 Jan 2010 12:30:54 -0500
Message-ID: <20100114173053.26079.21107.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:43552 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757391Ab0ANRbW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:22 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that SM_SIMU_CRASH does not allow non-AF_INET callers to
bypass the localhost check.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/simu.c |   35 +++++++++++++++++++----------------
 1 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/utils/statd/simu.c b/utils/statd/simu.c
index 7df04d9..825e428 100644
--- a/utils/statd/simu.c
+++ b/utils/statd/simu.c
@@ -8,8 +8,10 @@
 #include <config.h>
 #endif
 
+#include <netdb.h>
 #include <arpa/inet.h>
 
+#include "sockaddr.h"
 #include "rpcmisc.h"
 #include "statd.h"
 #include "notlist.h"
@@ -19,30 +21,25 @@ extern void my_svc_exit (void);
 
 /*
  * Services SM_SIMU_CRASH requests.
+ *
+ * Although the kernel contacts the statd service via only IPv4
+ * transports, the statd service can receive other requests, such
+ * as SM_NOTIFY, from remote peers via IPv6.
  */
 void *
-sm_simu_crash_1_svc (void *argp, struct svc_req *rqstp)
+sm_simu_crash_1_svc (__attribute__ ((unused)) void *argp, struct svc_req *rqstp)
 {
-  struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
+  struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
+  char buf[INET6_ADDRSTRLEN];
   static char *result = NULL;
-  struct in_addr caller;
 
   xlog(D_CALL, "Received SM_SIMU_CRASH");
 
-  if (sin->sin_family != AF_INET) {
-    xlog_warn("Call to statd from non-AF_INET address");
-    goto failure;
-  }
+  if (!nfs_is_v4_loopback(sap))
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
+  if ((int)nfs_get_port(sap) >= IPPORT_RESERVED) {
+    xlog_warn("SM_SIMU_CRASH call from unprivileged port");
     goto failure;
   }
 
@@ -54,4 +51,10 @@ sm_simu_crash_1_svc (void *argp, struct svc_req *rqstp)
 
  failure:
   return ((void *)&result);
+
+ out_nonlocal:
+  if (!statd_present_address(sap, buf, sizeof(buf)))
+    buf[0] = '\0';
+  xlog_warn("SM_SIMU_CRASH call from non-local host %s", buf);
+  goto failure;
 }

