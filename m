Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:61781 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933056Ab2KEPXH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:23:07 -0500
Received: by mail-yh0-f46.google.com with SMTP id m54so972013yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:23:07 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 25/34] vfs: make listxattr retry once on ESTALE error
Date: Mon,  5 Nov 2012 10:22:04 -0500
Message-Id: <1352128933-28526-26-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/xattr.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/xattr.c b/fs/xattr.c
index 3a5e3ff..8a318a4 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -576,12 +576,17 @@ SYSCALL_DEFINE3(listxattr, const char __user *, pathname, char __user *, list,
 {
 	struct path path;
 	ssize_t error;
+	unsigned int try = 0;
+	unsigned int lookup_flags = LOOKUP_FOLLOW;
 
-	error = user_path(pathname, &path);
-	if (error)
-		return error;
-	error = listxattr(path.dentry, list, size);
-	path_put(&path);
+	do {
+		error = user_path_at(AT_FDCWD, pathname, lookup_flags, &path);
+		if (error)
+			break;
+		error = listxattr(path.dentry, list, size);
+		path_put(&path);
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
 	return error;
 }
 
-- 
1.7.11.7

