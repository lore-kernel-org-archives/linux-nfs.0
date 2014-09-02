Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f49.google.com ([209.85.220.49]:45255 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbaIBOLV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 10:11:21 -0400
Received: by mail-pa0-f49.google.com with SMTP id kq14so14714266pab.22
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 07:11:20 -0700 (PDT)
Message-ID: <5405CFE4.9060407@gmail.com>
Date: Tue, 02 Sep 2014 22:10:44 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 1/6] NFSD: Put file after ima_file_check fail in nfsd_open()
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/vfs.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f501a9b..a994c50 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -649,6 +649,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
 {
 	struct path	path;
 	struct inode	*inode;
+	struct file	*file;
 	int		flags = O_RDONLY|O_LARGEFILE;
 	__be32		err;
 	int		host_err = 0;
@@ -703,17 +704,22 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
 		else
 			flags = O_WRONLY|O_LARGEFILE;
 	}
-	*filp = dentry_open(&path, flags, current_cred());
-	if (IS_ERR(*filp)) {
-		host_err = PTR_ERR(*filp);
-		*filp = NULL;
+
+	file = dentry_open(&path, flags, current_cred());
+	if (IS_ERR(file)) {
+		host_err = PTR_ERR(file);
 	} else {
-		host_err = ima_file_check(*filp, may_flags);
+		host_err = ima_file_check(file, may_flags);
+		if (host_err) {
+			nfsd_close(file);
+			goto out_nfserr;
+		}
 
 		if (may_flags & NFSD_MAY_64BIT_COOKIE)
-			(*filp)->f_mode |= FMODE_64BITHASH;
+			(file)->f_mode |= FMODE_64BITHASH;
 		else
-			(*filp)->f_mode |= FMODE_32BITHASH;
+			(file)->f_mode |= FMODE_32BITHASH;
+		*filp = file;
 	}
 
 out_nfserr:
-- 
1.9.3

