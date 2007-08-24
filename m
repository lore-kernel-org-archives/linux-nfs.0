From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/9] mount.nfs: Use get_client_addr() to build
	clientaddr=	option
Date: Fri, 24 Aug 2007 13:11:43 -0400
Message-ID: <20070824171143.10418.97754.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOchE-0003wT-S6
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:45 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOchJ-0006Ju-3i
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:49 -0700
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 57d8dad..b089d1b 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -231,17 +231,16 @@ static int append_addr_opt(struct sockaddr_in *saddr, char **extra_opts)
  * Returns 1 if 'clientaddr=' option created successfully;
  * otherwise zero.
  */
-static int append_clientaddr_opt(const char *spec, char **extra_opts)
+static int append_clientaddr_opt(struct sockaddr_in *saddr, char **extra_opts)
 {
-	static char new_opts[1024], cbuf[1024];
-	static char ip_addr[16] = "127.0.0.1";
+	static char new_opts[2048], cbuf[256];
+	struct sockaddr_in my_addr;
 
-	if (!get_my_ipv4addr(ip_addr, sizeof(ip_addr)))
+	if (!get_client_address(saddr, &my_addr))
 		return 0;
 
-	/* Ensure we have enough padding for the following strcat()s */
-	if (strlen(*extra_opts) + strlen(ip_addr) + 10 >= sizeof(new_opts)) {
-		nfs_error(_("%s: excessively long option argument"),
+	if (strlen(*extra_opts) + 30 >= sizeof(new_opts)) {
+		nfs_error(_("%s: too many mount options"),
 				progname);
 		return 0;
 	}
@@ -249,7 +248,8 @@ static int append_clientaddr_opt(const char *spec, char **extra_opts)
 	strcat(new_opts, *extra_opts);
 
 	snprintf(cbuf, sizeof(cbuf) - 1, "%sclientaddr=%s",
-			*extra_opts ? "," : "", ip_addr);
+			*extra_opts ? "," : "", inet_ntoa(my_addr.sin_addr));
+
 	strcat(new_opts, cbuf);
 
 	*extra_opts = xstrdup(new_opts);
@@ -352,7 +352,7 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 	if (!append_addr_opt(&saddr, extra_opts))
 		return EX_FAIL;
 
-	if (!append_clientaddr_opt(spec, extra_opts))
+	if (!append_clientaddr_opt(&saddr, extra_opts))
 		return EX_FAIL;
 
 	if (verbose)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
