From: Denis Vlasenko <vda@ilport.com.ua>
Subject: [PATCH] sanitize logging subsystem #2
Date: Mon, 14 Mar 2005 16:26:58 +0200
Message-ID: <200503141626.58679.vda@ilport.com.ua>
References: <200503111518.29792.vda@ilport.com.ua> <16949.9802.377554.583900@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_y8ZNCIxyAN/3i4C"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAqYF-0006ES-8h
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 06:28:11 -0800
Received: from [195.66.192.168] (helo=port.imtp.ilyichevsk.odessa.ua)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DAqXr-0003ZI-Ix
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 06:28:11 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16949.9802.377554.583900@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--Boundary-00=_y8ZNCIxyAN/3i4C
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

> > Patch does not introduce behavioral changes except for
> > making foregrounded mountd to really use stderr.
> > There was a bug which prevented this.
> > 
> > Patch is tested. Please comment/apply.
> 
> How well was it tested :-)
 
> > +		fprintf(stderr, "%s[%d] %04d-%02d-%02d %02d:%02d:%02d %s\n",
> > +				log_name, log_pid,
> > +				tm->tm_year, tm->tm_mon + 1, tm->tm_mday,
> > +				tm->tm_hour, tm->tm_min, tm->tm_sec,
> > +				buff);

Good spotting.
Totally overlooked because this thing normally is NOT compiled in.
It sits in #ifdef VERBOSE_PRINTF. VERBOSE_PRINTF is #undef'ed.

> tm_year is "number of years since 1900", which isn't what you want to
> print out.  It needs a "+1900", which I have given it.
> 
> Otherwise the patch looks reasonably sane.
> The only bit that bothers me is calling openlog in mountd where it
> wasn't called before.
> mountd (on debian at least) currently prefixes all log lines with
> "rpc_mountd" as that is the program name.  With this patch they will
> be prefixes with "mountd".
> This is a change and people who filter their log file (like me) might
> notice.   But it probably isn't a big concern..
> 
> I've committed it to CVS.

Your concern is indeed valid:

        /* Initialize logging. */
        if (!foreground) xlog_stderr(0);
        xlog_open("mountd");
...
        if (!foreground) {
                int fd = sysconf (_SC_OPEN_MAX);
                while (--fd > 2)
                        (void) close(fd);
        }

This could close a fd to syslog socket!
If it indeed happens, just move xlog_open below fd
closing loop. However, you may opt to just omit xlog_open().
I will test this scenario.

Meanwhile, here are two patches to be applied on top of
first one:

nfs-utils-1.0.7_log12.diff:

* Remove unneded '\n' from xlog messages. They were discarded
  by xlog anyway.
* Remove inconsistently used trailing periods and the like.

nfs-utils-1.0.7_log23.diff:

* Convert statd to use xlog. Kill log.[ch] from statd/ subdir.
* Change verbose logging in xlog.c to match one used by statd.
  NB: by default stderr logging no longer includes timestamp and PID.
  #define VERBOSE_PRINTF in xlog.h to revert to previous behaviour.
  This will make mountd and statd logging output formats uniform.
* Remove trailing '\n' and periods from messages. Convert %m to %s+strerror(errno)

Comments?
--
vda

--Boundary-00=_y8ZNCIxyAN/3i4C
Content-Type: text/x-diff;
  charset="koi8-r";
  name="nfs-utils-1.0.7_log12.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="nfs-utils-1.0.7_log12.diff"

diff -urpN nfs-utils-1.0.7.logging1/support/include/ha-callout.h nfs-utils-1.0.7.logging2/support/include/ha-callout.h
--- nfs-utils-1.0.7.logging1/support/include/ha-callout.h	Fri Dec 10 03:18:39 2004
+++ nfs-utils-1.0.7.logging2/support/include/ha-callout.h	Fri Mar 11 15:19:11 2005
@@ -56,7 +56,7 @@ ha_callout(char *event, char *arg1, char
 #ifdef dprintf
 	dprintf(N_DEBUG, "ha callout returned %d\n", WEXITSTATUS(ret));
 #else
-	xlog(D_GENERAL, "ha callout returned %d\n", WEXITSTATUS(ret));
+	xlog(D_GENERAL, "ha callout returned %d", WEXITSTATUS(ret));
 #endif
 }
 
diff -urpN nfs-utils-1.0.7.logging1/support/nfs/exports.c nfs-utils-1.0.7.logging2/support/nfs/exports.c
--- nfs-utils-1.0.7.logging1/support/nfs/exports.c	Wed Aug  6 08:23:40 2003
+++ nfs-utils-1.0.7.logging2/support/nfs/exports.c	Fri Mar 11 15:20:08 2005
@@ -384,7 +384,7 @@ parseopts(char *cp, struct exportent *ep
 			char *oe;
 			ep->e_anonuid = strtol(opt+8, &oe, 10);
 			if (opt[8]=='\0' || *oe != '\0') {
-				xlog(L_ERROR, "%s: %d: bad anonuid \"%s\"\n",
+				xlog(L_ERROR, "%s: %d: bad anonuid \"%s\"",
 				     flname, flline, opt);	
 bad_option:
 				free(opt);
@@ -395,7 +395,7 @@ bad_option:
 			char *oe;
 			ep->e_anongid = strtol(opt+8, &oe, 10);
 			if (opt[8]=='\0' || *oe != '\0') {
-				xlog(L_ERROR, "%s: %d: bad anongid \"%s\"\n",
+				xlog(L_ERROR, "%s: %d: bad anongid \"%s\"",
 				     flname, flline, opt);	
 				goto bad_option;
 			}
@@ -411,7 +411,7 @@ bad_option:
 			char *oe;
 			ep->e_fsid = strtoul(opt+5, &oe, 0);
 			if (opt[5]=='\0' || *oe != '\0') {
-				xlog(L_ERROR, "%s: %d: bad fsid \"%s\"\n",
+				xlog(L_ERROR, "%s: %d: bad fsid \"%s\"",
 				     flname, flline, opt);	
 				goto bad_option;
 			}
@@ -426,7 +426,7 @@ bad_option:
 			else
 				ep->e_mountpoint = strdup("");
 		} else {
-			xlog(L_ERROR, "%s:%d: unknown keyword \"%s\"\n",
+			xlog(L_ERROR, "%s:%d: unknown keyword \"%s\"",
 					flname, flline, opt);
 			ep->e_flags |= NFSEXP_ALLSQUASH | NFSEXP_READONLY;
 			goto bad_option;
@@ -445,7 +445,7 @@ out:
 	if (warn && !had_sync_opt)
 		xlog(L_WARNING, "%s [%d]: No 'sync' or 'async' option specified for export \"%s:%s\".\n"
 				"  Assuming default behaviour ('sync').\n"
-		     		"  NOTE: this default has changed from previous versions\n",
+		     		"  NOTE: this default has changed from previous versions",
 
 				flname, flline,
 				ep->e_hostname, ep->e_path);
diff -urpN nfs-utils-1.0.7.logging1/support/nfs/keytab.c nfs-utils-1.0.7.logging2/support/nfs/keytab.c
--- nfs-utils-1.0.7.logging1/support/nfs/keytab.c	Tue Oct 19 02:21:12 1999
+++ nfs-utils-1.0.7.logging2/support/nfs/keytab.c	Fri Mar 11 15:20:15 2005
@@ -38,7 +38,7 @@ fsetnfskeyent(char *fname, char *type)
 	FILE	*fp;
 
 	if ((fp = fopen(fname, type)) == NULL)
-		xlog(L_ERROR, "can't open %s for %sing\n",
+		xlog(L_ERROR, "can't open %s for %sing",
 				fname, type[0] == 'r'? "read" : "writ");
 	return fp;
 #else
diff -urpN nfs-utils-1.0.7.logging1/support/nfs/rpcmisc.c nfs-utils-1.0.7.logging2/support/nfs/rpcmisc.c
--- nfs-utils-1.0.7.logging1/support/nfs/rpcmisc.c	Wed Feb 19 06:25:04 2003
+++ nfs-utils-1.0.7.logging2/support/nfs/rpcmisc.c	Fri Mar 11 15:19:40 2005
@@ -75,7 +75,7 @@ rpc_init(char *name, int prog, int vers,
 			if (defport == 0)
 				sock = RPC_ANYSOCK;
 			else if ((sock = makesock(defport, IPPROTO_UDP)) < 0) {
-				xlog(L_FATAL, "%s: cannot make a UDP socket\n",
+				xlog(L_FATAL, "%s: cannot make a UDP socket",
 						name);
 			}
 		}
@@ -105,7 +105,7 @@ rpc_init(char *name, int prog, int vers,
 			if (defport == 0)
 				sock = RPC_ANYSOCK;
 			else if ((sock = makesock(defport, IPPROTO_TCP)) < 0) {
-				xlog(L_FATAL, "%s: cannot make a TCP socket\n",
+				xlog(L_FATAL, "%s: cannot make a TCP socket",
 						name);
 			}
 		}
@@ -161,7 +161,7 @@ int makesock(int port, int proto)
 	sock_type = (proto == IPPROTO_UDP) ? SOCK_DGRAM : SOCK_STREAM;
 	s = socket(AF_INET, sock_type, proto);
 	if (s < 0) {
-		xlog(L_FATAL, "Could not make a socket: %s\n",
+		xlog(L_FATAL, "Could not make a socket: %s",
 					strerror(errno));
 		return (-1);
 	}
@@ -172,7 +172,7 @@ int makesock(int port, int proto)
 
 	val = 1;
 	if (setsockopt(s, SOL_SOCKET, SO_REUSEADDR, &val, sizeof(val)) < 0)
-		xlog(L_ERROR, "setsockopt failed: %s\n", strerror(errno));
+		xlog(L_ERROR, "setsockopt failed: %s", strerror(errno));
 
 #if 0
 	/* I was told it didn't work with gigabit ethernet.
@@ -185,13 +185,13 @@ int makesock(int port, int proto)
 		sblen = rblen = socksz + 1024;
 		if (setsockopt(s, SOL_SOCKET, SO_SNDBUF, &sblen, sizeof sblen) < 0 ||
 		    setsockopt(s, SOL_SOCKET, SO_RCVBUF, &rblen, sizeof rblen) < 0)
-			xlog(L_ERROR, "setsockopt failed: %s\n", strerror(errno));
+			xlog(L_ERROR, "setsockopt failed: %s", strerror(errno));
 	}
 #endif				/* SO_SNDBUF */
 #endif
 
 	if (bind(s, (struct sockaddr *) &sin, sizeof(sin)) == -1) {
-		xlog(L_FATAL, "Could not bind name to socket: %s\n",
+		xlog(L_FATAL, "Could not bind name to socket: %s",
 					strerror(errno));
 		return (-1);
 	}
@@ -253,5 +253,5 @@ rpc_logcall(struct svc_req *rqstp, char 
 	default:
 		sprintf(sp, "CRED %d", rqstp->rq_cred.oa_flavor);
 	}
-	xlog(D_CALL, "%s [%s]\n\t%s\n", xname, buff, arg);
+	xlog(D_CALL, "%s [%s]\n\t%s", xname, buff, arg);
 }
diff -urpN nfs-utils-1.0.7.logging1/support/nfs/xlog.c nfs-utils-1.0.7.logging2/support/nfs/xlog.c
--- nfs-utils-1.0.7.logging1/support/nfs/xlog.c	Mon Mar 14 15:18:33 2005
+++ nfs-utils-1.0.7.logging2/support/nfs/xlog.c	Mon Mar 14 16:14:08 2005
@@ -114,7 +114,7 @@ xlog_sconfig(char *kind, int on)
 	while (tbl->df_name != NULL && strcasecmp(tbl->df_name, kind)) 
 		tbl++;
 	if (!tbl->df_name) {
-		xlog (L_WARNING, "Invalid debug facility: %s\n", kind);
+		xlog(L_WARNING, "Invalid debug facility: %s", kind);
 		return;
 	}
 	xlog_config(tbl->df_fac, on);
diff -urpN nfs-utils-1.0.7.logging1/utils/mountd/mountd.c nfs-utils-1.0.7.logging2/utils/mountd/mountd.c
--- nfs-utils-1.0.7.logging1/utils/mountd/mountd.c	Fri Mar 11 15:11:36 2005
+++ nfs-utils-1.0.7.logging2/utils/mountd/mountd.c	Fri Mar 11 16:00:58 2005
@@ -65,13 +65,13 @@ static int nfs_version = -1;
 static void 
 killer (int sig)
 {
-  if (nfs_version & 0x1)
-    pmap_unset (MOUNTPROG, MOUNTVERS);
-  if (nfs_version & (0x1 << 1))
-    pmap_unset (MOUNTPROG, MOUNTVERS_POSIX);
-  if (nfs_version & (0x1 << 2))
-    pmap_unset (MOUNTPROG, MOUNTVERS_NFSV3);
-  xlog (L_FATAL, "Caught signal %d, un-registering and exiting.", sig);
+	if (nfs_version & 0x1)
+		pmap_unset (MOUNTPROG, MOUNTVERS);
+	if (nfs_version & (0x1 << 1))
+		pmap_unset (MOUNTPROG, MOUNTVERS_POSIX);
+	if (nfs_version & (0x1 << 2))
+		pmap_unset (MOUNTPROG, MOUNTVERS_NFSV3);
+	xlog (L_FATAL, "Caught signal %d, un-registering and exiting", sig);
 }
 
 bool_t
@@ -577,7 +577,7 @@ main(int argc, char **argv)
 		if ((c = fork()) > 0)
 			exit(0);
 		if (c < 0) {
-			xlog(L_FATAL, "mountd: cannot fork: %s\n",
+			xlog(L_FATAL, "mountd: cannot fork: %s",
 						strerror(errno));
 		}
 		/* Now we remove ourselves from the foreground.
@@ -594,7 +594,7 @@ main(int argc, char **argv)
 
 	my_svc_run();
 
-	xlog(L_ERROR, "Ack! Gack! svc_run returned!\n");
+	xlog(L_ERROR, "Ack! Gack! svc_run returned!");
 	exit(1);
 }
 

--Boundary-00=_y8ZNCIxyAN/3i4C
Content-Type: text/x-diff;
  charset="koi8-r";
  name="nfs-utils-1.0.7_log23.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="nfs-utils-1.0.7_log23.diff"

diff -urpN nfs-utils-1.0.7.logging2/support/nfs/xlog.c nfs-utils-1.0.7.logging3/support/nfs/xlog.c
--- nfs-utils-1.0.7.logging2/support/nfs/xlog.c	Mon Mar 14 16:14:08 2005
+++ nfs-utils-1.0.7.logging3/support/nfs/xlog.c	Mon Mar 14 16:00:53 2005
@@ -173,7 +173,7 @@ xlog(int kind, const char *fmt, ...)
 
 		time(&now);
 		tm = localtime(&now);
-		fprintf(stderr, "%s[%d] %04d-%02d-%02d %02d:%02d:%02d %s\n",
+		fprintf(stderr, "%04d-%02d-%02d %02d:%02d:%02d %s[%d]: %s\n",
 				log_name, log_pid,
 				tm->tm_year+1900, tm->tm_mon + 1, tm->tm_mday,
 				tm->tm_hour, tm->tm_min, tm->tm_sec,
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/Makefile nfs-utils-1.0.7.logging3/utils/statd/Makefile
--- nfs-utils-1.0.7.logging2/utils/statd/Makefile	Mon Sep 15 02:45:55 2003
+++ nfs-utils-1.0.7.logging3/utils/statd/Makefile	Fri Mar 11 16:42:00 2005
@@ -19,7 +19,7 @@ CCOPTS	= $(DEBUG) $(SIMUL)
 LIBS	= -lexport -lnfs -lmisc $(LIBWRAP) $(LIBNSL)
 
 SRCS	= $(RPCSRCS) $(SIMSRCS) \
-	  callback.c notlist.c log.c misc.c monitor.c notify.c simu.c \
+	  callback.c notlist.c misc.c monitor.c notify.c simu.c \
 	  stat.c statd.c state.c svc_run.c rmtcall.c
 HDRS	= $(RPCHDRS) $(SIMHDRS)
 
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/callback.c nfs-utils-1.0.7.logging3/utils/statd/callback.c
--- nfs-utils-1.0.7.logging2/utils/statd/callback.c	Fri Aug 22 19:03:51 2003
+++ nfs-utils-1.0.7.logging3/utils/statd/callback.c	Fri Mar 11 17:04:03 2005
@@ -9,6 +9,7 @@
 #include "config.h"
 #include "statd.h"
 #include "notlist.h"
+#include "xlog.h"
 
 /* Callback notify list. */
 /* notify_list *cbnl = NULL; ... never used */
@@ -26,14 +27,14 @@ sm_notify_1_svc(struct stat_chge *argp, 
 	notify_list    *lp, *call;
 	static char    *result = NULL;
 
-	dprintf(N_DEBUG, "Received SM_NOTIFY from %s, state: %d",
+	xlog(D_GENERAL, "Received SM_NOTIFY from %s, state: %d",
 				argp->mon_name, argp->state);
 
 	/* quick check - don't bother if we're not monitoring anyone */
 	/* LH - this was != MULL, meaning that if anyone _was_ in our RTNL,
 	 * we'd never pass this point. */
 	if (!(lp = rtnl)) {
-		note(N_WARNING, "SM_NOTIFY from %s while not monitoring any hosts.",
+		xlog(L_WARNING, "SM_NOTIFY from %s while not monitoring any hosts",
 				argp->mon_name, argp->state);
 		return ((void *) &result);
 	}
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/log.c nfs-utils-1.0.7.logging3/utils/statd/log.c
--- nfs-utils-1.0.7.logging2/utils/statd/log.c	Fri Aug 22 19:03:51 2003
+++ nfs-utils-1.0.7.logging3/utils/statd/log.c	Thu Jan  1 03:00:00 1970
@@ -1,91 +0,0 @@
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
-#include "config.h"
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
-static int	opt_debug = 0;	/* Will be command-line option, eventually */
-
-void log_init()
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
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/log.h nfs-utils-1.0.7.logging3/utils/statd/log.h
--- nfs-utils-1.0.7.logging2/utils/statd/log.h	Fri Aug 22 19:03:51 2003
+++ nfs-utils-1.0.7.logging3/utils/statd/log.h	Thu Jan  1 03:00:00 1970
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
-void	log_init();
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
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/misc.c nfs-utils-1.0.7.logging3/utils/statd/misc.c
--- nfs-utils-1.0.7.logging2/utils/statd/misc.c	Fri Aug 22 19:03:51 2003
+++ nfs-utils-1.0.7.logging3/utils/statd/misc.c	Fri Mar 11 17:04:03 2005
@@ -14,6 +14,7 @@
 #include <unistd.h>
 #include "statd.h"
 #include "notlist.h"
+#include "xlog.h"
 
 /*
  * Error-checking malloc() wrapper.
@@ -28,7 +29,7 @@ xmalloc (size_t size)
 
   if (!(ptr = malloc (size)))
     /* SHIT!  SHIT!  SHIT! */
-    die ("malloc failed");
+    xlog(L_FATAL, "malloc failed");
 
   return (ptr);
 }
@@ -44,7 +45,7 @@ xstrdup (const char *string)
 
   /* Will only fail if underlying malloc() fails (ENOMEM). */
   if (!(result = strdup (string)))
-    die ("strdup failed");
+    xlog(L_FATAL, "strdup failed");
 
   return (result);
 }
@@ -64,10 +65,10 @@ xunlink (char *path, char *host, short i
 
   if (!check || !nlist_gethost(rtnl, host, 0)) {
     if (unlink (tozap) == -1)
-      note (N_ERROR, "unlink (%s): %s", tozap, strerror (errno));
+      xlog (L_ERROR, "unlink (%s): %s", tozap, strerror (errno));
     else
-      dprintf (N_DEBUG, "Unlinked %s", tozap);
+      xlog (D_GENERAL, "Unlinked %s", tozap);
   }
   else
-    dprintf (N_DEBUG, "Not unlinking %s--host still monitored.", tozap);
+    xlog (D_GENERAL, "Not unlinking %s - host still monitored", tozap);
 }
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/monitor.c nfs-utils-1.0.7.logging3/utils/statd/monitor.c
--- nfs-utils-1.0.7.logging2/utils/statd/monitor.c	Wed Sep 15 06:08:01 2004
+++ nfs-utils-1.0.7.logging3/utils/statd/monitor.c	Fri Mar 11 17:04:03 2005
@@ -16,6 +16,8 @@
 #include <unistd.h>
 #include <sys/stat.h>
 #include <arpa/inet.h>
+#include <errno.h>
+#include "xlog.h"
 #include "misc.h"
 #include "statd.h"
 #include "notlist.h"
@@ -59,7 +61,7 @@ sm_mon_1_svc(struct mon *argp, struct sv
 	 */
 	caller = svc_getcaller(rqstp->rq_xprt)->sin_addr;
 	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-		note(N_WARNING,
+		xlog(L_WARNING,
 			"Call to statd from non-local host %s",
 			inet_ntoa(caller));
 		goto failure;
@@ -78,7 +80,7 @@ sm_mon_1_svc(struct mon *argp, struct sv
 	if (id->my_prog != 100021 ||
 	    (id->my_proc != 16 && id->my_proc != 24))
 	{
-		note(N_WARNING,
+		xlog(L_WARNING,
 			"Attempt to register callback to %d/%d",
 			id->my_prog, id->my_proc);
 		goto failure;
@@ -88,7 +90,7 @@ sm_mon_1_svc(struct mon *argp, struct sv
 	 *	Again, specific to the linux kernel lockd.
 	 */
 	if (!inet_aton(mon_name, &mon_addr)) {
-		note(N_WARNING,
+		xlog(L_WARNING,
 			"Attempt to register host %s (not a dotted quad)",
 			mon_name);
 		goto failure;
@@ -101,15 +103,15 @@ sm_mon_1_svc(struct mon *argp, struct sv
 
 	/* must check for /'s in hostname!  See CERT's CA-96.09 for details. */
 	if (strchr(mon_name, '/')) {
-		note(N_CRIT, "SM_MON request for hostname containing '/': %s",
+		xlog(L_CRIT, "SM_MON request for hostname containing '/': %s",
 			mon_name);
-		note(N_CRIT, "POSSIBLE SPOOF/ATTACK ATTEMPT!");
+		xlog(L_CRIT, "POSSIBLE SPOOF/ATTACK ATTEMPT!");
 		goto failure;
 	} else if (gethostbyname(mon_name) == NULL) {
-		note(N_WARNING, "gethostbyname error for %s", mon_name);
+		xlog(L_WARNING, "gethostbyname error for %s", mon_name);
 		goto failure;
 	} else if (!(hostinfo = gethostbyname(my_name))) {
-		note(N_WARNING, "gethostbyname error for %s", my_name);
+		xlog(L_WARNING, "gethostbyname error for %s", my_name);
 		goto failure;
 	} else
 		my_addr = *(struct in_addr *) hostinfo->h_addr;
@@ -135,7 +137,7 @@ sm_mon_1_svc(struct mon *argp, struct sv
 				NL_MY_PROG(temp) == id->my_prog &&
 				NL_MY_VERS(temp) == id->my_vers) {
 				/* Hey!  We already know you guys! */
-				dprintf(N_DEBUG,
+				xlog(D_GENERAL,
 					"Duplicate SM_MON request for %s "
 					"from procedure on %s",
 					mon_name, my_name);
@@ -154,7 +156,7 @@ sm_mon_1_svc(struct mon *argp, struct sv
 	 * doesn't fail.  (I should probably fix this assumption.)
 	 */
 	if (!(clnt = nlist_new(my_name, mon_name, 0))) {
-		note(N_WARNING, "out of memory");
+		xlog(L_WARNING, "out of memory");
 		goto failure;
 	}
 
@@ -172,7 +174,7 @@ sm_mon_1_svc(struct mon *argp, struct sv
 	sprintf(path, "%s/%s", SM_DIR, mon_name);
 	if ((fd = open(path, O_WRONLY|O_SYNC|O_CREAT, S_IRUSR|S_IWUSR)) < 0) {
 		/* Didn't fly.  We won't monitor. */
-		note(N_ERROR, "creat(%s) failed: %m", path);
+		xlog(L_ERROR, "creat(%s) failed: %s", path, strerror(errno));
 		nlist_free(NULL, clnt);
 		free(path);
 		goto failure;
@@ -185,11 +187,11 @@ sm_mon_1_svc(struct mon *argp, struct sv
 
 	result.res_stat = STAT_SUCC;
 	result.state = MY_STATE;
-	dprintf(N_DEBUG, "MONITORING %s for %s", mon_name, my_name);
+	xlog(D_GENERAL, "MONITORING %s for %s", mon_name, my_name);
 	return (&result);
 
 failure:
-	note(N_WARNING, "STAT_FAIL to %s for SM_MON of %s", my_name, mon_name);
+	xlog(L_WARNING, "STAT_FAIL to %s for SM_MON of %s", my_name, mon_name);
 	return (&result);
 }
 
@@ -223,7 +225,7 @@ sm_unmon_1_svc(struct mon_id *argp, stru
 	 */
 	caller = svc_getcaller(rqstp->rq_xprt)->sin_addr;
 	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-		note(N_WARNING,
+		xlog(L_WARNING,
 			"Call to statd from non-local host %s",
 			inet_ntoa(caller));
 		goto failure;
@@ -233,9 +235,9 @@ sm_unmon_1_svc(struct mon_id *argp, stru
 
 	/* Check if we're monitoring anyone. */
 	if (!(clnt = rtnl)) {
-		note(N_WARNING,
+		xlog(L_WARNING,
 			"Received SM_UNMON request from %s for %s while not "
-			"monitoring any hosts.", my_name, argp->mon_name);
+			"monitoring any hosts", my_name, argp->mon_name);
 		return (&result);
 	}
 
@@ -251,7 +253,7 @@ sm_unmon_1_svc(struct mon_id *argp, stru
 			NL_MY_PROG(clnt) == id->my_prog &&
 			NL_MY_VERS(clnt) == id->my_vers) {
 			/* Match! */
-			dprintf(N_DEBUG, "UNMONITORING %s for %s",
+			xlog(D_GENERAL, "UNMONITORING %s for %s",
 					mon_name, my_name);
 
 			/* PRC: do the HA callout: */
@@ -266,7 +268,7 @@ sm_unmon_1_svc(struct mon_id *argp, stru
 	}
 
  failure:
-	note(N_WARNING, "Received erroneous SM_UNMON request from %s for %s",
+	xlog(L_WARNING, "Received erroneous SM_UNMON request from %s for %s",
 		my_name, mon_name);
 	return (&result);
 }
@@ -288,7 +290,7 @@ sm_unmon_all_1_svc(struct my_id *argp, s
 	 */
 	caller = svc_getcaller(rqstp->rq_xprt)->sin_addr;
 	if (caller.s_addr != htonl(INADDR_LOOPBACK)) {
-		note(N_WARNING,
+		xlog(L_WARNING,
 			"Call to statd from non-local host %s",
 			inet_ntoa(caller));
 		goto failure;
@@ -299,7 +301,7 @@ sm_unmon_all_1_svc(struct my_id *argp, s
 	result.state = MY_STATE;
 
 	if (!(clnt = rtnl)) {
-		note(N_WARNING, "Received SM_UNMON_ALL request from %s "
+		xlog(L_WARNING, "Received SM_UNMON_ALL request from %s "
 			"while not monitoring any hosts", my_name);
 		return (&result);
 	}
@@ -312,7 +314,7 @@ sm_unmon_all_1_svc(struct my_id *argp, s
 			char            mon_name[SM_MAXSTRLEN + 1];
 			notify_list	*temp;
 
-			dprintf(N_DEBUG,
+			xlog(D_GENERAL,
 				"UNMONITORING (SM_UNMON_ALL) %s for %s",
 				NL_MON_NAME(clnt), NL_MY_NAME(clnt));
 			strncpy(mon_name, NL_MON_NAME(clnt),
@@ -330,8 +332,8 @@ sm_unmon_all_1_svc(struct my_id *argp, s
 	}
 
 	if (!count) {
-		dprintf(N_DEBUG, "SM_UNMON_ALL request from %s with no "
-			"SM_MON requests from it.", my_name);
+		xlog(D_GENERAL, "SM_UNMON_ALL request from %s with no "
+			"SM_MON requests from it", my_name);
 	}
  failure:
 	return (&result);
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/notify.c nfs-utils-1.0.7.logging3/utils/statd/notify.c
--- nfs-utils-1.0.7.logging2/utils/statd/notify.c	Fri Aug 22 19:03:51 2003
+++ nfs-utils-1.0.7.logging3/utils/statd/notify.c	Fri Mar 11 17:04:03 2005
@@ -17,6 +17,7 @@
 #include <netdb.h>
 #include <string.h>
 #include <unistd.h>
+#include "xlog.h"
 #include "misc.h"
 #include "statd.h"
 #include "notlist.h"
@@ -54,10 +55,10 @@ notify_hosts(void)
 		 || matchhostname(de->d_name, "localhost")) {
 			char *fname;
 			fname=xmalloc(strlen(SM_BAK_DIR)+sizeof(de->d_name)+2);
-			dprintf(N_DEBUG, "We're on our own notify list?!?");
+			xlog(D_GENERAL, "We're on our own notify list?!?");
 			sprintf(fname, "%s/%s",  SM_BAK_DIR, de->d_name);
 			if (unlink(fname)) 
-				note(N_ERROR, "unlink(%s): %s", 
+				xlog(L_ERROR, "unlink(%s): %s", 
 					fname, strerror(errno));
 			free(fname);
 			continue;
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/rmtcall.c nfs-utils-1.0.7.logging3/utils/statd/rmtcall.c
--- nfs-utils-1.0.7.logging2/utils/statd/rmtcall.c	Mon Dec  6 03:07:27 2004
+++ nfs-utils-1.0.7.logging3/utils/statd/rmtcall.c	Fri Mar 11 17:04:03 2005
@@ -34,10 +34,11 @@
 #include <netdb.h>
 #include <string.h>
 #include <unistd.h>
+#include <errno.h>
+#include "xlog.h"
 #include "sm_inter.h"
 #include "statd.h"
 #include "notlist.h"
-#include "log.h"
 #include "ha-callout.h"
 
 #define MAXMSGSIZE	(2048 / sizeof(unsigned int))
@@ -57,7 +58,7 @@ statd_get_socket(int port)
 		return sockfd;
 
 	if ((sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
-		note(N_CRIT, "Can't create socket: %m");
+		xlog(L_ERROR, "Can't create socket: %s", strerror(errno));
 		return -1;
 	}
 
@@ -77,8 +78,8 @@ statd_get_socket(int port)
 			sin.sin_addr = *(struct in_addr *) hp->h_addr;
 	}
 	if (bindresvport(sockfd, &sin) < 0) {
-		dprintf(N_WARNING,
-			"process_hosts: can't bind to reserved port\n");
+		xlog(L_WARNING,
+			"process_hosts: can't bind to reserved port");
 	}
 
 	return sockfd;
@@ -101,7 +102,7 @@ try_to_resolve(notify_list *lp)
 	else
 		hname = NL_MY_NAME(lp);
 	if (!inet_aton(hname, &(NL_ADDR(lp)))) {
-		note(N_ERROR, "%s is not an dotted-quad address", hname);
+		xlog(L_ERROR, "%s is not an dotted-quad address", hname);
 		NL_TIMES(lp) = 0;
 		return 0;
 	}
@@ -124,7 +125,7 @@ try_to_resolve(notify_list *lp)
 	else
 		hname = NL_MY_NAME(lp);
 
-	dprintf(N_DEBUG, "Trying to resolve %s.", hname);
+	xlog(D_GENERAL, "Trying to resolve %s", hname);
 	if (!(hp = gethostbyname(hname))) {
 		herror("gethostbyname");
 		NL_TIMES(lp) -= 1;
@@ -132,7 +133,7 @@ try_to_resolve(notify_list *lp)
 	}
 
 	if (hp->h_addrtype != AF_INET) {
-		note(N_ERROR, "%s is not an AF_INET address", hname);
+		xlog(L_ERROR, "%s is not an AF_INET address", hname);
 		NL_TIMES(lp) = 0;
 		return 0;
 	}
@@ -141,7 +142,7 @@ try_to_resolve(notify_list *lp)
 	 * alternation because one interface might be down/unreachable. */
 	NL_ADDR(lp) = *(struct in_addr *) hp->h_addr;
 
-	dprintf(N_DEBUG, "address of %s is %s", hname, inet_ntoa(NL_ADDR(lp)));
+	xlog(D_GENERAL, "address of %s is %s", hname, inet_ntoa(NL_ADDR(lp)));
 	return 1;
 }
 #endif
@@ -192,7 +193,7 @@ xmit_call(int sockfd, struct sockaddr_in
 
 	/* Encode the RPC header part and payload */
 	if (!xdr_callmsg(xdrs, &mesg) || !func(xdrs, obj)) {
-		dprintf(N_WARNING, "xmit_mesg: can't encode RPC message!\n");
+		xlog(L_WARNING, "xmit_mesg: can't encode RPC message!");
 		xdr_destroy(xdrs);
 		return 0;
 	}
@@ -202,9 +203,9 @@ xmit_call(int sockfd, struct sockaddr_in
 
 	if ((err = sendto(sockfd, msgbuf, msglen, 0,
 			(struct sockaddr *) sin, sizeof(*sin))) < 0) {
-		dprintf(N_WARNING, "xmit_mesg: sendto failed: %m");
+		xlog(L_WARNING, "xmit_mesg: sendto failed: %s", strerror(errno));
 	} else if (err != msglen) {
-		dprintf(N_WARNING, "xmit_mesg: short write: %m\n");
+		xlog(L_WARNING, "xmit_mesg: short write: %s", strerror(errno));
 	}
 
 	xdr_destroy(xdrs);
@@ -224,7 +225,7 @@ recv_rply(int sockfd, struct sockaddr_in
 	/* Receive message */
 	if ((msglen = recvfrom(sockfd, msgbuf, sizeof(msgbuf), 0,
 			(struct sockaddr *) sin, &alen)) < 0) {
-		dprintf(N_WARNING, "recv_rply: recvfrom failed: %m");
+		xlog(L_WARNING, "recv_rply: recvfrom failed: %s", strerror(errno));
 		return NULL;
 	}
 
@@ -236,18 +237,18 @@ recv_rply(int sockfd, struct sockaddr_in
 	mesg.rm_reply.rp_acpt.ar_results.proc = (xdrproc_t) xdr_void;
 
 	if (!xdr_replymsg(xdrs, &mesg)) {
-		note(N_WARNING, "recv_rply: can't decode RPC message!\n");
+		xlog(L_WARNING, "recv_rply: can't decode RPC message!");
 		goto done;
 	}
 
 	if (mesg.rm_reply.rp_stat != 0) {
-		note(N_WARNING, "recv_rply: [%s] RPC status %d\n", 
+		xlog(L_WARNING, "recv_rply: [%s] RPC status %d", 
 				inet_ntoa(sin->sin_addr),
 				mesg.rm_reply.rp_stat);
 		goto done;
 	}
 	if (mesg.rm_reply.rp_acpt.ar_stat != 0) {
-		note(N_WARNING, "recv_rply: [%s] RPC status %d\n",
+		xlog(L_WARNING, "recv_rply: [%s] RPC status %d",
 				inet_ntoa(sin->sin_addr),
 				mesg.rm_reply.rp_acpt.ar_stat);
 		goto done;
@@ -264,14 +265,14 @@ recv_rply(int sockfd, struct sockaddr_in
 			strncpy (addr, inet_ntoa(lp->addr),
 				 sizeof (addr) - 1);
 			addr [sizeof (addr) - 1] = '\0';
-			dprintf(N_WARNING, "address mismatch: "
-				"expected %s, got %s\n",
+			xlog(L_WARNING, "address mismatch: "
+				"expected %s, got %s",
 				addr, inet_ntoa(sin->sin_addr));
 		}
 		if (lp->port == 0) {
 			if (!xdr_u_long(xdrs, portp)) {
-				note(N_WARNING, "recv_rply: [%s] "
-					"can't decode reply body!\n",
+				xlog(L_WARNING, "recv_rply: [%s] "
+					"can't decode reply body!",
 					inet_ntoa(sin->sin_addr));
 				lp = NULL;
 				goto done;
@@ -301,7 +302,7 @@ process_entry(int sockfd, notify_list *l
 	if (lp->addr.s_addr == INADDR_ANY && !try_to_resolve(lp))
 		return NL_TIMES(lp);
 	if (NL_TIMES(lp) == 0) {
-		note(N_DEBUG, "Cannot notify %s, giving up.\n",
+		xlog(D_GENERAL, "Cannot notify %s, giving up",
 					inet_ntoa(NL_ADDR(lp)));
 		return 0;
 	}
@@ -339,14 +340,14 @@ process_entry(int sockfd, notify_list *l
 		memcpy(new_status.priv, NL_PRIV(lp), SM_PRIV_SIZE);
 		break;
 	default:
-		note(N_ERROR, "notify_host: unknown notify type %d",
+		xlog(L_ERROR, "notify_host: unknown notify type %d",
 				NL_TYPE(lp));
 		return 0;
 	}
 
 	lp->xid = xmit_call(sockfd, &sin, prog, vers, proc, func, objp);
 	if (!lp->xid) {
-		note(N_WARNING, "notify_host: failed to notify %s\n",
+		xlog(L_WARNING, "notify_host: failed to notify %s",
 				inet_ntoa(lp->addr));
 	}
 	NL_TIMES(lp) -= 1;
@@ -379,15 +380,15 @@ process_reply(FD_SET_TYPE *rfds)
 			nlist_insert_timer(&notify, lp);
 			return 1;
 		}
-		note(N_WARNING, "recv_rply: [%s] service %d not registered",
+		xlog(L_WARNING, "recv_rply: [%s] service %d not registered",
 			inet_ntoa(lp->addr),
 			NL_TYPE(lp) == NOTIFY_REBOOT? SM_PROG : NL_MY_PROG(lp));
 	} else if (NL_TYPE(lp) == NOTIFY_REBOOT) {
-		dprintf(N_DEBUG, "Notification of %s succeeded.",
+		xlog(D_GENERAL, "Notification of %s succeeded",
 			NL_MON_NAME(lp));
 		xunlink(SM_BAK_DIR, NL_MON_NAME(lp), 0);
 	} else {
-		dprintf(N_DEBUG, "Callback to %s (for %d) succeeded.",
+		xlog(D_GENERAL, "Callback to %s (for %d) succeeded",
 			NL_MY_NAME(lp), NL_MON_NAME(lp));
 	}
 	nlist_free(&notify, lp);
@@ -415,15 +416,15 @@ process_notify_list(void)
 			nlist_remove(&notify, entry);
 			nlist_insert_timer(&notify, entry);
 		} else if (NL_TYPE(entry) == NOTIFY_CALLBACK) {
-			note(N_ERROR,
-				"Can't callback %s (%d,%d), giving up.",
+			xlog(L_ERROR,
+				"Can't callback %s (%d,%d), giving up",
 					NL_MY_NAME(entry),
 					NL_MY_PROG(entry),
 					NL_MY_VERS(entry));
 			nlist_free(&notify, entry);
 		} else {
-			note(N_ERROR,
-				"Can't notify %s, giving up.",
+			xlog(L_ERROR,
+				"Can't notify %s, giving up",
 					NL_MON_NAME(entry));
 			/* PRC: do the HA callout */
 			ha_callout("del-client", NL_MON_NAME(entry), NL_MY_NAME(entry), -1);
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/simu.c nfs-utils-1.0.7.logging3/utils/statd/simu.c
--- nfs-utils-1.0.7.logging2/utils/statd/simu.c	Fri Aug 22 19:03:51 2003
+++ nfs-utils-1.0.7.logging3/utils/statd/simu.c	Fri Mar 11 17:04:03 2005
@@ -4,6 +4,7 @@
  * NSM for Linux.
  */
 
+#include "xlog.h"
 #include "config.h"
 #include "statd.h"
 #include "notlist.h"
@@ -19,7 +20,7 @@ sm_simu_crash_1_svc (void *argp, struct 
 {
   static char *result = NULL;
 
-  note (N_WARNING, "*** SIMULATING CRASH! ***");
+  xlog (L_WARNING, "*** SIMULATING CRASH! ***");
   my_svc_exit ();
 
   if (rtnl)
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/simulate.c nfs-utils-1.0.7.logging3/utils/statd/simulate.c
--- nfs-utils-1.0.7.logging2/utils/statd/simulate.c	Fri Aug 22 19:03:51 2003
+++ nfs-utils-1.0.7.logging3/utils/statd/simulate.c	Fri Mar 11 16:41:04 2005
@@ -61,7 +61,7 @@ simulator (int argc, char **argv)
       simulate_mon (*(&argv[1]), *(&argv[2]), *(&argv[3]), *(&argv[4]),
 		    *(&argv[5]));
   }
-  die ("WTF?  Give me something I can use!");
+  xlog(L_FATAL, "WTF? Give me something I can use!");
 }
 
 static void
@@ -72,11 +72,11 @@ simulate_mon (char *calling, char *monit
   sm_stat_res *result;
   mon mon;
 
-  dprintf (N_DEBUG, "Calling %s (as %s) to monitor %s", calling, as,
+  xlog (D_GENERAL, "Calling %s (as %s) to monitor %s", calling, as,
 	   monitoring);
 
   if ((client = clnt_create (calling, SM_PROG, SM_VERS, "udp")) == NULL)
-    die ("%s", clnt_spcreateerror ("clnt_create"));
+    xlog(L_FATAL, "%s", clnt_spcreateerror ("clnt_create"));
 
   memcpy (mon.priv, fool, SM_PRIV_SIZE);
   mon.mon_id.my_id.my_name = xstrdup (as);
@@ -87,16 +87,15 @@ simulate_mon (char *calling, char *monit
   mon.mon_id.mon_name = monitoring;
 
   if (!(result = sm_mon_1 (&mon, client)))
-    die ("%s", clnt_sperror (client, "sm_mon_1"));
+    xlog(L_FATAL, "%s", clnt_sperror (client, "sm_mon_1"));
 
   free (mon.mon_id.my_id.my_name);
 
   if (result->res_stat != STAT_SUCC) {
-    note (N_FATAL, "SM_MON request failed, state: %d", result->state);
+    xlog (L_ERROR, "SM_MON request failed, state: %d", result->state);
     exit (0);
   } else {
-    dprintf (N_DEBUG, "SM_MON result successful, state: %d\n", result->state);
-    dprintf (N_DEBUG, "Waiting for callback.");
+    xlog (D_GENERAL, "SM_MON result successful, state: %d. Waiting for callback", result->state);
     daemon_simulator ();
     exit (0);
   }
@@ -109,11 +108,11 @@ simulate_unmon (char *calling, char *unm
   sm_stat *result;
   mon_id mon_id;
 
-  dprintf (N_DEBUG, "Calling %s (as %s) to unmonitor %s", calling, as,
+  xlog (D_GENERAL, "Calling %s (as %s) to unmonitor %s", calling, as,
 	   unmonitoring);
 
   if ((client = clnt_create (calling, SM_PROG, SM_VERS, "udp")) == NULL)
-    die ("%s", clnt_spcreateerror ("clnt_create"));
+    xlog(L_FATAL, "%s", clnt_spcreateerror ("clnt_create"));
 
   mon_id.my_id.my_name = xstrdup (as);
   mon_id.my_id.my_prog = atoi (proggy) * SIM_SM_PROG;
@@ -122,10 +121,10 @@ simulate_unmon (char *calling, char *unm
   mon_id.mon_name = unmonitoring;
 
   if (!(result = sm_unmon_1 (&mon_id, client)))
-    die ("%s", clnt_sperror (client, "sm_unmon_1"));
+    xlog(L_FATAL, "%s", clnt_sperror (client, "sm_unmon_1"));
 
   free (mon_id.my_id.my_name);
-  dprintf (N_DEBUG, "SM_UNMON request returned state: %d\n", result->state);
+  xlog (D_GENERAL, "SM_UNMON request returned state: %d", result->state);
   exit (0);
 }
 
@@ -136,10 +135,10 @@ simulate_unmon_all (char *calling, char 
   sm_stat *result;
   my_id my_id;
 
-  dprintf (N_DEBUG, "Calling %s (as %s) to unmonitor all hosts", calling, as);
+  xlog (D_GENERAL, "Calling %s (as %s) to unmonitor all hosts", calling, as);
 
   if ((client = clnt_create (calling, SM_PROG, SM_VERS, "udp")) == NULL)
-    die ("%s", clnt_spcreateerror ("clnt_create"));
+    xlog(L_FATAL, "%s", clnt_spcreateerror ("clnt_create"));
 
   my_id.my_name = xstrdup (as);
   my_id.my_prog = atoi (proggy) * SIM_SM_PROG;
@@ -147,10 +146,10 @@ simulate_unmon_all (char *calling, char 
   my_id.my_proc = SIM_SM_MON;
 
   if (!(result = sm_unmon_all_1 (&my_id, client)))
-    die ("%s", clnt_sperror (client, "sm_unmon_all_1"));
+    xlog(L_FATAL, "%s", clnt_sperror (client, "sm_unmon_all_1"));
 
   free (my_id.my_name);
-  dprintf (N_DEBUG, "SM_UNMON_ALL request returned state: %d\n", result->state);
+  xlog (D_GENERAL, "SM_UNMON_ALL request returned state: %d", result->state);
   exit (0);
 }
 
@@ -160,10 +159,10 @@ simulate_crash (char *host)
   CLIENT *client;
 
   if ((client = clnt_create (host, SM_PROG, SM_VERS, "udp")) == NULL)
-    die ("%s", clnt_spcreateerror ("clnt_create"));
+    xlog(L_FATAL, "%s", clnt_spcreateerror ("clnt_create"));
 
   if (!sm_simu_crash_1 (NULL, client))
-    die ("%s", clnt_sperror (client, "sm_simu_crash_1"));
+    xlog(L_FATAL, "%s", clnt_sperror (client, "sm_simu_crash_1"));
 
   exit (0);
 }
@@ -176,18 +175,18 @@ simulate_stat (char *calling, char *moni
   sm_stat_res *result;
   
   if ((client = clnt_create (calling, SM_PROG, SM_VERS, "udp")) == NULL)
-    die ("%s", clnt_spcreateerror ("clnt_create"));
+    xlog(L_FATAL, "%s", clnt_spcreateerror ("clnt_create"));
 
   checking.mon_name = monitoring;
 
   if (!(result = sm_stat_1 (&checking, client)))
-    die ("%s", clnt_sperror (client, "sm_stat_1"));
+    xlog(L_FATAL, "%s", clnt_sperror (client, "sm_stat_1"));
 
   if (result->res_stat == STAT_SUCC)
-    dprintf (N_DEBUG, "STAT_SUCC from %s for %s, state: %d", calling,
+    xlog (D_GENERAL, "STAT_SUCC from %s for %s, state: %d", calling,
 	     monitoring, result->state);
   else
-    dprintf (N_DEBUG, "STAT_FAIL from %s for %s, state: %d", calling,
+    xlog (D_GENERAL, "STAT_FAIL from %s for %s, state: %d", calling,
 	     monitoring, result->state);
 
   exit (0);
@@ -196,7 +195,7 @@ simulate_stat (char *calling, char *moni
 static void
 sim_killer (int sig)
 {
-  note (N_FATAL, "Simulator caught signal %d, un-registering and exiting.", sig);
+  xlog (L_ERROR, "Simulator caught signal %d, un-registering and exiting", sig);
   pmap_unset (sim_port, SIM_SM_VERS);
   exit (0);
 }
@@ -219,7 +218,7 @@ sim_sm_mon_1_svc (struct status *argp, s
 {
   static char *result;
 
-  dprintf (N_DEBUG, "Recieved state %d for mon_name %s (opaque \"%s\")",
+  xlog (D_GENERAL, "Recieved state %d for mon_name %s (opaque \"%s\")",
 	   argp->state, argp->mon_name, argp->priv);
   svc_exit ();
   return ((void *)&result);
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/stat.c nfs-utils-1.0.7.logging3/utils/statd/stat.c
--- nfs-utils-1.0.7.logging2/utils/statd/stat.c	Fri Aug 22 19:03:51 2003
+++ nfs-utils-1.0.7.logging3/utils/statd/stat.c	Fri Mar 11 17:04:03 2005
@@ -5,6 +5,7 @@
  * NSM for Linux.
  */
 
+#include "xlog.h"
 #include "config.h"
 #include <netdb.h>
 #include "statd.h"
@@ -25,12 +26,12 @@ sm_stat_1_svc (struct sm_name *argp, str
   static sm_stat_res result;
 
   if (gethostbyname (argp->mon_name) == NULL) {
-    note (N_WARNING, "gethostbyname error for %s", argp->mon_name);
+    xlog (L_WARNING, "gethostbyname error for %s", argp->mon_name);
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
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/statd.c nfs-utils-1.0.7.logging3/utils/statd/statd.c
--- nfs-utils-1.0.7.logging2/utils/statd/statd.c	Mon Dec  6 03:25:27 2004
+++ nfs-utils-1.0.7.logging3/utils/statd/statd.c	Mon Mar 14 16:09:52 2005
@@ -20,6 +20,7 @@
 #include <rpcmisc.h>
 #include <sys/resource.h>
 #include <grp.h>
+#include "xlog.h"
 #include "statd.h"
 #include "version.h"
 
@@ -42,11 +43,8 @@ char *  SM_STAT_PATH = DEFAULT_SM_STAT_P
 short int restart = 0;
 int	run_mode = 0;		/* foreground logging mode */
 
-/* LH - I had these local to main, but it seemed silly to have 
- * two copies of each - one in main(), one static in log.c... 
- * It also eliminates the 256-char static in log.c */
-char *name_p = NULL;
-char *version_p = NULL;
+static char *name_p = NULL;
+static char *version_p = NULL;
 
 /* PRC: a high-availability callout program can be specified with -H
  * When this is done, the program will receive callouts whenever clients
@@ -101,17 +99,16 @@ sm_prog_1_wrapper (struct svc_req *rqstp
 static void 
 killer (int sig)
 {
-	note (N_FATAL, "Caught signal %d, un-registering and exiting.", sig);
 	if (!(run_mode & MODE_NOTIFY_ONLY))
 		pmap_unset (SM_PROG, SM_VERS);
 
-	exit (0);
+	xlog (L_FATAL, "Caught signal %d, un-registering and exiting", sig);
 }
 
 static void
 sigusr (int sig)
 {
-	dprintf (N_DEBUG, "Caught signal %d, re-notifying (state %d).", sig,
+	xlog (D_GENERAL, "Caught signal %d, re-notifying (state %d)", sig,
 								MY_STATE);
 	re_notify = 1;
 }
@@ -137,11 +134,11 @@ static void log_modes(void)
 	{
 		strcat(buf,"Notify-Only ");
 	}
-	note(N_WARNING,buf);
+	xlog(L_WARNING,buf);
 	/* future: IP aliasing
 	if (run_mode & MODE_NOTIFY_ONLY)
 	{
-		dprintf(N_DEBUG,"Notify IP: %s",svr_addr);
+		xlog(D_GENERAL,"Notify IP: %s",svr_addr);
 	} */
 }
 
@@ -152,17 +149,19 @@ static void log_modes(void)
 static void 
 usage()
 {
-	fprintf(stderr,"usage: %s [options]\n", name_p);
-	fprintf(stderr,"      -h, -?, --help       Print this help screen.\n");
-	fprintf(stderr,"      -F, --foreground     Foreground (no-daemon mode)\n");
-	fprintf(stderr,"      -d, --no-syslog      Verbose logging to stderr.  Foreground mode only.\n");
-	fprintf(stderr,"      -p, --port           Port to listen on\n");
-	fprintf(stderr,"      -o, --outgoing-port  Port for outgoing connections\n");
-	fprintf(stderr,"      -V, -v, --version    Display version information and exit.\n");
-	fprintf(stderr,"      -n, --name           Specify a local hostname.\n");
-	fprintf(stderr,"      -P                   State directory path.\n");
-	fprintf(stderr,"      -N                   Run in notify only mode.\n");
-	fprintf(stderr,"      -H                   Specify a high-availability callout program.\n");
+	fprintf(stderr,
+	"usage: %s [options]\n"
+	"      -h, -?, --help       Print this help screen\n"
+	"      -F, --foreground     Foreground (no-daemon mode)\n"
+	"      -d, --no-syslog      Verbose logging to stderr.  Foreground mode only\n"
+	"      -p, --port           Port to listen on\n"
+	"      -o, --outgoing-port  Port for outgoing connections\n"
+	"      -V, -v, --version    Display version information and exit\n"
+	"      -n, --name           Specify a local hostname\n"
+	"      -P                   State directory path\n"
+	"      -N                   Run in notify only mode\n"
+	"      -H                   Specify a high-availability callout program\n"
+	, name_p);
 }
 
 static const char *pidfile = "/var/run/rpc.statd.pid";
@@ -175,12 +174,12 @@ static void create_pidfile(void)
 	unlink(pidfile);
 	fp = fopen(pidfile, "w");
 	if (!fp)
-		die("Opening %s failed: %s\n",
+		xlog(L_ERROR, "Opening %s failed: %s",
 		    pidfile, strerror(errno));
 	fprintf(fp, "%d\n", getpid());
 	pidfd = dup(fileno(fp));
 	if (fclose(fp) < 0)
-		note(N_WARNING, "Flushing pid file failed.\n");
+		xlog(L_WARNING, "Flushing pid file failed");
 }
 
 static void truncate_pidfile(void)
@@ -198,7 +197,7 @@ static void drop_privs(void)
 		st.st_uid = 0;
 
 	if (st.st_uid == 0) {
-		note(N_WARNING, "statd running as root. chown %s to choose different user\n",
+		xlog(L_WARNING, "statd running as root. chown %s to choose different user",
 		    SM_DIR);
 		return;
 	}
@@ -211,8 +210,7 @@ static void drop_privs(void)
 	setgroups(0, NULL);
 	if (setgid(st.st_gid) == -1
 	    || setuid(st.st_uid) == -1) {
-		note(N_ERROR, "Fail to drop privileges");
-		exit(1);
+		xlog(L_ERROR, "Fail to drop privileges");
 	}
 }
 
@@ -344,6 +342,10 @@ int main (int argc, char **argv)
 						   daemon mode. */
 	}
 
+	if (run_mode & MODE_LOG_STDERR) {
+		xlog_config(D_ALL, 1);		/* turn dprintf on */
+	}
+
 	if (getrlimit (RLIMIT_NOFILE, &rlim) != 0)
 		fprintf(stderr, "%s: getrlimit (RLIMIT_NOFILE) failed: %s\n",
 				argv [0], strerror(errno));
@@ -410,10 +412,9 @@ int main (int argc, char **argv)
 
 	}
 
-	/* Child. */
-
-	log_init (name_p,version_p);
-
+	xlog_stderr(run_mode & MODE_LOG_STDERR);
+	xlog_open(name_p);
+	xlog(L_WARNING,"Version %s Starting",version_p);
 	log_modes();
 
 	signal (SIGHUP, killer);
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/statd.h nfs-utils-1.0.7.logging3/utils/statd/statd.h
--- nfs-utils-1.0.7.logging2/utils/statd/statd.h	Mon Sep  6 05:15:51 2004
+++ nfs-utils-1.0.7.logging3/utils/statd/statd.h	Fri Mar 11 17:16:53 2005
@@ -8,7 +8,6 @@
 #include "config.h"
 #include "sm_inter.h"
 #include "system.h"
-#include "log.h"
 
 /*
  * Paths and filenames.
@@ -78,12 +77,5 @@ extern int run_mode;
 /* LH - notify_only mode would be for notifying hosts on an IP alias
  * that just came back up, for ex, when failing over a HA service to
  * another host.... */
-
-/*
- * Program name and version pointers -- See statd.c for the reasoning
- * as to why they're global.
- */
-extern char *name_p;		/* program basename */
-extern char *version_p;		/* program version */
 
 extern int		re_notify; /* time to re-read notify list */
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/state.c nfs-utils-1.0.7.logging3/utils/statd/state.c
--- nfs-utils-1.0.7.logging2/utils/statd/state.c	Fri Aug 22 19:03:51 2003
+++ nfs-utils-1.0.7.logging3/utils/statd/state.c	Fri Mar 11 17:04:03 2005
@@ -14,6 +14,7 @@
 #include <string.h>
 #include <unistd.h>
 #include <sys/stat.h>
+#include "xlog.h"
 #include "statd.h"
 
 
@@ -28,43 +29,43 @@ change_state (void)
   extern short int restart;
   
   if ((fd = open (SM_STAT_PATH, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)) == -1)
-    die ("open (%s): %s", SM_STAT_PATH, strerror (errno));
+    xlog(L_FATAL, "open (%s): %s", SM_STAT_PATH, strerror (errno));
 
   if ((size = read (fd, &MY_STATE, sizeof MY_STATE)) == -1)
-    die ("read (%s): %s", SM_STAT_PATH, strerror (errno));
+    xlog(L_FATAL, "read (%s): %s", SM_STAT_PATH, strerror (errno));
 
   if (size != 0 && size != sizeof MY_STATE) {
-    note (N_ERROR, "Error in status file format...correcting.");
+    xlog (L_ERROR, "Error in status file format...correcting");
 
     if (close (fd) == -1)
-      die ("close (%s): %s", SM_STAT_PATH, strerror (errno));
+      xlog(L_FATAL, "close (%s): %s", SM_STAT_PATH, strerror (errno));
 
     if ((fd = creat (SM_STAT_PATH, S_IRUSR | S_IWUSR)) == -1)
-      die ("creat (%s): %s", SM_STAT_PATH, strerror (errno));
+      xlog(L_FATAL, "creat (%s): %s", SM_STAT_PATH, strerror (errno));
   }
-  note (N_DEBUG, "New state: %u", (++MY_STATE % 2) ? MY_STATE : ++MY_STATE);
+  xlog (D_GENERAL, "New state: %u", (++MY_STATE % 2) ? MY_STATE : ++MY_STATE);
 
   if (lseek (fd, 0, SEEK_SET) == -1)
-    die ("lseek (%s): %s", SM_STAT_PATH, strerror (errno));
+    xlog(L_FATAL, "lseek (%s): %s", SM_STAT_PATH, strerror (errno));
 
   if (write (fd, &MY_STATE, sizeof MY_STATE) != sizeof MY_STATE)
-    die ("write (%s): %s", SM_STAT_PATH, strerror (errno));
+    xlog(L_FATAL, "write (%s): %s", SM_STAT_PATH, strerror (errno));
 
   if (fsync (fd) == -1)
-    note (N_ERROR, "fsync (%s): %s", SM_STAT_PATH, strerror (errno));
+    xlog (L_ERROR, "fsync (%s): %s", SM_STAT_PATH, strerror (errno));
 
   if (close (fd) == -1)
-    note (N_ERROR, "close (%s): %s", SM_STAT_PATH, strerror (errno));
+    xlog (L_ERROR, "close (%s): %s", SM_STAT_PATH, strerror (errno));
 
   if (MY_NAME == NULL) {
     char fullhost[SM_MAXSTRLEN + 1];
     struct hostent *hostinfo;
 
     if (gethostname (fullhost, SM_MAXSTRLEN) == -1)
-      die ("gethostname: %s", strerror (errno));
+      xlog(L_FATAL, "gethostname: %s", strerror (errno));
 
     if ((hostinfo = gethostbyname (fullhost)) == NULL)
-      note (N_ERROR, "gethostbyname error for %s", fullhost);
+      xlog (L_ERROR, "gethostbyname error for %s", fullhost);
     else {
       strncpy (fullhost, hostinfo->h_name, sizeof (fullhost) - 1);
       fullhost[sizeof (fullhost) - 1] = '\0';
@@ -88,23 +89,23 @@ shuffle_dirs (void)
   int len1, len2, len;
   
   if (stat (SM_DIR, &st) == -1 && errno != ENOENT)
-    die ("stat (%s): %s", SM_DIR, strerror (errno));
+    xlog(L_FATAL, "stat (%s): %s", SM_DIR, strerror (errno));
 
   if (!S_ISDIR (st.st_mode))
     if (mkdir (SM_DIR, S_IRWXU) == -1)
-      die ("mkdir (%s): %s", SM_DIR, strerror (errno));
+      xlog(L_FATAL, "mkdir (%s): %s", SM_DIR, strerror (errno));
 
   memset (&st, 0, sizeof st);
 
   if (stat (SM_BAK_DIR, &st) == -1 && errno != ENOENT)
-    die ("stat (%s): %s", SM_BAK_DIR, strerror (errno));
+    xlog(L_FATAL, "stat (%s): %s", SM_BAK_DIR, strerror (errno));
 
   if (!S_ISDIR (st.st_mode))
     if (mkdir (SM_BAK_DIR, S_IRWXU) == -1)
-      die ("mkdir (%s): %s", SM_BAK_DIR, strerror (errno));
+      xlog(L_FATAL, "mkdir (%s): %s", SM_BAK_DIR, strerror (errno));
 
   if (!(nld = opendir (SM_DIR)))
-    die ("opendir (%s): %s", SM_DIR, strerror (errno));
+    xlog(L_FATAL, "opendir (%s): %s", SM_DIR, strerror (errno));
 
   len1=strlen(SM_DIR);
   len2=strlen(SM_BAK_DIR);
@@ -117,10 +118,10 @@ shuffle_dirs (void)
     sprintf (src, "%s/%s", SM_DIR, de->d_name);
     sprintf (dst, "%s/%s", SM_BAK_DIR, de->d_name);
     if (rename (src, dst) == -1)
-      die ("rename (%s to %s): %s", SM_DIR, SM_BAK_DIR, strerror (errno));
+      xlog(L_FATAL, "rename (%s to %s): %s", SM_DIR, SM_BAK_DIR, strerror (errno));
     free(src);
     free(dst);
   }
   if (closedir (nld) == -1)
-    note (N_ERROR, "closedir (%s): %s", SM_DIR, strerror (errno));
+    xlog (L_ERROR, "closedir (%s): %s", SM_DIR, strerror (errno));
 }
diff -urpN nfs-utils-1.0.7.logging2/utils/statd/svc_run.c nfs-utils-1.0.7.logging3/utils/statd/svc_run.c
--- nfs-utils-1.0.7.logging2/utils/statd/svc_run.c	Mon Dec  6 03:25:28 2004
+++ nfs-utils-1.0.7.logging3/utils/statd/svc_run.c	Fri Mar 11 17:04:03 2005
@@ -50,6 +50,7 @@
 #include "config.h"
 #include <errno.h>
 #include <time.h>
+#include "xlog.h"
 #include "statd.h"
 #include "notlist.h"
 
@@ -89,7 +90,7 @@ my_svc_run(void)
 			return;
 		if (re_notify) {
 			change_state();
-			dprintf(N_DEBUG, "Notifying...(new state %d)",
+			xlog(D_GENERAL, "Notifying...(new state %d)",
 								MY_STATE);
 			notify_hosts();
 			re_notify = 0;
@@ -106,14 +107,14 @@ my_svc_run(void)
 
 			tv.tv_sec  = NL_WHEN(notify) - now;
 			tv.tv_usec = 0;
-			dprintf(N_DEBUG, "Waiting for reply... (timeo %d)",
+			xlog(D_GENERAL, "Waiting for reply... (timeo %d)",
 							tv.tv_sec);
 			selret = select(FD_SETSIZE, &readfds,
 				(void *) 0, (void *) 0, &tv);
 		} else if (run_mode & MODE_NOTIFY_ONLY)
 			return;
 		else {
-			dprintf(N_DEBUG, "Waiting for client connections.");
+			xlog(D_GENERAL, "Waiting for client connections");
 			selret = select(FD_SETSIZE, &readfds,
 				(void *) 0, (void *) 0, (struct timeval *) 0);
 		}
@@ -123,7 +124,7 @@ my_svc_run(void)
 			if (errno == EINTR || errno == ECONNREFUSED
 			 || errno == ENETUNREACH || errno == EHOSTUNREACH)
 				continue;
-			note(N_ERROR, "my_svc_run() - select: %m");
+			xlog(L_ERROR, "my_svc_run() - select: %s", strerror(errno));
 			return;
 
 		case 0:

--Boundary-00=_y8ZNCIxyAN/3i4C--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
