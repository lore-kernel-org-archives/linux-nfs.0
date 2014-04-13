Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f173.google.com ([209.85.192.173]:54274 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754783AbaDMPME (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Apr 2014 11:12:04 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so7170932pdj.32
        for <linux-nfs@vger.kernel.org>; Sun, 13 Apr 2014 08:12:04 -0700 (PDT)
Message-ID: <534AA92B.8010805@gmail.com>
Date: Sun, 13 Apr 2014 23:11:39 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH] NFSD: Checking whether kill_suid by should_remove_suid()
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As local filesystem, writing data to the file by non-owner will
clears the SUID+SGID, owner will not.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/vfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 16f0673..19c0931 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -943,7 +943,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh
*fhp, struct file *file,
 	fsnotify_modify(file);

 	/* clear setuid/setgid flag after write */
-	if (inode->i_mode & (S_ISUID | S_ISGID))
+	if (should_remove_suid(dentry))
 		kill_suid(dentry);

 	if (stable) {
-- 
1.9.0

