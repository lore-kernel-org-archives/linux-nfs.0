From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 1/5] nfsstat: display 3 additional NFSv4 client op
	counters
Date: Tue, 7 Aug 2007 19:52:39 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708071943460.26009@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIYqq-0006JL-MN
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:52:36 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIYqu-000635-KP
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:52:40 -0700
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

	Display three extra NFSv4 client counters that are already exposed 
in /proc/net/rpc/nfs: GETACL, SETACL, and FS_LOCATIONS.  Won't cause 
trouble on older kernels that might lack those counters.

Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index d9d119e..d27624e 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -30,7 +30,7 @@ static unsigned int	cltproc2info[20], cl
 static unsigned int	srvproc3info[24], srvproc3info_tmp[24];	/* NFSv3 call counts ([0] == 22) */
 static unsigned int	cltproc3info[24], cltproc3info_tmp[24];	/* NFSv3 call counts ([0] == 22) */
 static unsigned int	srvproc4info[4], srvproc4info_tmp[4];	/* NFSv4 call counts ([0] == 2) */
-static unsigned int	cltproc4info[34], cltproc4info_tmp[34];	/* NFSv4 call counts ([0] == 32) */
+static unsigned int	cltproc4info[37], cltproc4info_tmp[37];	/* NFSv4 call counts ([0] == 35) */
 static unsigned int	srvproc4opsinfo[42], srvproc4opsinfo_tmp[42];	/* NFSv4 call counts ([0] == 40) */
 static unsigned int	srvnetinfo[5], srvnetinfo_tmp[5];	/* 0  # of received packets
 								 * 1  UDP packets
@@ -93,13 +93,14 @@ static const char *	nfssrvproc4name[2] =
 	"compound",
 };
 
-static const char *	nfscltproc4name[32] = {
+static const char *	nfscltproc4name[35] = {
 	"null",      "read",      "write",   "commit",      "open",        "open_conf",
 	"open_noat", "open_dgrd", "close",   "setattr",     "fsinfo",      "renew",
 	"setclntid", "confirm",   "lock",
 	"lockt",     "locku",     "access",  "getattr",     "lookup",      "lookup_root",
 	"remove",    "rename",    "link",    "symlink",     "create",      "pathconf",
-	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn",
+	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn", "getacl",
+	"setacl",    "fs_locations"
 };
 
 static const char *     nfssrvproc4opname[40] = {
@@ -570,7 +571,7 @@ parse_statfile(const char *name, struct
 			ip->valptr[i] = atoi(sp);
 			total += ip->valptr[i];
 		}
-		ip->valptr[i] = total;
+		ip->valptr[cnt - 1] = total;
 	}
 
 	fclose(fp);
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
