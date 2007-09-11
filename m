From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/19] text-based mount.nfs: Use helpers for invoking
	mount(2)	system call
Date: Mon, 10 Sep 2007 20:59:22 -0400
Message-ID: <20070911005922.24927.84596.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUu65-00032m-Sh
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:59:21 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUu6A-0001LL-Ar
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:59:26 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi102.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8B0xB0A028471
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 17:59:11 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l8B0xMPx025050
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 20:59:22 -0400
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

 utils/mount/stropts.c |   36 ++----------------------------------
 1 files changed, 2 insertions(+), 34 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 2fd01ca..03267be 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -280,24 +280,8 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 	if (!fix_up_mounthost_opt(options))
 		goto out;
 
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
@@ -376,24 +360,8 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 	if (!append_clientaddr_option(&saddr, options))
 		goto out;
 
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
