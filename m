From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 7/7] nfsstat: add -D/--diff-stat
Date: Tue, 31 Jul 2007 17:39:49 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0707311719160.13370@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFzgP-0002mJ-2I
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:55:13 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFzRW-0001sl-Di
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:50 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

	Add -D/--diff-stat: instead of immediately displaying total 
collected NFS stats and exiting, nfsstat will take a snapshot of current 
statistics and pause until the user hits ^C, at which point it takes a 
second snapshot and then prints out the difference of the two; i.e., 
only the statistics collected during the pause.

Signed-off-by: David M. Richter <richterd@citi.umich.edu> 

---
 utils/nfsstat/nfsstat.c |   93 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 91 insertions(+), 2 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index ab6bce7..c9a2f7d 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -20,6 +20,8 @@
 #include <string.h>
 #include <fcntl.h>
 #include <errno.h>
+#include <signal.h>
+#include <time.h>
 
 #define MAXNRVALS	32
 
@@ -153,6 +155,11 @@ static int		mounts(const char *);
 
 static void		get_stats(const char *, statinfo *, int *, int, const char *);
 static int		has_stats(const unsigned int *);
+static void 		copy_stats(statinfo *, statinfo *);
+static void 		diff_stats(statinfo *, statinfo *);
+static void 		unpause(int);
+
+static time_t		starttime;
 
 #define PRNT_CALLS	0x0001
 #define PRNT_RPC	0x0002
@@ -191,6 +198,7 @@ void usage(char *name)
   -v, --verbose, --all\tSame as '-o all'\n\
   -r, --rpc\t\tShow RPC statistics\n\
   -n, --nfs\t\tShow NFS statistics\n\
+  -D, --diff-stat\tSaves stats, pauses, diffs current and saved\n\
   --version\t\tShow program version\n\
   --help\t\tWhat you just did\n\
 \n", name);
@@ -211,6 +219,7 @@ static struct option longopts[] =
 	{ "zero", 0, 0, 'z' },
 	{ "help", 0, 0, '\1' },
 	{ "version", 0, 0, '\2' },
+	{ "diff-stat", 0, 0, 'D' },
 	{ NULL, 0, 0, 0 }
 };
 
@@ -220,16 +229,22 @@ main(int argc, char **argv)
 	int		opt_all = 0,
 			opt_srv = 0,
 			opt_clt = 0,
-			opt_prt = 0;
+			opt_prt = 0,
+			opt_diffstat = 0;
 	int		c;
 	char           *progname;
 
+	struct sigaction act = {
+		.sa_handler = unpause,
+		.sa_flags = SA_ONESHOT,
+	};
+
 	if ((progname = strrchr(argv[0], '/')))
 		progname++;
 	else
 		progname = argv[0];
 
-	while ((c = getopt_long(argc, argv, "234acmno:vrsz\1\2", longopts, NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "234acmno:Dvrsz\1\2", longopts, NULL)) != EOF) {
 		switch (c) {
 		case 'a':
 			fprintf(stderr, "nfsstat: nfs acls are not yet supported.\n");
@@ -259,6 +274,9 @@ main(int argc, char **argv)
 				return 2;
 			}
 			break;
+		case 'D':
+			opt_diffstat = 1;
+			break;
 		case '2':
 		case '3':
 		case '4':
@@ -319,6 +337,29 @@ main(int argc, char **argv)
 	if (opt_clt)
 		get_stats(NFSCLTSTAT, cltinfo, &opt_clt, opt_srv, "Client");
 
+	/* save stat snapshots; wait for signal; then diff current and saved stats */
+	if (opt_diffstat) {
+		starttime = time(NULL);
+		printf("Collecting statistics; press CTRL-C to view results from interval (i.e., from pause to CTRL-C).\n");
+		if (opt_srv)
+			copy_stats(srvinfo_tmp, srvinfo);
+		if (opt_clt)
+			copy_stats(cltinfo_tmp, cltinfo);
+		if (sigaction(SIGINT, &act, NULL) != 0) {
+			fprintf(stderr, "Error: couldn't register for signal and pause.\n");
+			return 1;
+		}
+		pause();
+		if (opt_srv) {
+			get_stats(NFSSRVSTAT, srvinfo, &opt_srv, opt_clt, "Server");
+			diff_stats(srvinfo, srvinfo_tmp);
+		}
+		if (opt_clt) {
+			get_stats(NFSCLTSTAT, cltinfo, &opt_clt, opt_srv, "Client");
+			diff_stats(cltinfo, cltinfo_tmp);
+		}
+	}
+
 	if (opt_srv) {
 		if (opt_prt & PRNT_NET) {
 			print_numbers(
@@ -593,3 +634,51 @@ has_stats(const unsigned int *info)
 {
 	return (info[0] && info[info[0] + 1] != info[0]);
 }
+
+/* clone 'src' to 'dest' */
+static void
+copy_stats(struct statinfo *dest, struct statinfo *src)
+{
+	int i, j;
+
+	for (i = 0; src[i].tag; i++) {
+		dest[i].tag = src[i].tag;
+		dest[i].nrvals = src[i].nrvals;
+		for (j = 0; j < dest[i].nrvals; j++)
+			dest[i].valptr[j] = src[i].valptr[j];
+	}
+}
+
+/*
+ * take the difference of each individual stat value in 'new' and 'old'
+ * and store the results back into 'new'
+ */
+static void
+diff_stats(struct statinfo *new, struct statinfo *old)
+{
+	int i, j, is_srv, should_diff;
+	
+	is_srv = (new == srvinfo); 
+	for (i = 0; old[i].tag; i++) {
+		for (j = 0; j < new[i].nrvals; j++) {
+			/* skip items in valptr that shouldn't be changed */
+			should_diff = (i < (3 + is_srv) || j > 0); 
+			if (should_diff)
+				new[i].valptr[j] -= old[i].valptr[j];
+		}
+	}
+}
+
+static void
+unpause(int sig)
+{
+	double time_diff;
+	int minutes, seconds;
+	time_t endtime;
+	
+	endtime = time(NULL);
+	time_diff = difftime(endtime, starttime);
+	minutes = time_diff / 60;
+	seconds = (int)time_diff % 60;
+	printf("Signal received; displaying (only) statistics gathered over the last %d minutes, %d seconds:\n\n", minutes, seconds);
+}
-- 
1.4.4

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
