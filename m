From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/8] text-based mount.nfs: Clean up helper functions
	that are	no longer used
Date: Fri, 28 Sep 2007 16:37:01 -0400
Message-ID: <20070928203701.12851.74120.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbMa9-0006ZH-Dd
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 13:37:05 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbMa9-0007G1-3o
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 13:37:08 -0700
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

Remove older string parsing functions in the text-based mount.nfs
implementation that are now no longer used.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   99 -------------------------------------------------
 1 files changed, 0 insertions(+), 99 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 537a924..e3a3ac9 100644
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
@@ -142,100 +137,6 @@ static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
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
- * Append the 'addr=' option to the options string.  The server
- * address is added to /etc/mtab for use when unmounting.
- *
- * Returns 1 if 'addr=' option created successfully;
- * otherwise zero.
- */
-static int append_addr_opt(struct sockaddr_in *saddr, char **extra_opts)
-{
-	static char new_opts[1024];
-	char *s, *old_opts;
-
-	s = inet_ntoa(saddr->sin_addr);
-	old_opts = *extra_opts;
-	if (!old_opts)
-		old_opts = "";
-	if (strlen(old_opts) + strlen(s) + 10 >= sizeof(new_opts)) {
-		nfs_error(_("%s: too many mount options\n"),
-				progname);
-		return 0;
-	}
-	snprintf(new_opts, sizeof(new_opts), "%s%saddr=%s",
-		 old_opts, *old_opts ? "," : "", s);
-	*extra_opts = xstrdup(new_opts);
-
-	return 1;
-}
-
-/*
- * Called if no 'clientaddr=' option was specified in the options string
- * to discover our address and append an appropriate 'clientaddr=' option
- * to the options string.
- *
- * Returns 1 if 'clientaddr=' option created successfully;
- * otherwise zero.
- */
-static int append_clientaddr_opt(struct sockaddr_in *saddr, char **extra_opts)
-{
-	static char new_opts[2048], cbuf[256];
-	struct sockaddr_in my_addr;
-
-	if (!get_client_address(saddr, &my_addr))
-		return 0;
-
-	if (strlen(*extra_opts) + 30 >= sizeof(new_opts)) {
-		nfs_error(_("%s: too many mount options"),
-				progname);
-		return 0;
-	}
-
-	strcat(new_opts, *extra_opts);
-
-	snprintf(cbuf, sizeof(cbuf) - 1, "%sclientaddr=%s",
-			*extra_opts ? "," : "", inet_ntoa(my_addr.sin_addr));
-
-	strcat(new_opts, cbuf);
-
-	*extra_opts = xstrdup(new_opts);
-
-	return 1;
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
