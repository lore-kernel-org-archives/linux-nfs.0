From: Paul Clements <paul.clements@steeleye.com>
Subject: [PATCH / RFC] nfs-utils: High Availability NFS
Date: Thu, 26 Aug 2004 13:21:20 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412E1C10.5020703@steeleye.com>
References: <4124DB86.9060505@steeleye.com> <16677.22269.988036.787320@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080307000007030404070009"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0NwN-0008VZ-VF
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 10:21:35 -0700
Received: from stat16.steeleye.com ([209.192.50.48] helo=fenric.sc.steeleye.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C0NwK-0004P1-Eg
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 10:21:35 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
In-Reply-To: <16677.22269.988036.787320@cse.unsw.edu.au>
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
--------------080307000007030404070009
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi all,

I've recently coded up some modifications to nfs-utils that will
allow the tools to be used in a High Availability NFS environment
(i.e., capable of switching and failing over NFS exports from
one server to another, while still preserving client connections
and file locks). The modifications are in the form of callout
hooks in statd and mountd. Any HA NFS implementation may take
advantage of these hooks since the actual content of the callout
programs will not be dictated by nfs-utils, but rather will be
left up to the HA cluster software implementor. Currently, the
callout hooks in statd and mountd look like:

statd and mountd -- new command line option:
-------------------------------------------
-H command line option to specify an HA callout program (without -H
no callouts are made) -- the callout program can be any executable
or script

statd events that trigger a callout:
-----------------------------------
add client to notify list (SM_MON) - triggers "add-client" callout

delete client from notify list (SM_UNMON and SM_UNMONALL) - triggers 
"del-client" callout

statd events that trigger re-read of the notify list:
----------------------------------------------------
SIGUSR1 sent to statd - triggers re-read of notify list from disk
(notify_hosts()) -- this will be done when one server takes over
(e.g., on failover or switchover) an NFS export from another server

mountd events that trigger a callout:
------------------------------------
client mount request - triggers "mount" callout

client unmount request - triggers "unmount" callout


These callouts will simply result in the HA callout program being
called with the following command line arguments:

<ha_callout_prog> [mount|unmount|add-client|del-client] <client> 
<server> <count>

Note that the mountd hook is not needed when running on the 2.6
kernel. The 2.6 kernel has a mechanism (which is more reliable
than using the rmtab file) that it uses to authenticate
unknown clients.

The patch (against nfs-utils-1.0.6) is pretty unobtrusive, adding a 
little less than 100 lines.

Comments? Questions?

Thanks,
Paul

--------------080307000007030404070009
Content-Type: text/plain;
 name="nfs_utils_ha_callout.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs_utils_ha_callout.diff"

diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/support/include/ha-callout.h nfs-utils-1.0.6/support/include/ha-callout.h
--- nfs-utils-1.0.6-PRISTINE/support/include/ha-callout.h	1969-12-31 19:00:00.000000000 -0500
+++ nfs-utils-1.0.6/support/include/ha-callout.h	2004-08-26 10:37:53.000000000 -0400
@@ -0,0 +1,38 @@
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
+extern char *ha_callout_prog;
+
+static inline void
+ha_callout(char *event, char *arg1, char *arg2, int arg3)
+{
+	char buf[PATH_MAX]; /* should be plenty */
+	int ret;
+
+	if (!ha_callout_prog) /* HA callout is not enabled */
+		return;
+
+	sprintf(buf, "%s \"%s\" \"%s\" \"%s\" %.8x", ha_callout_prog,
+		event, arg1, arg2, arg3);
+	ret = system(buf);
+
+#ifdef dprintf
+	dprintf(N_DEBUG, "system call %s returned %d\n", buf, WEXITSTATUS(ret));
+#else
+	xlog(D_GENERAL, "system call %s returned %d\n", buf, WEXITSTATUS(ret));
+#endif
+}
+
+#endif
diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/utils/mountd/mountd.c nfs-utils-1.0.6/utils/mountd/mountd.c
--- nfs-utils-1.0.6-PRISTINE/utils/mountd/mountd.c	2004-08-17 11:01:14.000000000 -0400
+++ nfs-utils-1.0.6/utils/mountd/mountd.c	2004-08-26 10:40:25.000000000 -0400
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
diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/utils/mountd/rmtab.c nfs-utils-1.0.6/utils/mountd/rmtab.c
--- nfs-utils-1.0.6-PRISTINE/utils/mountd/rmtab.c	2003-07-31 01:19:26.000000000 -0400
+++ nfs-utils-1.0.6/utils/mountd/rmtab.c	2004-08-25 15:21:53.000000000 -0400
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
Binary files nfs-utils-1.0.6-PRISTINE/utils/nfsd/nfsd and nfs-utils-1.0.6/utils/nfsd/nfsd differ
Binary files nfs-utils-1.0.6-PRISTINE/utils/nfsstat/nfsstat and nfs-utils-1.0.6/utils/nfsstat/nfsstat differ
diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/utils/statd/monitor.c nfs-utils-1.0.6/utils/statd/monitor.c
--- nfs-utils-1.0.6-PRISTINE/utils/statd/monitor.c	2004-08-17 11:01:14.000000000 -0400
+++ nfs-utils-1.0.6/utils/statd/monitor.c	2004-08-26 09:40:10.000000000 -0400
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
 			/* Do not unlink the monitor file. There are
 			 * cases when a lock is cleared locally on the
@@ -287,6 +294,8 @@ sm_unmon_all_1_svc(struct my_id *argp, s
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
+++ nfs-utils-1.0.6/utils/statd/rmtcall.c	2004-08-25 14:54:00.000000000 -0400
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
+			ha_callout("del-client", NL_MY_NAME(entry), NL_MON_NAME(entry), 0);
 			xunlink(SM_BAK_DIR, NL_MON_NAME(entry), 0);
 			nlist_free(&notify, entry);
 		}
diff -purN --exclude-from /export/public/clemep/tmp/dontdiff nfs-utils-1.0.6-PRISTINE/utils/statd/statd.c nfs-utils-1.0.6/utils/statd/statd.c
--- nfs-utils-1.0.6-PRISTINE/utils/statd/statd.c	2003-09-12 02:24:29.000000000 -0400
+++ nfs-utils-1.0.6/utils/statd/statd.c	2004-08-25 13:29:08.000000000 -0400
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
 

--------------080307000007030404070009--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
