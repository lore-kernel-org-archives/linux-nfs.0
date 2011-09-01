Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53993 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932129Ab1IAPQf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Sep 2011 11:16:35 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id B009E1B4012
	for <linux-nfs@vger.kernel.org>; Thu,  1 Sep 2011 15:16:32 +0000 (UTC)
From: Mike Frysinger <vapier@gentoo.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] exportfs: drop extra newline in xlog
Date: Thu,  1 Sep 2011 11:16:31 -0400
Message-Id: <1314890192-11075-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Since xlog() itself appends a newline, we don't want to add our own
otherwise we get extra in the output.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 utils/exportfs/exportfs.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 12e8bf1..986a272 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -401,7 +401,7 @@ validate_export(nfs_export *exp)
 	int fs_has_fsid = 0;
 
 	if (stat(path, &stb) < 0) {
-		xlog(L_ERROR, "Failed to stat %s: %m \n", path);
+		xlog(L_ERROR, "Failed to stat %s: %m", path);
 		return;
 	}
 	if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode)) {
@@ -530,7 +530,7 @@ export_d_read(const char *dname)
 
 	n = scandir(dname, &namelist, NULL, versionsort);
 	if (n < 0)
-		xlog(L_NOTICE, "scandir %s: %s\n", dname, strerror(errno));
+		xlog(L_NOTICE, "scandir %s: %s", dname, strerror(errno));
 	else if (n == 0)
 		return;
 
@@ -558,7 +558,7 @@ export_d_read(const char *dname)
 
 		fname_len = snprintf(fname, PATH_MAX +1, "%s/%s", dname, d->d_name);
 		if (fname_len > PATH_MAX) {
-			xlog(L_WARNING, "Too long file name: %s in %s\n", d->d_name, dname);
+			xlog(L_WARNING, "Too long file name: %s in %s", d->d_name, dname);
 			continue;
 		}
 
@@ -672,7 +672,7 @@ dump(int verbose)
 static void
 error(nfs_export *exp, int err)
 {
-	xlog(L_ERROR, "%s:%s: %s\n", exp->m_client->m_hostname,
+	xlog(L_ERROR, "%s:%s: %s", exp->m_client->m_hostname,
 		exp->m_export.e_path, strerror(err));
 }
 
-- 
1.7.6

