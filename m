Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:53416 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758527Ab2HHNWO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 09:22:14 -0400
Received: by mail-gh0-f174.google.com with SMTP id r11so730335ghr.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 06:22:13 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v5 19/19] vfs: make chroot retry once on ESTALE error
Date: Wed,  8 Aug 2012 09:21:42 -0400
Message-Id: <1344432102-22312-20-git-send-email-jlayton@redhat.com>
In-Reply-To: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
References: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/open.c | 43 +++++++++++++++++++++++++++----------------
 1 file changed, 27 insertions(+), 16 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index 59a7e9d..991760f 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -455,27 +455,38 @@ SYSCALL_DEFINE1(chroot, const char __user *, filename)
 {
 	struct path path;
 	int error;
+	int lookup_flags = LOOKUP_FOLLOW | LOOKUP_DIRECTORY;
+	unsigned int try = 0;
+	char *name;
 
-	error = user_path_dir(filename, &path);
-	if (error)
-		goto out;
+	name = getname_flags(filename, lookup_flags, NULL);
+	if (IS_ERR(name))
+		return PTR_ERR(name);
 
-	error = inode_permission(path.dentry->d_inode, MAY_EXEC | MAY_CHDIR);
-	if (error)
-		goto dput_and_out;
+	do {
+		error = kern_path_at(AT_FDCWD, name, lookup_flags, &path);
+		if (error)
+			break;
 
-	error = -EPERM;
-	if (!capable(CAP_SYS_CHROOT))
-		goto dput_and_out;
-	error = security_path_chroot(&path);
-	if (error)
-		goto dput_and_out;
+		error = inode_permission(path.dentry->d_inode,
+					 MAY_EXEC | MAY_CHDIR);
+		if (error)
+			goto dput_and_out;
 
-	set_fs_root(current->fs, &path);
-	error = 0;
+		error = -EPERM;
+		if (!capable(CAP_SYS_CHROOT))
+			goto dput_and_out;
+		error = security_path_chroot(&path);
+		if (error)
+			goto dput_and_out;
+
+		set_fs_root(current->fs, &path);
+		error = 0;
 dput_and_out:
-	path_put(&path);
-out:
+		path_put(&path);
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
+	putname(name);
 	return error;
 }
 
-- 
1.7.11.2

