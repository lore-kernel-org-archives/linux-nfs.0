Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4135 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751487AbdJFPvA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Oct 2017 11:51:00 -0400
Subject: [PATCH 14/14] VFS: Remove kern_mount_data() [ver #6]
From: David Howells <dhowells@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Fri, 06 Oct 2017 16:50:58 +0100
Message-ID: <150730505814.6182.8657701161394210225.stgit@warthog.procyon.org.uk>
In-Reply-To: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
References: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kern_mount_data() isn't used any more so remove it.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namespace.c     |    6 ------
 include/linux/fs.h |    1 -
 2 files changed, 7 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 8676658b6b2c..091a63a63fa5 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3181,12 +3181,6 @@ struct vfsmount *kern_mount(struct file_system_type *type)
 }
 EXPORT_SYMBOL_GPL(kern_mount);
 
-struct vfsmount *kern_mount_data(struct file_system_type *type, void *data)
-{
-	return vfs_kern_mount(type, SB_KERNMOUNT, type->name, data);
-}
-EXPORT_SYMBOL_GPL(kern_mount_data);
-
 /*
  * Mount a new, prepared superblock (specified by fs_fd) on the location
  * specified by dfd and dir_name.  dfd can be AT_FDCWD, a dir fd or a container
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f391263c62a1..b1433076b8e2 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2168,7 +2168,6 @@ mount_pseudo(struct file_system_type *fs_type, char *name,
 extern int register_filesystem(struct file_system_type *);
 extern int unregister_filesystem(struct file_system_type *);
 extern struct vfsmount *kern_mount(struct file_system_type *);
-extern struct vfsmount *kern_mount_data(struct file_system_type *, void *);
 extern void kern_unmount(struct vfsmount *mnt);
 extern int may_umount_tree(struct vfsmount *);
 extern int may_umount(struct vfsmount *);

