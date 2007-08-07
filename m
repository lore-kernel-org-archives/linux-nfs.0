From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 4/5] nfsstat: rename --diff-stat to --sleep
Date: Tue, 7 Aug 2007 19:53:11 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708071948540.26009@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIYrO-0006PP-B1
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:53:10 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIYrQ-0006EK-8H
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:53:14 -0700
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

	As per Bruce Fields' suggestion, rename the clunky -D/--diff-stat 
to the more-intuitive -Z/--sleep.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index a6b8c6c..25ee890 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -207,7 +207,7 @@ void usage(char *name)
   -v, --verbose, --all\tSame as '-o all'\n\
   -r, --rpc\t\tShow RPC statistics\n\
   -n, --nfs\t\tShow NFS statistics\n\
-  -D, --diff-stat\tSaves stats, pauses, diffs current and saved\n\
+  -Z, --sleep\tSaves stats, pauses, diffs current and saved\n\
   --version\t\tShow program version\n\
   --help\t\tWhat you just did\n\
 \n", name);
@@ -228,7 +228,7 @@ static struct option longopts[] =
 	{ "zero", 0, 0, 'z' },
 	{ "help", 0, 0, '\1' },
 	{ "version", 0, 0, '\2' },
-	{ "diff-stat", 0, 0, 'D' },
+	{ "sleep", 0, 0, 'Z' },
 	{ NULL, 0, 0, 0 }
 };
 
@@ -239,7 +239,7 @@ main(int argc, char **argv)
 			opt_srv = 0,
 			opt_clt = 0,
 			opt_prt = 0,
-			opt_diffstat = 0;
+			opt_sleep = 0;
 	int		c;
 	char           *progname;
 
@@ -253,7 +253,7 @@ main(int argc, char **argv)
 	else
 		progname = argv[0];
 
-	while ((c = getopt_long(argc, argv, "234acmno:Dvrsz\1\2", longopts, NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "234acmno:Zvrsz\1\2", longopts, NULL)) != EOF) {
 		switch (c) {
 		case 'a':
 			fprintf(stderr, "nfsstat: nfs acls are not yet supported.\n");
@@ -283,8 +283,8 @@ main(int argc, char **argv)
 				return 2;
 			}
 			break;
-		case 'D':
-			opt_diffstat = 1;
+		case 'Z':
+			opt_sleep = 1;
 			break;
 		case '2':
 		case '3':
@@ -347,7 +347,7 @@ main(int argc, char **argv)
 		get_stats(NFSCLTSTAT, cltinfo, &opt_clt, opt_srv, "Client");
 
 	/* save stat snapshots; wait for signal; then diff current and saved stats */
-	if (opt_diffstat) {
+	if (opt_sleep) {
 		starttime = time(NULL);
 		printf("Collecting statistics; press CTRL-C to view results from interval (i.e., from pause to CTRL-C).\n");
 		if (opt_srv)
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
