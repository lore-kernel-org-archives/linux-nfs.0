From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 2/7] nfsstat: add get_stats()
Date: Tue, 31 Jul 2007 17:39:11 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0707311711210.13370@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFzQs-0001S9-AT
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:10 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFzQt-0007Qx-TN
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:14 -0700
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

	Share some of the existing statistics-gathering code by folding it 
into a function, get_stats().

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |   38 +++++++++++++++++---------------------
 1 files changed, 17 insertions(+), 21 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 7e822a7..619ce8b 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -149,6 +149,7 @@ static statinfo		*get_stat_info(const ch
 
 static int             mounts(const char *);
 
+static void		get_stats(const char *, statinfo *, int *, int, const char *);
 static int		has_stats(const unsigned int *);
 
 #define PRNT_CALLS	0x0001
@@ -217,8 +218,6 @@ main(int argc, char **argv)
 	int		opt_all = 0,
 			opt_srv = 0,
 			opt_clt = 0,
-			srv_info = 0,
-			clt_info = 0,
 			opt_prt = 0;
 	int		c;
 	char           *progname;
@@ -313,25 +312,10 @@ main(int argc, char **argv)
 			"server.\n");
 	}
 
-	if (opt_srv) {
-		srv_info = parse_statfile(NFSSVCSTAT, svcinfo);
-		if (srv_info == 0 && opt_clt == 0) {
-			fprintf(stderr, "Warning: No Server Stats (%s: %m).\n", NFSSVCSTAT);
-			return 2;
-		}
-		if (srv_info == 0)
-			opt_srv = 0;
-	}
-
-	if (opt_clt) {
-		clt_info = parse_statfile(NFSCLTSTAT, cltinfo);
-		if (opt_srv == 0 && clt_info == 0) {
-			fprintf(stderr, "Warning: No Client Stats (%s: %m).\n", NFSCLTSTAT);
-			return 2;
-		}
-		if (clt_info == 0)
-			opt_clt = 0;
-	}
+	if (opt_srv)
+		get_stats(NFSSVCSTAT, svcinfo, &opt_srv, opt_clt, "Server");
+	if (opt_clt)
+		get_stats(NFSCLTSTAT, cltinfo, &opt_clt, opt_srv, "Client");
 
 	if (opt_srv) {
 		if (opt_prt & PRNT_NET) {
@@ -590,6 +574,18 @@ mounts(const char *name)
 	return 1;
 }
 
+static void
+get_stats(const char *file, statinfo *info, int *opt, int other_opt, const char *label)
+{
+	if (!parse_statfile(file, info)) {
+		if (!other_opt) {
+			fprintf(stderr, "Warning: No %s Stats (%s: %m). \n", label, file);
+			exit(2);
+		}
+		*opt = 0;
+	}
+}
+
 static int
 has_stats(const unsigned int *info)
 {
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
