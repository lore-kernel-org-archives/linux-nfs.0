From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/29] statd: add IPv6 support in sm_notify_1_svc()
Date: Tue, 10 Nov 2009 16:59:29 -0500
Message-ID: <20091110215929.23822.84374.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:45580 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755629AbZKJWA0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 17:00:26 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have all the pieces in place, so update sm_notify_1_svc() to handle
SM_NOTIFY requests sent from IPv6 remotes.

This also eliminates a memory leak: the strdup'd memory containing the
callers' presentation address was never freed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/callback.c |   67 ++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 61 insertions(+), 6 deletions(-)

diff --git a/utils/statd/callback.c b/utils/statd/callback.c
index 56163d5..1a4b800 100644
--- a/utils/statd/callback.c
+++ b/utils/statd/callback.c
@@ -10,7 +10,7 @@
 #include <config.h>
 #endif
 
-#include <arpa/inet.h>
+#include <netdb.h>
 
 #include "rpcmisc.h"
 #include "statd.h"
@@ -22,17 +22,67 @@
 
 /* 
  * Services SM_NOTIFY requests.
- * Any clients that have asked us to monitor that host are put on
- * the global callback list, which is processed as soon as statd
- * returns to svc_run.
+ *
+ * When NLM uses an SM_MON request to tell statd to monitor a remote,
+ * the request contains a "mon_name" argument.  This is usually the
+ * "caller_name" argument of an NLMPROC_LOCK request.  On Linux, the
+ * NLM can send statd the remote's IP address instead of its
+ * caller_name.  The NSM protocol does not allow both the remote's
+ * caller_name and it's IP address to be sent in the same SM_MON
+ * request.
+ *
+ * The remote's caller_name is useful because it makes it simple
+ * to identify rebooting remotes by matching the "mon_name" argument
+ * they sent via an SM_NOTIFY request.
+ *
+ * The caller_name string may not be a fully qualified domain name,
+ * or even registered in the DNS database, however.  Having the
+ * remote's IP address is useful because then there is no ambiguity
+ * about where to send an SM_NOTIFY after the local system reboots.
+ *
+ * Without the actual caller_name, however, statd must use an
+ * heuristic to match an incoming SM_NOTIFY request to one of the
+ * hosts it is currently monitoring.  The incoming mon_name in an
+ * SM_NOTIFY address is converted to a list of IP addresses using
+ * DNS.  Each mon_name on statd's monitor list is also converted to
+ * an address list, and the two lists are checked to see if there is
+ * a matching address.
+ *
+ * There are some risks to this strategy:
+ *
+ *   1.  The external DNS database is not reliable.  It can change
+ *       over time, or the forward and reverse mappings could be
+ *       inconsistent.
+ *
+ *   2.  Local DNS resolution can produce different results for the
+ *       mon_name than the results the remote might see for the same
+ *       query, especially if the remote did not send a caller_name
+ *       or mon_name that is a fully qualified domain name.
+ *
+ *   3.  If the remote does not have a DNS entry at all (or if the
+ *       remote can resolve itself, but the local host can't resolve
+ *       the remote's hostname), the remote cannot be monitored, and
+ *       therefore NLM locking cannot be provided for that host.
+ *
+ *   4.  If statd's monitor list becomes substantial, finding a match
+ *       generates a not inconsequential amount of DNS traffic.
+ *
+ *   5.  statd is a single-threaded service.  When DNS becomes slow or
+ *       unresponsive, statd also becomes slow or unresponsive.
+ *
+ * Note that the caller_name is passed from NFS client to server, but the
+ * client never knows what mon_name the server might use to notify it of
+ * a reboot.  On Linux, the client extracts the server's name from the
+ * devname it was passed by the mount command.  This is often not a
+ * fully-qualified domain name.
  */
 void *
 sm_notify_1_svc(struct stat_chge *argp, struct svc_req *rqstp)
 {
 	notify_list    *lp, *call;
 	static char    *result = NULL;
-	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
-	char *ip_addr = xstrdup(inet_ntoa(sin->sin_addr));
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
+	static char	ip_addr[NI_MAXHOST];
 
 	xlog(D_CALL, "Received SM_NOTIFY from %s, state: %d",
 				argp->mon_name, argp->state);
@@ -44,6 +94,11 @@ sm_notify_1_svc(struct stat_chge *argp, struct svc_req *rqstp)
 		return ((void *) &result);
 	}
 
+	if (!nsm_present_address(sap, 0, ip_addr, sizeof(ip_addr))) {
+		xlog_warn("Unrecognized sender address");
+		return (void *)&result;
+	}
+
 	/* okir change: statd doesn't remove the remote host from its
 	 * internal monitor list when receiving an SM_NOTIFY call from
 	 * it. Lockd will want to continue monitoring the remote host

