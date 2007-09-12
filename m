From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/24] text-based mount.nfs: Use new call that handles
	NFSv2/3	foreground mounting
Date: Wed, 12 Sep 2007 12:16:08 -0400
Message-ID: <20070912161608.23491.76933.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUsr-0004Zo-Nh
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:09 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUsv-0002qS-5P
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:14 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGFIOx030051
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:15:19 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGG8Mh023621
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:16:08 -0400
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

Call foreground mount processing script from the main text-based mount
routine.  Background NFSv2/3 mounts will fail immediately until the next
couple of patches are applied.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 892790e..6658308 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -396,10 +396,8 @@ static int try_nfsmount(const char *spec, const char *node,
 	 * Kernel returns EOPNOTSUPP if the RPC bind failed,
 	 * and EPROTONOSUPPORT if the version isn't supported.
 	 */
-	if (errno != EOPNOTSUPP && errno != EPROTONOSUPPORT) {
-		mount_error(spec, node, errno);
+	if (errno != EOPNOTSUPP && errno != EPROTONOSUPPORT)
 		return 0;
-	}
 
 	if (!rewrite_mount_opts(options))
 		goto parse_err;
@@ -415,8 +413,6 @@ static int try_nfsmount(const char *spec, const char *node,
 	if (!mount(spec, node, "nfs",
 				flags & ~(MS_USER|MS_USERS), *extra_opts))
 		return 1;
-
-	mount_error(spec, node, errno);
 	return 0;
 
 parse_err:
@@ -515,9 +511,9 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 	if (!fix_up_mounthost_opt(options))
 		goto out;
 
-	if (!try_nfsmount(spec, node, flags, options, fake, extra_opts))
-		goto out;
-	retval = 0;
+	if (po_rightmost(options, "bg", "fg") > -1)
+		retval =  nfsmount_fg(spec, node, flags, options,
+							fake, extra_opts);
 
 out:
 	po_destroy(options);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
