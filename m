From: Paul Clements <paul.clements@steeleye.com>
Subject: Re: Re: [PATCH / RFC] nfs-utils: High Availability NFS
Date: Tue, 31 Aug 2004 12:26:21 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4134A6AD.1060502@steeleye.com>
References: <4124DB86.9060505@steeleye.com>	<16677.22269.988036.787320@cse.unsw.edu.au>	<412E1C10.5020703@steeleye.com> <16692.8187.411591.69640@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080902000608000801090500"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C2BSu-0000bS-4A
	for nfs@lists.sourceforge.net; Tue, 31 Aug 2004 09:26:36 -0700
Received: from stat16.steeleye.com ([209.192.50.48] helo=fenric.sc.steeleye.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C2BSs-0000l8-V1
	for nfs@lists.sourceforge.net; Tue, 31 Aug 2004 09:26:35 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16692.8187.411591.69640@cse.unsw.edu.au>
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

This is a multi-part message in MIME format.
--------------080902000608000801090500
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Thursday August 26, paul.clements@steeleye.com wrote:

> I'm mostly happy with this patch.
> I'd like to ask for two changes before it gets committed.
> 
> First - update the relevant man pages to explain -H and SIGUSR1
> usage. 

OK, I've added sections to the mountd and statd man pages.

> Second, I have a pathological aversion to "system(3)" for this sort
> of task.  I start worrying about stray quotes and other magic
> characters.
> I would much prefer something like:
> 
>   sprintf(buf, "%.8x" args3)
>   switch(pid=fork()) {
> 	case 0: execl(ha_callout_prog,"callout",arg1,arg2,buf,NULL);
> 		exit(1);
> 	case -1: perror(PROGNAME ": fork"); break;
> 	default: waitpid(pid, NULL, 0);
>   }

OK, I've changed this.

> Also, I would really prefer the count was passed in decimal (%d) - it
> is more traditional.  If hex is needed, the program can convert it.
> (why it is hex in "rmtab" I really don't know)....

OK, I pass it in decimal now.

New patch attached.

--
Paul

--------------080902000608000801090500
Content-Type: text/plain;
 name="nfs_utils_ha_callout-3.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs_utils_ha_callout-3.diff"

diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/support/include/ha-callout.h nfs-utils-1.0.6/support/include/ha-callout.h
--- nfs-utils-1.0.6-PRISTINE/support/include/ha-callout.h	1969-12-31 19:00:00.000000000 -0500
+++ nfs-utils-1.0.6/support/include/ha-callout.h	2004-08-31 10:31:18.000000000 -0400
@@ -0,0 +1,49 @@
+/*
+ * support/include/ha-callout.h
+ *
+ * High Availability NFS Callout support routines
+ *
+ * Copyright (c) 2004, Paul Clements, SteelEye Technology
+ *
+ * In order to implement HA NFS, we need several callouts at key
+ * points in statd and mountd. These callouts all come to ha_callout(),
+ * which, in turn, calls out to an ha-callout script (not part of nfs-utils;
+ * defined by -H argument to rpc.statd and rpc.mountd).
+ */
+#ifndef HA_CALLOUT_H
+#define HA_CALLOUT_H
+
+#include <sys/wait.h>
+
+extern char *ha_callout_prog;
+
+static inline void
+ha_callout(char *event, char *arg1, char *arg2, int arg3)
+{
+	char buf[16]; /* should be plenty */
+	pid_t pid;
+	int ret = -1;
+
+	if (!ha_callout_prog) /* HA callout is not enabled */
+		return;
+
+	sprintf(buf, "%d", arg3);
+
+	pid = fork();
+	switch (pid) {
+		case 0: execl(ha_callout_prog, event, arg1, arg2, buf, NULL);
+			perror("execl");
+			exit(2);
+		case -1: perror("fork");
+			break;
+		default: ret = waitpid(pid, NULL, 0);
+  	}
+
+#ifdef dprintf
+	dprintf(N_DEBUG, "ha callout returned %d\n", WEXITSTATUS(ret));
+#else
+	xlog(D_GENERAL, "ha callout returned %d\n", WEXITSTATUS(ret));
+#endif
+}
+
+#endif
diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/utils/mountd/mountd.c nfs-utils-1.0.6/utils/mountd/mountd.c
--- nfs-utils-1.0.6-PRISTINE/utils/mountd/mountd.c	2003-09-12 18:14:16.000000000 -0400
+++ nfs-utils-1.0.6/utils/mountd/mountd.c	2004-08-31 10:31:02.000000000 -0400
@@ -36,6 +36,11 @@ static struct nfs_fh_len *get_rootfh(str
 
 int new_cache = 0;
 
+/* PRC: a high-availability callout program can be specified with -H
+ * When this is done, the program will receive callouts whenever clients
+ * send mount or unmount requests -- the callout is not needed for 2.6 kernel */
+char *ha_callout_prog = NULL;
+
 static struct option longopts[] =
 {
 	{ "foreground", 0, 0, 'F' },
@@ -48,6 +53,7 @@ static struct option longopts[] =
 	{ "version", 0, 0, 'v' },
 	{ "port", 1, 0, 'p' },
 	{ "no-tcp", 0, 0, 'n' },
+	{ "ha-callout", 1, 0, 'H' },
 	{ NULL, 0, 0, 0 }
 };
 
@@ -444,7 +450,7 @@ main(int argc, char **argv)
 
 	/* Parse the command line options and arguments. */
 	opterr = 0;
-	while ((c = getopt_long(argc, argv, "o:n:Fd:f:p:P:hN:V:v", longopts, NULL)) != EOF)
+	while ((c = getopt_long(argc, argv, "o:n:Fd:f:p:P:hH:N:V:v", longopts, NULL)) != EOF)
 		switch (c) {
 		case 'o':
 			descriptors = atoi(optarg);
@@ -463,6 +469,9 @@ main(int argc, char **argv)
 		case 'f':
 			export_file = optarg;
 			break;
+		case 'H': /* PRC: specify a high-availability callout program */
+			ha_callout_prog = optarg;
+			break;
 		case 'h':
 			usage(argv [0], 0);
 			break;
@@ -596,6 +605,7 @@ usage(const char *prog, int n)
 "Usage: %s [-F|--foreground] [-h|--help] [-v|--version] [-d kind|--debug kind]\n"
 "	[-o num|--descriptors num] [-f exports-file|--exports-file=file]\n"
 "	[-p|--port port] [-V version|--nfs-version version]\n"
-"	[-N version|--no-nfs-version version] [-n|--no-tcp]\n", prog);
+"	[-N version|--no-nfs-version version] [-n|--no-tcp]\n"
+"	[-H ha-callout-prog]\n", prog);
 	exit(n);
 }
diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/utils/mountd/mountd.man nfs-utils-1.0.6/utils/mountd/mountd.man
--- nfs-utils-1.0.6-PRISTINE/utils/mountd/mountd.man	2003-07-17 19:17:28.000000000 -0400
+++ nfs-utils-1.0.6/utils/mountd/mountd.man	2004-08-31 10:31:02.000000000 -0400
@@ -2,7 +2,8 @@
 .\" mountd(8)
 .\"
 .\" Copyright (C) 1999 Olaf Kirch <okir@monad.swb.de>
-.TH rpc.mountd 8 "25 Aug 2000"
+.\" Modified by Paul Clements, 2004.
+.TH rpc.mountd 8 "31 Aug 2004"
 .SH NAME
 rpc.mountd \- NFS mount daemon
 .SH SYNOPSIS
@@ -99,6 +100,16 @@ Force
 to bind to the specified port num, instead of using the random port
 number assigned by the portmapper.
 .TP
+.B \-H " or " \-\-ha-callout prog
+Specify a high availability callout program, which will receive callouts
+for all client mount and unmount requests. This allows 
+.B rpc.mountd
+to be used in a High Availability NFS (HA-NFS) environment. This callout is not
+needed (and should not be used) with 2.6 and later kernels (instead,
+mount the nfsd filesystem on
+.B /proc/fs/nfsd
+).
+.TP
 .B \-V " or " \-\-nfs-version
 This option can be used to request that
 .B rpc.mountd
diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/utils/mountd/rmtab.c nfs-utils-1.0.6/utils/mountd/rmtab.c
--- nfs-utils-1.0.6-PRISTINE/utils/mountd/rmtab.c	2003-07-31 01:19:26.000000000 -0400
+++ nfs-utils-1.0.6/utils/mountd/rmtab.c	2004-08-31 10:31:02.000000000 -0400
@@ -19,6 +19,7 @@
 #include "exportfs.h"
 #include "xio.h"
 #include "mountd.h"
+#include "ha-callout.h"
 
 #include <limits.h> /* PATH_MAX */
 
@@ -61,6 +62,8 @@ mountlist_add(char *host, const char *pa
 			    host) == 0
 		    && strcmp(rep->r_path, path) == 0) {
 			rep->r_count++;
+			/* PRC: do the HA callout: */
+			ha_callout("mount", rep->r_client, rep->r_path, rep->r_count);
 			putrmtabent(rep, &pos);
 			endrmtabent();
 			xfunlock(lockid);
@@ -75,6 +78,8 @@ mountlist_add(char *host, const char *pa
 	xe.r_path [sizeof (xe.r_path) - 1] = '\0';
 	xe.r_count = 1;
 	if (setrmtabent("a")) {
+		/* PRC: do the HA callout: */
+		ha_callout("mount", xe.r_client, xe.r_path, xe.r_count);
 		putrmtabent(&xe, NULL);
 		endrmtabent();
 	}
@@ -103,8 +108,11 @@ mountlist_del(char *hname, const char *p
 	while ((rep = getrmtabent(1, NULL)) != NULL) {
 		match = !strcmp (rep->r_client, hname)
 			&& !strcmp(rep->r_path, path);
-		if (match)
+		if (match) {
 			rep->r_count--;
+			/* PRC: do the HA callout: */
+			ha_callout("umount", rep->r_client, rep->r_path, rep->r_count);
+		}
 		if (!match || rep->r_count)
 			fputrmtabent(fp, rep, NULL);
 	}
diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/utils/statd/monitor.c nfs-utils-1.0.6/utils/statd/monitor.c
--- nfs-utils-1.0.6-PRISTINE/utils/statd/monitor.c	2003-09-12 01:41:35.000000000 -0400
+++ nfs-utils-1.0.6/utils/statd/monitor.c	2004-08-31 10:31:02.000000000 -0400
@@ -19,6 +19,7 @@
 #include "misc.h"
 #include "statd.h"
 #include "notlist.h"
+#include "ha-callout.h"
 
 notify_list *		rtnl = NULL;	/* Run-time notify list. */
 
@@ -177,6 +178,8 @@ sm_mon_1_svc(struct mon *argp, struct sv
 		goto failure;
 	}
 	free(path);
+	/* PRC: do the HA callout: */
+	ha_callout("add-client", mon_name, my_name, 0);
 	nlist_insert(&rtnl, clnt);
 	close(fd);
 
@@ -232,6 +235,10 @@ sm_unmon_1_svc(struct mon_id *argp, stru
 			/* Match! */
 			dprintf(N_DEBUG, "UNMONITORING %s for %s",
 					mon_name, my_name);
+
+			/* PRC: do the HA callout: */
+			ha_callout("del-client", mon_name, my_name, 0);
+
 			nlist_free(&rtnl, clnt);
 			xunlink(SM_DIR, mon_name, 1);
 
@@ -276,6 +283,8 @@ sm_unmon_all_1_svc(struct my_id *argp, s
 				sizeof (mon_name) - 1);
 			mon_name[sizeof (mon_name) - 1] = '\0';
 			temp = NL_NEXT(clnt);
+			/* PRC: do the HA callout: */
+			ha_callout("del-client", mon_name, argp->my_name, 0);
 			nlist_free(&rtnl, clnt);
 			xunlink(SM_DIR, mon_name, 1);
 			++count;
diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/utils/statd/rmtcall.c nfs-utils-1.0.6/utils/statd/rmtcall.c
--- nfs-utils-1.0.6-PRISTINE/utils/statd/rmtcall.c	2003-09-12 01:41:38.000000000 -0400
+++ nfs-utils-1.0.6/utils/statd/rmtcall.c	2004-08-31 10:31:02.000000000 -0400
@@ -38,6 +38,7 @@
 #include "statd.h"
 #include "notlist.h"
 #include "log.h"
+#include "ha-callout.h"
 
 #define MAXMSGSIZE	(2048 / sizeof(unsigned int))
 
@@ -414,6 +415,8 @@ process_notify_list(void)
 			note(N_ERROR,
 				"Can't notify %s, giving up.",
 					NL_MON_NAME(entry));
+			/* PRC: do the HA callout */
+			ha_callout("del-client", NL_MON_NAME(entry), NL_MY_NAME(entry), 0);
 			xunlink(SM_BAK_DIR, NL_MON_NAME(entry), 0);
 			nlist_free(&notify, entry);
 		}
diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/utils/statd/statd.c nfs-utils-1.0.6/utils/statd/statd.c
--- nfs-utils-1.0.6-PRISTINE/utils/statd/statd.c	2003-09-12 02:24:29.000000000 -0400
+++ nfs-utils-1.0.6/utils/statd/statd.c	2004-08-31 10:31:02.000000000 -0400
@@ -48,6 +48,11 @@ int	run_mode = 0;		/* foreground logging
 char *name_p = NULL;
 char *version_p = NULL;
 
+/* PRC: a high-availability callout program can be specified with -H
+ * When this is done, the program will receive callouts whenever clients
+ * are added or deleted to the notify list */
+char *ha_callout_prog = NULL;
+
 static struct option longopts[] =
 {
 	{ "foreground", 0, 0, 'F' },
@@ -59,6 +64,7 @@ static struct option longopts[] =
 	{ "name", 1, 0, 'n' },
 	{ "state-directory-path", 1, 0, 'P' },
 	{ "notify-mode", 0, 0, 'N' },
+	{ "ha-callout", 1, 0, 'H' },
 	{ NULL, 0, 0, 0 }
 };
 
@@ -102,6 +108,13 @@ killer (int sig)
 	exit (0);
 }
 
+static void
+sigusr (int sig)
+{
+	dprintf (N_DEBUG, "Caught signal %d, re-reading notify list.", sig);
+	notify_hosts();
+}
+
 /*
  * Startup information.
  */
@@ -148,6 +161,7 @@ usage()
 	fprintf(stderr,"      -n, --name           Specify a local hostname.\n");
 	fprintf(stderr,"      -P                   State directory path.\n");
 	fprintf(stderr,"      -N                   Run in notify only mode.\n");
+	fprintf(stderr,"      -H                   Specify a high-availability callout program.\n");
 }
 
 static const char *pidfile = "/var/run/rpc.statd.pid";
@@ -236,7 +250,7 @@ int main (int argc, char **argv)
 	MY_NAME = NULL;
 
 	/* Process command line switches */
-	while ((arg = getopt_long(argc, argv, "h?vVFNdn:p:o:P:", longopts, NULL)) != EOF) {
+	while ((arg = getopt_long(argc, argv, "h?vVFNH:dn:p:o:P:", longopts, NULL)) != EOF) {
 		switch (arg) {
 		case 'V':	/* Version */
 		case 'v':
@@ -302,6 +316,13 @@ int main (int argc, char **argv)
 				sprintf(SM_STAT_PATH, "%s/state", DIR_BASE );
 			}
 			break;
+		case 'H': /* PRC: specify the ha-callout program */
+			if ((ha_callout_prog = xstrdup(optarg)) == NULL) {
+				fprintf(stderr, "%s: xstrdup(%s) failed!\n",
+					argv[0], optarg);
+				exit(1);
+			}
+			break;
 		case '?':	/* heeeeeelllllllpppp? heh */
 		case 'h':
 			usage();
@@ -397,6 +418,8 @@ int main (int argc, char **argv)
 	signal (SIGHUP, killer);
 	signal (SIGINT, killer);
 	signal (SIGTERM, killer);
+	/* PRC: trap SIGUSR1 to re-read notify list from disk */
+	signal(SIGUSR1, sigusr);
 	/* WARNING: the following works on Linux and SysV, but not BSD! */
 	signal(SIGCHLD, SIG_IGN);
 
diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/utils/statd/statd.man nfs-utils-1.0.6/utils/statd/statd.man
--- nfs-utils-1.0.6-PRISTINE/utils/statd/statd.man	2002-09-16 15:23:03.000000000 -0400
+++ nfs-utils-1.0.6/utils/statd/statd.man	2004-08-31 10:31:02.000000000 -0400
@@ -4,11 +4,12 @@
 .\" Copyright (C) 1999 Olaf Kirch <okir@monad.swb.de>
 .\" Modified by Jeffrey A. Uphoff, 1999, 2002.
 .\" Modified by Lon Hohberger, 2000.
-.TH rpc.statd 8 "16 Sep 2002"
+.\" Modified by Paul Clements, 2004.
+.TH rpc.statd 8 "31 Aug 2004"
 .SH NAME
 rpc.statd \- NSM status monitor
 .SH SYNOPSIS
-.B "/sbin/rpc.statd [-F] [-d] [-?] [-n " name "] [-o " port "] [-p " port "] [-V]"
+.B "/sbin/rpc.statd [-F] [-d] [-?] [-n " name "] [-o " port "] [-p " port "] [-H " prog "] [-V]"
 .SH DESCRIPTION
 The
 .B rpc.statd
@@ -101,6 +102,12 @@ statd program will check its state direc
 monitored nodes, and exit once the notifications have been sent. This mode is
 used to enable Highly Available NFS implementations (i.e. HA-NFS).
 .TP
+.BI "\-H, " "" " \-\-ha-callout " prog
+Specify a high availability callout program, which will receive callouts
+for all client monitor and unmonitor requests. This allows
+.B rpc.statd
+to be used in a High Availability NFS (HA-NFS) environment.
+.TP
 .B -?
 Causes
 .B rpc.statd
@@ -135,6 +142,15 @@ and
 .BR hosts_access (5)
 manual pages.
 
+.SH SIGNALS
+.BR SIGUSR1
+causes
+.B rpc.statd
+to re-read the notify list from disk
+and send notifications to clients. This can be used in High Availability NFS
+(HA-NFS) environments to notify clients to reacquire file locks upon takeover
+of an NFS export from another server.
+
 .SH FILES
 .BR /var/lib/nfs/state
 .br
@@ -153,3 +169,5 @@ Olaf Kirch <okir@monad.swb.de>
 H.J. Lu <hjl@gnu.org>
 .br
 Lon Hohberger <hohberger@missioncriticallinux.com>
+.br
+Paul Clements <paul.clements@steeleye.com>

--------------080902000608000801090500--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
