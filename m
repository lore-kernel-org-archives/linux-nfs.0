From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RFC [PATCH 1/6] VFS: Add GPL_EXPORTED function vfs_kern_mount()
Date: Tue, 11 Apr 2006 14:05:30 -0400
Message-ID: <20060411180530.12579.19894.stgit@lade.trondhjem.org>
References: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

do_kern_mount() does not allow the kernel to use private mount interfaces
without exposing the same interfaces to userland. The problem is that the
filesystem is referenced by name, thus meaning that it and its mount
interface must be registered in the global filesystem list.

vfs_kern_mount() passes the struct file_system_type as an explicit
parameter in order to overcome this limitation.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/super.c            |   22 +++++++++++++++-------
 include/linux/mount.h |    5 +++++
 2 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index a66f66b..848be4f 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -800,16 +800,12 @@ struct super_block *get_sb_single(struct
 EXPORT_SYMBOL(get_sb_single);
=20
 struct vfsmount *
-do_kern_mount(const char *fstype, int flags, const char *name, void *dat=
a)
+vfs_kern_mount(struct file_system_type *type, int flags, const char *nam=
e, void *data)
 {
-	struct file_system_type *type =3D get_fs_type(fstype);
 	struct super_block *sb =3D ERR_PTR(-ENOMEM);
 	struct vfsmount *mnt;
 	int error;
 	char *secdata =3D NULL;
-
-	if (!type)
-		return ERR_PTR(-ENODEV);
=20
 	mnt =3D alloc_vfsmnt(name);
 	if (!mnt)
@@ -841,7 +837,6 @@ do_kern_mount(const char *fstype, int fl
 	mnt->mnt_parent =3D mnt;
 	up_write(&sb->s_umount);
 	free_secdata(secdata);
-	put_filesystem(type);
 	return mnt;
 out_sb:
 	up_write(&sb->s_umount);
@@ -852,8 +847,21 @@ out_free_secdata:
 out_mnt:
 	free_vfsmnt(mnt);
 out:
-	put_filesystem(type);
 	return (struct vfsmount *)sb;
+}
+
+EXPORT_SYMBOL_GPL(vfs_kern_mount);
+
+struct vfsmount *
+do_kern_mount(const char *fstype, int flags, const char *name, void *dat=
a)
+{
+	struct file_system_type *type =3D get_fs_type(fstype);
+	struct vfsmount *mnt;
+	if (!type)
+		return ERR_PTR(-ENODEV);
+	mnt =3D vfs_kern_mount(type, flags, name, data);
+	put_filesystem(type);
+	return mnt;
 }
=20
 EXPORT_SYMBOL_GPL(do_kern_mount);
diff --git a/include/linux/mount.h b/include/linux/mount.h
index b7472ae..aff68c3 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -73,6 +73,11 @@ extern struct vfsmount *alloc_vfsmnt(con
 extern struct vfsmount *do_kern_mount(const char *fstype, int flags,
 				      const char *name, void *data);
=20
+struct file_system_type;
+extern struct vfsmount *vfs_kern_mount(struct file_system_type *type,
+				      int flags, const char *name,
+				      void *data);
+
 struct nameidata;
=20
 extern int do_add_mount(struct vfsmount *newmnt, struct nameidata *nd,
