Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:41191 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454Ab2KEPWZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:22:25 -0500
Received: by mail-gh0-f174.google.com with SMTP id g15so1012581ghb.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:22:24 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 02/34] vfs: make fstatat retry on ESTALE errors from getattr call
Date: Mon,  5 Nov 2012 10:21:41 -0500
Message-Id: <1352128933-28526-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/stat.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/stat.c b/fs/stat.c
index eae4946..c97a17e 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -74,7 +74,8 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 {
 	struct path path;
 	int error = -EINVAL;
-	int lookup_flags = 0;
+	unsigned int try = 0;
+	unsigned int lookup_flags = 0;
 
 	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
 		      AT_EMPTY_PATH)) != 0)
@@ -85,12 +86,15 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 	if (flag & AT_EMPTY_PATH)
 		lookup_flags |= LOOKUP_EMPTY;
 
-	error = user_path_at(dfd, filename, lookup_flags, &path);
-	if (error)
-		goto out;
+	do {
+		error = user_path_at(dfd, filename, lookup_flags, &path);
+		if (error)
+			break;
 
-	error = vfs_getattr(path.mnt, path.dentry, stat);
-	path_put(&path);
+		error = vfs_getattr(path.mnt, path.dentry, stat);
+		path_put(&path);
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
 out:
 	return error;
 }
-- 
1.7.11.7

