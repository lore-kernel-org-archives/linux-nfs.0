Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:56913 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753686Ab2J0Mdx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:33:53 -0400
Received: by mail-ye0-f174.google.com with SMTP id m12so638325yen.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:33:52 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 02/32] vfs: make fstatat retry on ESTALE errors from getattr call
Date: Sat, 27 Oct 2012 08:33:09 -0400
Message-Id: <1351341219-17837-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
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

