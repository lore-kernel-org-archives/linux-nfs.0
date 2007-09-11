From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/19] text-based mount.nfs: Implement fg/bg
	processing for	NFSv4 mounts
Date: Mon, 10 Sep 2007 21:00:04 -0400
Message-ID: <20070911010004.24927.4625.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUu6n-00039M-Ek
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 18:00:05 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUu6s-0001aZ-4o
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 18:00:10 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi102.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8B0xr6Q029734
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 17:59:53 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l8B104vq025098
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 21:00:04 -0400
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
index a1ddd99..4caf6dd 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -772,9 +772,17 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
 	if (!append_clientaddr_option(&saddr, options))
 		goto out;
 
-	if (!try_nfs4mount(spec, node, flags, options, fake, extra_opts))
-		goto out;
-	retval = 0;
+	if (po_rightmost(options, "bg", "fg") > -1) {
+		retval =  nfs4mount_fg(spec, node, flags, options,
+							fake, extra_opts);
+	} else {
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
