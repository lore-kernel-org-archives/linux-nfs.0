Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:35875 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754724Ab2J0MeA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:00 -0400
Received: by mail-gh0-f174.google.com with SMTP id g15so699669ghb.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:33:59 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 06/32] vfs: fix mkdir to retry on ESTALE errors
Date: Sat, 27 Oct 2012 08:33:13 -0400
Message-Id: <1351341219-17837-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 7b0ca39..6e8db3d 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3250,17 +3250,20 @@ SYSCALL_DEFINE3(mkdirat, int, dfd, const char __user *, pathname, umode_t, mode)
 	struct dentry *dentry;
 	struct path path;
 	int error;
+	unsigned int try = 0;
 
-	dentry = user_path_create(dfd, pathname, &path, true, false);
-	if (IS_ERR(dentry))
-		return PTR_ERR(dentry);
+	do {
+		dentry = user_path_create(dfd, pathname, &path, true, false);
+		if (IS_ERR(dentry))
+			return PTR_ERR(dentry);
 
-	if (!IS_POSIXACL(path.dentry->d_inode))
-		mode &= ~current_umask();
-	error = security_path_mkdir(&path, dentry, mode);
-	if (!error)
-		error = vfs_mkdir(path.dentry->d_inode, dentry, mode);
-	done_path_create(&path, dentry);
+		if (!IS_POSIXACL(path.dentry->d_inode))
+			mode &= ~current_umask();
+		error = security_path_mkdir(&path, dentry, mode);
+		if (!error)
+			error = vfs_mkdir(path.dentry->d_inode, dentry, mode);
+		done_path_create(&path, dentry);
+	} while (retry_estale(error, try++));
 	return error;
 }
 
-- 
1.7.11.7

