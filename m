From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/29] statd: Support IPv6 is caller_is_localhost()
Date: Tue, 10 Nov 2009 16:59:38 -0500
Message-ID: <20091110215938.23822.5447.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:25488 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbZKJWBT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 17:01:19 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For now statd is not going to support NLM upcalls and downcalls on
IPv6 transports.

However, the upcalls (SM_MON, etc.) arrive on the same socket that
receives calls from remotes.  So caller_is_localhost() at least has
to be smart enough to notice that the caller is not AF_INET, and to
display non-AF_INET addresses appropriately.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/monitor.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index a70b848..3db7ce8 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -32,20 +32,28 @@ notify_list *		rtnl = NULL;	/* Run-time notify list. */
 /*
  * Reject requests from non-loopback addresses in order
  * to prevent attack described in CERT CA-99.05.
+ *
+ * Although the kernel contacts statd only via IPv4 transports,
+ * the statd service can receive other requests, such as
+ * SM_NOTIFY, via IPv6.
  */
 static int
 caller_is_localhost(struct svc_req *rqstp)
 {
 	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
-	struct in_addr	caller;
+	static char buf[NI_MAXHOST];
 
-	caller = sin->sin_addr;
-	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-		xlog_warn("Call to statd from non-local host %s",
-			inet_ntoa(caller));
-		return 0;
-	}
+	if (sin->sin_family != AF_INET)
+		goto out_nonlocal;
+	if (sin->sin_addr.s_addr != htonl(INADDR_LOOPBACK))
+		goto out_nonlocal;
 	return 1;
+
+out_nonlocal:
+	if (!nsm_present_address((struct sockaddr *)sin, 0, buf, sizeof(buf)))
+		buf[0] = '\0';
+	xlog_warn("SM_MON/SM_UNMON call from non-local host %s", buf);
+	return 0;
 }
 
 /*

