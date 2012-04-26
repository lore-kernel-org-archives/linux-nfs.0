Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:60541 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758105Ab2DZP7J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 11:59:09 -0400
Received: by mail-yx0-f174.google.com with SMTP id l12so1015271yen.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Apr 2012 08:59:09 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com
Subject: [PATCH v1 11/12] vfs: fix linkat to retry on ESTALE errors
Date: Thu, 26 Apr 2012 11:57:22 -0400
Message-Id: <1335455843-16089-10-git-send-email-jlayton@redhat.com>
In-Reply-To: <1335455843-16089-1-git-send-email-jlayton@redhat.com>
References: <1335455843-16089-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index b189dc5..0d54eb3 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3054,6 +3054,7 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 	struct path old_path, new_path;
 	int how = 0;
 	int error;
+	unsigned int try = 0;
 
 	if ((flags & ~(AT_SYMLINK_FOLLOW | AT_EMPTY_PATH)) != 0)
 		return -EINVAL;
@@ -3071,11 +3072,12 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 	if (flags & AT_SYMLINK_FOLLOW)
 		how |= LOOKUP_FOLLOW;
 
+retry:
 	error = user_path_at(olddfd, oldname, how, &old_path);
 	if (error)
 		return error;
 
-	new_dentry = user_path_create(newdfd, newname, &new_path, false, false);
+	new_dentry = user_path_create(newdfd, newname, &new_path, false, try);
 	error = PTR_ERR(new_dentry);
 	if (IS_ERR(new_dentry))
 		goto out;
@@ -3098,7 +3100,10 @@ out_dput:
 	path_put(&new_path);
 out:
 	path_put(&old_path);
-
+	if (retry_estale(error, try++)) {
+		how |= LOOKUP_REVAL;
+		goto retry;
+	}
 	return error;
 }
 
-- 
1.7.7.6

