Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35138 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753239AbcLaNFU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Dec 2016 08:05:20 -0500
Received: by mail-pg0-f67.google.com with SMTP id i5so25069444pgh.2
        for <linux-nfs@vger.kernel.org>; Sat, 31 Dec 2016 05:05:20 -0800 (PST)
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Cc: kinglongmee@gmail.com, Christoph Hellwig <hch@infradead.org>
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] exportfs: Make sure pass all valid export flags to nfsd
Message-ID: <c0826298-545e-64a3-b6bb-86413bf9eb39@gmail.com>
Date: Sat, 31 Dec 2016 21:05:11 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

test_export pass a export flags only marks NFSEXP_FSID,
nfsd may want other flags for export checking.
This patch make sure exportfs pass all other flags to nfsd.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 utils/exportfs/exportfs.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 15a1583..bacf106 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -473,8 +473,10 @@ static int can_test(void)
 	return 1;
 }
 
-static int test_export(char *path, int with_fsid)
+static int test_export(nfs_export *exp, int with_fsid)
 {
+	char *path = exp->m_export.e_path;
+	int flags = exp->m_export.e_flags | (with_fsid ? NFSEXP_FSID : 0);
 	/* beside max path, buf size should take protocol str into account */
 	char buf[NFS_MAXPATHLEN+1+64] = { 0 };
 	char *bp = buf;
@@ -487,7 +489,7 @@ static int test_export(char *path, int with_fsid)
 	qword_add(&bp, &len, path);
 	if (len < 1)
 		return 0;
-	snprintf(bp, len, " 3 %d 65534 65534 0\n", with_fsid ? NFSEXP_FSID : 0);
+	snprintf(bp, len, " 3 %d 65534 65534 0\n", flags);
 	fd = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
 	if (fd < 0)
 		return 0;
@@ -529,12 +531,12 @@ validate_export(nfs_export *exp)
 
 	if ((exp->m_export.e_flags & NFSEXP_FSID) || exp->m_export.e_uuid ||
 	    fs_has_fsid) {
-		if ( !test_export(path, 1)) {
+		if ( !test_export(exp, 1)) {
 			xlog(L_ERROR, "%s does not support NFS export", path);
 			return;
 		}
-	} else if ( ! test_export(path, 0)) {
-		if (test_export(path, 1))
+	} else if ( !test_export(exp, 0)) {
+		if (test_export(exp, 1))
 			xlog(L_ERROR, "%s requires fsid= for NFS export", path);
 		else
 			xlog(L_ERROR, "%s does not support NFS export", path);
-- 
2.9.3

