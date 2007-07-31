From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 1/7] nfsstat: add has_stats()
Date: Tue, 31 Jul 2007 17:39:02 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0707311707400.13370@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFzQk-0001Mu-BO
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:05 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFzQl-0007Nv-01
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:06 -0700
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

	To help readability, add has_stats() and use it when deciding 
whether to print.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |   20 ++++++++++++++------
 1 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 436d407..7e822a7 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -149,6 +149,8 @@ static statinfo		*get_stat_info(const ch
 
 static int             mounts(const char *);
 
+static int		has_stats(const unsigned int *);
+
 #define PRNT_CALLS	0x0001
 #define PRNT_RPC	0x0002
 #define PRNT_NET	0x0004
@@ -383,17 +385,17 @@ main(int argc, char **argv)
 			printf("\n");
 		}
 		if (opt_prt & PRNT_CALLS) {
-			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && svcv2info[0] && svcv2info[svcv2info[0]+1] != svcv2info[0]))
+			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(svcv2info)))
 				print_callstats(
 				"Server nfs v2:\n",
 				    nfsv2name, svcv2info + 1, sizeof(nfsv2name)/sizeof(char *)
 				);
-			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && svcv3info[0] && svcv3info[svcv3info[0]+1] != svcv3info[0]))
+			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(svcv3info)))
 				print_callstats(
 				"Server nfs v3:\n",
 				nfsv3name, svcv3info + 1, sizeof(nfsv3name)/sizeof(char *)
 				);
-			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && svcv4info[0] && svcv4info[svcv4info[0]+1] != svcv4info[0])) {
+			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(svcv4info))) {
 				print_callstats(
 				"Server nfs v4:\n",
 				nfssvrv4name, svcv4info + 1, sizeof(nfssvrv4name)/sizeof(char *)
@@ -424,17 +426,17 @@ main(int argc, char **argv)
 			printf("\n");
 		}
 		if (opt_prt & PRNT_CALLS) {
-			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && cltv2info[0] && cltv2info[cltv2info[0]+1] != cltv2info[0]))
+			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(cltv2info)))
 				print_callstats(
 				"Client nfs v2:\n",
 				nfsv2name, cltv2info + 1,  sizeof(nfsv2name)/sizeof(char *)
 				);
-			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && cltv3info[0] && cltv3info[cltv3info[0]+1] != cltv3info[0]))
+			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(cltv3info)))
 				print_callstats(
 				"Client nfs v3:\n",
 				nfsv3name, cltv3info + 1, sizeof(nfsv3name)/sizeof(char *)
 				);
-			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && cltv4info[0] && cltv4info[cltv4info[0]+1] != cltv4info[0]))
+			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(cltv4info)))
 				print_callstats(
 				"Client nfs v4:\n",
 				nfscltv4name, cltv4info + 1,  sizeof(nfscltv4name)/sizeof(char *)
@@ -587,3 +589,9 @@ mounts(const char *name)
 	fclose(fp);
 	return 1;
 }
+
+static int
+has_stats(const unsigned int *info)
+{
+	return (info[0] && info[info[0] + 1] != info[0]);
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
