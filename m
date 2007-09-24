From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/14] Don't do_nfs_umount() for NFSv4 unmounts
Date: Mon, 24 Sep 2007 11:29:36 -0400
Message-ID: <20070924152936.3804.12528.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZq3L-0008Lm-KZ
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:41:00 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZpsU-0005Z2-OP
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:43 -0700
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

No need to talk to mountd when unmounting nfs4 filesystems.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Acked-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index e7f37ef..8902f00 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -348,7 +348,7 @@ int nfsumount(int argc, char *argv[])
 
 	ret = 0;
 	if (mc) {
-		if (!lazy)
+		if (!lazy && strcmp(mc->m.mnt_type, "nfs4") != 0)
 			ret = do_nfs_umount(mc->m.mnt_fsname, mc->m.mnt_opts);
 		if (!ret || force)
 			ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
