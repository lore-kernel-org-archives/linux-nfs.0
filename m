From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/9] mount.nfs: Remove get_my_ipv4addr()
	from	utils/mount/stropts.c
Date: Fri, 24 Aug 2007 13:11:48 -0400
Message-ID: <20070824171148.10418.66777.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOchK-0003x7-AY
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:50 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOchO-0006Mq-7p
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:54 -0700
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

The get_my_ipv4addr() function is no longer used, so remove it from
utils/mount/stropts.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   25 -------------------------
 1 files changed, 0 insertions(+), 25 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index b089d1b..12f6423 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -141,31 +141,6 @@ static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
 }
 
 /*
- * XXX: This should really use the technique neil recently added
- * to get the address off the local end of a socket connected to
- * the server -- to get the right address to use on multi-homed
- * clients
- */
-static int get_my_ipv4addr(char *ip_addr, int len)
-{
-	char myname[1024];
-	struct sockaddr_in myaddr;
-
-	if (gethostname(myname, sizeof(myname))) {
-		nfs_error(_("%s: can't determine client address\n"),
-				progname);
-		return 0;
-	}
-	if (!fill_ipv4_sockaddr(myname, &myaddr))
-		return 0;
-
-	snprintf(ip_addr, len, "%s", inet_ntoa(myaddr.sin_addr));
-	ip_addr[len - 1] = '\0';
-
-	return 1;
-}
-
-/*
  * Walk through our mount options string, and indicate the presence
  * of 'bg', 'retry=', 'addr=', and 'clientaddr='.
  */


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
