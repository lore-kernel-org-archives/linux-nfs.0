Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:42139 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760797Ab2IGOTI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Sep 2012 10:19:08 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so3363913vbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 07 Sep 2012 07:19:08 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v6 09/20] vfs: add a reval argument to user_path_parent
Date: Fri,  7 Sep 2012 10:18:16 -0400
Message-Id: <1347027507-20956-10-git-send-email-jlayton@redhat.com>
In-Reply-To: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
References: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...so we can tell it when to set LOOKUP_REVAL.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index e05d6ee..51841ec 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2183,15 +2183,20 @@ int user_path_at(int dfd, const char __user *name, unsigned flags,
  *     path-walking is complete.
  */
 static struct getname_info *
-user_path_parent(int dfd, const char __user *path, struct nameidata *nd)
+user_path_parent(int dfd, const char __user *path, struct nameidata *nd,
+		 unsigned int reval)
 {
 	struct getname_info *s = getname(path);
 	int error;
+	unsigned int flags = LOOKUP_PARENT;
+
+	if (reval)
+		flags |= LOOKUP_REVAL;
 
 	if (IS_ERR(s))
 		return s;
 
-	error = ginfo_lookup(dfd, s, LOOKUP_PARENT, nd);
+	error = ginfo_lookup(dfd, s, flags, nd);
 	if (error) {
 		putname(s);
 		return ERR_PTR(error);
@@ -3339,7 +3344,7 @@ static long do_rmdir(int dfd, const char __user *pathname)
 	struct dentry *dentry;
 	struct nameidata nd;
 
-	name = user_path_parent(dfd, pathname, &nd);
+	name = user_path_parent(dfd, pathname, &nd, 0);
 	if (IS_ERR(name))
 		return PTR_ERR(name);
 
@@ -3435,7 +3440,7 @@ static long do_unlinkat(int dfd, const char __user *pathname)
 	struct nameidata nd;
 	struct inode *inode = NULL;
 
-	name = user_path_parent(dfd, pathname, &nd);
+	name = user_path_parent(dfd, pathname, &nd, 0);
 	if (IS_ERR(name))
 		return PTR_ERR(name);
 
@@ -3830,13 +3835,13 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
 	struct getname_info *to;
 	int error;
 
-	from = user_path_parent(olddfd, oldname, &oldnd);
+	from = user_path_parent(olddfd, oldname, &oldnd, 0);
 	if (IS_ERR(from)) {
 		error = PTR_ERR(from);
 		goto exit;
 	}
 
-	to = user_path_parent(newdfd, newname, &newnd);
+	to = user_path_parent(newdfd, newname, &newnd, 0);
 	if (IS_ERR(to)) {
 		error = PTR_ERR(to);
 		goto exit1;
-- 
1.7.11.4

