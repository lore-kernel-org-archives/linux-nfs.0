From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/14] text-based mount.nfs: Fix memory leak in
	add_mtab()
Date: Mon, 24 Sep 2007 11:28:44 -0400
Message-ID: <20070924152844.3804.36330.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZq3b-0008Lj-6n
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:41:11 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZpre-0004rs-D3
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:28:50 -0700
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

The add_mtab() function in utils/mount/mount.c calls fix_opts_string() to
construct an /etc/mtab entry, but never frees the result.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 751fbb9..31e1969 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -237,6 +237,7 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 
 	if (flags & MS_REMOUNT) {
 		update_mtab(ment.mnt_dir, &ment);
+		free(ment.mnt_opts);
 		return EX_SUCCESS;
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
