From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 23/24] text-based mount.nfs: Implement fg/bg
	processing for	NFSv4 mounts
Date: Wed, 12 Sep 2007 12:16:29 -0400
Message-ID: <20070912161629.23491.42651.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUtC-0004bu-Ri
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:31 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUtH-0001Fh-Al
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:16:35 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGFdFE031137
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:15:39 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGGTER023645
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:16:29 -0400
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

We can now finish the fg/bg implementation for NFSv4 mounts by copying the
logic from nfsmount_s.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index b541087..d4d775b 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -796,9 +796,17 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 	if (!append_clientaddr_option(&saddr, options))
 		goto out;
 
-	if (!try_nfs4mount(spec, node, flags, options, fake, extra_opts))
-		goto out;
-	retval = 0;
+	if (po_rightmost(options, "bg", "fg") > -1)
+		retval =  nfs4mount_fg(spec, node, flags, options,
+							fake, extra_opts);
+	else {
+		if (!child)
+			retval = nfs4mount_parent(spec, node, hostname, flags,
+						  options, fake, extra_opts);
+		else
+			retval = nfs4mount_child(spec, node, hostname, flags,
+						 options, fake, extra_opts);
+	}
 
 out:
 	po_destroy(options);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
