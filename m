From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] rpc.statd: refactor check to see if call is from loopback
	address
Date: Tue, 02 Sep 2008 17:53:49 -0400
Message-ID: <20080902215348.31328.81732.stgit@manray.1015granger.net>
References: <20080902215132.31328.44934.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com, neilb@suse.de, okir@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:54626 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754625AbYIBVyo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2008 17:54:44 -0400
In-Reply-To: <20080902215132.31328.44934.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor common logic to check if call is from loopback address.

We'll have to do something about this for IPv6.  On IPv6 systems, there
will be only one listener, for AF_INET6 calls.  The loopback caller will
get either an IPv6 loopback address, or a mapped IPv4 loopback -- either
way this will be an AF_INET6 address.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/monitor.c |   77 ++++++++++++++++++++++---------------------------
 1 files changed, 35 insertions(+), 42 deletions(-)

diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index eadc434..66faa8f 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -29,6 +29,35 @@ notify_list *		rtnl = NULL;	/* Run-time notify list. */
 
 #define LINELEN (4*(8+1)+SM_PRIV_SIZE*2+1)
 
+#ifdef RESTRICTED_STATD
+/*
+ * Reject anyone not calling from a loopback address.
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
@@ -45,9 +74,6 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	notify_list	*clnt;
 	struct in_addr	my_addr;
 	char		*dnsname;
-#ifdef RESTRICTED_STATD
-	struct in_addr	caller;
-#endif
 	struct hostent	*hostinfo = NULL;
 
 	/* Assume that we'll fail. */
@@ -59,17 +85,12 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	 * statd.			--okir
 	 */
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
@@ -329,25 +350,12 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
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
@@ -388,9 +396,7 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 			clnt = NL_NEXT(clnt);
 	}
 
-#ifdef RESTRICTED_STATD
  failure:
-#endif
 	note(N_WARNING, "Received erroneous SM_UNMON request from %s for %s",
 		my_name, mon_name);
 	return (&result);
@@ -404,21 +410,9 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
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
 
@@ -457,8 +451,7 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
 		dprintf(N_DEBUG, "SM_UNMON_ALL request from %s with no "
 			"SM_MON requests from it.", my_name);
 	}
-#ifdef RESTRICTED_STATD
+
  failure:
-#endif
 	return (&result);
 }

