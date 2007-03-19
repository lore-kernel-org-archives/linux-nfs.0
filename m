From: Karel Zak <kzak@redhat.com>
Subject: [PATCH] Correctly handle -f (fake) mount option.
Date: Mon, 19 Mar 2007 20:33:17 +0100
Message-ID: <20070319193317.GH18681@petra.dvoda.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HTNbg-0007IA-O6
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 12:33:31 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HTNbh-0003WM-H5
	for nfs@lists.sourceforge.net; Mon, 19 Mar 2007 12:33:26 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l2JJXJOq002053
	for <nfs@lists.sourceforge.net>; Mon, 19 Mar 2007 15:33:19 -0400
Received: from devserv.devel.redhat.com (devserv.devel.redhat.com
	[172.16.58.1])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l2JJXJFt021772
	for <nfs@lists.sourceforge.net>; Mon, 19 Mar 2007 15:33:19 -0400
Received: from petra (vpn-4-50.str.redhat.com [10.32.4.50])
	by devserv.devel.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	l2JJXHkF019489
	for <nfs@lists.sourceforge.net>; Mon, 19 Mar 2007 14:33:18 -0500
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The fake option has to write to mtab like a normal mount. Read mount(8) man
page for more details.  It's very important for system init scripts that use
"-f" as a way how write info about mount points to /etc/mtab.

Signed-off-by: Karel Zak <kzak@redhat.com>
---
 utils/mount/mount.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index 45428b0..55d60aa 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -443,18 +443,18 @@ int main(int argc, char *argv[])
 			start_statd();
 	}
 
-	if (fake)
-		return 0;
 	if (mnt_err)
 		exit(EX_FAIL);
 
-	mnt_err = do_mount_syscall(spec, mount_point,
-				   nfs_mount_vers == 4 ? "nfs4" : "nfs",
-				   flags, mount_opts);
-		
-	if (mnt_err) {
-		mount_error(mount_point);
-		exit(EX_FAIL);
+	if (!fake) {
+		mnt_err = do_mount_syscall(spec, mount_point,
+					   nfs_mount_vers == 4 ? "nfs4" : "nfs",
+					   flags, mount_opts);
+
+		if (mnt_err) {
+			mount_error(mount_point);
+			exit(EX_FAIL);
+		}
 	}
 
 	if (!nomtab)
-- 
1.4.4.2


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
