Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49360 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752121AbdFNPQG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:16:06 -0400
Subject: [PATCH 05/27] VFS: Provide empty name qstr [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:16:00 +0100
Message-ID: <149745336036.10897.10933852145009970782.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide an empty name (ie. "") qstr for general use.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/dcache.c            |    8 ++++++--
 fs/gfs2/dir.c          |    3 +--
 fs/namei.c             |    3 +--
 fs/nsfs.c              |    3 +--
 fs/pipe.c              |    3 +--
 include/linux/dcache.h |    5 +++++
 6 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index cddf39777835..d3da2a3ffd73 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -90,6 +90,11 @@ EXPORT_SYMBOL(rename_lock);
 
 static struct kmem_cache *dentry_cache __read_mostly;
 
+const struct qstr empty_name = QSTR_INIT("", 0);
+EXPORT_SYMBOL(empty_name);
+const struct qstr slash_name = QSTR_INIT("/", 1);
+EXPORT_SYMBOL(slash_name);
+
 /*
  * This is the single most critical data structure when it comes
  * to the dcache: the hashtable for lookups. Somebody should try
@@ -1580,8 +1585,7 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
 	 */
 	dentry->d_iname[DNAME_INLINE_LEN-1] = 0;
 	if (unlikely(!name)) {
-		static const struct qstr anon = QSTR_INIT("/", 1);
-		name = &anon;
+		name = &slash_name;
 		dname = dentry->d_iname;
 	} else if (name->len > DNAME_INLINE_LEN-1) {
 		size_t size = offsetof(struct external_name, name[1]);
diff --git a/fs/gfs2/dir.c b/fs/gfs2/dir.c
index 79113219be5f..a5dfff6a033e 100644
--- a/fs/gfs2/dir.c
+++ b/fs/gfs2/dir.c
@@ -872,7 +872,6 @@ static struct gfs2_leaf *new_leaf(struct inode *inode, struct buffer_head **pbh,
 	struct buffer_head *bh;
 	struct gfs2_leaf *leaf;
 	struct gfs2_dirent *dent;
-	struct qstr name = { .name = "" };
 	struct timespec tv = current_time(inode);
 
 	error = gfs2_alloc_blocks(ip, &bn, &n, 0, NULL);
@@ -896,7 +895,7 @@ static struct gfs2_leaf *new_leaf(struct inode *inode, struct buffer_head **pbh,
 	leaf->lf_sec = cpu_to_be64(tv.tv_sec);
 	memset(leaf->lf_reserved2, 0, sizeof(leaf->lf_reserved2));
 	dent = (struct gfs2_dirent *)(leaf+1);
-	gfs2_qstr2dirent(&name, bh->b_size - sizeof(struct gfs2_leaf), dent);
+	gfs2_qstr2dirent(&empty_name, bh->b_size - sizeof(struct gfs2_leaf), dent);
 	*pbh = bh;
 	return leaf;
 }
diff --git a/fs/namei.c b/fs/namei.c
index 6571a5f5112e..0d35760fee00 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3400,7 +3400,6 @@ static int do_last(struct nameidata *nd,
 
 struct dentry *vfs_tmpfile(struct dentry *dentry, umode_t mode, int open_flag)
 {
-	static const struct qstr name = QSTR_INIT("/", 1);
 	struct dentry *child = NULL;
 	struct inode *dir = dentry->d_inode;
 	struct inode *inode;
@@ -3414,7 +3413,7 @@ struct dentry *vfs_tmpfile(struct dentry *dentry, umode_t mode, int open_flag)
 	if (!dir->i_op->tmpfile)
 		goto out_err;
 	error = -ENOMEM;
-	child = d_alloc(dentry, &name);
+	child = d_alloc(dentry, &slash_name);
 	if (unlikely(!child))
 		goto out_err;
 	error = dir->i_op->tmpfile(dir, child, mode);
diff --git a/fs/nsfs.c b/fs/nsfs.c
index f3db56e83dd2..08127a2b8559 100644
--- a/fs/nsfs.c
+++ b/fs/nsfs.c
@@ -53,7 +53,6 @@ static void nsfs_evict(struct inode *inode)
 static void *__ns_get_path(struct path *path, struct ns_common *ns)
 {
 	struct vfsmount *mnt = nsfs_mnt;
-	struct qstr qname = { .name = "", };
 	struct dentry *dentry;
 	struct inode *inode;
 	unsigned long d;
@@ -85,7 +84,7 @@ static void *__ns_get_path(struct path *path, struct ns_common *ns)
 	inode->i_fop = &ns_file_operations;
 	inode->i_private = ns;
 
-	dentry = d_alloc_pseudo(mnt->mnt_sb, &qname);
+	dentry = d_alloc_pseudo(mnt->mnt_sb, &empty_name);
 	if (!dentry) {
 		iput(inode);
 		return ERR_PTR(-ENOMEM);
diff --git a/fs/pipe.c b/fs/pipe.c
index 73b84baf58f8..97e5be897753 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -739,13 +739,12 @@ int create_pipe_files(struct file **res, int flags)
 	struct inode *inode = get_pipe_inode();
 	struct file *f;
 	struct path path;
-	static struct qstr name = { .name = "" };
 
 	if (!inode)
 		return -ENFILE;
 
 	err = -ENOMEM;
-	path.dentry = d_alloc_pseudo(pipe_mnt->mnt_sb, &name);
+	path.dentry = d_alloc_pseudo(pipe_mnt->mnt_sb, &empty_name);
 	if (!path.dentry)
 		goto err_inode;
 	path.mnt = mntget(pipe_mnt);
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index d2e38dc6172c..3f65a4fa72ed 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -55,6 +55,11 @@ struct qstr {
 
 #define QSTR_INIT(n,l) { { { .len = l } }, .name = n }
 
+extern const char empty_string[];
+extern const struct qstr empty_name;
+extern const char slash_string[];
+extern const struct qstr slash_name;
+
 struct dentry_stat_t {
 	long nr_dentry;
 	long nr_unused;

