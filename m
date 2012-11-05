Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:52182 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932610Ab2KEPWp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:22:45 -0500
Received: by mail-ye0-f174.google.com with SMTP id m12so1017184yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:22:45 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 13/34] vfs: have do_sys_truncate retry once on an ESTALE error
Date: Mon,  5 Nov 2012 10:21:52 -0500
Message-Id: <1352128933-28526-14-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/open.c | 86 +++++++++++++++++++++++++++++++++------------------------------
 1 file changed, 45 insertions(+), 41 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index 94d5649..2a32d5c 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -66,62 +66,66 @@ static long do_sys_truncate(const char __user *pathname, loff_t length)
 	struct path path;
 	struct inode *inode;
 	int error;
+	unsigned int lookup_flags = LOOKUP_FOLLOW;
+	unsigned int try = 0;
 
-	error = -EINVAL;
 	if (length < 0)	/* sorry, but loff_t says... */
-		goto out;
+		return -EINVAL;
 
-	error = user_path(pathname, &path);
-	if (error)
-		goto out;
-	inode = path.dentry->d_inode;
+	do {
+		error = user_path_at(AT_FDCWD, pathname, lookup_flags, &path);
+		if (error)
+			break;
+		inode = path.dentry->d_inode;
 
-	/* For directories it's -EISDIR, for other non-regulars - -EINVAL */
-	error = -EISDIR;
-	if (S_ISDIR(inode->i_mode))
-		goto dput_and_out;
+		/* For dirs, -EISDIR. For other non-regulars, -EINVAL */
+		error = -EISDIR;
+		if (S_ISDIR(inode->i_mode))
+			goto dput_and_out;
 
-	error = -EINVAL;
-	if (!S_ISREG(inode->i_mode))
-		goto dput_and_out;
+		error = -EINVAL;
+		if (!S_ISREG(inode->i_mode))
+			goto dput_and_out;
 
-	error = mnt_want_write(path.mnt);
-	if (error)
-		goto dput_and_out;
+		error = mnt_want_write(path.mnt);
+		if (error)
+			goto dput_and_out;
 
-	error = inode_permission(inode, MAY_WRITE);
-	if (error)
-		goto mnt_drop_write_and_out;
+		error = inode_permission(inode, MAY_WRITE);
+		if (error)
+			goto mnt_drop_write_and_out;
 
-	error = -EPERM;
-	if (IS_APPEND(inode))
-		goto mnt_drop_write_and_out;
+		error = -EPERM;
+		if (IS_APPEND(inode))
+			goto mnt_drop_write_and_out;
 
-	error = get_write_access(inode);
-	if (error)
-		goto mnt_drop_write_and_out;
+		error = get_write_access(inode);
+		if (error)
+			goto mnt_drop_write_and_out;
 
-	/*
-	 * Make sure that there are no leases.  get_write_access() protects
-	 * against the truncate racing with a lease-granting setlease().
-	 */
-	error = break_lease(inode, O_WRONLY);
-	if (error)
-		goto put_write_and_out;
+		/*
+		 * Make sure that there are no leases. get_write_access()
+		 * protects against the truncate racing with a lease-granting
+		 * setlease().
+		 */
+		error = break_lease(inode, O_WRONLY);
+		if (error)
+			goto put_write_and_out;
 
-	error = locks_verify_truncate(inode, NULL, length);
-	if (!error)
-		error = security_path_truncate(&path);
-	if (!error)
-		error = do_truncate(path.dentry, length, 0, NULL);
+		error = locks_verify_truncate(inode, NULL, length);
+		if (!error)
+			error = security_path_truncate(&path);
+		if (!error)
+			error = do_truncate(path.dentry, length, 0, NULL);
 
 put_write_and_out:
-	put_write_access(inode);
+		put_write_access(inode);
 mnt_drop_write_and_out:
-	mnt_drop_write(path.mnt);
+		mnt_drop_write(path.mnt);
 dput_and_out:
-	path_put(&path);
-out:
+		path_put(&path);
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
 	return error;
 }
 
-- 
1.7.11.7

