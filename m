Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:65280 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416Ab2J0MeS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:18 -0400
Received: by mail-yh0-f46.google.com with SMTP id m54so690985yhm.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:18 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 15/32] vfs: have chdir retry lookup and call once on ESTALE error
Date: Sat, 27 Oct 2012 08:33:22 -0400
Message-Id: <1351341219-17837-16-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/open.c | 25 +++++++++++++------------
 1 file changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index 9cd0a50..5c2a973 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -387,20 +387,21 @@ SYSCALL_DEFINE1(chdir, const char __user *, filename)
 {
 	struct path path;
 	int error;
+	int lookup_flags = LOOKUP_FOLLOW | LOOKUP_DIRECTORY;
+	unsigned int try = 0;
 
-	error = user_path_dir(filename, &path);
-	if (error)
-		goto out;
-
-	error = inode_permission(path.dentry->d_inode, MAY_EXEC | MAY_CHDIR);
-	if (error)
-		goto dput_and_out;
-
-	set_fs_pwd(current->fs, &path);
+	do {
+		error = user_path_at(AT_FDCWD, filename, lookup_flags, &path);
+		if (error)
+			break;
 
-dput_and_out:
-	path_put(&path);
-out:
+		error = inode_permission(path.dentry->d_inode,
+					 MAY_EXEC | MAY_CHDIR);
+		if (!error)
+			set_fs_pwd(current->fs, &path);
+		path_put(&path);
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
 	return error;
 }
 
-- 
1.7.11.7

