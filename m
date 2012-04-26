Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:55219 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590Ab2DZQ6c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 12:58:32 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so1078527yhm.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Apr 2012 09:58:32 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com
Subject: [PATCH v1 07/12] vfs: add a "reval" flag to args for user_path_parent
Date: Thu, 26 Apr 2012 11:57:18 -0400
Message-Id: <1335455843-16089-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1335455843-16089-1-git-send-email-jlayton@redhat.com>
References: <1335455843-16089-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All of the current callers set this to "false" for now, but we'll fix
them later to set it to true when they retry on an ESTALE error.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index e9da40b..b1b116b 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1908,15 +1908,19 @@ int user_path_at(int dfd, const char __user *name, unsigned flags,
 }
 
 static int user_path_parent(int dfd, const char __user *path,
-			struct nameidata *nd, char **name)
+			struct nameidata *nd, char **name, bool reval)
 {
 	char *s = getname(path);
 	int error;
+	unsigned int lookup_flags = LOOKUP_PARENT;
 
 	if (IS_ERR(s))
 		return PTR_ERR(s);
 
-	error = do_path_lookup(dfd, s, LOOKUP_PARENT, nd);
+	if (reval)
+		lookup_flags |= LOOKUP_REVAL;
+
+	error = do_path_lookup(dfd, s, lookup_flags, nd);
 	if (error)
 		putname(s);
 	else
@@ -2759,7 +2763,7 @@ static long do_rmdir(int dfd, const char __user *pathname)
 	struct dentry *dentry;
 	struct nameidata nd;
 
-	error = user_path_parent(dfd, pathname, &nd, &name);
+	error = user_path_parent(dfd, pathname, &nd, &name, false);
 	if (error)
 		return error;
 
@@ -2856,7 +2860,7 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 	struct nameidata nd;
 	struct inode *inode = NULL;
 
-	error = user_path_parent(dfd, pathname, &nd, &name);
+	error = user_path_parent(dfd, pathname, &nd, &name, false);
 	if (error)
 		return error;
 
@@ -3255,11 +3259,11 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
 	char *to;
 	int error;
 
-	error = user_path_parent(olddfd, oldname, &oldnd, &from);
+	error = user_path_parent(olddfd, oldname, &oldnd, &from, false);
 	if (error)
 		goto exit;
 
-	error = user_path_parent(newdfd, newname, &newnd, &to);
+	error = user_path_parent(newdfd, newname, &newnd, &to, false);
 	if (error)
 		goto exit1;
 
-- 
1.7.7.6

