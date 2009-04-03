From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: [PATCH 2/2] nfsstat: Add --list flag
Date: Fri,  3 Apr 2009 12:06:32 -0700
Message-ID: <1238785592-18869-3-git-send-email-kevin.constantine@disneyanimation.com>
References: <1238785592-18869-1-git-send-email-kevin.constantine@disneyanimation.com>
 <1238785592-18869-2-git-send-email-kevin.constantine@disneyanimation.com>
Cc: linux-nfs@vger.kernel.org, Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org,
	Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:61918 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764811AbZDCTGj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 15:06:39 -0400
In-Reply-To: <1238785592-18869-2-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 nfsstat.c: Adds the --list flag to print information in a list format instead of the standard multi-column format
 nfsstat.man: Updates the manpage to include the --list flag.

Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
---
 utils/nfsstat/nfsstat.c   |   83 +++++++++++++++++++++++++++++++++++++++++++--
 utils/nfsstat/nfsstat.man |    3 ++
 2 files changed, 83 insertions(+), 3 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 453d345..28385b8 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -170,10 +170,13 @@ DECLARE_CLT(cltinfo, _old);
 static void		print_all_stats(int, int, int);
 static void		print_server_stats(int, int);
 static void		print_client_stats(int, int);
+static void		print_stats_list(int);
 static void		print_numbers(const char *, unsigned int *,
 					unsigned int);
 static void		print_callstats(const char *, const char **,
 					unsigned int *, unsigned int);
+static void		print_callstats_list(const char *, const char **,
+					unsigned int *, unsigned int);
 static int		parse_raw_statfile(const char *, struct statinfo *);
 static int 		parse_pretty_statfile(const char *, struct statinfo *);
 
@@ -232,6 +235,7 @@ void usage(char *name)
           		    If # is provided, stats will be output every\n\
 			    # seconds.\n\
   -S, --since file	Shows difference between current stats and those in 'file'\n\
+  -l, --list		Prints stats in list format\n\
   --version		Show program version\n\
   --help		What you just did\n\
 \n", name);
@@ -254,6 +258,7 @@ static struct option longopts[] =
 	{ "version", 0, 0, '\2' },
 	{ "sleep", 2, 0, 'Z' },
 	{ "since", 1, 0, 'S' },
+	{ "list", 0, 0, 'l' },
 	{ NULL, 0, 0, 0 }
 };
 
@@ -266,6 +271,7 @@ main(int argc, char **argv)
 			opt_prt = 0,
 			opt_sleep = 0,
 			sleep_time = 0,
+			opt_list =0,
 			opt_since = 0;
 	int		c;
 	char           *progname,
@@ -287,7 +293,7 @@ main(int argc, char **argv)
 	else
 		progname = argv[0];
 
-	while ((c = getopt_long(argc, argv, "234acmno:Z::S:vrsz\1\2", longopts, NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "234acmno:Z::S:vrslz\1\2", longopts, NULL)) != EOF) {
 		switch (c) {
 		case 'a':
 			fprintf(stderr, "nfsstat: nfs acls are not yet supported.\n");
@@ -345,6 +351,9 @@ main(int argc, char **argv)
 		case 's':
 			opt_srv = 1;
 			break;
+		case 'l':
+			opt_list = 1;
+			break;
 		case 'z':
 			fprintf(stderr, "nfsstat: zeroing of nfs statistics "
 					"not yet supported\n");
@@ -425,14 +434,22 @@ main(int argc, char **argv)
 				get_stats(NFSCLTSTAT, clientinfo_tmp, &opt_clt, opt_srv, 0);
 				diff_stats(clientinfo_tmp, clientinfo, 0);
 			}
-			print_all_stats(opt_srv, opt_clt, opt_prt);
+			if (opt_list) {
+				print_stats_list(opt_prt);
+			} else {
+				print_all_stats(opt_srv, opt_clt, opt_prt);
+			}
 			fflush(stdout);
 
 			update_old_counters(clientinfo_tmp, clientinfo);
 			sleep(sleep_time);
 		}	
 	} else {
-		print_all_stats(opt_srv, opt_clt, opt_prt);
+		if (opt_list) {
+			print_stats_list(opt_prt);
+		} else {
+			print_all_stats(opt_srv, opt_clt, opt_prt);
+		}
 	}
 
 	return 0;
@@ -563,6 +580,47 @@ print_client_stats(int opt_clt, int opt_prt)
 	}
 }
 
+static void
+print_stats_list(int opt_prt) 
+{
+	if (opt_prt & PRNT_CALLS) {
+		if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc2info))) {
+			print_callstats_list(
+			"nfs v2 server",
+			nfsv2name, srvproc2info + 1, sizeof(nfsv2name)/sizeof(char *));
+			printf("\n");
+			print_callstats_list(
+			"nfs v2 client",
+			nfsv2name, cltproc2info + 1,  sizeof(nfsv2name)/sizeof(char *));
+			printf("\n");
+		}
+		if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc3info))) {
+			print_callstats_list(
+			"nfs v3 server",
+			nfsv3name, srvproc3info + 1, sizeof(nfsv3name)/sizeof(char *));
+			printf("\n");
+			print_callstats_list(
+			"nfs v3 client",
+			nfsv3name, cltproc3info + 1, sizeof(nfsv3name)/sizeof(char *));
+			printf("\n");
+		}
+		if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc4info))) {
+			print_callstats_list(
+			"nfs v4 server",
+			nfssrvproc4name, srvproc4info + 1, sizeof(nfssrvproc4name)/sizeof(char *));
+			printf("\n");
+			print_callstats_list(
+			"nfs v4 ops",
+			nfssrvproc4opname, srvproc4opsinfo + 1, sizeof(nfssrvproc4opname)/sizeof(char *));
+			printf("\n");
+			print_callstats_list(
+			"nfs v4 client",
+			nfscltproc4name, cltproc4info + 1,  sizeof(nfscltproc4name)/sizeof(char *));
+			printf("\n");
+		}
+	}
+}
+
 static statinfo *
 get_stat_info(const char *sp, struct statinfo *statp)
 {
@@ -613,6 +671,25 @@ print_callstats(const char *hdr, const char **names,
 	printf("\n");
 }
 
+static void
+print_callstats_list(const char *hdr, const char **names,
+		 	unsigned int *callinfo, unsigned int nr)
+{
+	unsigned long long	calltotal;
+	int			i;
+
+	for (i = 0, calltotal = 0; i < nr; i++) {
+		calltotal += callinfo[i];
+	}
+	printf("%13s %13s %8llu \n", hdr, "total:", calltotal);
+	printf("------------- ------------- --------\n");
+	for (i = 0; i < nr; i++) {
+			printf("%13s %12s: %8u \n", hdr, names[i], callinfo[i]);
+	}
+		
+}
+
+
 /* returns 0 on success, 1 otherwise */
 static int
 parse_raw_statfile(const char *name, struct statinfo *statp)
diff --git a/utils/nfsstat/nfsstat.man b/utils/nfsstat/nfsstat.man
index 461b2c0..52215a9 100644
--- a/utils/nfsstat/nfsstat.man
+++ b/utils/nfsstat/nfsstat.man
@@ -72,6 +72,9 @@ Display all of the above facilities.
 .B \-v, \-\-verbose
 This is equivalent to \fB\-o all\fR.
 .TP
+.B \-l, \-\-list
+Print information in list form.
+.TP
 .BI "\-S, \-\-since " file
 Instead of printing current statistics, 
 .B nfsstat
-- 
1.6.2.1

