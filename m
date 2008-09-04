From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/16] rpc.statd: eliminate --secure_statd
Date: Thu, 04 Sep 2008 12:56:03 -0400
Message-ID: <20080904165602.1471.33895.stgit@manray.1015granger.net>
References: <20080904165122.1471.24485.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:55141 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752725AbYIDQ5N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 12:57:13 -0400
In-Reply-To: <20080904165122.1471.24485.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Remove RESTRICTED_STATD to help make IPv6 changes simpler.
We keep the code behind RESTRICTED_STATD, and toss anything that is
compiled out when it is set.

RESTRICTED_STATD was added almost 10 years ago in response to CERT
CERT CA-99.05, which addresses exposures in rpc.statd that might allow
an attacker to take advantage of buffer overflows in rpc.statd while it
is running in privileged mode.

These days, I can't think of a reason why anyone would want to run
rpc.statd without setting RESTRICTED_STATD.  In addition, I don't
think rpc.statd is ever tested without it.

Removing RESTRICTED_STATD will get rid of some address storage and
comparison issues that will make IPv6 support simpler.  Plus it will
make our test matrix smaller!

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Neil Brown <neilb@suse.de>
---

 configure.ac          |    9 ---------
 utils/statd/monitor.c |   34 ----------------------------------
 utils/statd/simu.c    |   35 +++++++++++++----------------------
 3 files changed, 13 insertions(+), 65 deletions(-)

diff --git a/configure.ac b/configure.ac
index 6ae6c6d..1ab89db 100644
--- a/configure.ac
+++ b/configure.ac
@@ -95,15 +95,6 @@ AC_ARG_ENABLE(kprefix,
 	test "$enableval" = "yes" && kprefix=k,
 	kprefix=)
 	AC_SUBST(kprefix)
-AC_ARG_ENABLE(secure-statd,
-	[AC_HELP_STRING([--enable-secure-statd],
-                        [Only lockd can use statd (security)])],
-	test "$enableval" = "yes" && secure_statd=yes,
-	secure_statd=yes)
-	if test "$secure_statd" = yes; then
-		AC_DEFINE(RESTRICTED_STATD, 1, [Define this if you want to enable various security checks in statd. These checks basically keep anyone but lockd from using this service.])
-	fi
-	AC_SUBST(secure_statd)
 AC_ARG_WITH(rpcgen,
 	[AC_HELP_STRING([--with-rpcgen=internal], [use internal rpcgen instead of system one])],
 	rpcgen_path=$withval,
diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index 5d4aa49..d300338 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -29,7 +29,6 @@ notify_list *		rtnl = NULL;	/* Run-time notify list. */
 
 #define LINELEN (4*(8+1)+SM_PRIV_SIZE*2+1)
 
-#ifdef RESTRICTED_STATD
 /*
  * Reject requests from non-loopback addresses in order
  * to prevent attack described in CERT CA-99.05.
@@ -48,16 +47,6 @@ caller_is_localhost(struct svc_req *rqstp)
 	}
 	return 1;
 }
-#else	/* RESTRICTED_STATD */
-/*
- * No restrictions for remote callers.
- */
-static int
-caller_is_localhost(struct svc_req *rqstp)
-{
-	return 1;
-}
-#endif	/* RESTRICTED_STATD */
 
 /*
  * Services SM_MON requests.
@@ -81,7 +70,6 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	result.res_stat = STAT_FAIL;
 	result.state = -1;	/* State is undefined for STAT_FAIL. */
 
-#ifdef RESTRICTED_STATD
 	/* 1.	Reject any remote callers.
 	 *	Ignore the my_name specified by the caller, and
 	 *	use "127.0.0.1" instead.
@@ -107,28 +95,6 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 		goto failure;
 	}
 
-#if 0
-	This is not usable anymore.  Linux-kernel can be configured to use
-	host names with NSM so that multi-homed hosts are handled properly.
-		NeilBrown 15mar2007
-
-	/* 3.	mon_name must be an address in dotted quad.
-	 *	Again, specific to the linux kernel lockd.
-	 */
-	if (!inet_aton(mon_name, &mon_addr)) {
-		note(N_WARNING,
-			"Attempt to register host %s (not a dotted quad)",
-			mon_name);
-		goto failure;
-	}
-#endif
-#else
-	if (!(hostinfo = gethostbyname(my_name))) {
-		note(N_WARNING, "gethostbyname error for %s", my_name);
-		goto failure;
-	} else
-		my_addr = *(struct in_addr *) hostinfo->h_addr;
-#endif
 	/*
 	 * Check hostnames.  If I can't look them up, I won't monitor.  This
 	 * might not be legal, but it adds a little bit of safety and sanity.
diff --git a/utils/statd/simu.c b/utils/statd/simu.c
index 82d794e..25e8bad 100644
--- a/utils/statd/simu.c
+++ b/utils/statd/simu.c
@@ -22,35 +22,26 @@ void *
 sm_simu_crash_1_svc (void *argp, struct svc_req *rqstp)
 {
   static char *result = NULL;
+  struct in_addr caller;
+
+  caller = svc_getcaller(rqstp->rq_xprt)->sin_addr;
+  if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
+    note(N_WARNING, "Call to statd from non-local host %s",
+      inet_ntoa(caller));
+    goto failure;
+  }
+
+  if (ntohs(svc_getcaller(rqstp->rq_xprt)->sin_port) >= 1024) {
+    note(N_WARNING, "Call to statd-simu-crash from unprivileged port");
+    goto failure;
+  }
 
-#ifdef RESTRICTED_STATD
-	struct in_addr	caller;
-
-	/* 1.	Reject anyone not calling from 127.0.0.1.
-	 *	Ignore the my_name specified by the caller, and
-	 *	use "127.0.0.1" instead.
-	 */
-	caller = svc_getcaller(rqstp->rq_xprt)->sin_addr;
-	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-		note(N_WARNING,
-			"Call to statd from non-local host %s",
-			inet_ntoa(caller));
-		goto failure;
-	}
-	if (ntohs(svc_getcaller(rqstp->rq_xprt)->sin_port) >= 1024) {
-		note(N_WARNING,
-		     "Call to statd-simu-crash from unprivileged port\n");
-		goto failure;
-	}
-#endif
   note (N_WARNING, "*** SIMULATING CRASH! ***");
   my_svc_exit ();
 
   if (rtnl)
     nlist_kill (&rtnl);
 
-#ifdef RESTRICTED_STATD
  failure:
-#endif
   return ((void *)&result);
 }

