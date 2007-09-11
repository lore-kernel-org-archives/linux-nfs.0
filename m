From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/19] text-based mount.nfs: Use new call that handles
	NFSv2/3	foreground mounting
Date: Mon, 10 Sep 2007 20:59:43 -0400
Message-ID: <20070911005943.24927.3134.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUu6T-00033z-HV
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:59:45 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUu6X-0001Pq-7m
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 17:59:50 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi102.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8B0xWvv028969
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 17:59:32 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l8B0xhau025074
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 20:59:43 -0400
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
index dd68f9a..0bfa1ab 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -377,10 +377,8 @@ static int try_nfsmount(const char *spec, const char *node,
 				flags & ~(MS_USER|MS_USERS), *extra_opts))
 		return 1;
 
-	if (errno != EOPNOTSUPP) {
-		mount_error(spec, node, errno);
+	if (errno != EOPNOTSUPP)
 		return 0;
-	}
 
 	if (!rewrite_mount_opts(options))
 		goto parse_err;
@@ -391,8 +389,6 @@ static int try_nfsmount(const char *spec, const char *node,
 	if (!mount(spec, node, "nfs",
 				flags & ~(MS_USER|MS_USERS), *extra_opts))
 		return 1;
-
-	mount_error(spec, node, errno);
 	return 0;
 
 parse_err:
@@ -491,9 +487,9 @@ int nfsmount_s(const char *spec, const char *node, int flags,
 	if (!fix_up_mounthost_opt(options))
 		goto out;
 
-	if (!try_nfsmount(spec, node, flags, options, fake, extra_opts))
-		goto out;
-	retval = 0;
+	if (po_rightmost(options, "bg", "fg") == -1)
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
