From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/6] mount.nfs: Use nfs_ variants of setmntent() and friends
Date: Tue, 15 Jan 2008 12:48:21 -0500
Message-ID: <20080115174821.30730.33377.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:57088 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbYAORsz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jan 2008 12:48:55 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
index cc00bf7..ea47cb4 100644
--- a/utils/mount/mount.c
+++ b/utils/mount/mount.c
@@ -36,6 +36,7 @@
 #include "nls.h"
 #include "mount_constants.h"
 #include "nfs_paths.h"
+#include "nfs_mntent.h"
 
 #include "nfs_mount.h"
 #include "nfs4_mount.h"
@@ -227,7 +228,7 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 			int flags, char *opts, int freq, int pass)
 {
 	struct mntent ment;
-	FILE *mtab;
+	mntFILE *mtab;
 	int result = EX_FILEIO;
 
 	ment.mnt_fsname = spec;
@@ -245,19 +246,20 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 
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
@@ -266,7 +268,7 @@ static int add_mtab(char *spec, char *mount_point, char *fstype,
 	result = EX_SUCCESS;
 
 fail_close:
-	endmntent(mtab);
+	nfs_endmntent(mtab);
 fail_unlock:
 	unlock_mtab();
 	free(ment.mnt_opts);

