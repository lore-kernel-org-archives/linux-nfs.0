From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 2/5] nfsstat: Obviate and remove copy_stats().
Date: Mon, 13 Aug 2007 15:15:40 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708131504280.6965@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKfO7-0001ws-KC
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 12:15:39 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKfOB-00051H-I5
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 12:15:43 -0700
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

	Rather than copying stats during --sleep, instead introduce a few 
pointers and rearrange them to avoid the copy.  Will be useful with 
--since, too.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |   43 ++++++++++++++++++-------------------------
 1 files changed, 18 insertions(+), 25 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index ada099e..6201f28 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -164,7 +164,6 @@ static int		mounts(const char *);
 
 static void		get_stats(const char *, statinfo *, int *, int, const char *);
 static int		has_stats(const unsigned int *);
-static void 		copy_stats(statinfo *, statinfo *);
 static void 		diff_stats(statinfo *, statinfo *);
 static void 		unpause(int);
 
@@ -243,6 +242,11 @@ main(int argc, char **argv)
 	int		c;
 	char           *progname;
 
+	struct statinfo *serverinfo = srvinfo,
+			*serverinfo_tmp = srvinfo_old,
+			*clientinfo = cltinfo,
+			*clientinfo_tmp = cltinfo_old;
+
 	struct sigaction act = {
 		.sa_handler = unpause,
 		.sa_flags = SA_ONESHOT,
@@ -341,31 +345,34 @@ main(int argc, char **argv)
 			"server.\n");
 	}
 
+	if (opt_sleep) {
+		serverinfo = srvinfo_old;
+		serverinfo_tmp = srvinfo;
+		clientinfo = cltinfo_old;
+		clientinfo_tmp = cltinfo;
+	}
+
 	if (opt_srv)
-		get_stats(NFSSRVSTAT, srvinfo, &opt_srv, opt_clt, "Server");
+		get_stats(NFSSRVSTAT, serverinfo, &opt_srv, opt_clt, "Server");
 	if (opt_clt)
-		get_stats(NFSCLTSTAT, cltinfo, &opt_clt, opt_srv, "Client");
+		get_stats(NFSCLTSTAT, clientinfo, &opt_clt, opt_srv, "Client");
 
 	/* save stat snapshots; wait for signal; then diff current and saved stats */
 	if (opt_sleep) {
 		starttime = time(NULL);
 		printf("Collecting statistics; press CTRL-C to view results from interval (i.e., from pause to CTRL-C).\n");
-		if (opt_srv)
-			copy_stats(srvinfo_old, srvinfo);
-		if (opt_clt)
-			copy_stats(cltinfo_old, cltinfo);
 		if (sigaction(SIGINT, &act, NULL) != 0) {
 			fprintf(stderr, "Error: couldn't register for signal and pause.\n");
 			return 1;
 		}
 		pause();
 		if (opt_srv) {
-			get_stats(NFSSRVSTAT, srvinfo, &opt_srv, opt_clt, "Server");
-			diff_stats(srvinfo, srvinfo_old);
+			get_stats(NFSSRVSTAT, serverinfo_tmp, &opt_srv, opt_clt, "Server");
+			diff_stats(serverinfo_tmp, serverinfo);
 		}
 		if (opt_clt) {
-			get_stats(NFSCLTSTAT, cltinfo, &opt_clt, opt_srv, "Client");
-			diff_stats(cltinfo, cltinfo_old);
+			get_stats(NFSCLTSTAT, clientinfo_tmp, &opt_clt, opt_srv, "Client");
+			diff_stats(clientinfo_tmp, clientinfo);
 		}
 	}
 
@@ -650,20 +657,6 @@ has_stats(const unsigned int *info)
 	return (info[0] && info[info[0] + 1] > info[0]);
 }
 
-/* clone 'src' to 'dest' */
-static void
-copy_stats(struct statinfo *dest, struct statinfo *src)
-{
-	int i, j;
-
-	for (i = 0; src[i].tag; i++) {
-		dest[i].tag = src[i].tag;
-		dest[i].nrvals = src[i].nrvals;
-		for (j = 0; j < dest[i].nrvals; j++)
-			dest[i].valptr[j] = src[i].valptr[j];
-	}
-}
-
 /*
  * take the difference of each individual stat value in 'new' and 'old'
  * and store the results back into 'new'
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
