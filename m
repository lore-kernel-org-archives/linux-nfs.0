Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:47879 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756537Ab2J0Meg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:36 -0400
Received: by mail-gh0-f174.google.com with SMTP id g15so699677ghb.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:36 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 27/32] vfs: make removexattr retry once on ESTALE
Date: Sat, 27 Oct 2012 08:33:34 -0400
Message-Id: <1351341219-17837-28-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/xattr.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/xattr.c b/fs/xattr.c
index 8a30ef0..e2071ed 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -645,16 +645,21 @@ SYSCALL_DEFINE2(removexattr, const char __user *, pathname,
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
-		error = removexattr(path.dentry, name);
-		mnt_drop_write(path.mnt);
-	}
-	path_put(&path);
+	do {
+		error = user_path_at(AT_FDCWD, pathname, lookup_flags, &path);
+		if (error)
+			break;
+		error = mnt_want_write(path.mnt);
+		if (!error) {
+			error = removexattr(path.dentry, name);
+			mnt_drop_write(path.mnt);
+		}
+		path_put(&path);
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
 	return error;
 }
 
-- 
1.7.11.7

