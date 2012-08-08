Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:36202 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758514Ab2HHNWL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 09:22:11 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so724688yhm.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 06:22:11 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v5 17/19] vfs: have faccessat retry once on an ESTALE error
Date: Wed,  8 Aug 2012 09:21:40 -0400
Message-Id: <1344432102-22312-18-git-send-email-jlayton@redhat.com>
In-Reply-To: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
References: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/open.c | 70 ++++++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 40 insertions(+), 30 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index 0df0c5d..147b232 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -318,6 +318,9 @@ SYSCALL_DEFINE3(faccessat, int, dfd, const char __user *, filename, int, mode)
 	struct path path;
 	struct inode *inode;
 	int res;
+	unsigned int lookup_flags = LOOKUP_FOLLOW;
+	unsigned int try = 0;
+	char *name;
 
 	if (mode & ~S_IRWXO)	/* where's F_OK, X_OK, W_OK, R_OK? */
 		return -EINVAL;
@@ -339,44 +342,51 @@ SYSCALL_DEFINE3(faccessat, int, dfd, const char __user *, filename, int, mode)
 				override_cred->cap_permitted;
 	}
 
+	name = getname_flags(filename, lookup_flags, NULL);
+	if (IS_ERR(name))
+		return PTR_ERR(name);
+
 	old_cred = override_creds(override_cred);
 
-	res = user_path_at(dfd, filename, LOOKUP_FOLLOW, &path);
-	if (res)
-		goto out;
+	do {
+		res = kern_path_at(dfd, name, lookup_flags, &path);
+		if (res)
+			break;
 
-	inode = path.dentry->d_inode;
+		inode = path.dentry->d_inode;
 
-	if ((mode & MAY_EXEC) && S_ISREG(inode->i_mode)) {
+		if ((mode & MAY_EXEC) && S_ISREG(inode->i_mode)) {
+			/*
+			 * MAY_EXEC on regular files is denied if the fs is
+			 * mounted with the "noexec" flag.
+			 */
+			res = -EACCES;
+			if (path.mnt->mnt_flags & MNT_NOEXEC)
+				goto out_path_release;
+		}
+
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
+	putname(name);
 	revert_creds(old_cred);
 	put_cred(override_cred);
 	return res;
-- 
1.7.11.2

