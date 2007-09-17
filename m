From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/10] text-based mount.nfs: Fix memory leak in
	add_mtab()
Date: Mon, 17 Sep 2007 12:28:58 -0400
Message-ID: <20070917162858.25850.25050.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IXJTz-0000ll-Fu
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 09:29:59 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IXJU1-0006YJ-W1
	for nfs@lists.sourceforge.net; Mon, 17 Sep 2007 09:30:04 -0700
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
