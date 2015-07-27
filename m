Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36858 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755260AbbG0DIm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Jul 2015 23:08:42 -0400
Message-ID: <55B5A0B0.7060604@gmail.com>
Date: Mon, 27 Jul 2015 11:08:32 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 4/9 v8] fs: New helper legitimize_mntget() for getting a legitimize
 mnt
References: <55B5A012.1030006@gmail.com>
In-Reply-To: <55B5A012.1030006@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

New helper legitimize_mntget for getting a mnt without setting
MNT_SYNC_UMOUNT | MNT_UMOUNT | MNT_DOOMED, otherwise return NULL.

v8, same as v6

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/namespace.c        | 19 +++++++++++++++++++
 include/linux/mount.h |  1 +
 2 files changed, 20 insertions(+)

diff --git a/fs/namespace.c b/fs/namespace.c
index 2b8aa15..842cf57 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1153,6 +1153,25 @@ struct vfsmount *mntget(struct vfsmount *mnt)
 }
 EXPORT_SYMBOL(mntget);
 
+struct vfsmount *legitimize_mntget(struct vfsmount *vfsmnt)
+{
+	struct mount *mnt;
+
+	if (vfsmnt == NULL)
+		return NULL;
+
+	read_seqlock_excl(&mount_lock);
+	mnt = real_mount(vfsmnt);
+	if (vfsmnt->mnt_flags & (MNT_SYNC_UMOUNT | MNT_UMOUNT | MNT_DOOMED))
+		vfsmnt = NULL;
+	else
+		mnt_add_count(mnt, 1);
+	read_sequnlock_excl(&mount_lock);
+
+	return vfsmnt;
+}
+EXPORT_SYMBOL(legitimize_mntget);
+
 struct vfsmount *mnt_clone_internal(struct path *path)
 {
 	struct mount *p;
diff --git a/include/linux/mount.h b/include/linux/mount.h
index f822c3c..8ae9dc0 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -79,6 +79,7 @@ extern void mnt_drop_write(struct vfsmount *mnt);
 extern void mnt_drop_write_file(struct file *file);
 extern void mntput(struct vfsmount *mnt);
 extern struct vfsmount *mntget(struct vfsmount *mnt);
+extern struct vfsmount *legitimize_mntget(struct vfsmount *vfsmnt);
 extern struct vfsmount *mnt_clone_internal(struct path *path);
 extern int __mnt_is_readonly(struct vfsmount *mnt);
 
-- 
2.4.3

