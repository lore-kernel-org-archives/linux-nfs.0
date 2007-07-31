From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 3/7] nfsstat: standardize naming of server variables
Date: Tue, 31 Jul 2007 17:39:16 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0707311712390.13370@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFzQw-0001SF-Kb
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:16 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFzQz-0007Sj-Nb
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:18 -0700
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

	Standardized Naming 1: Instead of having a variety of different 
server-related variable name prefixes ("srv", "svr", "svc", "SVC"), set 
them all to "srv" or "SRV".  A subsequent patch will rely on this naming 
scheme. 

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |   80 +++++++++++++++++++++++-----------------------
 1 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 619ce8b..2ab578c 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -8,7 +8,7 @@
 #include <config.h>
 #endif
 
-#define NFSSVCSTAT	"/proc/net/rpc/nfsd"
+#define NFSSRVSTAT	"/proc/net/rpc/nfsd"
 #define NFSCLTSTAT	"/proc/net/rpc/nfs"
 
 #define MOUNTSFILE	"/proc/mounts"
@@ -23,14 +23,14 @@
 
 #define MAXNRVALS	32
 
-static unsigned int	svcv2info[20];	/* NFSv2 call counts ([0] == 18) */
+static unsigned int	srvv2info[20];	/* NFSv2 call counts ([0] == 18) */
 static unsigned int	cltv2info[20];	/* NFSv2 call counts ([0] == 18) */
-static unsigned int	svcv3info[24];	/* NFSv3 call counts ([0] == 22) */
+static unsigned int	srvv3info[24];	/* NFSv3 call counts ([0] == 22) */
 static unsigned int	cltv3info[24];	/* NFSv3 call counts ([0] == 22) */
-static unsigned int	svcv4info[4];	/* NFSv4 call counts ([0] == 2) */
+static unsigned int	srvv4info[4];	/* NFSv4 call counts ([0] == 2) */
 static unsigned int	cltv4info[34];	/* NFSv4 call counts ([0] == 32) */
-static unsigned int	svcv4opinfo[42];/* NFSv4 call counts ([0] == 40) */
-static unsigned int	svcnetinfo[5];	/* 0  # of received packets
+static unsigned int	srvv4opinfo[42];/* NFSv4 call counts ([0] == 40) */
+static unsigned int	srvnetinfo[5];	/* 0  # of received packets
 					 * 1  UDP packets
 					 * 2  TCP packets
 					 * 3  TCP connections
@@ -41,7 +41,7 @@ static unsigned int	cltnetinfo[5];	/* 0
 					 * 3  TCP connections
 					 */
 
-static unsigned int	svcrpcinfo[6];	/* 0  total # of RPC calls
+static unsigned int	srvrpcinfo[6];	/* 0  total # of RPC calls
 					 * 1  total # of bad calls
 					 * 2  bad format
 					 * 3  authentication failed
@@ -52,7 +52,7 @@ static unsigned int	cltrpcinfo[4];	/* 0
 					 * 2  cred refreshs
 					 */
 
-static unsigned int	svcrcinfo[9];	/* 0  repcache hits
+static unsigned int	srvrcinfo[9];	/* 0  repcache hits
 					 * 1  repcache hits
 					 * 2  uncached reqs
 					 * (for pre-2.4 kernels:)
@@ -63,7 +63,7 @@ static unsigned int	svcrcinfo[9];	/* 0
 					 * 7  stale
 					 */
 
-static unsigned int	svcfhinfo[7];	/* (for kernels >= 2.4.0)
+static unsigned int	srvfhinfo[7];	/* (for kernels >= 2.4.0)
 					 * 0  stale
 					 * 1  FH lookups
 					 * 2  'anon' FHs
@@ -86,7 +86,7 @@ static const char *	nfsv3name[22] = {
 	"fsstat", "fsinfo",  "pathconf", "commit"
 };
 
-static const char *	nfssvrv4name[2] = {
+static const char *	nfssrvv4name[2] = {
 	"null",
 	"compound",
 };
@@ -100,7 +100,7 @@ static const char *	nfscltv4name[32] = {
 	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn",
 };
 
-static const char *     nfssvrv4opname[40] = {
+static const char *     nfssrvv4opname[40] = {
         "op0-unused",   "op1-unused", "op2-future",  "access",     "close",       "commit",
         "create",       "delegpurge", "delegreturn", "getattr",    "getfh",       "link",
         "lock",         "lockt",      "locku",       "lookup",     "lookup_root", "nverify",
@@ -118,15 +118,15 @@ typedef struct statinfo {
 
 #define STRUCTSIZE(x)   sizeof(x)/sizeof(*x)
 
-static statinfo		svcinfo[] = {
-	{ "net",        STRUCTSIZE(svcnetinfo), svcnetinfo },
-	{ "rpc",        STRUCTSIZE(svcrpcinfo), svcrpcinfo },
-	{ "rc",         STRUCTSIZE(svcrcinfo),  svcrcinfo  },
-	{ "fh",         STRUCTSIZE(svcfhinfo),  svcfhinfo  },
-	{ "proc2",      STRUCTSIZE(svcv2info),  svcv2info  },
-	{ "proc3",      STRUCTSIZE(svcv3info),  svcv3info  },
-	{ "proc4",      STRUCTSIZE(svcv4info),  svcv4info  },
-	{ "proc4ops",   STRUCTSIZE(svcv4opinfo),svcv4opinfo},
+static statinfo		srvinfo[] = {
+	{ "net",        STRUCTSIZE(srvnetinfo), srvnetinfo },
+	{ "rpc",        STRUCTSIZE(srvrpcinfo), srvrpcinfo },
+	{ "rc",         STRUCTSIZE(srvrcinfo),  srvrcinfo  },
+	{ "fh",         STRUCTSIZE(srvfhinfo),  srvfhinfo  },
+	{ "proc2",      STRUCTSIZE(srvv2info),  srvv2info  },
+	{ "proc3",      STRUCTSIZE(srvv3info),  srvv3info  },
+	{ "proc4",      STRUCTSIZE(srvv4info),  srvv4info  },
+	{ "proc4ops",   STRUCTSIZE(srvv4opinfo),srvv4opinfo},
 	{ NULL,         0,                      NULL       }
 };
 
@@ -147,7 +147,7 @@ static int		parse_statfile(const char *,
 
 static statinfo		*get_stat_info(const char *, struct statinfo *);
 
-static int             mounts(const char *);
+static int		mounts(const char *);
 
 static void		get_stats(const char *, statinfo *, int *, int, const char *);
 static int		has_stats(const unsigned int *);
@@ -221,7 +221,7 @@ main(int argc, char **argv)
 			opt_prt = 0;
 	int		c;
 	char           *progname;
- 
+
 	if ((progname = strrchr(argv[0], '/')))
 		progname++;
 	else
@@ -313,7 +313,7 @@ main(int argc, char **argv)
 	}
 
 	if (opt_srv)
-		get_stats(NFSSVCSTAT, svcinfo, &opt_srv, opt_clt, "Server");
+		get_stats(NFSSRVSTAT, srvinfo, &opt_srv, opt_clt, "Server");
 	if (opt_clt)
 		get_stats(NFSCLTSTAT, cltinfo, &opt_clt, opt_srv, "Client");
 
@@ -322,7 +322,7 @@ main(int argc, char **argv)
 			print_numbers(
 			"Server packet stats:\n"
 			"packets    udp        tcp        tcpconn\n",
-			svcnetinfo, 4
+			srvnetinfo, 4
 			);
 			printf("\n");
 		}
@@ -330,7 +330,7 @@ main(int argc, char **argv)
 			print_numbers(
 			"Server rpc stats:\n"
 			"calls      badcalls   badauth    badclnt    xdrcall\n",
-			svcrpcinfo, 5
+			srvrpcinfo, 5
 			);
 			printf("\n");
 		}
@@ -338,7 +338,7 @@ main(int argc, char **argv)
 			print_numbers(
 			"Server reply cache:\n"
 			"hits       misses     nocache\n",
-			svcrcinfo, 3
+			srvrcinfo, 3
 			);
 			printf("\n");
 		}
@@ -350,43 +350,43 @@ main(int argc, char **argv)
 		 *     We preseve the 2.2 order
 		 */
 		if (opt_prt & PRNT_FH) {
-			if (get_stat_info("fh", svcinfo)) {	/* >= 2.4 */
-				int t = svcfhinfo[3];
-				svcfhinfo[3]=svcfhinfo[4];
-				svcfhinfo[4]=t;
+			if (get_stat_info("fh", srvinfo)) {	/* >= 2.4 */
+				int t = srvfhinfo[3];
+				srvfhinfo[3]=srvfhinfo[4];
+				srvfhinfo[4]=t;
 				
-				svcfhinfo[5]=svcfhinfo[0]; /* relocate 'stale' */
+				srvfhinfo[5]=srvfhinfo[0]; /* relocate 'stale' */
 				
 				print_numbers(
 					"Server file handle cache:\n"
 					"lookup     anon       ncachedir  ncachedir  stale\n",
-					svcfhinfo + 1, 5);
+					srvfhinfo + 1, 5);
 			} else					/* < 2.4 */
 				print_numbers(
 					"Server file handle cache:\n"
 					"lookup     anon       ncachedir  ncachedir  stale\n",
-					svcrcinfo + 3, 5);
+					srvrcinfo + 3, 5);
 			printf("\n");
 		}
 		if (opt_prt & PRNT_CALLS) {
-			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(svcv2info)))
+			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(srvv2info)))
 				print_callstats(
 				"Server nfs v2:\n",
-				    nfsv2name, svcv2info + 1, sizeof(nfsv2name)/sizeof(char *)
+				    nfsv2name, srvv2info + 1, sizeof(nfsv2name)/sizeof(char *)
 				);
-			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(svcv3info)))
+			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(srvv3info)))
 				print_callstats(
 				"Server nfs v3:\n",
-				nfsv3name, svcv3info + 1, sizeof(nfsv3name)/sizeof(char *)
+				nfsv3name, srvv3info + 1, sizeof(nfsv3name)/sizeof(char *)
 				);
-			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(svcv4info))) {
+			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(srvv4info))) {
 				print_callstats(
 				"Server nfs v4:\n",
-				nfssvrv4name, svcv4info + 1, sizeof(nfssvrv4name)/sizeof(char *)
+				nfssrvv4name, srvv4info + 1, sizeof(nfssrvv4name)/sizeof(char *)
 				);
 				print_callstats(
 				"Server nfs v4 operations:\n",
-				nfssvrv4opname, svcv4opinfo + 1, sizeof(nfssvrv4opname)/sizeof(char *)
+				nfssrvv4opname, srvv4opinfo + 1, sizeof(nfssrvv4opname)/sizeof(char *)
 				);
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
