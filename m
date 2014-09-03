Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f43.google.com ([209.85.220.43]:45402 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728AbaICAOZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 20:14:25 -0400
Received: by mail-pa0-f43.google.com with SMTP id et14so15990895pad.16
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 17:14:24 -0700 (PDT)
Message-ID: <54065D4E.7040808@gmail.com>
Date: Wed, 03 Sep 2014 08:14:06 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH v2] NFSD: Put file after ima_file_check fail in nfsd_open()
References: <5405CFE4.9060407@gmail.com> <20140902155755.GA14472@infradead.org>
In-Reply-To: <20140902155755.GA14472@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/vfs.c | 27 +++++++++++++++++----------
 1 file changed, 17 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f501a9b..89d1ae3 100644
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
@@ -703,19 +704,25 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, umode_t type,
 		else
 			flags = O_WRONLY|O_LARGEFILE;
 	}
-	*filp = dentry_open(&path, flags, current_cred());
-	if (IS_ERR(*filp)) {
-		host_err = PTR_ERR(*filp);
-		*filp = NULL;
-	} else {
-		host_err = ima_file_check(*filp, may_flags);
 
-		if (may_flags & NFSD_MAY_64BIT_COOKIE)
-			(*filp)->f_mode |= FMODE_64BITHASH;
-		else
-			(*filp)->f_mode |= FMODE_32BITHASH;
+	file = dentry_open(&path, flags, current_cred());
+	if (IS_ERR(file)) {
+		host_err = PTR_ERR(file);
+		goto out_nfserr;
 	}
 
+	host_err = ima_file_check(file, may_flags);
+	if (host_err) {
+		nfsd_close(file);
+		goto out_nfserr;
+	}
+
+	if (may_flags & NFSD_MAY_64BIT_COOKIE)
+		file->f_mode |= FMODE_64BITHASH;
+	else
+		file->f_mode |= FMODE_32BITHASH;
+
+	*filp = file;
 out_nfserr:
 	err = nfserrno(host_err);
 out:
-- 
1.9.3

