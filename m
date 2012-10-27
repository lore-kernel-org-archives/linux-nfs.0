Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:53867 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755312Ab2J0MeQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:16 -0400
Received: by mail-gg0-f174.google.com with SMTP id k5so690907ggd.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:16 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 14/32] vfs: have faccessat retry once on an ESTALE error
Date: Sat, 27 Oct 2012 08:33:21 -0400
Message-Id: <1351341219-17837-15-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/open.c | 64 +++++++++++++++++++++++++++++++++------------------------------
 1 file changed, 34 insertions(+), 30 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index 2a32d5c..9cd0a50 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -310,6 +310,8 @@ SYSCALL_DEFINE3(faccessat, int, dfd, const char __user *, filename, int, mode)
 	struct path path;
 	struct inode *inode;
 	int res;
+	unsigned int lookup_flags = LOOKUP_FOLLOW;
+	unsigned int try = 0;
 
 	if (mode & ~S_IRWXO)	/* where's F_OK, X_OK, W_OK, R_OK? */
 		return -EINVAL;
@@ -333,42 +335,44 @@ SYSCALL_DEFINE3(faccessat, int, dfd, const char __user *, filename, int, mode)
 
 	old_cred = override_creds(override_cred);
 
-	res = user_path_at(dfd, filename, LOOKUP_FOLLOW, &path);
-	if (res)
-		goto out;
+	do {
+		res = user_path_at(dfd, filename, lookup_flags, &path);
+		if (res)
+			break;
 
-	inode = path.dentry->d_inode;
+		inode = path.dentry->d_inode;
+
+		if ((mode & MAY_EXEC) && S_ISREG(inode->i_mode)) {
+			/*
+			 * MAY_EXEC on regular files is denied if the fs is
+			 * mounted with the "noexec" flag.
+			 */
+			res = -EACCES;
+			if (path.mnt->mnt_flags & MNT_NOEXEC)
+				goto out_path_release;
+		}
 
-	if ((mode & MAY_EXEC) && S_ISREG(inode->i_mode)) {
+		res = inode_permission(inode, mode | MAY_ACCESS);
+		/* SuS v2 requires we report a read only fs too */
+		if (res || !(mode & S_IWOTH) || special_file(inode->i_mode))
+			goto out_path_release;
 		/*
-		 * MAY_EXEC on regular files is denied if the fs is mounted
-		 * with the "noexec" flag.
+		 * This is a rare case where using __mnt_is_readonly()
+		 * is OK without a mnt_want/drop_write() pair.  Since
+		 * no actual write to the fs is performed here, we do
+		 * not need to telegraph to that to anyone.
+		 *
+		 * By doing this, we accept that this access is
+		 * inherently racy and know that the fs may change
+		 * state before we even see this result.
 		 */
-		res = -EACCES;
-		if (path.mnt->mnt_flags & MNT_NOEXEC)
-			goto out_path_release;
-	}
-
-	res = inode_permission(inode, mode | MAY_ACCESS);
-	/* SuS v2 requires we report a read only fs too */
-	if (res || !(mode & S_IWOTH) || special_file(inode->i_mode))
-		goto out_path_release;
-	/*
-	 * This is a rare case where using __mnt_is_readonly()
-	 * is OK without a mnt_want/drop_write() pair.  Since
-	 * no actual write to the fs is performed here, we do
-	 * not need to telegraph to that to anyone.
-	 *
-	 * By doing this, we accept that this access is
-	 * inherently racy and know that the fs may change
-	 * state before we even see this result.
-	 */
-	if (__mnt_is_readonly(path.mnt))
-		res = -EROFS;
+		if (__mnt_is_readonly(path.mnt))
+			res = -EROFS;
 
 out_path_release:
-	path_put(&path);
-out:
+		path_put(&path);
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(res, try++));
 	revert_creds(old_cred);
 	put_cred(override_cred);
 	return res;
-- 
1.7.11.7

