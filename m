Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34533 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbbEXPKo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 May 2015 11:10:44 -0400
Message-ID: <5561E9ED.6060703@gmail.com>
Date: Sun, 24 May 2015 23:10:37 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>, kinglongmee@gmail.com
Subject: [PATCH 3/5 v2] path: New helpers path_get_pin/path_put_unpin for
 path pin
References: <5561E7E4.50604@gmail.com>
In-Reply-To: <5561E7E4.50604@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two helpers for filesystem pining to vfsmnt, not mntget.

v2, new patch.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/namei.c           | 26 ++++++++++++++++++++++++++
 include/linux/path.h |  4 ++++
 2 files changed, 30 insertions(+)

diff --git a/fs/namei.c b/fs/namei.c
index fe30d3b..8f94e7c 100644
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
2.4.1

