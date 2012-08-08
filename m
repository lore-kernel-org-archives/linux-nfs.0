Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:58345 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758454Ab2HHNWA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 09:22:00 -0400
Received: by mail-yx0-f174.google.com with SMTP id l2so730657yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 06:22:00 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v5 09/19] vfs: fix mkdir to retry on ESTALE errors
Date: Wed,  8 Aug 2012 09:21:32 -0400
Message-Id: <1344432102-22312-10-git-send-email-jlayton@redhat.com>
In-Reply-To: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
References: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 29 +++++++++++++++++++----------
 1 file changed, 19 insertions(+), 10 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 0a0397f..9fd5163 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3190,17 +3190,26 @@ SYSCALL_DEFINE3(mkdirat, int, dfd, const char __user *, pathname, umode_t, mode)
 	struct dentry *dentry;
 	struct path path;
 	int error;
+	char *name;
+	unsigned int try = 0;
 
-	dentry = user_path_create(dfd, pathname, &path, 1);
-	if (IS_ERR(dentry))
-		return PTR_ERR(dentry);
-
-	if (!IS_POSIXACL(path.dentry->d_inode))
-		mode &= ~current_umask();
-	error = security_path_mkdir(&path, dentry, mode);
-	if (!error)
-		error = vfs_mkdir(path.dentry->d_inode, dentry, mode);
-	done_path_create(&path, dentry);
+	name = getname(pathname);
+	if (IS_ERR(name))
+		return PTR_ERR(name);
+	do {
+		dentry = kern_path_create(dfd, name, &path, true, try);
+		if (IS_ERR(dentry)) {
+			error = PTR_ERR(dentry);
+			break;
+		}
+		if (!IS_POSIXACL(path.dentry->d_inode))
+			mode &= ~current_umask();
+		error = security_path_mkdir(&path, dentry, mode);
+		if (!error)
+			error = vfs_mkdir(path.dentry->d_inode, dentry, mode);
+		done_path_create(&path, dentry);
+	} while (retry_estale(error, try++));
+	putname(name);
 	return error;
 }
 
-- 
1.7.11.2

