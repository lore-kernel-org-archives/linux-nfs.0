From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/14] umount.nfs: umount doesn't recognize a busy
	file system
Date: Mon, 24 Sep 2007 11:29:31 -0400
Message-ID: <20070924152931.3804.58445.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZpsT-0006q5-0A
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:42 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZpsR-0006io-GL
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:40 -0700
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

umount.nfs shouldn't remove a busy file system from /etc/mtab, and should
report and return an error.  I also added an extra "goto" to make the flow
of control more clear, and to reduce the chance that a future change in
this logic will break it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 4311473..e7f37ef 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -102,10 +102,14 @@ static int del_mtab(const char *spec, const char *node)
 	} else
 		res = umount (node);
 
-	if (res < 0 && remount && errno == EBUSY && spec) {
-		res = try_remount(spec, node);
-		if (!res)
+	if (res < 0) {
+		if (remount && errno == EBUSY && spec) {
+			res = try_remount(spec, node);
+			if (res)
+				goto writemtab;
 			return 0;
+		} else
+			umnt_err = errno;
 	}
 
 	if (res >= 0) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
