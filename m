From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 1/5] nfsstat: rename *_tmp variables to *_old.
Date: Mon, 13 Aug 2007 15:15:31 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708131502450.6965@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKfNx-0001wI-KN
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 12:15:29 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKfO0-0004wX-GQ
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 12:15:33 -0700
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

	To make a subsequent patch a little clearer, make it explicit that 
current *_tmp variables are actually always/only the "old" set used in 
comparisons.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 76d8f8b..ada099e 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -25,36 +25,36 @@
 
 #define MAXNRVALS	32
 
-static unsigned int	srvproc2info[20], srvproc2info_tmp[20];	/* NFSv2 call counts ([0] == 18) */
-static unsigned int	cltproc2info[20], cltproc2info_tmp[20];	/* NFSv2 call counts ([0] == 18) */
-static unsigned int	srvproc3info[24], srvproc3info_tmp[24];	/* NFSv3 call counts ([0] == 22) */
-static unsigned int	cltproc3info[24], cltproc3info_tmp[24];	/* NFSv3 call counts ([0] == 22) */
-static unsigned int	srvproc4info[4], srvproc4info_tmp[4];	/* NFSv4 call counts ([0] == 2) */
-static unsigned int	cltproc4info[37], cltproc4info_tmp[37];	/* NFSv4 call counts ([0] == 35) */
-static unsigned int	srvproc4opsinfo[42], srvproc4opsinfo_tmp[42];	/* NFSv4 call counts ([0] == 40) */
-static unsigned int	srvnetinfo[5], srvnetinfo_tmp[5];	/* 0  # of received packets
+static unsigned int	srvproc2info[20], srvproc2info_old[20];	/* NFSv2 call counts ([0] == 18) */
+static unsigned int	cltproc2info[20], cltproc2info_old[20];	/* NFSv2 call counts ([0] == 18) */
+static unsigned int	srvproc3info[24], srvproc3info_old[24];	/* NFSv3 call counts ([0] == 22) */
+static unsigned int	cltproc3info[24], cltproc3info_old[24];	/* NFSv3 call counts ([0] == 22) */
+static unsigned int	srvproc4info[4], srvproc4info_old[4];	/* NFSv4 call counts ([0] == 2) */
+static unsigned int	cltproc4info[37], cltproc4info_old[37];	/* NFSv4 call counts ([0] == 35) */
+static unsigned int	srvproc4opsinfo[42], srvproc4opsinfo_old[42];	/* NFSv4 call counts ([0] == 40) */
+static unsigned int	srvnetinfo[5], srvnetinfo_old[5];	/* 0  # of received packets
 								 * 1  UDP packets
 								 * 2  TCP packets
 								 * 3  TCP connections
 								 */
-static unsigned int	cltnetinfo[5], cltnetinfo_tmp[5];	/* 0  # of received packets
+static unsigned int	cltnetinfo[5], cltnetinfo_old[5];	/* 0  # of received packets
 								 * 1  UDP packets
 								 * 2  TCP packets
 								 * 3  TCP connections
 								 */
 
-static unsigned int	srvrpcinfo[6], srvrpcinfo_tmp[6];	/* 0  total # of RPC calls
+static unsigned int	srvrpcinfo[6], srvrpcinfo_old[6];	/* 0  total # of RPC calls
 								 * 1  total # of bad calls
 								 * 2  bad format
 								 * 3  authentication failed
 								 * 4  unknown client
 								 */
-static unsigned int	cltrpcinfo[4], cltrpcinfo_tmp[4];	/* 0  total # of RPC calls
+static unsigned int	cltrpcinfo[4], cltrpcinfo_old[4];	/* 0  total # of RPC calls
 								 * 1  retransmitted calls
 								 * 2  cred refreshs
 								 */
 
-static unsigned int	srvrcinfo[9], srvrcinfo_tmp[9];		/* 0  repcache hits
+static unsigned int	srvrcinfo[9], srvrcinfo_old[9];		/* 0  repcache hits
 								 * 1  repcache hits
 								 * 2  uncached reqs
 								 * (for pre-2.4 kernels:)
@@ -65,7 +65,7 @@ static unsigned int	srvrcinfo[9], srvrci
 								 * 7  stale
 								 */
 
-static unsigned int	srvfhinfo[7], srvfhinfo_tmp[7];		/* (for kernels >= 2.4.0)
+static unsigned int	srvfhinfo[7], srvfhinfo_old[7];		/* (for kernels >= 2.4.0)
 								 * 0  stale
 								 * 1  FH lookups
 								 * 2  'anon' FHs
@@ -148,9 +148,9 @@ typedef struct statinfo {
 					{ NULL, 0, NULL }\
 				}
 DECLARE_SRV(srvinfo);
-DECLARE_SRV(srvinfo, _tmp);
+DECLARE_SRV(srvinfo, _old);
 DECLARE_CLT(cltinfo);
-DECLARE_CLT(cltinfo, _tmp);
+DECLARE_CLT(cltinfo, _old);
 
 static void		print_numbers(const char *, unsigned int *,
 					unsigned int);
@@ -351,9 +351,9 @@ main(int argc, char **argv)
 		starttime = time(NULL);
 		printf("Collecting statistics; press CTRL-C to view results from interval (i.e., from pause to CTRL-C).\n");
 		if (opt_srv)
-			copy_stats(srvinfo_tmp, srvinfo);
+			copy_stats(srvinfo_old, srvinfo);
 		if (opt_clt)
-			copy_stats(cltinfo_tmp, cltinfo);
+			copy_stats(cltinfo_old, cltinfo);
 		if (sigaction(SIGINT, &act, NULL) != 0) {
 			fprintf(stderr, "Error: couldn't register for signal and pause.\n");
 			return 1;
@@ -361,11 +361,11 @@ main(int argc, char **argv)
 		pause();
 		if (opt_srv) {
 			get_stats(NFSSRVSTAT, srvinfo, &opt_srv, opt_clt, "Server");
-			diff_stats(srvinfo, srvinfo_tmp);
+			diff_stats(srvinfo, srvinfo_old);
 		}
 		if (opt_clt) {
 			get_stats(NFSCLTSTAT, cltinfo, &opt_clt, opt_srv, "Client");
-			diff_stats(cltinfo, cltinfo_tmp);
+			diff_stats(cltinfo, cltinfo_old);
 		}
 	}
 
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
