From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/12] text-based mount.nfs: Remove unused top level
	functions
Date: Mon, 08 Oct 2007 11:53:57 -0400
Message-ID: <20071008155357.15051.5638.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ieuvh-0007eF-4e
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:01 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ieuvl-0006Ef-MA
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:06 -0700
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

nfsmount_s() and nfs4mount_s() are no longer used, so eliminate them.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |  129 -------------------------------------------------
 1 files changed, 0 insertions(+), 129 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 8859bf5..6f57e86 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -237,135 +237,6 @@ static int set_mandatory_options(const char *type,
 	return 1;
 }
 
-/*
- * nfsmount_s - Mount an NFSv2 or v3 file system using C string options
- *
- * @spec:	C string hostname:path specifying remoteshare to mount
- * @node:	C string pathname of local mounted on directory
- * @flags:	MS_ style flags
- * @extra_opts:	pointer to C string containing fs-specific mount options
- *		(possibly also a return argument)
- * @fake:	flag indicating whether to carry out the whole operation
- * @child:	one if this is a backgrounded mount
- *
- * XXX: need to handle bg, fg, and retry options.
- */
-int nfsmount_s(const char *spec, const char *node, int flags,
-		char **extra_opts, int fake, int child)
-{
-	struct mount_options *options = NULL;
-	struct sockaddr_in saddr;
-	char *hostname;
-	int err, retval = EX_FAIL;
-
-	if (!parse_devname(spec, &hostname))
-		goto out;
-	err = fill_ipv4_sockaddr(hostname, &saddr);
-	free(hostname);
-	if (!err)
-		goto out;
-
-	options = po_split(*extra_opts);
-	if (!options) {
-		nfs_error(_("%s: internal option parsing error"), progname);
-		goto out;
-	}
-
-	if (!append_addr_option(&saddr, options))
-		goto out;
-
-	if (!fix_mounthost_option(options))
-		goto out;
-
-	if (po_join(options, extra_opts) == PO_FAILED) {
-		nfs_error(_("%s: internal option parsing error"), progname);
-		goto out;
-	}
-
-	if (verbose)
-		printf(_("%s: text-based options: '%s'\n"),
-			progname, *extra_opts);
-
-	if (!fake) {
-		if (mount(spec, node, "nfs",
-				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
-			mount_error(spec, node, errno);
-			goto out;
-		}
-	}
-
-	retval = EX_SUCCESS;
-
-out:
-	po_destroy(options);
-	return retval;
-}
-
-/*
- * nfs4mount_s - Mount an NFSv4 file system using C string options
- *
- * @spec:	C string hostname:path specifying remoteshare to mount
- * @node:	C string pathname of local mounted on directory
- * @flags:	MS_ style flags
- * @extra_opts:	pointer to C string containing fs-specific mount options
- *		(possibly also a return argument)
- * @fake:	flag indicating whether to carry out the whole operation
- * @child:	one if this is a backgrounded mount
- *
- * XXX: need to handle bg, fg, and retry options.
- *
- */
-int nfs4mount_s(const char *spec, const char *node, int flags,
-		char **extra_opts, int fake, int child)
-{
-	struct mount_options *options = NULL;
-	struct sockaddr_in saddr;
-	char *hostname;
-	int err, retval = EX_FAIL;
-
-	if (!parse_devname(spec, &hostname))
-		goto out;
-	err = fill_ipv4_sockaddr(hostname, &saddr);
-	free(hostname);
-	if (!err)
-		goto out;
-
-	options = po_split(*extra_opts);
-	if (!options) {
-		nfs_error(_("%s: internal option parsing error"), progname);
-		goto out;
-	}
-
-	if (!append_addr_option(&saddr, options))
-		goto out;
-
-	if (!append_clientaddr_option(&saddr, options))
-		goto out;
-
-	if (po_join(options, extra_opts) == PO_FAILED) {
-		nfs_error(_("%s: internal option parsing error"), progname);
-		goto out;
-	}
-
-	if (verbose)
-		printf(_("%s: text-based options: '%s'\n"),
-			progname, *extra_opts);
-
-	if (!fake) {
-		if (mount(spec, node, "nfs4",
-				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
-			mount_error(spec, node, errno);
-			goto out;
-		}
-	}
-
-	retval = EX_SUCCESS;
-
-out:
-	po_destroy(options);
-	return retval;
-}
-
 /**
  * nfsmount_string - Mount an NFS file system using C string options
  * @spec: C string specifying remote share to mount ("hostname:path")


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
