Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35005 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbIGOFL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Sep 2015 10:05:11 -0400
Subject: [PATCH 4/6 v10] fs: New helper legitimize_mntget() for getting a
 legitimize mnt
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
References: <55ED9899.9010401@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55ED9986.3040203@gmail.com>
Date: Mon, 7 Sep 2015 22:04:54 +0800
MIME-Version: 1.0
In-Reply-To: <55ED9899.9010401@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

New helper legitimize_mntget for getting a mnt without setting
MNT_SYNC_UMOUNT | MNT_UMOUNT | MNT_DOOMED, otherwise return NULL.

v9, Update using read_seqbegin_or_lock instead read_seqlock_excl
v10, fix bad logical of using seqlock

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/namespace.c        | 38 ++++++++++++++++++++++++++++++++++++++
 include/linux/mount.h |  1 +
 2 files changed, 39 insertions(+)

diff --git a/fs/namespace.c b/fs/namespace.c
index 0570729..6377672 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1153,6 +1153,44 @@ struct vfsmount *mntget(struct vfsmount *mnt)
 }
 EXPORT_SYMBOL(mntget);
 
+struct vfsmount *legitimize_mntget(struct vfsmount *vfsmnt)
+{
+	struct mount *mnt;
+	unsigned seq = 0;
+
+	if (vfsmnt == NULL)
+		return NULL;
+
+	rcu_read_lock();
+retry:
+	read_seqbegin_or_lock(&mount_lock, &seq);
+
+	if (vfsmnt->mnt_flags & (MNT_SYNC_UMOUNT | MNT_UMOUNT | MNT_DOOMED))
+		vfsmnt = NULL;
+	else {
+		mnt = real_mount(vfsmnt);
+		mnt_add_count(mnt, 1);
+		if (need_seqretry(&mount_lock, seq)) {
+			/* lost the race, need to try again */
+			if (vfsmnt->mnt_flags & MNT_SYNC_UMOUNT) {
+				/* no point trying... */
+				mnt_add_count(mnt, -1);
+				vfsmnt = NULL;
+			} else {
+				mntput(vfsmnt);
+				seq = 1;
+				goto retry;
+			}
+		}
+	}
+
+	done_seqretry(&mount_lock, seq);
+	rcu_read_unlock();
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

