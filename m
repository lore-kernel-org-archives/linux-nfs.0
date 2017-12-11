Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46362 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751956AbdLKGEc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Dec 2017 01:04:32 -0500
From: NeilBrown <neilb@suse.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>
Date: Mon, 11 Dec 2017 17:04:05 +1100
Subject: [PATCH 2/4] fs/notify: don't put file handle buffer on stack.
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Amir Goldstein <amir73il@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Message-ID: <151297224516.7818.4371883364929399006.stgit@noble>
In-Reply-To: <151297214390.7818.7216826079527521005.stgit@noble>
References: <151297214390.7818.7216826079527521005.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A file handle buffer is not tiny, and could need to be larger in future,
so it isn't safe to allocate one on the stack.  Instead, we need to
kmalloc().

There is no way to return an error status from a ->show_fdinfo()
function, so if the kmalloc fails, we silently exclude the filehandle
from the output.  As it is at the end of line, this shouldn't
upset parsing too much.  In any case, it can only fail when the
process is being killed by the OOM killer, so the file will never
be parsed anyway.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/notify/fdinfo.c |   47 +++++++++++++++++++++++++----------------------
 1 file changed, 25 insertions(+), 22 deletions(-)

diff --git a/fs/notify/fdinfo.c b/fs/notify/fdinfo.c
index d1135ed61229..7347f295bc0f 100644
--- a/fs/notify/fdinfo.c
+++ b/fs/notify/fdinfo.c
@@ -23,54 +23,56 @@
 
 static void show_fdinfo(struct seq_file *m, struct file *f,
 			void (*show)(struct seq_file *m,
-				     struct fsnotify_mark *mark))
+				     struct fsnotify_mark *mark,
+				     struct fid *fh))
 {
 	struct fsnotify_group *group = f->private_data;
 	struct fsnotify_mark *mark;
+	struct fid *fh = kmalloc(MAX_HANDLE_SZ, GFP_KERNEL);
 
 	mutex_lock(&group->mark_mutex);
 	list_for_each_entry(mark, &group->marks_list, g_list) {
-		show(m, mark);
+		show(m, mark, fh);
 		if (seq_has_overflowed(m))
 			break;
 	}
 	mutex_unlock(&group->mark_mutex);
+	kfree(fh);
 }
 
 #if defined(CONFIG_EXPORTFS)
-static void show_mark_fhandle(struct seq_file *m, struct inode *inode)
+static void show_mark_fhandle(struct seq_file *m, struct inode *inode,
+			      struct fid *fhbuf)
 {
-	struct {
-		struct file_handle handle;
-		u8 pad[MAX_HANDLE_SZ];
-	} f;
 	int size, ret, i;
+	unsigned char *bytes;
 
-	f.handle.handle_bytes = sizeof(f.pad);
-	size = f.handle.handle_bytes >> 2;
+	if (!fhbuf)
+		return;
+	size = MAX_HANDLE_SZ >> 2;
 
-	ret = exportfs_encode_inode_fh(inode, (struct fid *)f.handle.f_handle, &size, 0);
+	ret = exportfs_encode_inode_fh(inode, fhbuf, &size, 0);
 	if ((ret == FILEID_INVALID) || (ret < 0))
 		return;
 
-	f.handle.handle_type = ret;
-	f.handle.handle_bytes = size * sizeof(u32);
-
-	seq_printf(m, "fhandle-bytes:%x fhandle-type:%x f_handle:",
-		   f.handle.handle_bytes, f.handle.handle_type);
+	seq_printf(m, "fhandle-bytes:%zx fhandle-type:%x f_handle:",
+		   size * sizeof(u32), ret);
 
-	for (i = 0; i < f.handle.handle_bytes; i++)
-		seq_printf(m, "%02x", (int)f.handle.f_handle[i]);
+	bytes = (unsigned char *)(fhbuf->raw);
+	for (i = 0; i < size * sizeof(u32); i++)
+		seq_printf(m, "%02x", bytes[i]);
 }
 #else
-static void show_mark_fhandle(struct seq_file *m, struct inode *inode)
+static void show_mark_fhandle(struct seq_file *m, struct inode *inode,
+			      struct fid *fhbuf)
 {
 }
 #endif
 
 #ifdef CONFIG_INOTIFY_USER
 
-static void inotify_fdinfo(struct seq_file *m, struct fsnotify_mark *mark)
+static void inotify_fdinfo(struct seq_file *m, struct fsnotify_mark *mark,
+			   struct fid *fhbuf)
 {
 	struct inotify_inode_mark *inode_mark;
 	struct inode *inode;
@@ -91,7 +93,7 @@ static void inotify_fdinfo(struct seq_file *m, struct fsnotify_mark *mark)
 		seq_printf(m, "inotify wd:%x ino:%lx sdev:%x mask:%x ignored_mask:%x ",
 			   inode_mark->wd, inode->i_ino, inode->i_sb->s_dev,
 			   mask, mark->ignored_mask);
-		show_mark_fhandle(m, inode);
+		show_mark_fhandle(m, inode, fhbuf);
 		seq_putc(m, '\n');
 		iput(inode);
 	}
@@ -106,7 +108,8 @@ void inotify_show_fdinfo(struct seq_file *m, struct file *f)
 
 #ifdef CONFIG_FANOTIFY
 
-static void fanotify_fdinfo(struct seq_file *m, struct fsnotify_mark *mark)
+static void fanotify_fdinfo(struct seq_file *m, struct fsnotify_mark *mark,
+			    struct fid *fhbuf)
 {
 	unsigned int mflags = 0;
 	struct inode *inode;
@@ -121,7 +124,7 @@ static void fanotify_fdinfo(struct seq_file *m, struct fsnotify_mark *mark)
 		seq_printf(m, "fanotify ino:%lx sdev:%x mflags:%x mask:%x ignored_mask:%x ",
 			   inode->i_ino, inode->i_sb->s_dev,
 			   mflags, mark->mask, mark->ignored_mask);
-		show_mark_fhandle(m, inode);
+		show_mark_fhandle(m, inode, fhbuf);
 		seq_putc(m, '\n');
 		iput(inode);
 	} else if (mark->connector->flags & FSNOTIFY_OBJ_TYPE_VFSMOUNT) {


