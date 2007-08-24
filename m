From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/9] mount.nfs: Remove get_my_ipv4addr() from
	append_addr_opt()
Date: Fri, 24 Aug 2007 13:11:22 -0400
Message-ID: <20070824171122.10418.50348.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOch7-0003vj-Hf
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:37 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOch9-00022I-GN
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:39 -0700
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

The result of the get_my_ipv4addr() function is not used in
append_addr_opt(), so remove the call and the ip_addr variable.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index e43bbf4..cc13325 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -168,7 +168,7 @@ static void extract_interesting_options(char *opts)
  */
 static int append_addr_opt(const char *spec, char **extra_opts)
 {
-	static char hostdir[1024], new_opts[1024], ip_addr[255];
+	static char hostdir[1024], new_opts[1024];
 	char *hostname, *dirname, *s, *old_opts;
 	struct sockaddr_in addr;
 
@@ -186,8 +186,6 @@ static int append_addr_opt(const char *spec, char **extra_opts)
 
 	if (!fill_ipv4_sockaddr(hostname, &addr))
 		return 0;
-	if (!get_my_ipv4addr(ip_addr, sizeof(ip_addr)))
-		return 0;
 
 	/* add IP address to mtab options for use when unmounting */
 	s = inet_ntoa(addr.sin_addr);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
