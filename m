From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/24] mount.nfs: Don't leak extra_opts
Date: Wed, 12 Sep 2007 12:14:40 -0400
Message-ID: <20070912161440.23491.23368.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUrj-0004It-Mo
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:14:59 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUrm-00028j-Lc
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:15:03 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGDo2C026041
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:13:50 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGEeGO023519
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:14:40 -0400
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

Properly release extra_opts before exiting.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 152ae04..2c1899a 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -575,6 +575,8 @@ int main(int argc, char *argv[])
 	}
 
 out:
+	if (extra_opts)
+		free(extra_opts);
 	free(mount_point);
 	exit(mnt_err);
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
