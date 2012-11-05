Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:52182 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933014Ab2KEPXA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:23:00 -0500
Received: by mail-ye0-f174.google.com with SMTP id m12so1017184yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:22:59 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 21/34] vfs: allow setxattr to retry once on ESTALE errors
Date: Mon,  5 Nov 2012 10:22:00 -0500
Message-Id: <1352128933-28526-22-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/xattr.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/xattr.c b/fs/xattr.c
index f3a2ffa..5b6e48d 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -370,16 +370,21 @@ SYSCALL_DEFINE5(setxattr, const char __user *, pathname,
 {
 	struct path path;
 	int error;
+	unsigned int try = 0;
+	unsigned int lookup_flags = LOOKUP_FOLLOW;
 
-	error = user_path(pathname, &path);
-	if (error)
-		return error;
-	error = mnt_want_write(path.mnt);
-	if (!error) {
-		error = setxattr(path.dentry, name, value, size, flags);
-		mnt_drop_write(path.mnt);
-	}
-	path_put(&path);
+	do {
+		error = user_path_at(AT_FDCWD, pathname, lookup_flags, &path);
+		if (error)
+			break;
+		error = mnt_want_write(path.mnt);
+		if (!error) {
+			error = setxattr(path.dentry, name, value, size, flags);
+			mnt_drop_write(path.mnt);
+		}
+		path_put(&path);
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
 	return error;
 }
 
-- 
1.7.11.7

