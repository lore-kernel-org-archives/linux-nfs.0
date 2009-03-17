From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: [PATCH 1/2] nfsstat: Print diff stats every N seconds
Date: Tue, 17 Mar 2009 00:46:28 -0700
Message-ID: <1237275989-16421-1-git-send-email-kevin.constantine@disneyanimation.com>
References: <49BF2478.8080600@sgi.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: gnb@sgi.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:1313 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754628AbZCQHqc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Mar 2009 03:46:32 -0400
In-Reply-To: <49BF2478.8080600@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsstat.c: Implements an optional "interval" argument to --sleep
nfsstat.man: Explains the use of --sleep[interval]

Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
---
 utils/nfsstat/nfsstat.c   |  107 ++++++++++++++++++++++++++++++++++-----------
 utils/nfsstat/nfsstat.man |    6 ++-
 2 files changed, 86 insertions(+), 27 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 1517414..a447cf9 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -167,6 +167,9 @@ DECLARE_SRV(srvinfo, _old);
 DECLARE_CLT(cltinfo);
 DECLARE_CLT(cltinfo, _old);
 
+static void		print_all_stats(int, int, int);
+static void		print_server_stats(int, int);
+static void		print_client_stats(int, int);
 static void		print_numbers(const char *, unsigned int *,
 					unsigned int);
 static void		print_callstats(const char *, const char **,
@@ -183,6 +186,7 @@ static void		get_stats(const char *, struct statinfo *, int *, int,
 static int		has_stats(const unsigned int *);
 static void 		diff_stats(struct statinfo *, struct statinfo *, int);
 static void 		unpause(int);
+static void 		update_old_counters(struct statinfo *, struct statinfo *);
 
 static time_t		starttime;
 
@@ -207,26 +211,29 @@ void usage(char *name)
 {
 	printf("Usage: %s [OPTION]...\n\
 \n\
-  -m, --mounts\t\tShow statistics on mounted NFS filesystems\n\
-  -c, --client\t\tShow NFS client statistics\n\
-  -s, --server\t\tShow NFS server statistics\n\
-  -2\t\t\tShow NFS version 2 statistics\n\
-  -3\t\t\tShow NFS version 3 statistics\n\
-  -4\t\t\tShow NFS version 4 statistics\n\
-  -o [facility]\t\tShow statistics on particular facilities.\n\
-     nfs\tNFS protocol information\n\
-     rpc\tGeneral RPC information\n\
-     net\tNetwork layer statistics\n\
-     fh\t\tUsage information on the server's file handle cache\n\
-     rc\t\tUsage information on the server's request reply cache\n\
-     all\tSelect all of the above\n\
-  -v, --verbose, --all\tSame as '-o all'\n\
-  -r, --rpc\t\tShow RPC statistics\n\
-  -n, --nfs\t\tShow NFS statistics\n\
-  -Z, --sleep\t\tSaves stats, pauses, diffs current and saved\n\
-  -S, --since file\tShows difference between current stats and those in 'file'\n\
-  --version\t\tShow program version\n\
-  --help\t\tWhat you just did\n\
+  -m, --mounts		Show statistics on mounted NFS filesystems\n\
+  -c, --client		Show NFS client statistics\n\
+  -s, --server		Show NFS server statistics\n\
+  -2			Show NFS version 2 statistics\n\
+  -3			Show NFS version 3 statistics\n\
+  -4			Show NFS version 4 statistics\n\
+  -o [facility]		Show statistics on particular facilities.\n\
+     nfs		NFS protocol information\n\
+     rpc		General RPC information\n\
+     net		Network layer statistics\n\
+     fh			Usage information on the server's file handle cache\n\
+     rc			Usage information on the server's request reply cache\n\
+     all		Select all of the above\n\
+  -v, --verbose, --all	Same as '-o all'\n\
+  -r, --rpc		Show RPC statistics\n\
+  -n, --nfs		Show NFS statistics\n\
+  -Z[#], --sleep[=#]	Collects stats until interrupted.\n\
+			    Cumulative stats are then printed\n\
+          		    If # is provided, stats will be output every\n\
+			    # seconds.\n\
+  -S, --since file	Shows difference between current stats and those in 'file'\n\
+  --version		Show program version\n\
+  --help		What you just did\n\
 \n", name);
 	exit(0);
 }
@@ -245,7 +252,7 @@ static struct option longopts[] =
 	{ "zero", 0, 0, 'z' },
 	{ "help", 0, 0, '\1' },
 	{ "version", 0, 0, '\2' },
-	{ "sleep", 0, 0, 'Z' },
+	{ "sleep", 2, 0, 'Z' },
 	{ "since", 1, 0, 'S' },
 	{ NULL, 0, 0, 0 }
 };
@@ -258,6 +265,7 @@ main(int argc, char **argv)
 			opt_clt = 0,
 			opt_prt = 0,
 			opt_sleep = 0,
+			sleep_time = 0,
 			opt_since = 0;
 	int		c;
 	char           *progname,
@@ -279,7 +287,7 @@ main(int argc, char **argv)
 	else
 		progname = argv[0];
 
-	while ((c = getopt_long(argc, argv, "234acmno:ZS:vrsz\1\2", longopts, NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "234acmno:Z::S:vrsz\1\2", longopts, NULL)) != EOF) {
 		switch (c) {
 		case 'a':
 			fprintf(stderr, "nfsstat: nfs acls are not yet supported.\n");
@@ -311,6 +319,9 @@ main(int argc, char **argv)
 			break;
 		case 'Z':
 			opt_sleep = 1;
+			if (optarg) {
+				sleep_time = atoi(optarg);
+			}
 			break;
 		case 'S':
 			opt_since = 1;
@@ -384,7 +395,7 @@ main(int argc, char **argv)
 	if (opt_clt)
 		get_stats(clientfile, clientinfo, &opt_clt, opt_srv, 0);
 
-	if (opt_sleep) {
+	if (opt_sleep && !sleep_time) {
 		starttime = time(NULL);
 		printf("Collecting statistics; press CTRL-C to view results from interval (i.e., from pause to CTRL-C).\n");
 		if (sigaction(SIGINT, &act, NULL) != 0) {
@@ -404,7 +415,40 @@ main(int argc, char **argv)
 			diff_stats(clientinfo_tmp, clientinfo, 0);
 		}
 	}
+	if(sleep_time) {
+		while(1) {
+			if (opt_srv) {
+				get_stats(NFSSRVSTAT, serverinfo_tmp , &opt_srv, opt_clt, 1);
+				diff_stats(serverinfo_tmp, serverinfo, 1);
+			}
+			if (opt_clt) {
+				get_stats(NFSCLTSTAT, clientinfo_tmp, &opt_clt, opt_srv, 0);
+				diff_stats(clientinfo_tmp, clientinfo, 0);
+			}
+			print_all_stats(opt_srv, opt_clt, opt_prt);
+			printf("\n\n");
+			fflush(stdout);
+
+			update_old_counters(clientinfo_tmp, clientinfo);
+			sleep(sleep_time);
+		}	
+	} else {
+		print_all_stats(opt_srv, opt_clt, opt_prt);
+	}
+
+	return 0;
+}
+
+static void
+print_all_stats (int opt_srv, int opt_clt, int opt_prt)
+{
+	print_server_stats(opt_srv, opt_prt);
+	print_client_stats(opt_clt, opt_prt);
+}
 
+static void 
+print_server_stats(int opt_srv, int opt_prt) 
+{
 	if (opt_srv) {
 		if (opt_prt & PRNT_NET) {
 			print_numbers(
@@ -479,7 +523,10 @@ main(int argc, char **argv)
 			}
 		}
 	}
-
+}
+static void
+print_client_stats(int opt_clt, int opt_prt) 
+{
 	if (opt_clt) {
 		if (opt_prt & PRNT_NET) {
 			print_numbers(
@@ -515,8 +562,6 @@ main(int argc, char **argv)
 				);
 		}
 	}
-
-	return 0;
 }
 
 static statinfo *
@@ -846,3 +891,13 @@ unpause(int sig)
 	seconds = (int)time_diff % 60;
 	printf("Signal received; displaying (only) statistics gathered over the last %d minutes, %d seconds:\n\n", minutes, seconds);
 }
+
+static void
+update_old_counters(struct statinfo *new, struct statinfo *old)
+{
+	int z, i;
+	for (z = 0; old[z].tag; z++) 
+		for (i = 0; i <= old[z].nrvals; i++) 
+			old[z].valptr[i] += new[z].valptr[i];
+
+}
diff --git a/utils/nfsstat/nfsstat.man b/utils/nfsstat/nfsstat.man
index cb5f89f..461b2c0 100644
--- a/utils/nfsstat/nfsstat.man
+++ b/utils/nfsstat/nfsstat.man
@@ -91,7 +91,7 @@ output
 .I file
 are treated as zeroes.
 .TP
-.B \-Z, \-\-sleep
+.B \-Z[interval], \-\-sleep=[interval]
 Instead of printing current statistics and immediately exiting,
 .B nfsstat
 takes a snapshot of the current statistics and pauses until it receives
@@ -100,6 +100,10 @@ takes a snapshot of the current statistics and pauses until it receives
 .BR Ctrl-C ),
 at which point it takes another snapshot and displays the difference
 between the two.
+If \fIinterval\fR is specified, 
+.B nfsstat
+will print the number of \fBNFS\fR calls made since the previous report.
+Stats will be printed repeatedly every \fIinterval\fR seconds.
 .\" --------------------- EXAMPLES -------------------------------
 .SH EXAMPLES
 .TP
-- 
1.6.0.4.761.g47577

