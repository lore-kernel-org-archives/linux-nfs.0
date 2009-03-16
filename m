From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: [PATCH 2/2] nfsstat: Add --list flag
Date: Mon, 16 Mar 2009 10:45:56 -0700
Message-ID: <1237225556-27691-2-git-send-email-kevin.constantine@disneyanimation.com>
References: <1237225556-27691-1-git-send-email-kevin.constantine@disneyanimation.com>
Cc: steved@redhat.com, Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:42517 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761029AbZCPRz3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Mar 2009 13:55:29 -0400
In-Reply-To: <1237225556-27691-1-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsstat.c: Adds the --list flag to print information in a list format instead of the standard multi-column format
nfsstat.man: Updates the manpage to include the --list flag.

Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
---
 utils/nfsstat/nfsstat.c   |   87 ++++++++++++++++++++++++++++++--------------
 utils/nfsstat/nfsstat.man |    3 ++
 2 files changed, 62 insertions(+), 28 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index c25580c..51aea8d 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -176,7 +176,7 @@ static void		print_callstats(const char *, const char **,
 					unsigned int *, unsigned int);
 static void		print_callstats_list(const char *, const char **,
                         		unsigned int *, unsigned int *, 
-		                        unsigned int);
+		                        unsigned int, unsigned int);
 static int		parse_raw_statfile(const char *, struct statinfo *);
 static int 		parse_pretty_statfile(const char *, struct statinfo *);
 
@@ -257,6 +257,7 @@ static struct option longopts[] =
 	{ "version", 0, 0, '\2' },
 	{ "sleep", 2, 0, 'Z' },
 	{ "since", 1, 0, 'S' },
+	{ "list", 0, 0, 'l' },
 	{ NULL, 0, 0, 0 }
 };
 
@@ -269,6 +270,7 @@ main(int argc, char **argv)
 			opt_prt = 0,
 			opt_sleep = 0,
 			sleep_time = 0,
+			opt_list = 0,
 			opt_since = 0;
 	int		c;
 	char           *progname,
@@ -290,7 +292,7 @@ main(int argc, char **argv)
 	else
 		progname = argv[0];
 
-	while ((c = getopt_long(argc, argv, "234acmno:Z::S:vrsz\1\2", longopts, NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "234acmno:Z::S:vrszl\1\2", longopts, NULL)) != EOF) {
 		switch (c) {
 		case 'a':
 			fprintf(stderr, "nfsstat: nfs acls are not yet supported.\n");
@@ -348,6 +350,9 @@ main(int argc, char **argv)
 		case 's':
 			opt_srv = 1;
 			break;
+		case 'l':
+			opt_list = 1;
+			break;
 		case 'z':
 			fprintf(stderr, "nfsstat: zeroing of nfs statistics "
 					"not yet supported\n");
@@ -428,15 +433,24 @@ main(int argc, char **argv)
 				get_stats(NFSCLTSTAT, clientinfo_tmp, &opt_clt, opt_srv, 0);
 				diff_stats(clientinfo_tmp, clientinfo, 0);
 			}
-			print_stats_list(opt_prt);
+			if (opt_list) {
+				print_stats_list(opt_prt);
+			} else {
+				print_server_stats(opt_srv, opt_prt);
+				print_client_stats(opt_clt, opt_prt);
+			}		
 			fflush(stdout);
 
 			update_old_counters(clientinfo_tmp, clientinfo);
 			sleep(sleep_time);
 		}	
 	} else {
-		print_server_stats(opt_srv, opt_prt);
-		print_client_stats(opt_clt, opt_prt);
+		if (opt_list) {
+			print_stats_list(opt_prt);
+		} else {
+			print_server_stats(opt_srv, opt_prt);
+			print_client_stats(opt_clt, opt_prt);
+		}
 	}
 
 	return 0;
@@ -568,29 +582,31 @@ print_stats_list(int opt_prt)
 			print_callstats_list(
 			"nfs v2 stats:",
 			nfsv2name, srvproc2info + 1, cltproc2info + 1,  
-			sizeof(nfsv2name)/sizeof(char *)
+			sizeof(nfsv2name)/sizeof(char *), 2
 			);
 			printf("\n");
 		if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc3info)))
 			print_callstats_list(
 			"nfs v3 stats:",
 			nfsv3name, srvproc3info + 1, cltproc3info + 1, 
-			sizeof(nfsv3name)/sizeof(char *)
+			sizeof(nfsv3name)/sizeof(char *), 3
 			);
 			printf("\n");
 		if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc4info))) {
-				print_callstats(
-				LABEL_srvproc4,
-				nfssrvproc4name, srvproc4info + 1, sizeof(nfssrvproc4name)/sizeof(char *)
-				);
-				print_callstats(
-				LABEL_srvproc4ops,
-				nfssrvproc4opname, srvproc4opsinfo + 1, sizeof(nfssrvproc4opname)/sizeof(char *)
-				);
-				print_callstats(
-				LABEL_cltproc4,
-				nfscltproc4name, cltproc4info + 1,  sizeof(nfscltproc4name)/sizeof(char *)
-				);
+			/* Pass 0 as the clientproc#info to avoid having to write a whole new function
+				to handle nfsv4 since the client server calls aren't named the same */
+			print_callstats_list(
+			LABEL_srvproc4,
+			nfssrvproc4name, srvproc4info + 1, 0, sizeof(nfssrvproc4name)/sizeof(char *), 4
+			);
+			print_callstats_list(
+			LABEL_srvproc4ops,
+			nfssrvproc4opname, srvproc4opsinfo + 1, 0, sizeof(nfssrvproc4opname)/sizeof(char *), 4
+			);
+			print_callstats_list(
+			LABEL_cltproc4,
+			nfscltproc4name, cltproc4info + 1,  0, sizeof(nfscltproc4name)/sizeof(char *), 4
+			);
 		}
 	}
 }
@@ -648,19 +664,34 @@ print_callstats(const char *hdr, const char **names,
 static void
 print_callstats_list(const char *hdr, const char **names,
 		 	unsigned int *srvinfo, unsigned int *cltinfo, 
-			unsigned int nr)
+			unsigned int nr, unsigned int nfsvers)
 {
 	unsigned long long	srvtotal, clttotal;
 	int			i;
 
-	for (i = 0, srvtotal = 0, clttotal = 0; i < nr; i++) {
-		srvtotal += srvinfo[i];
-		clttotal += cltinfo[i];
-	}
-	printf("%13s %8s %8s\n", hdr, "Server", "Client");
-	printf("%12s: %8llu %8llu \n", "total", srvtotal, clttotal);
-	for (i = 0; i < nr; i++) {
-			printf("%12s: %8u %8u \n", names[i], srvinfo[i], cltinfo[i]);
+	if (nfsvers < 4) {
+		for (i = 0, srvtotal = 0, clttotal = 0; i < nr; i++) {
+			srvtotal += srvinfo[i];
+			clttotal += cltinfo[i];
+		}
+		printf("%13s %8s %8s\n", hdr, "Server", "Client");
+		printf("%12s: %8llu %8llu \n", "total", srvtotal, clttotal);
+		for (i = 0; i < nr; i++) {
+				printf("%12s: %8u %8u \n", names[i], srvinfo[i], cltinfo[i]);
+		}
+	} else {
+		/* nfsv4's client and server calls aren't named the same, so we'll print them out
+		*	separately.  Everything will be passed in as srvinfo.  Ignore cltinfo which
+		*	will be passed in as 0
+		*/
+		for (i = 0, srvtotal = 0; i < nr; i++)
+			srvtotal += srvinfo[i];
+		printf("%13s %8s\n", hdr, "Calls");
+		printf("%12s: %8llu \n", "total", srvtotal);
+		for (i = 0; i < nr; i++) {
+				printf("%12s: %8u \n", names[i], srvinfo[i]);
+		}
+		printf("\n");
 	}
 		
 }
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
1.6.0.4.761.g47577

