From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 4/7] nfsstat: standardize naming of opcount arrays
Date: Tue, 31 Jul 2007 17:39:23 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0707311714120.13370@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFzR3-0001TA-0z
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:21 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFzR6-0007V6-BC
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:25 -0700
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

	Standardized Naming 2: Make the client and server "call counts" 
arrays' variable names reflect/include the actual text labels from the 
/proc files -- e.g., "cltv2info" becomes "cltproc2info".  A subsequent 
patch will rely on this naming scheme.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |   60 +++++++++++++++++++++++-----------------------
 1 files changed, 30 insertions(+), 30 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 2ab578c..0186fa5 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -23,13 +23,13 @@
 
 #define MAXNRVALS	32
 
-static unsigned int	srvv2info[20];	/* NFSv2 call counts ([0] == 18) */
-static unsigned int	cltv2info[20];	/* NFSv2 call counts ([0] == 18) */
-static unsigned int	srvv3info[24];	/* NFSv3 call counts ([0] == 22) */
-static unsigned int	cltv3info[24];	/* NFSv3 call counts ([0] == 22) */
-static unsigned int	srvv4info[4];	/* NFSv4 call counts ([0] == 2) */
-static unsigned int	cltv4info[34];	/* NFSv4 call counts ([0] == 32) */
-static unsigned int	srvv4opinfo[42];/* NFSv4 call counts ([0] == 40) */
+static unsigned int	srvproc2info[20];	/* NFSv2 call counts ([0] == 18) */
+static unsigned int	cltproc2info[20];	/* NFSv2 call counts ([0] == 18) */
+static unsigned int	srvproc3info[24];	/* NFSv3 call counts ([0] == 22) */
+static unsigned int	cltproc3info[24];	/* NFSv3 call counts ([0] == 22) */
+static unsigned int	srvproc4info[4];	/* NFSv4 call counts ([0] == 2) */
+static unsigned int	cltproc4info[34];	/* NFSv4 call counts ([0] == 32) */
+static unsigned int	srvproc4opsinfo[42];/* NFSv4 call counts ([0] == 40) */
 static unsigned int	srvnetinfo[5];	/* 0  # of received packets
 					 * 1  UDP packets
 					 * 2  TCP packets
@@ -86,12 +86,12 @@ static const char *	nfsv3name[22] = {
 	"fsstat", "fsinfo",  "pathconf", "commit"
 };
 
-static const char *	nfssrvv4name[2] = {
+static const char *	nfssrvproc4name[2] = {
 	"null",
 	"compound",
 };
 
-static const char *	nfscltv4name[32] = {
+static const char *	nfscltproc4name[32] = {
 	"null",      "read",      "write",   "commit",      "open",        "open_conf",
 	"open_noat", "open_dgrd", "close",   "setattr",     "fsinfo",      "renew",
 	"setclntid", "confirm",   "lock",
@@ -100,7 +100,7 @@ static const char *	nfscltv4name[32] = {
 	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn",
 };
 
-static const char *     nfssrvv4opname[40] = {
+static const char *     nfssrvproc4opname[40] = {
         "op0-unused",   "op1-unused", "op2-future",  "access",     "close",       "commit",
         "create",       "delegpurge", "delegreturn", "getattr",    "getfh",       "link",
         "lock",         "lockt",      "locku",       "lookup",     "lookup_root", "nverify",
@@ -123,19 +123,19 @@ static statinfo		srvinfo[] = {
 	{ "rpc",        STRUCTSIZE(srvrpcinfo), srvrpcinfo },
 	{ "rc",         STRUCTSIZE(srvrcinfo),  srvrcinfo  },
 	{ "fh",         STRUCTSIZE(srvfhinfo),  srvfhinfo  },
-	{ "proc2",      STRUCTSIZE(srvv2info),  srvv2info  },
-	{ "proc3",      STRUCTSIZE(srvv3info),  srvv3info  },
-	{ "proc4",      STRUCTSIZE(srvv4info),  srvv4info  },
-	{ "proc4ops",   STRUCTSIZE(srvv4opinfo),srvv4opinfo},
+	{ "proc2",      STRUCTSIZE(srvproc2info),  srvproc2info  },
+	{ "proc3",      STRUCTSIZE(srvproc3info),  srvproc3info  },
+	{ "proc4",      STRUCTSIZE(srvproc4info),  srvproc4info  },
+	{ "proc4ops",   STRUCTSIZE(srvproc4opsinfo),srvproc4opsinfo},
 	{ NULL,         0,                      NULL       }
 };
 
 static statinfo		cltinfo[] = {
 	{ "net",        STRUCTSIZE(cltnetinfo), cltnetinfo },
 	{ "rpc",        STRUCTSIZE(cltrpcinfo), cltrpcinfo },
-	{ "proc2",      STRUCTSIZE(cltv2info),  cltv2info  },
-	{ "proc3",      STRUCTSIZE(cltv3info),  cltv3info  },
-	{ "proc4",      STRUCTSIZE(cltv4info),  cltv4info  },
+	{ "proc2",      STRUCTSIZE(cltproc2info),  cltproc2info  },
+	{ "proc3",      STRUCTSIZE(cltproc3info),  cltproc3info  },
+	{ "proc4",      STRUCTSIZE(cltproc4info),  cltproc4info  },
 	{ NULL,         0,                      NULL       }
 };
 
@@ -369,24 +369,24 @@ main(int argc, char **argv)
 			printf("\n");
 		}
 		if (opt_prt & PRNT_CALLS) {
-			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(srvv2info)))
+			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(srvproc2info)))
 				print_callstats(
 				"Server nfs v2:\n",
-				    nfsv2name, srvv2info + 1, sizeof(nfsv2name)/sizeof(char *)
+				    nfsv2name, srvproc2info + 1, sizeof(nfsv2name)/sizeof(char *)
 				);
-			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(srvv3info)))
+			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(srvproc3info)))
 				print_callstats(
 				"Server nfs v3:\n",
-				nfsv3name, srvv3info + 1, sizeof(nfsv3name)/sizeof(char *)
+				nfsv3name, srvproc3info + 1, sizeof(nfsv3name)/sizeof(char *)
 				);
-			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(srvv4info))) {
+			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(srvproc4info))) {
 				print_callstats(
 				"Server nfs v4:\n",
-				nfssrvv4name, srvv4info + 1, sizeof(nfssrvv4name)/sizeof(char *)
+				nfssrvproc4name, srvproc4info + 1, sizeof(nfssrvproc4name)/sizeof(char *)
 				);
 				print_callstats(
 				"Server nfs v4 operations:\n",
-				nfssrvv4opname, srvv4opinfo + 1, sizeof(nfssrvv4opname)/sizeof(char *)
+				nfssrvproc4opname, srvproc4opsinfo + 1, sizeof(nfssrvproc4opname)/sizeof(char *)
 				);
 			}
 		}
@@ -410,20 +410,20 @@ main(int argc, char **argv)
 			printf("\n");
 		}
 		if (opt_prt & PRNT_CALLS) {
-			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(cltv2info)))
+			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc2info)))
 				print_callstats(
 				"Client nfs v2:\n",
-				nfsv2name, cltv2info + 1,  sizeof(nfsv2name)/sizeof(char *)
+				nfsv2name, cltproc2info + 1,  sizeof(nfsv2name)/sizeof(char *)
 				);
-			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(cltv3info)))
+			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc3info)))
 				print_callstats(
 				"Client nfs v3:\n",
-				nfsv3name, cltv3info + 1, sizeof(nfsv3name)/sizeof(char *)
+				nfsv3name, cltproc3info + 1, sizeof(nfsv3name)/sizeof(char *)
 				);
-			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(cltv4info)))
+			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc4info)))
 				print_callstats(
 				"Client nfs v4:\n",
-				nfscltv4name, cltv4info + 1,  sizeof(nfscltv4name)/sizeof(char *)
+				nfscltproc4name, cltproc4info + 1,  sizeof(nfscltproc4name)/sizeof(char *)
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
