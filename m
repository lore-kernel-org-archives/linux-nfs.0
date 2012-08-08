Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:49060 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758506Ab2HHNWK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 09:22:10 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so724917yhm.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 06:22:09 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v5 16/19] vfs: have do_sys_truncate retry once on an ESTALE error
Date: Wed,  8 Aug 2012 09:21:39 -0400
Message-Id: <1344432102-22312-17-git-send-email-jlayton@redhat.com>
In-Reply-To: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
References: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/open.c | 92 +++++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 51 insertions(+), 41 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index 7babeed..0df0c5d 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -66,62 +66,72 @@ static long do_sys_truncate(const char __user *pathname, loff_t length)
 	struct path path;
 	struct inode *inode;
 	int error;
+	unsigned int lookup_flags = LOOKUP_FOLLOW;
+	unsigned int try = 0;
+	char *name;
 
-	error = -EINVAL;
 	if (length < 0)	/* sorry, but loff_t says... */
-		goto out;
+		return -EINVAL;
 
-	error = user_path(pathname, &path);
-	if (error)
-		goto out;
-	inode = path.dentry->d_inode;
+	name = getname_flags(pathname, lookup_flags, NULL);
+	if (IS_ERR(name))
+		return PTR_ERR(name);
 
-	/* For directories it's -EISDIR, for other non-regulars - -EINVAL */
-	error = -EISDIR;
-	if (S_ISDIR(inode->i_mode))
-		goto dput_and_out;
+	do {
+		error = kern_path_at(AT_FDCWD, name, lookup_flags, &path);
+		if (error)
+			break;
+		inode = path.dentry->d_inode;
 
-	error = -EINVAL;
-	if (!S_ISREG(inode->i_mode))
-		goto dput_and_out;
+		/* For dirs, -EISDIR. For other non-regulars, -EINVAL */
+		error = -EISDIR;
+		if (S_ISDIR(inode->i_mode))
+			goto dput_and_out;
 
-	error = mnt_want_write(path.mnt);
-	if (error)
-		goto dput_and_out;
+		error = -EINVAL;
+		if (!S_ISREG(inode->i_mode))
+			goto dput_and_out;
 
-	error = inode_permission(inode, MAY_WRITE);
-	if (error)
-		goto mnt_drop_write_and_out;
+		error = mnt_want_write(path.mnt);
+		if (error)
+			goto dput_and_out;
 
-	error = -EPERM;
-	if (IS_APPEND(inode))
-		goto mnt_drop_write_and_out;
+		error = inode_permission(inode, MAY_WRITE);
+		if (error)
+			goto mnt_drop_write_and_out;
 
-	error = get_write_access(inode);
-	if (error)
-		goto mnt_drop_write_and_out;
+		error = -EPERM;
+		if (IS_APPEND(inode))
+			goto mnt_drop_write_and_out;
 
-	/*
-	 * Make sure that there are no leases.  get_write_access() protects
-	 * against the truncate racing with a lease-granting setlease().
-	 */
-	error = break_lease(inode, O_WRONLY);
-	if (error)
-		goto put_write_and_out;
+		error = get_write_access(inode);
+		if (error)
+			goto mnt_drop_write_and_out;
 
-	error = locks_verify_truncate(inode, NULL, length);
-	if (!error)
-		error = security_path_truncate(&path);
-	if (!error)
-		error = do_truncate(path.dentry, length, 0, NULL);
+		/*
+		 * Make sure that there are no leases. get_write_access()
+		 * protects against the truncate racing with a lease-granting
+		 * setlease().
+		 */
+		error = break_lease(inode, O_WRONLY);
+		if (error)
+			goto put_write_and_out;
+
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
+	putname(name);
 	return error;
 }
 
-- 
1.7.11.2

