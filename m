Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35506 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbbFYOUJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 10:20:09 -0400
Message-ID: <558C0E0E.4030102@gmail.com>
Date: Thu, 25 Jun 2015 22:19:58 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 03/10 v6] path: New helpers path_get_pin/path_put_unpin for
 path pin
References: <558C0D6A.9050104@gmail.com>
In-Reply-To: <558C0D6A.9050104@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two helpers for filesystem pining to vfsmnt, not mntget.

v4, v5, v6 same as v2.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/namei.c           | 26 ++++++++++++++++++++++++++
 include/linux/path.h |  4 ++++
 2 files changed, 30 insertions(+)

diff --git a/fs/namei.c b/fs/namei.c
index 4a8d998b..ac71c65 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -492,6 +492,32 @@ void path_put(const struct path *path)
 }
 EXPORT_SYMBOL(path_put);
 
+/**
+ * path_get_pin - get a reference to a path's dentry
+ *                and pin to path's vfsmnt
+ * @path: path to get the reference to
+ * @p: the fs_pin pin to vfsmnt
+ */
+void path_get_pin(struct path *path, struct fs_pin *p)
+{
+	dget(path->dentry);
+	pin_insert_group(p, path->mnt, NULL);
+}
+EXPORT_SYMBOL(path_get_pin);
+
+/**
+ * path_put_unpin - put a reference to a path's dentry
+ *                  and remove pin to path's vfsmnt
+ * @path: path to put the reference to
+ * @p: the fs_pin removed from vfsmnt
+ */
+void path_put_unpin(struct path *path, struct fs_pin *p)
+{
+	dput(path->dentry);
+	pin_remove(p);
+}
+EXPORT_SYMBOL(path_put_unpin);
+
 struct nameidata {
 	struct path	path;
 	struct qstr	last;
diff --git a/include/linux/path.h b/include/linux/path.h
index d137218..34599fb 100644
--- a/include/linux/path.h
+++ b/include/linux/path.h
@@ -3,6 +3,7 @@
 
 struct dentry;
 struct vfsmount;
+struct fs_pin;
 
 struct path {
 	struct vfsmount *mnt;
@@ -12,6 +13,9 @@ struct path {
 extern void path_get(const struct path *);
 extern void path_put(const struct path *);
 
+extern void path_get_pin(struct path *, struct fs_pin *);
+extern void path_put_unpin(struct path *, struct fs_pin *);
+
 static inline int path_equal(const struct path *path1, const struct path *path2)
 {
 	return path1->mnt == path2->mnt && path1->dentry == path2->dentry;
-- 
2.4.3

