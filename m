From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RFC [PATCH 5/6] NFS: Ensure the client submounts,
	when it crosses a server mountpoint.
Date: Tue, 11 Apr 2006 14:05:39 -0400
Message-ID: <20060411180539.12579.89064.stgit@lade.trondhjem.org>
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

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/Makefile        |    3=20
 fs/nfs/dir.c           |   16 +++
 fs/nfs/inode.c         |  303 ++++++++++++++++++++++++++++++++++++++++++=
++++++
 fs/nfs/namespace.c     |   89 ++++++++++++++
 fs/nfs/nfs4_fs.h       |    1=20
 fs/nfs/nfs4proc.c      |    2=20
 include/linux/nfs_fs.h |    9 +
 7 files changed, 418 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index ec61fd5..d9d494c 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -5,7 +5,8 @@ #
 obj-$(CONFIG_NFS_FS) +=3D nfs.o
=20
 nfs-y 			:=3D dir.o file.o inode.o nfs2xdr.o pagelist.o \
-			   proc.o read.o symlink.o unlink.o write.o
+			   proc.o read.o symlink.o unlink.o write.o \
+			   namespace.o
 nfs-$(CONFIG_ROOT_NFS)	+=3D nfsroot.o mount_clnt.o     =20
 nfs-$(CONFIG_NFS_V3)	+=3D nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+=3D nfs3acl.o
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index a23f348..866672a 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -869,6 +869,17 @@ int nfs_is_exclusive_create(struct inode
 	return (nd->intent.open.flags & O_EXCL) !=3D 0;
 }
=20
+static inline int nfs_reval_fsid(struct inode *dir,
+		struct nfs_fh *fh, struct nfs_fattr *fattr)
+{
+	struct nfs_server *server =3D NFS_SERVER(dir);
+
+	if (!nfs_fsid_equal(&server->fsid, &fattr->fsid))
+		/* Revalidate fsid on root dir */
+		return __nfs_revalidate_inode(server, dir->i_sb->s_root->d_inode);
+	return 0;
+}
+
 static struct dentry *nfs_lookup(struct inode *dir, struct dentry * dent=
ry, struct nameidata *nd)
 {
 	struct dentry *res;
@@ -897,6 +908,11 @@ static struct dentry *nfs_lookup(struct=20
 	error =3D NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr=
);
 	if (error =3D=3D -ENOENT)
 		goto no_entry;
+	if (error < 0) {
+		res =3D ERR_PTR(error);
+		goto out_unlock;
+	}
+	error =3D nfs_reval_fsid(dir, &fhandle, &fattr);
 	if (error < 0) {
 		res =3D ERR_PTR(error);
 		goto out_unlock;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index bf9d404..f5a133f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -238,6 +238,14 @@ nfs_block_size(unsigned long bsize, unsi
 	return nfs_block_bits(bsize, nrbitsp);
 }
=20
+static inline void
+nfs_super_set_maxbytes(struct super_block *sb, __u64 maxfilesize)
+{
+	sb->s_maxbytes =3D (loff_t)maxfilesize;
+	if (sb->s_maxbytes > MAX_LFS_FILESIZE || sb->s_maxbytes <=3D 0)
+		sb->s_maxbytes =3D MAX_LFS_FILESIZE;
+}
+
 /*
  * Obtain the root inode of the file system.
  */
@@ -348,9 +356,7 @@ nfs_sb_init(struct super_block *sb, rpc_
 	}
 	server->backing_dev_info.ra_pages =3D server->rpages * NFS_MAX_READAHEA=
D;
=20
-	sb->s_maxbytes =3D fsinfo.maxfilesize;
-	if (sb->s_maxbytes > MAX_LFS_FILESIZE)=20
-		sb->s_maxbytes =3D MAX_LFS_FILESIZE;=20
+	nfs_super_set_maxbytes(sb, fsinfo.maxfilesize);
=20
 	server->client->cl_intr =3D (server->flags & NFS_MOUNT_INTR) ? 1 : 0;
 	server->client->cl_softrtry =3D (server->flags & NFS_MOUNT_SOFT) ? 1 : =
0;
@@ -897,6 +903,11 @@ nfs_fhget(struct super_block *sb, struct
 			if (nfs_server_capable(inode, NFS_CAP_READDIRPLUS)
 			    && fattr->size <=3D NFS_LIMIT_READDIRPLUS)
 				set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
+			/* Deal with crossing mountpoints */
+			if (!nfs_fsid_equal(&NFS_SB(sb)->fsid, &fattr->fsid)) {
+				inode->i_op =3D &nfs_mountpoint_inode_operations;
+				inode->i_fop =3D NULL;
+			}
 		} else if (S_ISLNK(inode->i_mode))
 			inode->i_op =3D &nfs_symlink_inode_operations;
 		else
@@ -1670,6 +1681,141 @@ #endif
 /*
  * File system information
  */
+
+/*
+ * nfs_path - reconstruct the path given an arbitrary dentry
+ * @base - arbitrary string to prepend to the path
+ * @dentry - pointer to dentry
+ * @buffer - result buffer
+ * @buflen - length of buffer
+ *
+ * Helper function for constructing the path from the
+ * root dentry to an arbitrary hashed dentry.
+ *
+ * This is mainly for use in figuring out the path on the
+ * server side when automounting on top of an existing partition.
+ */
+static char *nfs_path(const char *base, const struct dentry *dentry,
+		      char *buffer, ssize_t buflen)
+{
+	char *end =3D buffer+buflen;
+	int namelen;
+
+	*--end =3D '\0';
+	buflen--;
+	spin_lock(&dcache_lock);
+	while (!IS_ROOT(dentry)) {
+		namelen =3D dentry->d_name.len;
+		buflen -=3D namelen + 1;
+		if (buflen < 0)
+			goto Elong;
+		end -=3D namelen;
+		memcpy(end, dentry->d_name.name, namelen);
+		*--end =3D '/';
+		dentry =3D dentry->d_parent;
+	}
+	spin_unlock(&dcache_lock);
+	namelen =3D strlen(base);
+	/* Strip off excess slashes in base string */
+	while (namelen > 0 && base[namelen - 1] =3D=3D '/')
+		namelen--;
+	buflen -=3D namelen;
+	if (buflen < 0)
+		goto Elong;
+	end -=3D namelen;
+	memcpy(end, base, namelen);
+	return end;
+Elong:
+	return ERR_PTR(-ENAMETOOLONG);
+}
+
+struct nfs_clone_mount {
+	const struct super_block *sb;
+	const struct dentry *dentry;
+	struct nfs_fh *fh;
+	struct nfs_fattr *fattr;
+};
+
+static struct super_block *nfs_clone_generic_sb(struct nfs_clone_mount *=
data,
+		struct super_block *(*clone_client)(struct nfs_server *, struct nfs_cl=
one_mount *))
+{
+	struct nfs_server *server;
+	struct nfs_server *parent =3D NFS_SB(data->sb);
+	struct super_block *sb =3D ERR_PTR(-EINVAL);
+	void *err =3D ERR_PTR(-ENOMEM);
+	struct inode *root_inode;
+	struct nfs_fsinfo fsinfo;
+	int len;
+
+	server =3D kmalloc(sizeof(struct nfs_server), GFP_KERNEL);
+	if (server =3D=3D NULL)
+		goto out_err;
+	memcpy(server, parent, sizeof(*server));
+	len =3D strlen(parent->hostname) + 1;
+	server->hostname =3D kmalloc(len, GFP_KERNEL);
+	if (server->hostname =3D=3D NULL)
+		goto free_server;
+	memcpy(server->hostname, parent->hostname, len);
+	server->fsid =3D data->fattr->fsid;
+	nfs_copy_fh(&server->fh, data->fh);
+	if (rpciod_up() !=3D 0)
+		goto free_hostname;
+
+	sb =3D clone_client(server, data);
+	if (IS_ERR((err =3D sb)) || sb->s_root)
+		goto kill_rpciod;
+
+	sb->s_op =3D data->sb->s_op;
+	sb->s_blocksize =3D data->sb->s_blocksize;
+	sb->s_blocksize_bits =3D data->sb->s_blocksize_bits;
+	sb->s_maxbytes =3D data->sb->s_maxbytes;
+
+	server->client_sys =3D server->client_acl =3D ERR_PTR(-EINVAL);
+	err =3D ERR_PTR(-ENOMEM);
+	server->io_stats =3D nfs_alloc_iostats();
+	if (server->io_stats =3D=3D NULL)
+		goto out_deactivate;
+
+	server->client =3D rpc_clone_client(parent->client);
+	if (IS_ERR((err =3D server->client)))
+		goto out_deactivate;
+	if (!IS_ERR(parent->client_sys)) {
+		server->client_sys =3D rpc_clone_client(parent->client_sys);
+		if (IS_ERR((err =3D server->client_sys)))
+			goto out_deactivate;
+	}
+	if (!IS_ERR(parent->client_acl)) {
+		server->client_acl =3D rpc_clone_client(parent->client_acl);
+		if (IS_ERR((err =3D server->client_acl)))
+			goto out_deactivate;
+	}
+	root_inode =3D nfs_fhget(sb, data->fh, data->fattr);
+	if (!root_inode)
+		goto out_deactivate;
+	sb->s_root =3D d_alloc_root(root_inode);
+	if (!sb->s_root)
+		goto out_put_root;
+	fsinfo.fattr =3D data->fattr;
+	if (NFS_PROTO(root_inode)->fsinfo(server, data->fh, &fsinfo) =3D=3D 0)
+		nfs_super_set_maxbytes(sb, fsinfo.maxfilesize);
+	sb->s_root->d_op =3D server->rpc_ops->dentry_ops;
+	sb->s_flags |=3D MS_ACTIVE;
+	return sb;
+out_put_root:
+	iput(root_inode);
+out_deactivate:
+	up_write(&sb->s_umount);
+	deactivate_super(sb);
+	return (struct super_block *)err;
+kill_rpciod:
+	rpciod_down();
+free_hostname:
+	kfree(server->hostname);
+free_server:
+	kfree(server);
+out_err:
+	return (struct super_block *)err;
+}
=20
 static int nfs_set_super(struct super_block *s, void *data)
 {
@@ -1827,7 +1973,32 @@ static struct file_system_type nfs_fs_ty
 	.kill_sb	=3D nfs_kill_super,
 	.fs_flags	=3D FS_ODD_RENAME|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
 };
+
+static struct super_block *nfs_clone_client(struct nfs_server *server, s=
truct nfs_clone_mount *data)
+{
+	struct super_block *sb;
=20
+	sb =3D sget(&nfs_fs_type, nfs_compare_super, nfs_set_super, server);
+	if (!IS_ERR(sb) && sb->s_root =3D=3D NULL && !(server->flags & NFS_MOUN=
T_NONLM))
+		lockd_up();
+	return sb;
+}
+
+static struct super_block *nfs_clone_nfs_sb(struct file_system_type *fs_=
type,
+		int flags, const char *dev_name, void *raw_data)
+{
+	struct nfs_clone_mount *data =3D raw_data;
+	return nfs_clone_generic_sb(data, nfs_clone_client);
+}
+
+static struct file_system_type clone_nfs_fs_type =3D {
+	.owner		=3D THIS_MODULE,
+	.name		=3D "nfs",
+	.get_sb		=3D nfs_clone_nfs_sb,
+	.kill_sb	=3D nfs_kill_super,
+	.fs_flags	=3D FS_ODD_RENAME|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
 #ifdef CONFIG_NFS_V4
=20
 static void nfs4_clear_inode(struct inode *);
@@ -2177,7 +2348,76 @@ static int param_set_idmap_timeout(const
=20
 module_param_call(idmap_cache_timeout, param_set_idmap_timeout, param_ge=
t_int,
 		 &nfs_idmap_cache_timeout, 0644);
+
+/* Constructs the SERVER-side path */
+static inline char *nfs4_path(const struct dentry *dentry, char *buffer,=
 ssize_t buflen)
+{
+	return nfs_path(NFS_SB(dentry->d_sb)->mnt_path, dentry, buffer, buflen)=
;
+}
+
+static inline char *nfs4_dup_path(const struct dentry *dentry)
+{
+	char *page =3D (char *) __get_free_page(GFP_USER);
+	char *path;
=20
+	path =3D nfs4_path(dentry, page, PAGE_SIZE);
+	if (!IS_ERR(path)) {
+		int len =3D PAGE_SIZE + page - path;
+		char *tmp =3D path;
+
+		path =3D kmalloc(len, GFP_KERNEL);
+		if (path)
+			memcpy(path, tmp, len);
+		else
+			path =3D ERR_PTR(-ENOMEM);
+	}
+	free_page((unsigned long)page);
+	return path;
+}
+
+static struct super_block *nfs4_clone_client(struct nfs_server *server, =
struct nfs_clone_mount *data)
+{
+	const struct dentry *dentry =3D data->dentry;
+	struct nfs4_client *clp =3D server->nfs4_state;
+	struct super_block *sb;
+
+	server->mnt_path =3D nfs4_dup_path(dentry);
+	if (IS_ERR(server->mnt_path)) {
+		sb =3D (struct super_block *)server->mnt_path;
+		goto err;
+	}
+	sb =3D sget(&nfs4_fs_type, nfs4_compare_super, nfs_set_super, server);
+	if (IS_ERR(sb) || sb->s_root)
+		goto free_path;
+	nfs4_server_capabilities(server, &server->fh);
+
+	down_write(&clp->cl_sem);
+	atomic_inc(&clp->cl_count);
+	list_add_tail(&server->nfs4_siblings, &clp->cl_superblocks);
+	up_write(&clp->cl_sem);
+	return sb;
+free_path:
+	kfree(server->mnt_path);
+err:
+	server->mnt_path =3D NULL;
+	return sb;
+}
+
+static struct super_block *nfs_clone_nfs4_sb(struct file_system_type *fs=
_type,
+		int flags, const char *dev_name, void *raw_data)
+{
+	struct nfs_clone_mount *data =3D raw_data;
+	return nfs_clone_generic_sb(data, nfs4_clone_client);
+}
+
+static struct file_system_type clone_nfs4_fs_type =3D {
+	.owner		=3D THIS_MODULE,
+	.name		=3D "nfs",
+	.get_sb		=3D nfs_clone_nfs4_sb,
+	.kill_sb	=3D nfs4_kill_super,
+	.fs_flags	=3D FS_ODD_RENAME|FS_REVAL_DOT|FS_BINARY_MOUNTDATA,
+};
+
 #define nfs4_init_once(nfsi) \
 	do { \
 		INIT_LIST_HEAD(&(nfsi)->open_states); \
@@ -2205,11 +2445,68 @@ static inline void unregister_nfs4fs(voi
 	nfs_unregister_sysctl();
 }
 #else
+#define nfs4_clone_client(a,b) ERR_PTR(-EINVAL)
 #define nfs4_init_once(nfsi) \
 	do { } while (0)
 #define register_nfs4fs() (0)
 #define unregister_nfs4fs()
 #endif
+
+static inline char *nfs_devname(const struct vfsmount *mnt_parent,
+			 const struct dentry *dentry,
+			 char *buffer, ssize_t buflen)
+{
+	return nfs_path(mnt_parent->mnt_devname, dentry, buffer, buflen);
+}
+
+/**
+ * nfs_do_submount - set up mountpoint when crossing a filesystem bounda=
ry
+ * @mnt_parent - mountpoint of parent directory
+ * @dentry - parent directory
+ * @fh - filehandle for new root dentry
+ * @fattr - attributes for new root inode
+ *
+ */
+struct vfsmount *nfs_do_submount(const struct vfsmount *mnt_parent,
+		const struct dentry *dentry, struct nfs_fh *fh,
+		struct nfs_fattr *fattr)
+{
+	struct nfs_clone_mount mountdata =3D {
+		.sb =3D mnt_parent->mnt_sb,
+		.dentry =3D dentry,
+		.fh =3D fh,
+		.fattr =3D fattr,
+	};
+	struct vfsmount *mnt =3D ERR_PTR(-ENOMEM);
+	char *page =3D (char *) __get_free_page(GFP_USER);
+	char *devname;
+
+	dprintk("%s: submounting on %s/%s\n", __FUNCTION__,
+			dentry->d_parent->d_name.name,
+			dentry->d_name.name);
+	if (page =3D=3D NULL)
+		goto out;
+	devname =3D nfs_devname(mnt_parent, dentry, page, PAGE_SIZE);
+	mnt =3D (struct vfsmount *)devname;
+	if (IS_ERR(devname))
+		goto free_page;
+	switch (NFS_SB(mnt_parent->mnt_sb)->rpc_ops->version) {
+		case 2:
+		case 3:
+			mnt =3D vfs_kern_mount(&clone_nfs_fs_type, 0, devname, &mountdata);
+			break;
+		case 4:
+			mnt =3D vfs_kern_mount(&clone_nfs4_fs_type, 0, devname, &mountdata);
+			break;
+		default:
+			BUG();
+	}
+free_page:
+	free_page((unsigned long)page);
+out:
+	dprintk("%s: done\n", __FUNCTION__);
+	return mnt;
+}
=20
 extern int nfs_init_nfspagecache(void);
 extern void nfs_destroy_nfspagecache(void);
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
new file mode 100644
index 0000000..a155505
--- /dev/null
+++ b/fs/nfs/namespace.c
@@ -0,0 +1,89 @@
+/*
+ * linux/fs/nfs/namespace.c
+ *
+ * Copyright (C) 2005 Trond Myklebust <Trond.Myklebust@netapp.com>
+ *
+ * NFS namespace
+ */
+
+#include <linux/config.h>
+
+#include <linux/dcache.h>
+#include <linux/mount.h>
+#include <linux/namei.h>
+#include <linux/nfs_fs.h>
+#include <linux/string.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/vfs.h>
+
+#define NFSDBG_FACILITY		NFSDBG_VFS
+
+/*
+ * nfs_follow_mountpoint - handle crossing a mountpoint on the server
+ * @dentry - dentry of mountpoint
+ * @nd - nameidata info
+ *
+ * When we encounter a mountpoint on the server, we want to set up
+ * a mountpoint on the client too, to prevent inode numbers from
+ * colliding, and to allow "df" to work properly.
+ * On NFSv4, we also want to allow for the fact that different
+ * filesystems may be migrated to different servers in a failover
+ * situation, and that different filesystems may want to use
+ * different security flavours.
+ */
+static void * nfs_follow_mountpoint(struct dentry *dentry, struct nameid=
ata *nd)
+{
+	struct vfsmount *mnt;
+	struct nfs_server *server =3D NFS_SERVER(dentry->d_inode);
+	struct dentry *parent;
+	struct nfs_fh fh;
+	struct nfs_fattr fattr;
+	int err;
+
+	BUG_ON(IS_ROOT(dentry));
+	dprintk("%s: enter\n", __FUNCTION__);
+	dput(nd->dentry);
+	nd->dentry =3D dget(dentry);
+	if (d_mountpoint(nd->dentry))
+		goto out_follow;
+	/* Look it up again */
+	parent =3D dget_parent(nd->dentry);
+	err =3D server->rpc_ops->lookup(parent->d_inode, &nd->dentry->d_name, &=
fh, &fattr);
+	dput(parent);
+	if (err !=3D 0)
+		goto out_err;
+
+	mnt =3D nfs_do_submount(nd->mnt, nd->dentry, &fh, &fattr);
+	err =3D PTR_ERR(mnt);
+	if (IS_ERR(mnt))
+		goto out_err;
+
+	mntget(mnt);
+	err =3D do_add_mount(mnt, nd, nd->mnt->mnt_flags, NULL);
+	if (err < 0) {
+		mntput(mnt);
+		if (err =3D=3D -EBUSY)
+			goto out_follow;
+		goto out_err;
+	}
+	mntput(nd->mnt);
+	dput(nd->dentry);
+	nd->mnt =3D mnt;
+	nd->dentry =3D dget(mnt->mnt_root);
+out:
+	dprintk("%s: done, returned %d\n", __FUNCTION__, err);
+	return ERR_PTR(err);
+out_err:
+	path_release(nd);
+	goto out;
+out_follow:
+	while(d_mountpoint(nd->dentry) && follow_down(&nd->mnt, &nd->dentry))
+		;
+	err =3D 0;
+	goto out;
+}
+
+struct inode_operations nfs_mountpoint_inode_operations =3D {
+	.follow_link	=3D nfs_follow_mountpoint,
+	.getattr	=3D nfs_getattr,
+};
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 0f5e4e7..307832f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -217,6 +217,7 @@ extern int nfs4_proc_renew(struct nfs4_c
 extern int nfs4_do_close(struct inode *inode, struct nfs4_state *state);
 extern struct dentry *nfs4_atomic_open(struct inode *, struct dentry *, =
struct nameidata *);
 extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, st=
ruct nameidata *);
+extern int nfs4_server_capabilities(struct nfs_server *server, struct nf=
s_fh *fhandle);
=20
 extern struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops;
 extern struct nfs4_state_recovery_ops nfs4_network_partition_recovery_op=
s;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 86f81a7..e108142 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1331,7 +1331,7 @@ static int _nfs4_server_capabilities(str
 	return status;
 }
=20
-static int nfs4_server_capabilities(struct nfs_server *server, struct nf=
s_fh *fhandle)
+int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f=
handle)
 {
 	struct nfs4_exception exception =3D { };
 	int err;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 83e2b8a..7cd75e0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -308,6 +308,10 @@ extern void nfs_end_data_update(struct i
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_con=
text *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);
 extern struct nfs_open_context *nfs_find_open_context(struct inode *inod=
e, struct rpc_cred *cred, int mode);
+extern struct vfsmount *nfs_do_submount(const struct vfsmount *mnt_paren=
t,
+					const struct dentry *dentry,
+					struct nfs_fh *fh,
+					struct nfs_fattr *fattr);
=20
 /* linux/net/ipv4/ipconfig.c: trims ip addr off front of name, too. */
 extern u32 root_nfs_parse_addr(char *name); /*__init*/
@@ -392,6 +396,11 @@ #else
 #define nfs_register_sysctl() 0
 #define nfs_unregister_sysctl() do { } while(0)
 #endif
+
+/*
+ * linux/fs/nfs/namespace.c
+ */
+extern struct inode_operations nfs_mountpoint_inode_operations;
=20
 /*
  * linux/fs/nfs/unlink.c
