Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:56913 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756280Ab2J0Mec (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:32 -0400
Received: by mail-ye0-f174.google.com with SMTP id m12so638325yen.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:32 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 24/32] vfs: make lgetxattr retry once on ESTALE
Date: Sat, 27 Oct 2012 08:33:31 -0400
Message-Id: <1351341219-17837-25-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/xattr.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/xattr.c b/fs/xattr.c
index 42284fc..3a5e3ff 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -505,12 +505,17 @@ SYSCALL_DEFINE4(lgetxattr, const char __user *, pathname,
 {
 	struct path path;
 	ssize_t error;
+	unsigned int try = 0;
+	unsigned int lookup_flags = 0;
 
-	error = user_lpath(pathname, &path);
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

