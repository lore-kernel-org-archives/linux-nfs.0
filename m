From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] statd: Replace note() with xlog() in rpc.statd
Date: Fri, 23 Oct 2009 02:03:59 +0900
Message-ID: <20091022170359.3519.65244.stgit@matisse.1015granger.net>
References: <20091022165432.3519.31428.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:48855 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbZJVREZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Oct 2009 13:04:25 -0400
In-Reply-To: <20091022165432.3519.31428.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To facilitate code sharing between statd and sm-notify (and with other
components of nfs-utils), replace rpc.statd's note() with xlog().

Bonus: add debugging xlog() messages to report incoming RPC requests.
These additional messages are enabled when "-d" is specified on the
statd command line.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/ha-callout.h |    4 --
 utils/statd/Makefile.am      |    4 +-
 utils/statd/callback.c       |    4 +-
 utils/statd/log.c            |   95 ------------------------------------------
 utils/statd/log.h            |   42 -------------------
 utils/statd/misc.c           |   12 ++---
 utils/statd/monitor.c        |   47 +++++++++++----------
 utils/statd/rmtcall.c        |   36 ++++++++--------
 utils/statd/simu.c           |   10 +++-
 utils/statd/simulate.c       |   52 +++++++++++------------
 utils/statd/stat.c           |    8 ++--
 utils/statd/statd.c          |   57 +++++++++++--------------
 utils/statd/statd.h          |    9 ----
 utils/statd/svc_run.c        |    7 +--
 utils/statd/version.h        |    7 ---
 15 files changed, 118 insertions(+), 276 deletions(-)
 delete mode 100644 utils/statd/log.c
 delete mode 100644 utils/statd/log.h
 delete mode 100644 utils/statd/version.h

diff --git a/support/include/ha-callout.h b/support/include/ha-callout.h
index efb70fb..1164336 100644
--- a/support/include/ha-callout.h
+++ b/support/include/ha-callout.h
@@ -53,11 +53,7 @@ ha_callout(char *event, char *arg1, char *arg2, int arg3)
 		default: pid = waitpid(pid, &ret, 0);
   	}
 	sigaction(SIGCHLD, &oldact, &newact);
-#ifdef dprintf
-	dprintf(N_DEBUG, "ha callout returned %d\n", WEXITSTATUS(ret));
-#else
 	xlog(D_GENERAL, "ha callout returned %d\n", WEXITSTATUS(ret));
-#endif
 }
 
 #endif
diff --git a/utils/statd/Makefile.am b/utils/statd/Makefile.am
index 8a3ba4e..19ba7b4 100644
--- a/utils/statd/Makefile.am
+++ b/utils/statd/Makefile.am
@@ -13,9 +13,9 @@ RPCPREFIX	= rpc.
 KPREFIX		= @kprefix@
 sbin_PROGRAMS	= statd sm-notify
 dist_sbin_SCRIPTS	= start-statd
-statd_SOURCES = callback.c notlist.c log.c misc.c monitor.c \
+statd_SOURCES = callback.c notlist.c misc.c monitor.c \
 	        simu.c stat.c statd.c svc_run.c rmtcall.c \
-	        sm_inter_clnt.c sm_inter_svc.c sm_inter_xdr.c log.h \
+	        sm_inter_clnt.c sm_inter_svc.c sm_inter_xdr.c \
 	        notlist.h statd.h system.h version.h sm_inter.h
 sm_notify_SOURCES = sm-notify.c
 
diff --git a/utils/statd/callback.c b/utils/statd/callback.c
index 8885238..2f98aeb 100644
--- a/utils/statd/callback.c
+++ b/utils/statd/callback.c
@@ -35,12 +35,12 @@ sm_notify_1_svc(struct stat_chge *argp, struct svc_req *rqstp)
 	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
 	char *ip_addr = xstrdup(inet_ntoa(sin->sin_addr));
 
-	dprintf(N_DEBUG, "Received SM_NOTIFY from %s, state: %d",
+	xlog(D_CALL, "Received SM_NOTIFY from %s, state: %d",
 				argp->mon_name, argp->state);
 
 	/* quick check - don't bother if we're not monitoring anyone */
 	if (rtnl == NULL) {
-		note(N_WARNING, "SM_NOTIFY from %s while not monitoring any hosts.",
+		xlog_warn("SM_NOTIFY from %s while not monitoring any hosts",
 				argp->mon_name);
 		return ((void *) &result);
 	}
diff --git a/utils/statd/log.c b/utils/statd/log.c
deleted file mode 100644
index a6ca996..0000000
--- a/utils/statd/log.c
+++ /dev/null
@@ -1,95 +0,0 @@
-/*
- * Copyright (C) 1995 Olaf Kirch
- * Modified by Jeffrey A. Uphoff, 1995, 1997, 1999.
- * Modified by H.J. Lu, 1998.
- * Modified by Lon Hohberger, Oct. 2000
- *
- * NSM for Linux.
- */
-
-/* 
- * 	log.c - logging functions for lockd/statd
- *	260295	 okir	started with simply syslog logging.
- */
-
-#ifdef HAVE_CONFIG_H
-#include <config.h>
-#endif
-
-#include <syslog.h>
-#include <unistd.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
-#include <stdarg.h>
-#include <time.h>
-#include <sys/types.h>
-#include "log.h"
-#include "statd.h"
-
-static pid_t	mypid;
-								/* Turns on logging to console/stderr. */
-#if 0
-static int	opt_debug = 0;	/* Will be command-line option, eventually */
-#endif
-
-void log_init(void)
-{
-	if (!(run_mode & MODE_LOG_STDERR)) 
-		openlog(name_p, LOG_PID | LOG_NDELAY, LOG_DAEMON);
-
-	mypid = getpid();
-
-	note(N_WARNING,"Version %s Starting",version_p);
-}
-
-void log_background(void)
-{
-	/* NOP */
-}
-
-void die(char *fmt, ...)
-{
-	char	buffer[1024];
-	va_list	ap;
-
-	va_start(ap, fmt);
-	vsnprintf (buffer, 1024, fmt, ap);
-	va_end(ap);
-	buffer[1023]=0;
-
-	note(N_FATAL, "%s", buffer);
-
-#ifndef DEBUG
-	exit (2);
-#else
-	abort();	/* make a core */
-#endif
-}
-
-void note(int level, char *fmt, ...)
-{
-	char	buffer[1024];
-	va_list	ap;
-
-	va_start(ap, fmt);
-	vsnprintf (buffer, 1024, fmt, ap);
-	va_end(ap);
-	buffer[1023]=0;
-
-	if ((!(run_mode & MODE_LOG_STDERR)) && (level < N_DEBUG)) {
-		syslog(level, "%s", buffer);
-	} else if (run_mode & MODE_LOG_STDERR) {
-		/* Log everything, including dprintf() stuff to stderr */
-		time_t		now;
-		struct tm *	tm;
-
-		time(&now);
-		tm = localtime(&now);
-		fprintf (stderr, "%02d/%02d/%04d %02d:%02d:%02d %s[%d]: %s\n",
-			tm->tm_mon + 1, tm->tm_mday, tm->tm_year + 1900,
-			tm->tm_hour, tm->tm_min, tm->tm_sec,
-			name_p, mypid,
-			buffer);
-	}
-}
diff --git a/utils/statd/log.h b/utils/statd/log.h
deleted file mode 100644
index fc55d3c..0000000
--- a/utils/statd/log.h
+++ /dev/null
@@ -1,42 +0,0 @@
-/*
- * Copyright (C) 1995 Olaf Kirch
- * Modified by Jeffrey A. Uphoff, 1996, 1997, 1999.
- * Modified by Lon Hohberger, Oct. 2000
- *
- * NSM for Linux.
- */
-
-/*
- * 	logging functionality
- *	260295	okir
- */
-
-#ifndef _LOCKD_LOG_H_
-#define _LOCKD_LOG_H_
-
-#include <syslog.h>
-
-void	log_init(void);
-void	log_background(void);
-void	log_enable(int facility);
-int	log_enabled(int facility);
-void	note(int level, char *fmt, ...);
-void	die(char *fmt, ...);
-
-/*
- * Map per-application severity to system severity. What's fatal for
- * lockd is merely an itching spot from the universe's point of view.
- */
-#define N_CRIT		LOG_CRIT
-#define N_FATAL		LOG_ERR
-#define N_ERROR		LOG_WARNING
-#define N_WARNING	LOG_NOTICE
-#define N_DEBUG		LOG_DEBUG
-
-#ifdef DEBUG
-#define dprintf		note
-#else
-#define dprintf		if (run_mode & MODE_LOG_STDERR) note
-#endif
-
-#endif /* _LOCKD_LOG_H_ */
diff --git a/utils/statd/misc.c b/utils/statd/misc.c
index 7256291..44af30e 100644
--- a/utils/statd/misc.c
+++ b/utils/statd/misc.c
@@ -29,8 +29,7 @@ xmalloc (size_t size)
     return ((void *)NULL);
 
   if (!(ptr = malloc (size)))
-    /* SHIT!  SHIT!  SHIT! */
-    die ("malloc failed");
+    xlog_err ("malloc failed");
 
   return (ptr);
 }
@@ -46,7 +45,7 @@ xstrdup (const char *string)
 
   /* Will only fail if underlying malloc() fails (ENOMEM). */
   if (!(result = strdup (string)))
-    die ("strdup failed");
+    xlog_err ("strdup failed");
 
   return (result);
 }
@@ -62,16 +61,15 @@ xunlink (char *path, char *host)
 
 	tozap = malloc(strlen(path)+strlen(host)+2);
 	if (tozap == NULL) {
-		note(N_ERROR, "xunlink: malloc failed: errno %d (%s)", 
-			errno, strerror(errno));
+		xlog(L_ERROR, "xunlink: malloc failed: errno %d (%m)", errno);
 		return;
 	}
 	sprintf (tozap, "%s/%s", path, host);
 
 	if (unlink (tozap) == -1)
-		note(N_ERROR, "unlink (%s): %s", tozap, strerror (errno));
+		xlog(L_ERROR, "unlink (%s): %m", tozap);
 	else
-		dprintf (N_DEBUG, "Unlinked %s", tozap);
+		xlog(D_GENERAL, "Unlinked %s", tozap);
 
 	free(tozap);
 }
diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index a2c9e2b..09f03da 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -43,8 +43,7 @@ caller_is_localhost(struct svc_req *rqstp)
 
 	caller = sin->sin_addr;
 	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-		note(N_WARNING,
-			"Call to statd from non-local host %s",
+		xlog_warn("Call to statd from non-local host %s",
 			inet_ntoa(caller));
 		return 0;
 	}
@@ -69,6 +68,8 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	char		*dnsname;
 	struct hostent	*hostinfo = NULL;
 
+	xlog(D_CALL, "Received SM_MON for %s from %s", mon_name, my_name);
+
 	/* Assume that we'll fail. */
 	result.res_stat = STAT_FAIL;
 	result.state = -1;	/* State is undefined for STAT_FAIL. */
@@ -92,8 +93,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	if (id->my_prog != 100021 ||
 	    (id->my_proc != 16 && id->my_proc != 24))
 	{
-		note(N_WARNING,
-			"Attempt to register callback to %d/%d",
+		xlog_warn("Attempt to register callback to %d/%d",
 			id->my_prog, id->my_proc);
 		goto failure;
 	}
@@ -105,12 +105,12 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 
 	/* must check for /'s in hostname!  See CERT's CA-96.09 for details. */
 	if (strchr(mon_name, '/') || mon_name[0] == '.') {
-		note(N_CRIT, "SM_MON request for hostname containing '/' "
+		xlog(L_ERROR, "SM_MON request for hostname containing '/' "
 		     "or starting '.': %s", mon_name);
-		note(N_CRIT, "POSSIBLE SPOOF/ATTACK ATTEMPT!");
+		xlog(L_ERROR, "POSSIBLE SPOOF/ATTACK ATTEMPT!");
 		goto failure;
 	} else if ((hostinfo = gethostbyname(mon_name)) == NULL) {
-		note(N_WARNING, "gethostbyname error for %s", mon_name);
+		xlog_warn("gethostbyname error for %s", mon_name);
 		goto failure;
 	}
 
@@ -152,7 +152,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 		    NL_MY_VERS(clnt) == id->my_vers &&
 		    memcmp(NL_PRIV(clnt), argp->priv, SM_PRIV_SIZE) == 0) {
 			/* Hey!  We already know you guys! */
-			dprintf(N_DEBUG,
+			xlog(D_GENERAL,
 				"Duplicate SM_MON request for %s "
 				"from procedure on %s",
 				mon_name, my_name);
@@ -168,7 +168,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	 * doesn't fail.  (I should probably fix this assumption.)
 	 */
 	if (!(clnt = nlist_new(my_name, mon_name, 0))) {
-		note(N_WARNING, "out of memory");
+		xlog_warn("out of memory");
 		goto failure;
 	}
 
@@ -188,7 +188,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	if ((fd = open(path, O_WRONLY|O_SYNC|O_CREAT|O_APPEND,
 		       S_IRUSR|S_IWUSR)) < 0) {
 		/* Didn't fly.  We won't monitor. */
-		note(N_ERROR, "creat(%s) failed: %s", path, strerror (errno));
+		xlog(L_ERROR, "creat(%s) failed: %m", path);
 		nlist_free(NULL, clnt);
 		free(path);
 		goto failure;
@@ -205,7 +205,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 		if (e+1-buf != LINELEN) abort();
 		e += sprintf(e, " %s %s\n", mon_name, my_name);
 		if (write(fd, buf, e-buf) != (e-buf)) {
-			note(N_WARNING, "writing to %s failed: errno %d (%s)",
+			xlog_warn("writing to %s failed: errno %d (%s)",
 				path, errno, strerror(errno));
 		}
 	}
@@ -215,7 +215,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	ha_callout("add-client", mon_name, my_name, -1);
 	nlist_insert(&rtnl, clnt);
 	close(fd);
-	dprintf(N_DEBUG, "MONITORING %s for %s", mon_name, my_name);
+	xlog(D_GENERAL, "MONITORING %s for %s", mon_name, my_name);
  success:
 	result.res_stat = STAT_SUCC;
 	/* SUN's sm_inter.x says this should be "state number of local site".
@@ -232,7 +232,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	return (&result);
 
 failure:
-	note(N_WARNING, "STAT_FAIL to %s for SM_MON of %s", my_name, mon_name);
+	xlog_warn("STAT_FAIL to %s for SM_MON of %s", my_name, mon_name);
 	return (&result);
 }
 
@@ -320,6 +320,8 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 	struct my_id	*id = &argp->my_id;
 	char		*cp;
 
+	xlog(D_CALL, "Received SM_UNMON for %s from %s", mon_name, my_name);
+
 	result.state = MY_STATE;
 
 	if (!caller_is_localhost(rqstp))
@@ -333,9 +335,8 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 
 	/* Check if we're monitoring anyone. */
 	if (rtnl == NULL) {
-		note(N_WARNING,
-			"Received SM_UNMON request from %s for %s while not "
-			"monitoring any hosts.", my_name, argp->mon_name);
+		xlog_warn("Received SM_UNMON request from %s for %s while not "
+			"monitoring any hosts", my_name, argp->mon_name);
 		return (&result);
 	}
 	clnt = rtnl;
@@ -352,7 +353,7 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 			NL_MY_PROG(clnt) == id->my_prog &&
 			NL_MY_VERS(clnt) == id->my_vers) {
 			/* Match! */
-			dprintf(N_DEBUG, "UNMONITORING %s for %s",
+			xlog(D_GENERAL, "UNMONITORING %s for %s",
 					mon_name, my_name);
 
 			/* PRC: do the HA callout: */
@@ -367,7 +368,7 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 	}
 
  failure:
-	note(N_WARNING, "Received erroneous SM_UNMON request from %s for %s",
+	xlog_warn("Received erroneous SM_UNMON request from %s for %s",
 		my_name, mon_name);
 	return (&result);
 }
@@ -381,13 +382,15 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
 	notify_list	*clnt;
 	char		*my_name = argp->my_name;
 
+	xlog(D_CALL, "Received SM_UNMON_ALL for %s", my_name);
+
 	if (!caller_is_localhost(rqstp))
 		goto failure;
 
 	result.state = MY_STATE;
 
 	if (rtnl == NULL) {
-		note(N_WARNING, "Received SM_UNMON_ALL request from %s "
+		xlog_warn("Received SM_UNMON_ALL request from %s "
 			"while not monitoring any hosts", my_name);
 		return (&result);
 	}
@@ -401,7 +404,7 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
 			char            mon_name[SM_MAXSTRLEN + 1];
 			notify_list	*temp;
 
-			dprintf(N_DEBUG,
+			xlog(D_GENERAL,
 				"UNMONITORING (SM_UNMON_ALL) %s for %s",
 				NL_MON_NAME(clnt), NL_MY_NAME(clnt));
 			strncpy(mon_name, NL_MON_NAME(clnt),
@@ -419,8 +422,8 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
 	}
 
 	if (!count) {
-		dprintf(N_DEBUG, "SM_UNMON_ALL request from %s with no "
-			"SM_MON requests from it.", my_name);
+		xlog(D_GENERAL, "SM_UNMON_ALL request from %s with no "
+			"SM_MON requests from it", my_name);
 	}
 
  failure:
diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
index cc1a4a4..5700fc7 100644
--- a/utils/statd/rmtcall.c
+++ b/utils/statd/rmtcall.c
@@ -43,7 +43,6 @@
 #include "sm_inter.h"
 #include "statd.h"
 #include "notlist.h"
-#include "log.h"
 #include "ha-callout.h"
 
 #if SIZEOF_SOCKLEN_T - 0 == 0
@@ -81,7 +80,7 @@ statd_get_socket(void)
 		if (sockfd >= 0) close(sockfd);
 
 		if ((sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
-			note(N_CRIT, "%s: Can't create socket: %m", __func__);
+			xlog(L_ERROR, "%s: Can't create socket: %m", __func__);
 			return -1;
 		}
 
@@ -91,7 +90,7 @@ statd_get_socket(void)
 		sin.sin_addr.s_addr = INADDR_ANY;
 
 		if (bindresvport(sockfd, &sin) < 0) {
-			dprintf(N_WARNING, "%s: can't bind to reserved port",
+			xlog(D_GENERAL, "%s: can't bind to reserved port",
 					__func__);
 			break;
 		}
@@ -150,7 +149,7 @@ xmit_call(struct sockaddr_in *sin,
 
 	/* Encode the RPC header part and payload */
 	if (!xdr_callmsg(xdrs, &mesg) || !func(xdrs, obj)) {
-		dprintf(N_WARNING, "%s: can't encode RPC message!", __func__);
+		xlog(D_GENERAL, "%s: can't encode RPC message!", __func__);
 		xdr_destroy(xdrs);
 		return 0;
 	}
@@ -160,9 +159,9 @@ xmit_call(struct sockaddr_in *sin,
 
 	if ((err = sendto(sockfd, msgbuf, msglen, 0,
 			(struct sockaddr *) sin, sizeof(*sin))) < 0) {
-		dprintf(N_WARNING, "%s: sendto failed: %m", __func__);
+		xlog_warn("%s: sendto failed: %m", __func__);
 	} else if (err != msglen) {
-		dprintf(N_WARNING, "%s: short write: %m", __func__);
+		xlog_warn("%s: short write: %m", __func__);
 	}
 
 	xdr_destroy(xdrs);
@@ -182,7 +181,7 @@ recv_rply(struct sockaddr_in *sin, u_long *portp)
 	/* Receive message */
 	if ((msglen = recvfrom(sockfd, msgbuf, sizeof(msgbuf), 0,
 			(struct sockaddr *) sin, &alen)) < 0) {
-		dprintf(N_WARNING, "%s: recvfrom failed: %m", __func__);
+		xlog_warn("%s: recvfrom failed: %m", __func__);
 		return NULL;
 	}
 
@@ -194,19 +193,19 @@ recv_rply(struct sockaddr_in *sin, u_long *portp)
 	mesg.rm_reply.rp_acpt.ar_results.proc = (xdrproc_t) xdr_void;
 
 	if (!xdr_replymsg(xdrs, &mesg)) {
-		note(N_WARNING, "%s: can't decode RPC message!", __func__);
+		xlog_warn("%s: can't decode RPC message!", __func__);
 		goto done;
 	}
 
 	if (mesg.rm_reply.rp_stat != 0) {
-		note(N_WARNING, "%s: [%s] RPC status %d", 
+		xlog_warn("%s: [%s] RPC status %d", 
 				__func__,
 				inet_ntoa(sin->sin_addr),
 				mesg.rm_reply.rp_stat);
 		goto done;
 	}
 	if (mesg.rm_reply.rp_acpt.ar_stat != 0) {
-		note(N_WARNING, "%s: [%s] RPC status %d",
+		xlog_warn("%s: [%s] RPC status %d",
 				__func__,
 				inet_ntoa(sin->sin_addr),
 				mesg.rm_reply.rp_acpt.ar_stat);
@@ -224,14 +223,13 @@ recv_rply(struct sockaddr_in *sin, u_long *portp)
 			strncpy (addr, inet_ntoa(lp->addr),
 				 sizeof (addr) - 1);
 			addr [sizeof (addr) - 1] = '\0';
-			dprintf(N_WARNING, "%s: address mismatch: "
+			xlog_warn("%s: address mismatch: "
 				"expected %s, got %s", __func__,
 				addr, inet_ntoa(sin->sin_addr));
 		}
 		if (lp->port == 0) {
 			if (!xdr_u_long(xdrs, portp)) {
-				note(N_WARNING,
-					"%s: [%s] can't decode reply body!",
+				xlog_warn("%s: [%s] can't decode reply body!",
 					__func__,
 					inet_ntoa(sin->sin_addr));
 				lp = NULL;
@@ -260,7 +258,7 @@ process_entry(notify_list *lp)
 /* 	__u32			proc, vers, prog; */
 
 	if (NL_TIMES(lp) == 0) {
-		note(N_DEBUG, "%s: Cannot notify %s, giving up.",
+		xlog(D_GENERAL, "%s: Cannot notify %s, giving up",
 				__func__, inet_ntoa(NL_ADDR(lp)));
 		return 0;
 	}
@@ -286,7 +284,7 @@ process_entry(notify_list *lp)
 
 	lp->xid = xmit_call(&sin, prog, vers, proc, func, objp);
 	if (!lp->xid) {
-		note(N_WARNING, "%s: failed to notify port %d",
+		xlog_warn("%s: failed to notify port %d",
 				__func__, ntohs(lp->port));
 	}
 	NL_TIMES(lp) -= 1;
@@ -319,10 +317,10 @@ process_reply(FD_SET_TYPE *rfds)
 			nlist_insert_timer(&notify, lp);
 			return 1;
 		}
-		note(N_WARNING, "%s: [%s] service %d not registered",
+		xlog_warn("%s: [%s] service %d not registered",
 			__func__, inet_ntoa(lp->addr), NL_MY_PROG(lp));
 	} else {
-		dprintf(N_DEBUG, "%s: Callback to %s (for %d) succeeded.",
+		xlog(D_GENERAL, "%s: Callback to %s (for %d) succeeded",
 			__func__, NL_MY_NAME(lp), NL_MON_NAME(lp));
 	}
 	nlist_free(&notify, lp);
@@ -346,8 +344,8 @@ process_notify_list(void)
 			nlist_remove(&notify, entry);
 			nlist_insert_timer(&notify, entry);
 		} else {
-			note(N_ERROR,
-				"%s: Can't callback %s (%d,%d), giving up.",
+			xlog(L_ERROR,
+				"%s: Can't callback %s (%d,%d), giving up",
 					__func__,
 					NL_MY_NAME(entry),
 					NL_MY_PROG(entry),
diff --git a/utils/statd/simu.c b/utils/statd/simu.c
index a7ecb85..7df04d9 100644
--- a/utils/statd/simu.c
+++ b/utils/statd/simu.c
@@ -27,24 +27,26 @@ sm_simu_crash_1_svc (void *argp, struct svc_req *rqstp)
   static char *result = NULL;
   struct in_addr caller;
 
+  xlog(D_CALL, "Received SM_SIMU_CRASH");
+
   if (sin->sin_family != AF_INET) {
-    note(N_WARNING, "Call to statd from non-AF_INET address");
+    xlog_warn("Call to statd from non-AF_INET address");
     goto failure;
   }
 
   caller = sin->sin_addr;
   if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-    note(N_WARNING, "Call to statd from non-local host %s",
+    xlog_warn("Call to statd from non-local host %s",
       inet_ntoa(caller));
     goto failure;
   }
 
   if (ntohs(sin->sin_port) >= 1024) {
-    note(N_WARNING, "Call to statd-simu-crash from unprivileged port");
+    xlog_warn("Call to statd-simu-crash from unprivileged port");
     goto failure;
   }
 
-  note (N_WARNING, "*** SIMULATING CRASH! ***");
+  xlog_warn("*** SIMULATING CRASH! ***");
   my_svc_exit ();
 
   if (rtnl)
diff --git a/utils/statd/simulate.c b/utils/statd/simulate.c
index de8f1c9..4ed1468 100644
--- a/utils/statd/simulate.c
+++ b/utils/statd/simulate.c
@@ -38,7 +38,9 @@ extern void svc_exit (void);
 void
 simulator (int argc, char **argv)
 {
-  log_enable (1);
+  xlog_stderr (1);
+  xlog_syslog (0);
+  xlog_open ("statd simulator");
 
   if (argc == 2)
     if (!strcasecmp (*argv, "crash"))
@@ -61,7 +63,7 @@ simulator (int argc, char **argv)
       simulate_mon (*(&argv[1]), *(&argv[2]), *(&argv[3]), *(&argv[4]),
 		    *(&argv[5]));
   }
-  die ("WTF?  Give me something I can use!");
+  xlog_err ("WTF?  Give me something I can use!");
 }
 
 static void
@@ -72,11 +74,11 @@ simulate_mon (char *calling, char *monitoring, char *as, char *proggy,
   sm_stat_res *result;
   mon mon;
 
-  dprintf (N_DEBUG, "Calling %s (as %s) to monitor %s", calling, as,
+  xlog (D_GENERAL, "Calling %s (as %s) to monitor %s", calling, as,
 	   monitoring);
 
   if ((client = clnt_create (calling, SM_PROG, SM_VERS, "udp")) == NULL)
-    die ("%s", clnt_spcreateerror ("clnt_create"));
+    xlog_err ("%s", clnt_spcreateerror ("clnt_create"));
 
   memcpy (mon.priv, fool, SM_PRIV_SIZE);
   mon.mon_id.my_id.my_name = xstrdup (as);
@@ -87,16 +89,15 @@ simulate_mon (char *calling, char *monitoring, char *as, char *proggy,
   mon.mon_id.mon_name = monitoring;
 
   if (!(result = sm_mon_1 (&mon, client)))
-    die ("%s", clnt_sperror (client, "sm_mon_1"));
+    xlog_err ("%s", clnt_sperror (client, "sm_mon_1"));
 
   free (mon.mon_id.my_id.my_name);
 
   if (result->res_stat != STAT_SUCC) {
-    note (N_FATAL, "SM_MON request failed, state: %d", result->state);
-    exit (0);
+    xlog_err ("SM_MON request failed, state: %d", result->state);
   } else {
-    dprintf (N_DEBUG, "SM_MON result successful, state: %d\n", result->state);
-    dprintf (N_DEBUG, "Waiting for callback.");
+    xlog (D_GENERAL, "SM_MON result successful, state: %d\n", result->state);
+    xlog (D_GENERAL, "Waiting for callback");
     daemon_simulator ();
     exit (0);
   }
@@ -109,11 +110,11 @@ simulate_unmon (char *calling, char *unmonitoring, char *as, char *proggy)
   sm_stat *result;
   mon_id mon_id;
 
-  dprintf (N_DEBUG, "Calling %s (as %s) to unmonitor %s", calling, as,
+  xlog (D_GENERAL, "Calling %s (as %s) to unmonitor %s", calling, as,
 	   unmonitoring);
 
   if ((client = clnt_create (calling, SM_PROG, SM_VERS, "udp")) == NULL)
-    die ("%s", clnt_spcreateerror ("clnt_create"));
+    xlog_err ("%s", clnt_spcreateerror ("clnt_create"));
 
   mon_id.my_id.my_name = xstrdup (as);
   mon_id.my_id.my_prog = atoi (proggy) * SIM_SM_PROG;
@@ -122,10 +123,10 @@ simulate_unmon (char *calling, char *unmonitoring, char *as, char *proggy)
   mon_id.mon_name = unmonitoring;
 
   if (!(result = sm_unmon_1 (&mon_id, client)))
-    die ("%s", clnt_sperror (client, "sm_unmon_1"));
+    xlog_err ("%s", clnt_sperror (client, "sm_unmon_1"));
 
   free (mon_id.my_id.my_name);
-  dprintf (N_DEBUG, "SM_UNMON request returned state: %d\n", result->state);
+  xlog (D_GENERAL, "SM_UNMON request returned state: %d\n", result->state);
   exit (0);
 }
 
@@ -136,10 +137,10 @@ simulate_unmon_all (char *calling, char *as, char *proggy)
   sm_stat *result;
   my_id my_id;
 
-  dprintf (N_DEBUG, "Calling %s (as %s) to unmonitor all hosts", calling, as);
+  xlog (D_GENERAL, "Calling %s (as %s) to unmonitor all hosts", calling, as);
 
   if ((client = clnt_create (calling, SM_PROG, SM_VERS, "udp")) == NULL)
-    die ("%s", clnt_spcreateerror ("clnt_create"));
+    xlog_err ("%s", clnt_spcreateerror ("clnt_create"));
 
   my_id.my_name = xstrdup (as);
   my_id.my_prog = atoi (proggy) * SIM_SM_PROG;
@@ -147,10 +148,10 @@ simulate_unmon_all (char *calling, char *as, char *proggy)
   my_id.my_proc = SIM_SM_MON;
 
   if (!(result = sm_unmon_all_1 (&my_id, client)))
-    die ("%s", clnt_sperror (client, "sm_unmon_all_1"));
+    xlog_err ("%s", clnt_sperror (client, "sm_unmon_all_1"));
 
   free (my_id.my_name);
-  dprintf (N_DEBUG, "SM_UNMON_ALL request returned state: %d\n", result->state);
+  xlog (D_GENERAL, "SM_UNMON_ALL request returned state: %d\n", result->state);
   exit (0);
 }
 
@@ -160,10 +161,10 @@ simulate_crash (char *host)
   CLIENT *client;
 
   if ((client = clnt_create (host, SM_PROG, SM_VERS, "udp")) == NULL)
-    die ("%s", clnt_spcreateerror ("clnt_create"));
+    xlog_err ("%s", clnt_spcreateerror ("clnt_create"));
 
   if (!sm_simu_crash_1 (NULL, client))
-    die ("%s", clnt_sperror (client, "sm_simu_crash_1"));
+    xlog_err ("%s", clnt_sperror (client, "sm_simu_crash_1"));
 
   exit (0);
 }
@@ -176,18 +177,18 @@ simulate_stat (char *calling, char *monitoring)
   sm_stat_res *result;
   
   if ((client = clnt_create (calling, SM_PROG, SM_VERS, "udp")) == NULL)
-    die ("%s", clnt_spcreateerror ("clnt_create"));
+    xlog_err ("%s", clnt_spcreateerror ("clnt_create"));
 
   checking.mon_name = monitoring;
 
   if (!(result = sm_stat_1 (&checking, client)))
-    die ("%s", clnt_sperror (client, "sm_stat_1"));
+    xlog_err ("%s", clnt_sperror (client, "sm_stat_1"));
 
   if (result->res_stat == STAT_SUCC)
-    dprintf (N_DEBUG, "STAT_SUCC from %s for %s, state: %d", calling,
+    xlog (D_GENERAL, "STAT_SUCC from %s for %s, state: %d", calling,
 	     monitoring, result->state);
   else
-    dprintf (N_DEBUG, "STAT_FAIL from %s for %s, state: %d", calling,
+    xlog (D_GENERAL, "STAT_FAIL from %s for %s, state: %d", calling,
 	     monitoring, result->state);
 
   exit (0);
@@ -196,9 +197,8 @@ simulate_stat (char *calling, char *monitoring)
 static void
 sim_killer (int sig)
 {
-  note (N_FATAL, "Simulator caught signal %d, un-registering and exiting.", sig);
   pmap_unset (sim_port, SIM_SM_VERS);
-  exit (0);
+  xlog_err ("Simulator caught signal %d, un-registering and exiting", sig);
 }
 
 static void
@@ -219,7 +219,7 @@ sim_sm_mon_1_svc (struct status *argp, struct svc_req *rqstp)
 {
   static char *result;
 
-  dprintf (N_DEBUG, "Recieved state %d for mon_name %s (opaque \"%s\")",
+  xlog (D_GENERAL, "Recieved state %d for mon_name %s (opaque \"%s\")",
 	   argp->state, argp->mon_name, argp->priv);
   svc_exit ();
   return ((void *)&result);
diff --git a/utils/statd/stat.c b/utils/statd/stat.c
index 799239f..477f632 100644
--- a/utils/statd/stat.c
+++ b/utils/statd/stat.c
@@ -42,13 +42,15 @@ sm_stat_1_svc (struct sm_name *argp, struct svc_req *rqstp)
 {
   static sm_stat_res result;
 
+  xlog(D_CALL, "Received SM_STAT from %s", argp->mon_name);
+
   if (gethostbyname (argp->mon_name) == NULL) {
-    note (N_WARNING, "gethostbyname error for %s", argp->mon_name);
+    xlog_warn ("gethostbyname error for %s", argp->mon_name);
     result.res_stat = STAT_FAIL;
-    dprintf (N_DEBUG, "STAT_FAIL for %s", argp->mon_name);
+    xlog (D_GENERAL, "STAT_FAIL for %s", argp->mon_name);
   } else {
     result.res_stat = STAT_SUCC;
-    dprintf (N_DEBUG, "STAT_SUCC for %s", argp->mon_name);
+    xlog (D_GENERAL, "STAT_SUCC for %s", argp->mon_name);
   }
   result.state = MY_STATE;
   return(&result);
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 1c5247e..6148952 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -26,7 +26,6 @@
 #include <sys/wait.h>
 #include <grp.h>
 #include "statd.h"
-#include "version.h"
 #include "nfslib.h"
 
 /* Socket operations */
@@ -50,8 +49,7 @@ int	run_mode = 0;		/* foreground logging mode */
 /* LH - I had these local to main, but it seemed silly to have 
  * two copies of each - one in main(), one static in log.c... 
  * It also eliminates the 256-char static in log.c */
-char *name_p = NULL;
-const char *version_p = NULL;
+static char *name_p = NULL;
 
 /* PRC: a high-availability callout program can be specified with -H
  * When this is done, the program will receive callouts whenever clients
@@ -109,17 +107,15 @@ sm_prog_1_wrapper (struct svc_req *rqstp, register SVCXPRT *transp)
 static void 
 killer (int sig)
 {
-	note (N_FATAL, "Caught signal %d, un-registering and exiting.", sig);
 	pmap_unset (SM_PROG, SM_VERS);
-
-	exit (0);
+	xlog_err ("Caught signal %d, un-registering and exiting", sig);
 }
 
 static void
 sigusr (int sig)
 {
 	extern void my_svc_exit (void);
-	dprintf (N_DEBUG, "Caught signal %d, re-notifying (state %d).", sig,
+	xlog(D_GENERAL, "Caught signal %d, re-notifying (state %d)", sig,
 								MY_STATE);
 	my_svc_exit();
 }
@@ -141,7 +137,7 @@ static void log_modes(void)
 	if (run_mode & MODE_LOG_STDERR)
 		strcat(buf,"Log-STDERR ");
 
-	note(N_WARNING,buf);
+	xlog_warn(buf);
 }
 
 /*
@@ -175,13 +171,12 @@ static void create_pidfile(void)
 	unlink(pidfile);
 	fp = fopen(pidfile, "w");
 	if (!fp)
-		die("Opening %s failed: %s\n",
-		    pidfile, strerror(errno));
+		xlog_err("Opening %s failed: %m\n", pidfile);
 	fprintf(fp, "%d\n", getpid());
 	pidfd = dup(fileno(fp));
 	if (fclose(fp) < 0) {
-		note(N_WARNING, "Flushing pid file failed: errno %d (%s)\n",
-			errno, strerror(errno));
+		xlog_warn("Flushing pid file failed: errno %d (%m)\n",
+			errno);
 	}
 }
 
@@ -189,8 +184,8 @@ static void truncate_pidfile(void)
 {
 	if (pidfd >= 0) {
 		if (ftruncate(pidfd, 0) < 0) {
-			note(N_WARNING, "truncating pid file failed: errno %d (%s)\n",
-				errno, strerror(errno));
+			xlog_warn("truncating pid file failed: errno %d (%m)\n",
+				errno);
 		}
 	}
 }
@@ -206,8 +201,8 @@ static void drop_privs(void)
 	}
 
 	if (st.st_uid == 0) {
-		note(N_WARNING, "statd running as root. chown %s to choose different user\n",
-		    SM_DIR);
+		xlog_warn("Running as 'root'.  "
+			"chown %s to choose different user\n", SM_DIR);
 		return;
 	}
 	/* better chown the pid file before dropping, as if it
@@ -215,14 +210,14 @@ static void drop_privs(void)
 	 */
 	if (pidfd >= 0) {
 		if (fchown(pidfd, st.st_uid, st.st_gid) < 0) {
-			note(N_ERROR, "Unable to change owner of %s: %d (%s)",
+			xlog(L_ERROR, "Unable to change owner of %s: %d (%s)",
 					SM_DIR, strerror (errno));
 		}
 	}
 	setgroups(0, NULL);
 	if (setgid(st.st_gid) == -1
 	    || setuid(st.st_uid) == -1) {
-		note(N_ERROR, "Fail to drop privileges");
+		xlog(L_ERROR, "Fail to drop privileges");
 		exit(1);
 	}
 }
@@ -266,6 +261,8 @@ int main (int argc, char **argv)
 
 	/* Default: daemon mode, no other options */
 	run_mode = 0;
+	xlog_stderr(0);
+	xlog_syslog(1);
 
 	/* Set the basename */
 	if ((name_p = strrchr(argv[0],'/')) != NULL) {
@@ -274,13 +271,6 @@ int main (int argc, char **argv)
 		name_p = argv[0];
 	}
 
-	/* Get the version */
-	if ((version_p = strrchr(VERSION,' ')) != NULL) {
-		version_p++;
-	} else {
-		version_p = VERSION;
-	}
-	
 	/* Set hostname */
 	MY_NAME = NULL;
 
@@ -289,7 +279,7 @@ int main (int argc, char **argv)
 		switch (arg) {
 		case 'V':	/* Version */
 		case 'v':
-			printf("%s version %s\n",name_p,version_p);
+			printf("%s version " VERSION "\n",name_p);
 			exit(0);
 		case 'F':	/* Foreground/nodaemon mode */
 			run_mode |= MODE_NODAEMON;
@@ -383,7 +373,6 @@ int main (int argc, char **argv)
 		run_sm_notify(out_port);
 	}
 
-
 	if (!(run_mode & MODE_NODAEMON)) {
 		run_mode &= ~MODE_LOG_STDERR;	/* Never log to console in
 						   daemon mode. */
@@ -455,7 +444,13 @@ int main (int argc, char **argv)
 
 	/* Child. */
 
-	log_init (/*name_p,version_p*/);
+	if (run_mode & MODE_LOG_STDERR) {
+		xlog_syslog(0);
+		xlog_stderr(1);
+		xlog_config(D_ALL, 1);
+	}
+	xlog_open(name_p);
+	xlog(L_NOTICE, "Version " VERSION " starting");
 
 	log_modes();
 
@@ -505,7 +500,7 @@ int main (int argc, char **argv)
 	if (pipefds[1] > 0) {
 		status = 0;
 		if (write(pipefds[1], &status, 1) != 1) {
-			note(N_WARNING, "writing to parent pipe failed: errno %d (%s)\n",
+			xlog_warn("writing to parent pipe failed: errno %d (%s)\n",
 				errno, strerror(errno));
 		}
 		close(pipefds[1]);
@@ -552,7 +547,7 @@ load_state_number(void)
 		return;
 
 	if (read(fd, &MY_STATE, sizeof(MY_STATE)) != sizeof(MY_STATE)) {
-		note(N_WARNING, "Unable to read state from '%s': errno %d (%s)",
+		xlog_warn("Unable to read state from '%s': errno %d (%s)",
 				SM_STAT_PATH, errno, strerror(errno));
 	}
 	close(fd);
@@ -561,7 +556,7 @@ load_state_number(void)
 		char buf[20];
 		snprintf(buf, sizeof(buf), "%d", MY_STATE);
 		if (write(fd, buf, strlen(buf)) != strlen(buf))
-			note(N_WARNING, "Writing to '%s' failed: errno %d (%s)",
+			xlog_warn("Writing to '%s' failed: errno %d (%s)",
 				file, errno, strerror(errno));
 		close(fd);
 	}
diff --git a/utils/statd/statd.h b/utils/statd/statd.h
index 88ba208..085f32d 100644
--- a/utils/statd/statd.h
+++ b/utils/statd/statd.h
@@ -11,7 +11,7 @@
 
 #include "sm_inter.h"
 #include "system.h"
-#include "log.h"
+#include "xlog.h"
 
 /*
  * Paths and filenames.
@@ -84,10 +84,3 @@ extern int run_mode;
  * another host.... */
 #define STATIC_HOSTNAME 8	/* Always use the hostname set by -n */
 #define	MODE_NO_NOTIFY	16	/* Don't notify peers of a reboot */
-/*
- * Program name and version pointers -- See statd.c for the reasoning
- * as to why they're global.
- */
-extern char *name_p;		/* program basename */
-extern const char *version_p;	/* program version */
-
diff --git a/utils/statd/svc_run.c b/utils/statd/svc_run.c
index 14ee663..d98ecee 100644
--- a/utils/statd/svc_run.c
+++ b/utils/statd/svc_run.c
@@ -101,12 +101,12 @@ my_svc_run(void)
 
 			tv.tv_sec  = NL_WHEN(notify) - now;
 			tv.tv_usec = 0;
-			dprintf(N_DEBUG, "Waiting for reply... (timeo %d)",
+			xlog(D_GENERAL, "Waiting for reply... (timeo %d)",
 							tv.tv_sec);
 			selret = select(FD_SETSIZE, &readfds,
 				(void *) 0, (void *) 0, &tv);
 		} else {
-			dprintf(N_DEBUG, "Waiting for client connections.");
+			xlog(D_GENERAL, "Waiting for client connections");
 			selret = select(FD_SETSIZE, &readfds,
 				(void *) 0, (void *) 0, (struct timeval *) 0);
 		}
@@ -116,8 +116,7 @@ my_svc_run(void)
 			if (errno == EINTR || errno == ECONNREFUSED
 			 || errno == ENETUNREACH || errno == EHOSTUNREACH)
 				continue;
-			note(N_ERROR, "my_svc_run() - select: %s",
-				strerror (errno));
+			xlog(L_ERROR, "my_svc_run() - select: %m");
 			return;
 
 		case 0:
diff --git a/utils/statd/version.h b/utils/statd/version.h
deleted file mode 100644
index 12f16bd..0000000
--- a/utils/statd/version.h
+++ /dev/null
@@ -1,7 +0,0 @@
-/*
- * Copyright (C) 1997-1999 Jeffrey A. Uphoff
- *
- * NSM for Linux.
- */
-
-#define STATD_RELEASE "1.1.1"

