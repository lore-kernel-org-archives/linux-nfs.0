Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35374 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbbIGOES (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Sep 2015 10:04:18 -0400
Subject: [PATCH 3/6 v10] path: New helpers path_get_pin/path_put_unpin for
 path,pin
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
References: <55ED9899.9010401@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55ED9955.2040209@gmail.com>
Date: Mon, 7 Sep 2015 22:04:05 +0800
MIME-Version: 1.0
In-Reply-To: <55ED9899.9010401@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two helpers for filesystem pining to vfsmnt, not mntget.

v9, Update base on NeilBrown's new patch
v10, same as v9

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/namei.c           | 26 ++++++++++++++++++++++++++
 include/linux/path.h |  4 ++++
 2 files changed, 30 insertions(+)

diff --git a/fs/namei.c b/fs/namei.c
index 29b9279..3a5b0eb 100644
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
+int path_put_unpin(struct path *path, struct fs_pin *p)
+{
+	dput(path->dentry);
+	return pin_remove(p);
+}
+EXPORT_SYMBOL(path_put_unpin);
+
 #define EMBEDDED_LEVELS 2
 struct nameidata {
 	struct path	path;
diff --git a/include/linux/path.h b/include/linux/path.h
index d137218..40d376a 100644
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
+extern int path_put_unpin(struct path *, struct fs_pin *);
+
 static inline int path_equal(const struct path *path1, const struct path *path2)
 {
 	return path1->mnt == path2->mnt && path1->dentry == path2->dentry;
-- 
2.4.3

