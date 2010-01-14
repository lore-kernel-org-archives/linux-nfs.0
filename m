From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/24] statd: add IPv6 support in sm_notify_1_svc()
Date: Thu, 14 Jan 2010 12:30:36 -0500
Message-ID: <20100114173036.26079.2923.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:32028 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757389Ab0ANRbJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:09 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have all the pieces in place, so update sm_notify_1_svc() to handle
SM_NOTIFY requests sent from IPv6 remotes.

This also eliminates a memory leak: the strdup'd memory containing the
callers' presentation address was never freed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/callback.c |   69 +++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 62 insertions(+), 7 deletions(-)

diff --git a/utils/statd/callback.c b/utils/statd/callback.c
index b1acd15..d1cc139 100644
--- a/utils/statd/callback.c
+++ b/utils/statd/callback.c
@@ -10,7 +10,7 @@
 #include <config.h>
 #endif
 
-#include <arpa/inet.h>
+#include <netdb.h>
 
 #include "rpcmisc.h"
 #include "statd.h"
@@ -20,19 +20,69 @@
 /* notify_list *cbnl = NULL; ... never used */
 
 
-/* 
+/*
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
+ *   2.  If statd's monitor list becomes substantial, finding a match
+ *       can generate a not inconsequential amount of DNS traffic.
+ *
+ *   3.  statd is a single-threaded service.  When DNS becomes slow or
+ *       unresponsive, statd also becomes slow or unresponsive.
+ *
+ *   4.  If the remote does not have a DNS entry at all (or if the
+ *       remote can resolve itself, but the local host can't resolve
+ *       the remote's hostname), the remote cannot be monitored, and
+ *       therefore NLM locking cannot be provided for that host.
+ *
+ *   5.  Local DNS resolution can produce different results for the
+ *       mon_name than the results the remote might see for the same
+ *       query, especially if the remote did not send a caller_name
+ *       or mon_name that is a fully qualified domain name.
+ *
+ *       Note that a caller_name is passed from NFS client to server,
+ *       but the client never knows what mon_name the server might use
+ *       to notify it of a reboot.  On Linux, the client extracts the
+ *       server's name from the devname it was passed by the mount
+ *       command.  This is often not a fully-qualified domain name.
  */
 void *
 sm_notify_1_svc(struct stat_chge *argp, struct svc_req *rqstp)
 {
 	notify_list    *lp, *call;
 	static char    *result = NULL;
-	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
-	char *ip_addr = xstrdup(inet_ntoa(sin->sin_addr));
+	struct sockaddr *sap = nfs_getrpccaller(rqstp->rq_xprt);
+	char		ip_addr[INET6_ADDRSTRLEN];
 
 	xlog(D_CALL, "Received SM_NOTIFY from %s, state: %d",
 				argp->mon_name, argp->state);
@@ -44,6 +94,11 @@ sm_notify_1_svc(struct stat_chge *argp, struct svc_req *rqstp)
 		return ((void *) &result);
 	}
 
+	if (!statd_present_address(sap, ip_addr, sizeof(ip_addr))) {
+		xlog_warn("Unrecognized sender address");
+		return ((void *) &result);
+	}
+
 	/* okir change: statd doesn't remove the remote host from its
 	 * internal monitor list when receiving an SM_NOTIFY call from
 	 * it. Lockd will want to continue monitoring the remote host

