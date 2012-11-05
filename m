Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:61085 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932993Ab2KEPXD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:23:03 -0500
Received: by mail-ye0-f174.google.com with SMTP id m12so1017195yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:23:03 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 23/34] vfs: make getxattr retry once on an ESTALE error
Date: Mon,  5 Nov 2012 10:22:02 -0500
Message-Id: <1352128933-28526-24-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/xattr.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/xattr.c b/fs/xattr.c
index 5a9ddba..42284fc 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -486,12 +486,17 @@ SYSCALL_DEFINE4(getxattr, const char __user *, pathname,
 {
 	struct path path;
 	ssize_t error;
+	unsigned int try = 0;
+	unsigned int lookup_flags = LOOKUP_FOLLOW;
 
-	error = user_path(pathname, &path);
-	if (error)
-		return error;
-	error = getxattr(path.dentry, name, value, size);
-	path_put(&path);
+	do {
+		error = user_path_at(AT_FDCWD, pathname, lookup_flags, &path);
+		if (error)
+			break;
+		error = getxattr(path.dentry, name, value, size);
+		path_put(&path);
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
 	return error;
 }
 
-- 
1.7.11.7

