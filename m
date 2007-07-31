From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 6/7] nfsstat: just declare -D/--diff-stat's variables
Date: Tue, 31 Jul 2007 17:39:42 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0707311717320.13370@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Richardson <chardson@umich.edu>,
	nfs@lists.sourceforge.net, Alex Soule <soule@umich.edu>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFzRL-0001US-Hw
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:40 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFzRP-0007bu-3r
	for nfs@lists.sourceforge.net; Tue, 31 Jul 2007 14:39:43 -0700
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

	Add the temp vars -D/--diff-stat will use.  (just using a separate 
patch to make the next one easier to read)

Signed-off-by: David M. Richter <richterd@citi.umich.edu> 

---
 utils/nfsstat/nfsstat.c |  100 ++++++++++++++++++++++++-----------------------
 1 files changed, 51 insertions(+), 49 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 8ec32e2..ab6bce7 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -23,55 +23,55 @@
 
 #define MAXNRVALS	32
 
-static unsigned int	srvproc2info[20];	/* NFSv2 call counts ([0] == 18) */
-static unsigned int	cltproc2info[20];	/* NFSv2 call counts ([0] == 18) */
-static unsigned int	srvproc3info[24];	/* NFSv3 call counts ([0] == 22) */
-static unsigned int	cltproc3info[24];	/* NFSv3 call counts ([0] == 22) */
-static unsigned int	srvproc4info[4];	/* NFSv4 call counts ([0] == 2) */
-static unsigned int	cltproc4info[34];	/* NFSv4 call counts ([0] == 32) */
-static unsigned int	srvproc4opsinfo[42];/* NFSv4 call counts ([0] == 40) */
-static unsigned int	srvnetinfo[5];	/* 0  # of received packets
-					 * 1  UDP packets
-					 * 2  TCP packets
-					 * 3  TCP connections
-					 */
-static unsigned int	cltnetinfo[5];	/* 0  # of received packets
-					 * 1  UDP packets
-					 * 2  TCP packets
-					 * 3  TCP connections
-					 */
-
-static unsigned int	srvrpcinfo[6];	/* 0  total # of RPC calls
-					 * 1  total # of bad calls
-					 * 2  bad format
-					 * 3  authentication failed
-					 * 4  unknown client
-					 */
-static unsigned int	cltrpcinfo[4];	/* 0  total # of RPC calls
-					 * 1  retransmitted calls
-					 * 2  cred refreshs
-					 */
-
-static unsigned int	srvrcinfo[9];	/* 0  repcache hits
-					 * 1  repcache hits
-					 * 2  uncached reqs
-					 * (for pre-2.4 kernels:)
-					 * 3  FH lookups
-					 * 4  'anon' FHs
-					 * 5  noncached non-directories
-					 * 6  noncached directories
-					 * 7  stale
-					 */
-
-static unsigned int	srvfhinfo[7];	/* (for kernels >= 2.4.0)
-					 * 0  stale
-					 * 1  FH lookups
-					 * 2  'anon' FHs
-					 * 3  noncached directories
-					 * 4  noncached non-directories
-					 * leave hole to relocate stale for order
-					 *    compatability.
-					 */
+static unsigned int	srvproc2info[20], srvproc2info_tmp[20];	/* NFSv2 call counts ([0] == 18) */
+static unsigned int	cltproc2info[20], cltproc2info_tmp[20];	/* NFSv2 call counts ([0] == 18) */
+static unsigned int	srvproc3info[24], srvproc3info_tmp[24];	/* NFSv3 call counts ([0] == 22) */
+static unsigned int	cltproc3info[24], cltproc3info_tmp[24];	/* NFSv3 call counts ([0] == 22) */
+static unsigned int	srvproc4info[4], srvproc4info_tmp[4];	/* NFSv4 call counts ([0] == 2) */
+static unsigned int	cltproc4info[34], cltproc4info_tmp[34];	/* NFSv4 call counts ([0] == 32) */
+static unsigned int	srvproc4opsinfo[42], srvproc4opsinfo_tmp[42];	/* NFSv4 call counts ([0] == 40) */
+static unsigned int	srvnetinfo[5], srvnetinfo_tmp[5];	/* 0  # of received packets
+					 			 * 1  UDP packets
+					 			 * 2  TCP packets
+					 			 * 3  TCP connections
+					 			 */
+static unsigned int	cltnetinfo[5], cltnetinfo_tmp[5];	/* 0  # of received packets
+								 * 1  UDP packets
+								 * 2  TCP packets
+								 * 3  TCP connections
+								 */
+
+static unsigned int	srvrpcinfo[6], srvrpcinfo_tmp[6];	/* 0  total # of RPC calls
+								 * 1  total # of bad calls
+								 * 2  bad format
+								 * 3  authentication failed
+								 * 4  unknown client
+								 */
+static unsigned int	cltrpcinfo[4], cltrpcinfo_tmp[4];	/* 0  total # of RPC calls
+								 * 1  retransmitted calls
+								 * 2  cred refreshs
+								 */
+
+static unsigned int	srvrcinfo[9], srvrcinfo_tmp[9];		/* 0  repcache hits
+								 * 1  repcache hits
+								 * 2  uncached reqs
+								 * (for pre-2.4 kernels:)
+								 * 3  FH lookups
+								 * 4  'anon' FHs
+								 * 5  noncached non-directories
+								 * 6  noncached directories
+								 * 7  stale
+								 */
+
+static unsigned int	srvfhinfo[7], srvfhinfo_tmp[7];		/* (for kernels >= 2.4.0)
+								 * 0  stale
+								 * 1  FH lookups
+								 * 2  'anon' FHs
+								 * 3  noncached directories
+								 * 4  noncached non-directories
+								 * leave hole to relocate stale for order
+								 *    compatability.
+								 */
 
 static const char *	nfsv2name[18] = {
 	"null", "getattr", "setattr", "root",   "lookup",  "readlink",
@@ -137,7 +137,9 @@ typedef struct statinfo {
 					{ NULL, 0, NULL }\
 				}
 DECLARE_SRV(srvinfo);
+DECLARE_SRV(srvinfo, _tmp);
 DECLARE_CLT(cltinfo);
+DECLARE_CLT(cltinfo, _tmp);
 
 static void		print_numbers(const char *, unsigned int *,
 					unsigned int);
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
