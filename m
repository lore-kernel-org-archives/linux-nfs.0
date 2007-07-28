From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/23] umount.nfs: Pass return codes from
	do_nfs_umount back
Date: Sat, 28 Jul 2007 17:50:09 -0400
Message-ID: <20070728215009.21871.32078.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEuAu-0007YP-Oh
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:50:12 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IEuAy-0003tH-L7
	for nfs@lists.sourceforge.net; Sat, 28 Jul 2007 14:50:16 -0700
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

Do we really care about these return codes?

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 4a41ff1..8e4207f 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -326,11 +326,12 @@ int nfsumount(int argc, char *argv[])
 	ret = 0;
 	if (mc) {
 		if (!lazy)
-			do_nfs_umount(mc->m.mnt_fsname, mc->m.mnt_opts);
-		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
+			ret = do_nfs_umount(mc->m.mnt_fsname, mc->m.mnt_opts);
+		if (!ret || force)
+			ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
 	} else if (*spec != '/') {
 		if (!lazy)
-			do_nfs_umount(spec, "tcp,v3");
+			ret = do_nfs_umount(spec, "tcp,v3");
 	} else
 		ret = del_mtab(NULL, spec);
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
