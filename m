Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:34812 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753423AbeDSNdK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:33:10 -0400
Subject: [PATCH 17/24] VFS: Remove kern_mount_data() [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:33:07 +0100
Message-ID: <152414478717.23902.768680385310283192.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kern_mount_data() isn't used any more so remove it.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/namespace.c     |    7 -------
 include/linux/fs.h |    1 -
 2 files changed, 8 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index c61ff2ab090a..dff482ad87b4 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3192,13 +3192,6 @@ struct vfsmount *kern_mount(struct file_system_type *type)
 }
 EXPORT_SYMBOL_GPL(kern_mount);
 
-struct vfsmount *kern_mount_data(struct file_system_type *type,
-				 void *data, size_t data_size)
-{
-	return vfs_kern_mount(type, SB_KERNMOUNT, type->name, data, data_size);
-}
-EXPORT_SYMBOL_GPL(kern_mount_data);
-
 /*
  * Return true if path is reachable from root
  *
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c1f1428f6c67..9bc78e2c3ce5 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2187,7 +2187,6 @@ mount_pseudo(struct file_system_type *fs_type, char *name,
 extern int register_filesystem(struct file_system_type *);
 extern int unregister_filesystem(struct file_system_type *);
 extern struct vfsmount *kern_mount(struct file_system_type *);
-extern struct vfsmount *kern_mount_data(struct file_system_type *, void *, size_t);
 extern void kern_unmount(struct vfsmount *mnt);
 extern int may_umount_tree(struct vfsmount *);
 extern int may_umount(struct vfsmount *);

