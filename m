Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:32839 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbbFYOVs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 10:21:48 -0400
Message-ID: <558C0E6D.3000704@gmail.com>
Date: Thu, 25 Jun 2015 22:21:33 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 04/10 v6] fs: New helper legitimize_mntget() for getting a
 legitimize mnt
References: <558C0D6A.9050104@gmail.com>
In-Reply-To: <558C0D6A.9050104@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

New helper legitimize_mntget for getting a mnt without setting
MNT_SYNC_UMOUNT | MNT_UMOUNT | MNT_DOOMED, otherwise return NULL.

v6, New one

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/namespace.c        | 19 +++++++++++++++++++
 include/linux/mount.h |  1 +
 2 files changed, 20 insertions(+)

diff --git a/fs/namespace.c b/fs/namespace.c
index 1f4f9da..f31d165 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1142,6 +1142,25 @@ struct vfsmount *mntget(struct vfsmount *mnt)
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

