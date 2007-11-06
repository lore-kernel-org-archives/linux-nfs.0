From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] mount.nfs: Use nfs_ variants of setmntent() and
	friends
Date: Mon, 05 Nov 2007 19:55:22 -0500
Message-ID: <20071106005522.4721.64446.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: steved@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpCiy-0003sk-EK
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 16:55:24 -0800
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpCj3-000366-45
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 16:55:30 -0800
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

Address an inconsistency:  the mount.nfs command uses the glibc routines
to manipulate /etc/mtab (setmntent) but, everything else in nfs-utils
uses a local private version (nfs_setmntent).  The local version does
some extra mangling of the mtab entries.

We should check what util-linux does these days to be sure, but for now,
let's make the mount.nfs command use the nfs_ variants of setmntent().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/mount.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/utils/mount/mount.c b/utils/mount/mount.c
index db150de..f3400e2 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -36,6 +36,7 @@
 #include "nls.h"
 #include "mount_constants.h"
 #include "nfs_paths.h"
+#include "nfs_mntent.h"
 
 #include "nfs_mount.h"
 #include "nfs4_mount.h"
@@ -225,7 +226,7 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 			int flags, char *opts, int freq, int pass)
 {
 	struct mntent ment;
-	FILE *mtab;
+	mntFILE *mtab;
 	int result = EX_FILEIO;
 
 	ment.mnt_fsname = spec;
@@ -243,19 +244,20 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 
 	lock_mtab();
 
-	if ((mtab = setmntent(MOUNTED, "a+")) == NULL) {
+	mtab = nfs_setmntent(MOUNTED, "a+");
+	if (mtab == NULL || mtab->mntent_fp == NULL) {
 		nfs_error(_("Can't open mtab: %s"),
 				strerror(errno));
 		goto fail_unlock;
 	}
 
-	if (addmntent(mtab, &ment) == 1) {
+	if (nfs_addmntent(mtab, &ment) == 1) {
 		nfs_error(_("Can't write mount entry to mtab: %s"),
 				strerror(errno));
 		goto fail_close;
 	}
 
-	if (fchmod(fileno(mtab), 0644) == -1) {
+	if (fchmod(fileno(mtab->mntent_fp), 0644) == -1) {
 		nfs_error(_("Can't set permissions on mtab: %s"),
 				strerror(errno));
 		goto fail_close;
@@ -264,7 +266,7 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 	result = EX_SUCCESS;
 
 fail_close:
-	endmntent(mtab);
+	nfs_endmntent(mtab);
 fail_unlock:
 	unlock_mtab();
 	free(ment.mnt_opts);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
