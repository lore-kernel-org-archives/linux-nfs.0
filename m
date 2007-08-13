From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 4/5] nfsstat: #define stat header labels.
Date: Mon, 13 Aug 2007 15:15:57 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708131507550.6965@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKfOP-0001yN-GL
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 12:15:57 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKfOQ-0001FP-Up
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 12:16:01 -0700
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

	Make #defines for the stat header labels, use for output, and add 
to struct statinfo.  This will be used by a subsequent patch for 
-S/--since.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |   55 +++++++++++++++++++++++++++++-----------------
 1 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 087d102..c6f2ace 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -113,19 +113,34 @@ static const char *     nfssrvproc4opnam
         "setcltidconf", "verify",     "write",       "rellockowner"
 };
 
+#define LABEL_srvnet		"Server packet stats:\n"
+#define LABEL_srvrpc		"Server rpc stats:\n"
+#define LABEL_srvrc		"Server reply cache:\n"
+#define LABEL_srvfh		"Server file handle cache:\n"
+#define LABEL_srvproc2		"Server nfs v2:\n"
+#define LABEL_srvproc3		"Server nfs v3:\n"
+#define LABEL_srvproc4		"Server nfs v4:\n"
+#define LABEL_srvproc4ops	"Server nfs v4 operations:\n"
+#define LABEL_cltnet		"Client packet stats:\n"
+#define LABEL_cltrpc		"Client rpc stats:\n"
+#define LABEL_cltproc2		"Client nfs v2:\n"
+#define LABEL_cltproc3		"Client nfs v3:\n"
+#define LABEL_cltproc4		"Client nfs v4:\n"
+
 typedef struct statinfo {
 	char		*tag;
+	char		*label;
 	int		nrvals;
 	unsigned int *	valptr;
 } statinfo;
 
 /*
  * We now build the arrays of statinfos using macros, which will make it easier
- * to add new variables for --diff-stat.
- * e.g., SRV(net) expands into the struct statinfo:  { "net", 5, srvnetinfo }
+ * to add new variables for --sleep.  e.g., SRV(net) expands into the struct
+ * statinfo:  { "net", "Server packet stats:\n", 5, srvnetinfo }
  */
 #define ARRAYSIZE(x)		sizeof(x)/sizeof(*x)
-#define STATINFO(k, t, s...)	{ #t, ARRAYSIZE(k##t##info##s), k##t##info##s }
+#define STATINFO(k, t, s...)	{ #t, LABEL_##k##t, ARRAYSIZE(k##t##info##s), k##t##info##s }
 #define SRV(t, s...)		STATINFO(srv, t, s)
 #define CLT(t, s...)		STATINFO(clt, t, s)
 #define DECLARE_SRV(n, s...)	static statinfo n##s[] = { \
@@ -137,7 +152,7 @@ typedef struct statinfo {
 					SRV(proc3,s),\
 					SRV(proc4,s), \
 					SRV(proc4ops,s),\
-					{ NULL, 0, NULL }\
+					{ NULL, NULL, 0, NULL }\
 				}
 #define DECLARE_CLT(n, s...)  	static statinfo n##s[] = { \
 					CLT(net,s), \
@@ -145,7 +160,7 @@ typedef struct statinfo {
 					CLT(proc2,s),\
 					CLT(proc3,s), \
 					CLT(proc4,s),\
-					{ NULL, 0, NULL }\
+					{ NULL, NULL, 0, NULL }\
 				}
 DECLARE_SRV(srvinfo);
 DECLARE_SRV(srvinfo, _old);
@@ -380,7 +395,7 @@ main(int argc, char **argv)
 	if (opt_srv) {
 		if (opt_prt & PRNT_NET) {
 			print_numbers(
-			"Server packet stats:\n"
+			LABEL_srvnet
 			"packets    udp        tcp        tcpconn\n",
 			srvnetinfo, 4
 			);
@@ -388,7 +403,7 @@ main(int argc, char **argv)
 		}
 		if (opt_prt & PRNT_RPC) {
 			print_numbers(
-			"Server rpc stats:\n"
+			LABEL_srvrpc
 			"calls      badcalls   badauth    badclnt    xdrcall\n",
 			srvrpcinfo, 5
 			);
@@ -396,7 +411,7 @@ main(int argc, char **argv)
 		}
 		if (opt_prt & PRNT_RC) {
 			print_numbers(
-			"Server reply cache:\n"
+			LABEL_srvrc
 			"hits       misses     nocache\n",
 			srvrcinfo, 3
 			);
@@ -418,12 +433,12 @@ main(int argc, char **argv)
 				srvfhinfo[5]=srvfhinfo[0]; /* relocate 'stale' */
 				
 				print_numbers(
-					"Server file handle cache:\n"
+					LABEL_srvfh
 					"lookup     anon       ncachedir  ncachedir  stale\n",
 					srvfhinfo + 1, 5);
 			} else					/* < 2.4 */
 				print_numbers(
-					"Server file handle cache:\n"
+					LABEL_srvfh
 					"lookup     anon       ncachedir  ncachedir  stale\n",
 					srvrcinfo + 3, 5);
 			printf("\n");
@@ -431,21 +446,21 @@ main(int argc, char **argv)
 		if (opt_prt & PRNT_CALLS) {
 			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(srvproc2info)))
 				print_callstats(
-				"Server nfs v2:\n",
-				    nfsv2name, srvproc2info + 1, sizeof(nfsv2name)/sizeof(char *)
+				LABEL_srvproc2,
+				nfsv2name, srvproc2info + 1, sizeof(nfsv2name)/sizeof(char *)
 				);
 			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(srvproc3info)))
 				print_callstats(
-				"Server nfs v3:\n",
+				LABEL_srvproc3,
 				nfsv3name, srvproc3info + 1, sizeof(nfsv3name)/sizeof(char *)
 				);
 			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(srvproc4info))) {
 				print_callstats(
-				"Server nfs v4:\n",
+				LABEL_srvproc4,
 				nfssrvproc4name, srvproc4info + 1, sizeof(nfssrvproc4name)/sizeof(char *)
 				);
 				print_callstats(
-				"Server nfs v4 operations:\n",
+				LABEL_srvproc4ops,
 				nfssrvproc4opname, srvproc4opsinfo + 1, sizeof(nfssrvproc4opname)/sizeof(char *)
 				);
 			}
@@ -455,7 +470,7 @@ main(int argc, char **argv)
 	if (opt_clt) {
 		if (opt_prt & PRNT_NET) {
 			print_numbers(
-			"Client packet stats:\n"
+			LABEL_cltnet
 			"packets    udp        tcp        tcpconn\n",
 			cltnetinfo, 4
 			);
@@ -463,7 +478,7 @@ main(int argc, char **argv)
 		}
 		if (opt_prt & PRNT_RPC) {
 			print_numbers(
-			"Client rpc stats:\n"
+			LABEL_cltrpc
 			"calls      retrans    authrefrsh\n",
 			cltrpcinfo, 3
 			);
@@ -472,17 +487,17 @@ main(int argc, char **argv)
 		if (opt_prt & PRNT_CALLS) {
 			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc2info)))
 				print_callstats(
-				"Client nfs v2:\n",
+				LABEL_cltproc2,
 				nfsv2name, cltproc2info + 1,  sizeof(nfsv2name)/sizeof(char *)
 				);
 			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc3info)))
 				print_callstats(
-				"Client nfs v3:\n",
+				LABEL_cltproc3,
 				nfsv3name, cltproc3info + 1, sizeof(nfsv3name)/sizeof(char *)
 				);
 			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc4info)))
 				print_callstats(
-				"Client nfs v4:\n",
+				LABEL_cltproc4,
 				nfscltproc4name, cltproc4info + 1,  sizeof(nfscltproc4name)/sizeof(char *)
 				);
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
