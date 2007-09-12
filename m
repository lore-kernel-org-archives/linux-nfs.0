From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/24] text-based mount.nfs: Fix memory leak in
	add_mtab()
Date: Wed, 12 Sep 2007 12:14:34 -0400
Message-ID: <20070912161434.23491.58121.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVUra-0004IY-JO
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:14:50 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IVUrd-0000IJ-3O
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 09:14:54 -0700
Received: from manray.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi101.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l8CGDjuB025834
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 09:13:45 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id l8CGEYFI023513
	for <nfs@lists.sourceforge.net>; Wed, 12 Sep 2007 12:14:35 -0400
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

Properly release memory acquired by fix_opts_string.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 2513943..152ae04 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -237,6 +237,7 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 
 	if (flags & MS_REMOUNT) {
 		update_mtab(ment.mnt_dir, &ment);
+		free(ment.mnt_opts);
 		return 0;
 	}
 
@@ -267,6 +268,7 @@ fail_close:
 	endmntent(mtab);
 fail_unlock:
 	unlock_mtab();
+	free(ment.mnt_opts);
 
 	return result;
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
