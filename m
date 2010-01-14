From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/24] statd: Support IPv6 is caller_is_localhost()
Date: Thu, 14 Jan 2010 12:30:45 -0500
Message-ID: <20100114173045.26079.35275.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:43356 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757391Ab0ANRbJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:09 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For the time being, statd is not going to support receiving SM_MON
calls from the local lockd via IPv6.

However, the upcalls (SM_MON, etc.) from the local lockd arrive on the
same socket that receives calls from remote peers.  Thus
caller_is_localhost() at least has to be smart enough to notice that
the caller is not AF_INET, and to display non-AF_INET addresses
appropriately.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/monitor.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index 51075b5..5bedb3e 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -21,6 +21,7 @@
 #include <arpa/inet.h>
 #include <dirent.h>
 
+#include "sockaddr.h"
 #include "rpcmisc.h"
 #include "nsm.h"
 #include "statd.h"
@@ -32,20 +33,26 @@ notify_list *		rtnl = NULL;	/* Run-time notify list. */
 /*
  * Reject requests from non-loopback addresses in order
  * to prevent attack described in CERT CA-99.05.
+ *
+ * Although the kernel contacts the statd service via only IPv4
+ * transports, the statd service can receive other requests, such
+ * as SM_NOTIFY, from remote peers via IPv6.
  */
-static int
+static _Bool
 caller_is_localhost(struct svc_req *rqstp)
 {
-	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
-	struct in_addr	caller;
-
-	caller = sin->sin_addr;
-	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-		xlog_warn("Call to statd from non-local host %s",
-			inet_ntoa(caller));
-		return 0;
-	}
-	return 1;
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
+	char buf[INET6_ADDRSTRLEN];
+
+	if (!nfs_is_v4_loopback(sap))
+		goto out_nonlocal;
+	return true;
+
+out_nonlocal:
+	if (!statd_present_address(sap, buf, sizeof(buf)))
+		buf[0] = '\0';
+	xlog_warn("SM_MON/SM_UNMON call from non-local host %s", buf);
+	return false;
 }
 
 /*

