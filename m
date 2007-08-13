From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 3/5] nfsstat: Remove some pointer comparisons against
 global statinfos.
Date: Mon, 13 Aug 2007 15:15:48 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708131505300.6965@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKfOD-0001xT-JT
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 12:15:45 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKfOH-0001A6-H2
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 12:15:49 -0700
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

	Pass-in an "is_srv" arg instead of doing pointer comparisons 
against the static statinfo arrays themselves.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |   27 +++++++++++++++------------
 1 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 6201f28..087d102 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -162,9 +162,10 @@ static statinfo		*get_stat_info(const ch
 
 static int		mounts(const char *);
 
-static void		get_stats(const char *, statinfo *, int *, int, const char *);
+static void		get_stats(const char *, struct statinfo *, int *, int,
+					int);
 static int		has_stats(const unsigned int *);
-static void 		diff_stats(statinfo *, statinfo *);
+static void 		diff_stats(struct statinfo *, struct statinfo *, int);
 static void 		unpause(int);
 
 static time_t		starttime;
@@ -353,9 +354,9 @@ main(int argc, char **argv)
 	}
 
 	if (opt_srv)
-		get_stats(NFSSRVSTAT, serverinfo, &opt_srv, opt_clt, "Server");
+		get_stats(NFSSRVSTAT, serverinfo, &opt_srv, opt_clt, 1);
 	if (opt_clt)
-		get_stats(NFSCLTSTAT, clientinfo, &opt_clt, opt_srv, "Client");
+		get_stats(NFSCLTSTAT, clientinfo, &opt_clt, opt_srv, 0);
 
 	/* save stat snapshots; wait for signal; then diff current and saved stats */
 	if (opt_sleep) {
@@ -367,12 +368,12 @@ main(int argc, char **argv)
 		}
 		pause();
 		if (opt_srv) {
-			get_stats(NFSSRVSTAT, serverinfo_tmp, &opt_srv, opt_clt, "Server");
-			diff_stats(serverinfo_tmp, serverinfo);
+			get_stats(NFSSRVSTAT, serverinfo_tmp, &opt_srv, opt_clt, 1);
+			diff_stats(serverinfo_tmp, serverinfo, 1);
 		}
 		if (opt_clt) {
-			get_stats(NFSCLTSTAT, clientinfo_tmp, &opt_clt, opt_srv, "Client");
-			diff_stats(clientinfo_tmp, clientinfo);
+			get_stats(NFSCLTSTAT, clientinfo_tmp, &opt_clt, opt_srv, 0);
+			diff_stats(clientinfo_tmp, clientinfo, 0);
 		}
 	}
 
@@ -634,8 +635,11 @@ mounts(const char *name)
 }
 
 static void
-get_stats(const char *file, statinfo *info, int *opt, int other_opt, const char *label)
+get_stats(const char *file, struct statinfo *info, int *opt, int other_opt,
+		int is_srv)
 {
+	const char *label = is_srv ? "Server" : "Client";
+
 	if (!parse_statfile(file, info)) {
 		if (!other_opt) {
 			fprintf(stderr, "Warning: No %s Stats (%s: %m). \n", label, file);
@@ -662,9 +666,9 @@ has_stats(const unsigned int *info)
  * and store the results back into 'new'
  */
 static void
-diff_stats(struct statinfo *new, struct statinfo *old)
+diff_stats(struct statinfo *new, struct statinfo *old, int is_srv)
 {
-	int i, j, is_srv, nodiff_first_index, should_diff;
+	int i, j, nodiff_first_index, should_diff;
 
 	/*
 	 * Different stat types have different formats in the /proc
@@ -675,7 +679,6 @@ diff_stats(struct statinfo *new, struct
 	 * procX types ("i" < 2 for clt, < 4 for srv), or if it's not
 	 * the first entry ("j" > 0).
 	 */
-	is_srv = (new == srvinfo);
 	nodiff_first_index = 2 + (2 * is_srv);
 
 	for (i = 0; old[i].tag; i++) {
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
