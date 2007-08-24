From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/9] mount.nfs: Refactor parse_devname and
	fill_ipv4_addr
Date: Fri, 24 Aug 2007 13:11:32 -0400
Message-ID: <20070824171132.10418.82881.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOch3-0003vi-QW
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:37 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOch7-00020g-W7
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:11:38 -0700
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

We will eventually need the server address in both append_addr_opt()
and append_clientaddr_opt().  Call parse_devname() and fill_ipv4_addr()
from the top level functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   66 +++++++++++++++++++++++++------------------------
 1 files changed, 34 insertions(+), 32 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index bd6e60d..57d8dad 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -204,27 +204,17 @@ static void extract_interesting_options(char *opts)
  * Returns 1 if 'addr=' option created successfully;
  * otherwise zero.
  */
-static int append_addr_opt(const char *spec, char **extra_opts)
+static int append_addr_opt(struct sockaddr_in *saddr, char **extra_opts)
 {
 	static char new_opts[1024];
-	char *hostname, *s, *old_opts;
-	struct sockaddr_in addr;
-	int err;
-
-	if (!parse_devname(spec, &hostname))
-		return 0;
-
-	err = fill_ipv4_sockaddr(hostname, &addr);
-	free(hostname);
-	if (!err)
-		return 0;
+	char *s, *old_opts;
 
-	s = inet_ntoa(addr.sin_addr);
+	s = inet_ntoa(saddr->sin_addr);
 	old_opts = *extra_opts;
 	if (!old_opts)
 		old_opts = "";
 	if (strlen(old_opts) + strlen(s) + 10 >= sizeof(new_opts)) {
-		nfs_error(_("%s: excessively long option argument\n"),
+		nfs_error(_("%s: too many mount options\n"),
 				progname);
 		return 0;
 	}
@@ -283,17 +273,26 @@ static int append_clientaddr_opt(const char *spec, char **extra_opts)
 int nfsmount_s(const char *spec, const char *node, int flags,
 		char **extra_opts, int fake, int bg)
 {
-	int retval = EX_FAIL;
+	struct sockaddr_in saddr;
+	char *hostname;
+	int err;
+
+	if (!parse_devname(spec, &hostname))
+		return EX_FAIL;
+	err = fill_ipv4_sockaddr(hostname, &saddr);
+	free(hostname);
+	if (!err)
+		return EX_FAIL;
 
 	extract_interesting_options(*extra_opts);
 
 	if (!bg && addr_opt) {
 		nfs_error(_("%s: Illegal option: 'addr='"), progname);
-		goto fail;
+		return EX_FAIL;
 	}
 
-	if (!append_addr_opt(spec, extra_opts))
-		goto fail;
+	if (!append_addr_opt(&saddr, extra_opts))
+		return EX_FAIL;
 
 	if (verbose)
 		printf(_("%s: text-based options: '%s'\n"),
@@ -303,14 +302,11 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 		if (mount(spec, node, "nfs",
 				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
 			mount_error(spec, node, errno);
-			goto fail;
+			return EX_FAIL;
 		}
 	}
 
 	return 0;
-
-fail:
-	return retval;
 }
 
 /*
@@ -330,25 +326,34 @@ fail:
 int nfs4mount_s(const char *spec, const char *node, int flags,
 		char **extra_opts, int fake, int child)
 {
-	int retval = EX_FAIL;
+	struct sockaddr_in saddr;
+	char *hostname;
+	int err;
+
+	if (!parse_devname(spec, &hostname))
+		return EX_FAIL;
+	err = fill_ipv4_sockaddr(hostname, &saddr);
+	free(hostname);
+	if (!err)
+		return EX_FAIL;
 
 	extract_interesting_options(*extra_opts);
 
 	if (addr_opt) {
 		nfs_error(_("%s: Illegal option: 'addr='"), progname);
-		goto fail;
+		return EX_FAIL;
 	}
 
 	if (ca_opt) {
 		nfs_error(_("%s: Illegal option: 'clientaddr='"), progname);
-		goto fail;
+		return EX_FAIL;
 	}
 
-	if (!append_addr_opt(spec, extra_opts))
-		goto fail;
+	if (!append_addr_opt(&saddr, extra_opts))
+		return EX_FAIL;
 
 	if (!append_clientaddr_opt(spec, extra_opts))
-		goto fail;
+		return EX_FAIL;
 
 	if (verbose)
 		printf(_("%s: text-based options: '%s'\n"),
@@ -358,12 +363,9 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 		if (mount(spec, node, "nfs4",
 				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
 			mount_error(spec, node, errno);
-			goto fail;
+			return EX_FAIL;
 		}
 	}
 
 	return 0;
-
-fail:
-	return retval;
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
