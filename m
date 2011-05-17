Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49749 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751007Ab1EQExL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 May 2011 00:53:11 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Tue, 17 May 2011 14:52:17 +1000
Subject: [PATCH 1/2] Remove risk of nfs_addmntent corrupting mtab
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Message-ID: <20110517045217.29020.16140.stgit@notabene.brown>
In-Reply-To: <20110517045125.29020.14596.stgit@notabene.brown>
References: <20110517045125.29020.14596.stgit@notabene.brown>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

nfs_addmntent is used to append directly to /etc/mtab.
If the write partially fail, e.g. due to RLIMIT_FSIZE,
truncate back to original size and return an error.

See also https://bugzilla.redhat.com/show_bug.cgi?id=697975
 (CVE-2011-1749) CVE-2011-1749 nfs-utils: mount.nfs fails to anticipate RLIMIT_FSIZE

Signed-off-by: NeilBrown <neilb@suse.de>
---

 support/nfs/nfs_mntent.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/support/nfs/nfs_mntent.c b/support/nfs/nfs_mntent.c
index a5216fc..a2118a2 100644
--- a/support/nfs/nfs_mntent.c
+++ b/support/nfs/nfs_mntent.c
@@ -12,6 +12,7 @@
 #include <string.h>		/* for index */
 #include <ctype.h>		/* for isdigit */
 #include <sys/stat.h>		/* for umask */
+#include <unistd.h>		/* for ftruncate */
 
 #include "nfs_mntent.h"
 #include "nls.h"
@@ -127,9 +128,11 @@ int
 nfs_addmntent (mntFILE *mfp, struct mntent *mnt) {
 	char *m1, *m2, *m3, *m4;
 	int res;
+	off_t length;
 
 	if (fseek (mfp->mntent_fp, 0, SEEK_END))
 		return 1;			/* failure */
+	length = ftell(mfp->mntent_fp);
 
 	m1 = mangle(mnt->mnt_fsname);
 	m2 = mangle(mnt->mnt_dir);
@@ -143,6 +146,12 @@ nfs_addmntent (mntFILE *mfp, struct mntent *mnt) {
 	free(m2);
 	free(m3);
 	free(m4);
+	if (res >= 0) {
+		res = fflush(mfp->mntent_fp);
+		if (res < 0)
+			/* Avoid leaving a corrupt mtab file */
+			ftruncate(fileno(mfp->mntent_fp), length);
+	}
 	return (res < 0) ? 1 : 0;
 }
 


