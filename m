From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/16] rpc.statd: refactor check to see if call is from
	loopback address
Date: Thu, 04 Sep 2008 12:55:57 -0400
Message-ID: <20080904165556.1471.75730.stgit@manray.1015granger.net>
References: <20080904165122.1471.24485.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:47959 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735AbYIDQ5N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 12:57:13 -0400
In-Reply-To: <20080904165122.1471.24485.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor common logic to check if SM_FOO request is from loopback
address.

We'll have to do something about this for IPv6.  On IPv6-capable
systems, there will be only one AF_INET6 listener.  The loopback caller
will get either an IPv6 loopback address, or a mapped IPv4 loopback --
either way this will be an AF_INET6 address.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Neil Brown <neilb@suse.de>
---

 utils/statd/monitor.c |   82 ++++++++++++++++++++++---------------------------
 1 files changed, 36 insertions(+), 46 deletions(-)

diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index eadc434..5d4aa49 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -29,6 +29,36 @@ notify_list *		rtnl = NULL;	/* Run-time notify list. */
 
 #define LINELEN (4*(8+1)+SM_PRIV_SIZE*2+1)
 
+#ifdef RESTRICTED_STATD
+/*
+ * Reject requests from non-loopback addresses in order
+ * to prevent attack described in CERT CA-99.05.
+ */
+static int
+caller_is_localhost(struct svc_req *rqstp)
+{
+	struct in_addr	caller;
+
+	caller = svc_getcaller(rqstp->rq_xprt)->sin_addr;
+	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
+		note(N_WARNING,
+			"Call to statd from non-local host %s",
+			inet_ntoa(caller));
+		return 0;
+	}
+	return 1;
+}
+#else	/* RESTRICTED_STATD */
+/*
+ * No restrictions for remote callers.
+ */
+static int
+caller_is_localhost(struct svc_req *rqstp)
+{
+	return 1;
+}
+#endif	/* RESTRICTED_STATD */
+
 /*
  * Services SM_MON requests.
  */
@@ -45,31 +75,19 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	notify_list	*clnt;
 	struct in_addr	my_addr;
 	char		*dnsname;
-#ifdef RESTRICTED_STATD
-	struct in_addr	caller;
-#endif
 	struct hostent	*hostinfo = NULL;
 
 	/* Assume that we'll fail. */
 	result.res_stat = STAT_FAIL;
 	result.state = -1;	/* State is undefined for STAT_FAIL. */
 
-	/* Restrict access to statd.
-	 * In the light of CERT CA-99.05, we tighten access to
-	 * statd.			--okir
-	 */
 #ifdef RESTRICTED_STATD
-	/* 1.	Reject anyone not calling from 127.0.0.1.
+	/* 1.	Reject any remote callers.
 	 *	Ignore the my_name specified by the caller, and
 	 *	use "127.0.0.1" instead.
 	 */
-	caller = svc_getcaller(rqstp->rq_xprt)->sin_addr;
-	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-		note(N_WARNING,
-			"Call to statd from non-local host %s",
-			inet_ntoa(caller));
+	if (!caller_is_localhost(rqstp))
 		goto failure;
-	}
 	my_addr.s_addr = htonl(INADDR_LOOPBACK);
 
 	/* 2.	Reject any registrations for non-lockd services.
@@ -329,25 +347,12 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 			*my_name  = argp->my_id.my_name;
 	struct my_id	*id = &argp->my_id;
 	char		*cp;
-#ifdef RESTRICTED_STATD
-	struct in_addr	caller;
-#endif
 
 	result.state = MY_STATE;
 
-#ifdef RESTRICTED_STATD
-	/* 1.	Reject anyone not calling from 127.0.0.1.
-	 *	Ignore the my_name specified by the caller, and
-	 *	use "127.0.0.1" instead.
-	 */
-	caller = svc_getcaller(rqstp->rq_xprt)->sin_addr;
-	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-		note(N_WARNING,
-			"Call to statd from non-local host %s",
-			inet_ntoa(caller));
+	if (!caller_is_localhost(rqstp))
 		goto failure;
-	}
-#endif
+
 	/* my_name must not have white space */
 	for (cp=my_name ; *cp ; cp++)
 		if (*cp == ' ' || *cp == '\t' || *cp == '\r' || *cp == '\n')
@@ -388,9 +393,7 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 			clnt = NL_NEXT(clnt);
 	}
 
-#ifdef RESTRICTED_STATD
  failure:
-#endif
 	note(N_WARNING, "Received erroneous SM_UNMON request from %s for %s",
 		my_name, mon_name);
 	return (&result);
@@ -404,21 +407,9 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
 	static sm_stat  result;
 	notify_list	*clnt;
 	char		*my_name = argp->my_name;
-#ifdef RESTRICTED_STATD
-	struct in_addr	caller;
 
-	/* 1.	Reject anyone not calling from 127.0.0.1.
-	 *	Ignore the my_name specified by the caller, and
-	 *	use "127.0.0.1" instead.
-	 */
-	caller = svc_getcaller(rqstp->rq_xprt)->sin_addr;
-	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-		note(N_WARNING,
-			"Call to statd from non-local host %s",
-			inet_ntoa(caller));
+	if (!caller_is_localhost(rqstp))
 		goto failure;
-	}
-#endif
 
 	result.state = MY_STATE;
 
@@ -457,8 +448,7 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
 		dprintf(N_DEBUG, "SM_UNMON_ALL request from %s with no "
 			"SM_MON requests from it.", my_name);
 	}
-#ifdef RESTRICTED_STATD
+
  failure:
-#endif
 	return (&result);
 }

