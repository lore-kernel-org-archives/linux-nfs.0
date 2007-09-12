From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/24] text-based mount.nfs: Use helpers for invoking
	mount(2)	system call
Date: Wed, 12 Sep 2007 12:15:42 -0400
Message-ID: <20070912161542.23491.78214.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUsT-0004S0-6Z
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:15:45 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUsW-0002ay-Ke
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:15:50 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGEqwh028826
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:14:53 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGFglP023591
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:15:42 -0400
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

Use the new mount system call helpers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   38 ++------------------------------------
 1 files changed, 2 insertions(+), 36 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 7c1d3ac..c435e0d 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -281,25 +281,8 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 	if (!fix_up_mounthost_opt(options))
 		goto out;
 
-	free(*extra_opts);
-	*extra_opts = po_join(options);
-	if (!*extra_opts) {
-		nfs_error(_("%s: internal option parsing error"), progname);
+	if (!try_nfsmount(spec, node, flags, options, fake, extra_opts))
 		goto out;
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
 	retval = 0;
 
 out:
@@ -380,25 +363,8 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 	if (!append_clientaddr_option(&saddr, options))
 		goto out;
 
-	free(*extra_opts);
-	*extra_opts = po_join(options);
-	if (!options) {
-		nfs_error(_("%s: internal option parsing error"), progname);
+	if (!try_nfs4mount(spec, node, flags, options, fake, extra_opts))
 		goto out;
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
 	retval = 0;
 
 out:


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
