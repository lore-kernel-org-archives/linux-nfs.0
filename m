From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/12] text-based mount.nfs: Use helpers for invoking
	mount(2)	system call
Date: Mon, 08 Oct 2007 11:54:18 -0400
Message-ID: <20071008155418.15051.88831.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ieuvz-0007kh-Bk
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:19 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ieuw4-0006T3-Hz
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 08:54:24 -0700
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

Expose support for NFS version and transport protocol fallback for NFSv2/3
mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   16 ++--------------
 1 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 62eca87..2d43e18 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -521,23 +521,11 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 	if (!set_mandatory_options(type, &saddr, options))
 		goto out;
 
-	if (po_join(options, extra_opts) == PO_FAILED) {
-		nfs_error(_("%s: internal option parsing error"), progname);
+	if (try_mount(spec, node, type, flags, options, fake, extra_opts)) {
+		mount_error(spec, node, errno);
 		goto out;
 	}
 
-	if (verbose)
-		printf(_("%s: text-based options: '%s'\n"),
-			progname, *extra_opts);
-
-	if (!fake) {
-		if (mount(spec, node, type,
-				flags & ~(MS_USER|MS_USERS), *extra_opts)) {
-			mount_error(spec, node, errno);
-			goto out;
-		}
-	}
-
 	retval = EX_SUCCESS;
 
 out:


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
