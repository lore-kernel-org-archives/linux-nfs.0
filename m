From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/19] text-based mount.nfs: start using new mount
	option	parsing facility
Date: Mon, 10 Sep 2007 20:58:39 -0400
Message-ID: <20070911005839.24927.57539.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUu5R-0002w0-3u
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:58:41 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUu5V-00015l-N0
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:58:46 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi102.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8B0wSPk027590
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 17:58:29 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l8B0wdDA025002
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 20:58:39 -0400
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

Use the new mount option parsing functions to handle existing mount
option string parsing needs in the text-based mount implementation.

Replace the functions for handling the 'addr=' and 'clientaddr=' options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |  132 ++++++++++++++++++++++++++-----------------------
 1 files changed, 71 insertions(+), 61 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 018c6e7..3d20d39 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -40,6 +40,7 @@
 #include "stropts.h"
 #include "error.h"
 #include "network.h"
+#include "parse_opt.h"
 
 #ifdef HAVE_RPCSVC_NFS_PROT_H
 #include <rpcsvc/nfs_prot.h>
@@ -173,31 +174,28 @@ static void extract_interesting_options(char *opts)
 }
 
 /*
- * Append the 'addr=' option to the options string.  The server
- * address is added to /etc/mtab for use when unmounting.
+ * Append the 'addr=' option to the options string to pass a resolved
+ * server address to the kernel.  After a successful mount, this address
+ * is also added to /etc/mtab for use when unmounting.
  *
- * Returns 1 if 'addr=' option created successfully;
+ * Returns 1 if 'addr=' option appended successfully;
  * otherwise zero.
  */
-static int append_addr_opt(struct sockaddr_in *saddr, char **extra_opts)
+static int append_addr_option(struct sockaddr_in *saddr,
+			   struct mount_options *options,
+			   int child)
 {
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
+	char new_option[24];
+
+	if (!child && po_contains(options, "addr")) {
+		nfs_error(_("%s: illegal option: 'addr='"), progname);
 		return 0;
 	}
-	snprintf(new_opts, sizeof(new_opts), "%s%saddr=%s",
-		 old_opts, *old_opts ? "," : "", s);
-	*extra_opts = xstrdup(new_opts);
 
-	return 1;
+	snprintf(new_option, sizeof(new_option) - 1,
+			"addr=%s", inet_ntoa(saddr->sin_addr));
+
+	return po_append(options, new_option);
 }
 
 /*
@@ -208,30 +206,22 @@ static int append_addr_opt(struct sockaddr_in *saddr, char **extra_opts)
  * Returns 1 if 'clientaddr=' option created successfully;
  * otherwise zero.
  */
-static int append_clientaddr_opt(struct sockaddr_in *saddr, char **extra_opts)
+static int append_clientaddr_option(struct sockaddr_in *saddr,
+				    struct mount_options *options)
 {
-	static char new_opts[2048], cbuf[256];
 	struct sockaddr_in my_addr;
+	char new_option[32];
 
-	if (!get_client_address(saddr, &my_addr))
-		return 0;
+	if (po_contains(options, "clientaddr"))
+		return 1;
 
-	if (strlen(*extra_opts) + 30 >= sizeof(new_opts)) {
-		nfs_error(_("%s: too many mount options"),
-				progname);
+	if (!get_client_address(saddr, &my_addr))
 		return 0;
-	}
-
-	strcat(new_opts, *extra_opts);
-
-	snprintf(cbuf, sizeof(cbuf) - 1, "%sclientaddr=%s",
-			*extra_opts ? "," : "", inet_ntoa(my_addr.sin_addr));
 
-	strcat(new_opts, cbuf);
+	snprintf(new_option, sizeof(new_option) - 1,
+			"clientaddr=%s", inet_ntoa(my_addr.sin_addr));
 
-	*extra_opts = xstrdup(new_opts);
-
-	return 1;
+	return po_append(options, new_option);
 }
 
 /*
@@ -250,26 +240,32 @@ static int append_clientaddr_opt(struct sockaddr_in *saddr, char **extra_opts)
 int nfsmount_s(const char *spec, const char *node, int flags,
 		char **extra_opts, int fake, int child)
 {
+	struct mount_options *options;
 	struct sockaddr_in saddr;
 	char *hostname;
-	int err;
+	int err, retval = EX_FAIL;
 
 	if (!parse_devname(spec, &hostname))
-		return EX_FAIL;
+		return retval;
 	err = fill_ipv4_sockaddr(hostname, &saddr);
 	free(hostname);
 	if (!err)
-		return EX_FAIL;
-
-	extract_interesting_options(*extra_opts);
+		return retval;
 
-	if (!child && addr_opt) {
-		nfs_error(_("%s: Illegal option: 'addr='"), progname);
-		return EX_FAIL;
+	options = po_split(*extra_opts);
+	if (!options) {
+		nfs_error(_("%s: internal option parsing error"), progname);
+		return retval;
 	}
 
-	if (!append_addr_opt(&saddr, extra_opts))
-		return EX_FAIL;
+	if (!append_addr_option(&saddr, options, child))
+		goto out;
+
+	*extra_opts = po_join(options);
+	if (!*extra_opts) {
+		nfs_error(_("%s: internal option parsing error"), progname);
+		goto out;
+	}
 
 	if (verbose)
 		printf(_("%s: text-based options: '%s'\n"),
@@ -279,11 +275,15 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 		if (mount(spec, node, "nfs",
 				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
 			mount_error(spec, node, errno);
-			return EX_FAIL;
+			goto out;
 		}
 	}
 
-	return 0;
+	retval = 0;
+
+out:
+	po_destroy(options);
+	return retval;
 }
 
 /*
@@ -303,29 +303,35 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 int nfs4mount_s(const char *spec, const char *node, int flags,
 		char **extra_opts, int fake, int child)
 {
+	struct mount_options *options;
 	struct sockaddr_in saddr;
 	char *hostname;
-	int err;
+	int err, retval = EX_FAIL;
 
 	if (!parse_devname(spec, &hostname))
-		return EX_FAIL;
+		return retval;
 	err = fill_ipv4_sockaddr(hostname, &saddr);
 	free(hostname);
 	if (!err)
-		return EX_FAIL;
-
-	extract_interesting_options(*extra_opts);
+		return retval;
 
-	if (addr_opt) {
-		nfs_error(_("%s: Illegal option: 'addr='"), progname);
-		return EX_FAIL;
+	options = po_split(*extra_opts);
+	if (!options) {
+		nfs_error(_("%s: internal option parsing error"), progname);
+		return retval;
 	}
 
-	if (!append_addr_opt(&saddr, extra_opts))
-		return EX_FAIL;
+	if (!append_addr_option(&saddr, options, child))
+		goto out;
 
-	if (!ca_opt && !append_clientaddr_opt(&saddr, extra_opts))
-		return EX_FAIL;
+	if (!append_clientaddr_option(&saddr, options))
+		goto out;
+
+	*extra_opts = po_join(options);
+	if (!options) {
+		nfs_error(_("%s: internal option parsing error"), progname);
+		goto out;
+	}
 
 	if (verbose)
 		printf(_("%s: text-based options: '%s'\n"),
@@ -335,9 +341,13 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 		if (mount(spec, node, "nfs4",
 				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
 			mount_error(spec, node, errno);
-			return EX_FAIL;
+			goto out;
 		}
 	}
 
-	return 0;
+	retval = 0;
+
+out:
+	po_destroy(options);
+	return retval;
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
