From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/19] text-based mount.nfs: Remove a helper function
	that is	no longer used
Date: Mon, 10 Sep 2007 20:58:50 -0400
Message-ID: <20070911005850.24927.46203.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUu5Z-0002wP-TG
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:58:50 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUu5e-0007rR-J2
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:58:54 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi102.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8B0wd5X027769
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 17:58:40 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l8B0woKR025014
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 20:58:50 -0400
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

Remove an older string parsing function in the text-based mount.nfs
implementation that is no longer used, in favor of the new option
parsing helpers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   37 -------------------------------------
 1 files changed, 0 insertions(+), 37 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index da9c14a..796a741 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -65,11 +65,6 @@ extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
 
-static int retry_opt = 10000;		/* 10,000 minutes ~= 1 week */
-static int bg_opt = 0;
-static int addr_opt = 0;
-static int ca_opt = 0;
-
 static int parse_devname(const char *spec, char **hostname)
 {
 	int ret = 0;
@@ -142,38 +137,6 @@ static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
 }
 
 /*
- * Walk through our mount options string, and indicate the presence
- * of 'bg', 'retry=', 'addr=', and 'clientaddr='.
- */
-static void extract_interesting_options(char *opts)
-{
-	char *opt, *opteq;
-	int val;
-
-	opts = xstrdup(opts);
-
-	for (opt = strtok(opts, ","); opt; opt = strtok(NULL, ",")) {
-		if ((opteq = strchr(opt, '='))) {
-			val = atoi(opteq + 1);
-			*opteq = '\0';
-			if (strcmp(opt, "bg") == 0)
-				bg_opt++;
-			else if (strcmp(opt, "retry") == 0)
-				retry_opt = val;
-			else if (strcmp(opt, "addr") == 0)
-				addr_opt++;
-			else if (strcmp(opt, "clientaddr") == 0)
-				ca_opt++;
-		} else {
-			if (strcmp(opt, "bg") == 0)
-				bg_opt++;
-		}
-	}
-
-	free(opts);
-}
-
-/*
  * Append the 'addr=' option to the options string to pass a resolved
  * server address to the kernel.  After a successful mount, this address
  * is also added to /etc/mtab for use when unmounting.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
