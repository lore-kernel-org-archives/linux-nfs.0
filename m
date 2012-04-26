Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:58169 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758050Ab2DZP6J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 11:58:09 -0400
Received: by yenl12 with SMTP id l12so1014243yen.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Apr 2012 08:58:09 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com
Subject: [PATCH v1 02/12] vfs: make fstatat retry on ESTALE errors from getattr call
Date: Thu, 26 Apr 2012 11:57:13 -0400
Message-Id: <1335455843-16089-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/stat.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/stat.c b/fs/stat.c
index c733dc5..f3eef0d 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -73,7 +73,8 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 {
 	struct path path;
 	int error = -EINVAL;
-	int lookup_flags = 0;
+	unsigned int try = 0;
+	unsigned int lookup_flags = 0;
 
 	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
 		      AT_EMPTY_PATH)) != 0)
@@ -84,12 +85,15 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
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
1.7.7.6

