From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Secure user authentication using RPCSEC_GSS [6/7]
Date: Thu, 31 Oct 2002 21:22:25 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15809.37121.350434.617910@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187Lpl-0003ja-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 12:22:29 -0800
To: Linus Torvalds <torvalds@transmeta.com>,
    NFS maillist <nfs@lists.sourceforge.net>,nfsv4-wg@citi.umich.edu
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Provide a 'ramfs' style filesystem for communicating between the kernel
RPCSEC_GSS caches, and the userland security token management daemons.

Each time the kernel initializes a new NFS, lockd, statd or portmapper
client, a directory automatically gets set up in this rpc_pipefs. It
is initially only populated with a single file "info", however a
set of functions is provided that allows the kernel to create
named pipes to provide 2 way communication between the kernel and
userland much along the lines of what is done by CODA upcall/downcalls.

The purpose of the exercise is to allow RPCSEC_GSS to request
the negotiation of Kerberos/SPKM/... sessions, and to allow the
userland daemon to stuff the resulting tokens down into a kernel
cache.
The same mechanism will also be used by NFSv4 in order to provide
name-to/from-uid and name-to/from-gid translation.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.45-05-rpc_gss/include/linux/sunrpc/clnt.h linux-2.5.45-06-auth_upcall/include/linux/sunrpc/clnt.h
--- linux-2.5.45-05-rpc_gss/include/linux/sunrpc/clnt.h	2002-09-18 06:05:34.000000000 -0400
+++ linux-2.5.45-06-auth_upcall/include/linux/sunrpc/clnt.h	2002-10-31 10:23:24.000000000 -0500
@@ -28,6 +28,8 @@
 	__u16			pm_port;
 };
 
+struct rpc_inode;
+
 /*
  * The high-level client handle
  */
@@ -60,6 +62,8 @@
 
 	int			cl_nodelen;	/* nodename length */
 	char 			cl_nodename[UNX_MAXNODENAME];
+	char			cl_pathname[30];/* Path in rpc_pipe_fs */
+	struct dentry *		cl_dentry;	/* inode */
 };
 #define cl_timeout		cl_xprt->timeout
 #define cl_prog			cl_pmap.pm_prog
diff -u --recursive --new-file linux-2.5.45-05-rpc_gss/include/linux/sunrpc/rpc_pipe_fs.h linux-2.5.45-06-auth_upcall/include/linux/sunrpc/rpc_pipe_fs.h
--- linux-2.5.45-05-rpc_gss/include/linux/sunrpc/rpc_pipe_fs.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.45-06-auth_upcall/include/linux/sunrpc/rpc_pipe_fs.h	2002-10-31 13:10:13.000000000 -0500
@@ -0,0 +1,46 @@
+#ifndef _LINUX_SUNRPC_RPC_PIPE_FS_H
+#define _LINUX_SUNRPC_RPC_PIPE_FS_H
+
+#ifdef __KERNEL__
+
+struct rpc_pipe_msg {
+	struct list_head list;
+	void *data;
+	size_t len;
+	size_t copied;
+	int errno;
+};
+
+struct rpc_pipe_ops {
+	ssize_t (*upcall)(struct file *, struct rpc_pipe_msg *, char *, size_t);
+	ssize_t (*downcall)(struct file *, const char *, size_t);
+	void (*destroy_msg)(struct rpc_pipe_msg *);
+};
+
+struct rpc_inode {
+	struct inode vfs_inode;
+	struct rpc_clnt *rpc_client;
+	struct list_head pipe;
+	int pipelen;
+	int nreaders;
+	wait_queue_head_t waitq;
+	struct rpc_pipe_ops *ops;
+};
+
+static inline struct rpc_inode *
+RPC_I(struct inode *inode)
+{
+	return container_of(inode, struct rpc_inode, vfs_inode);
+}
+
+extern void rpc_inode_setowner(struct inode *, struct rpc_clnt *);
+extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
+
+extern struct dentry *rpc_mkdir(char *, struct rpc_clnt *);
+extern int rpc_rmdir(char *);
+extern struct dentry *rpc_mkpipe(char *, struct rpc_clnt *clnt,
+				 struct rpc_pipe_ops *);
+extern int rpc_unlink(char *);
+
+#endif
+#endif
diff -u --recursive --new-file linux-2.5.45-05-rpc_gss/net/sunrpc/Makefile linux-2.5.45-06-auth_upcall/net/sunrpc/Makefile
--- linux-2.5.45-05-rpc_gss/net/sunrpc/Makefile	2002-10-31 10:22:55.000000000 -0500
+++ linux-2.5.45-06-auth_upcall/net/sunrpc/Makefile	2002-10-31 10:23:24.000000000 -0500
@@ -10,7 +10,7 @@
 	    auth.o auth_null.o auth_unix.o \
 	    svc.o svcsock.o svcauth.o svcauth_unix.o \
 	    pmap_clnt.o timer.o xdr.o \
-	    sunrpc_syms.o cache.o
+	    sunrpc_syms.o cache.o rpc_pipe.o
 sunrpc-$(CONFIG_PROC_FS) += stats.o
 sunrpc-$(CONFIG_SYSCTL) += sysctl.o
 
diff -u --recursive --new-file linux-2.5.45-05-rpc_gss/net/sunrpc/clnt.c linux-2.5.45-06-auth_upcall/net/sunrpc/clnt.c
--- linux-2.5.45-05-rpc_gss/net/sunrpc/clnt.c	2002-10-31 10:22:55.000000000 -0500
+++ linux-2.5.45-06-auth_upcall/net/sunrpc/clnt.c	2002-10-31 10:59:45.000000000 -0500
@@ -30,6 +30,7 @@
 #include <linux/utsname.h>
 
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 
 #include <linux/nfs.h>
 
@@ -108,8 +109,19 @@
 
 	rpc_init_rtt(&clnt->cl_rtt, xprt->timeout.to_initval);
 
-	if (!rpcauth_create(flavor, clnt))
+	snprintf(clnt->cl_pathname, sizeof(clnt->cl_pathname),
+			"/%s/clnt%p", clnt->cl_protname, clnt);
+	clnt->cl_dentry = rpc_mkdir(clnt->cl_pathname, clnt);
+	if (IS_ERR(clnt->cl_dentry)) {
+		printk(KERN_INFO "RPC: Couldn't create pipefs entry %s\n",
+				clnt->cl_pathname);
+		goto out_no_path;
+	}
+	if (!rpcauth_create(flavor, clnt)) {
+		printk(KERN_INFO "RPC: Couldn't create auth handle (flavor %u)\n",
+				flavor);
 		goto out_no_auth;
+	}
 
 	/* save the nodename */
 	clnt->cl_nodelen = strlen(system_utsname.nodename);
@@ -123,8 +135,8 @@
 	printk(KERN_INFO "RPC: out of memory in rpc_create_client\n");
 	goto out;
 out_no_auth:
-	printk(KERN_INFO "RPC: Couldn't create auth handle (flavor %u)\n",
-		flavor);
+	rpc_rmdir(clnt->cl_pathname);
+out_no_path:
 	rpc_free(clnt);
 	clnt = NULL;
 	goto out;
@@ -172,6 +184,7 @@
 	dprintk("RPC: destroying %s client for %s\n",
 			clnt->cl_protname, clnt->cl_server);
 
+	rpc_rmdir(clnt->cl_pathname);
 	if (clnt->cl_auth) {
 		rpcauth_destroy(clnt->cl_auth);
 		clnt->cl_auth = NULL;
diff -u --recursive --new-file linux-2.5.45-05-rpc_gss/net/sunrpc/rpc_pipe.c linux-2.5.45-06-auth_upcall/net/sunrpc/rpc_pipe.c
--- linux-2.5.45-05-rpc_gss/net/sunrpc/rpc_pipe.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.45-06-auth_upcall/net/sunrpc/rpc_pipe.c	2002-10-31 10:23:24.000000000 -0500
@@ -0,0 +1,788 @@
+/*
+ * net/sunrpc/rpc_pipe.c
+ *
+ * Userland/kernel interface for rpcauth_gss.
+ * Code shamelessly plagiarized from fs/nfsd/nfsctl.c
+ * and fs/driverfs/inode.c
+ *
+ * Copyright (c) 2002, Trond Myklebust <trond.myklebust@fys.uio.no>
+ *
+ */
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/pagemap.h>
+#include <linux/mount.h>
+#include <linux/namei.h>
+#include <linux/dnotify.h>
+#include <linux/kernel.h>
+
+#include <asm/ioctls.h>
+#include <linux/fs.h>
+#include <linux/poll.h>
+#include <linux/wait.h>
+#include <linux/seq_file.h>
+
+#include <linux/sunrpc/auth_gss.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
+
+static struct vfsmount *rpc_mount;
+static spinlock_t rpc_mount_lock = SPIN_LOCK_UNLOCKED;
+static int rpc_mount_count;
+
+static struct file_system_type rpc_pipe_fs_type;
+
+
+static kmem_cache_t *rpc_inode_cachep;
+
+static void
+__rpc_purge_upcall(struct inode *inode, int err)
+{
+	struct rpc_inode *rpci = RPC_I(inode);
+	struct rpc_pipe_msg *msg;
+
+	while (!list_empty(&rpci->pipe)) {
+		msg = list_entry(rpci->pipe.next, struct rpc_pipe_msg, list);
+		list_del_init(&msg->list);
+		msg->errno = err;
+		rpci->ops->destroy_msg(msg);
+	}
+	rpci->pipelen = 0;
+	wake_up(&rpci->waitq);
+}
+
+void
+rpc_purge_upcall(struct inode *inode, int err)
+{
+	down(&inode->i_sem);
+	__rpc_purge_upcall(inode, err);
+	up(&inode->i_sem);
+}
+
+int
+rpc_queue_upcall(struct inode *inode, struct rpc_pipe_msg *msg)
+{
+	struct rpc_inode *rpci = RPC_I(inode);
+	int res = 0;
+
+	down(&inode->i_sem);
+	if (rpci->nreaders) {
+		list_add_tail(&msg->list, &rpci->pipe);
+		rpci->pipelen += msg->len;
+	} else
+		res = -EPIPE;
+	up(&inode->i_sem);
+	wake_up(&rpci->waitq);
+}
+
+void
+rpc_inode_setowner(struct inode *inode, struct rpc_clnt *clnt)
+{
+	struct rpc_inode *rpci = RPC_I(inode);
+	down(&inode->i_sem);
+	rpci->rpc_client = clnt;
+	if (!clnt)
+		__rpc_purge_upcall(inode, -EPIPE);
+	up(&inode->i_sem);
+}
+
+static struct inode *
+rpc_alloc_inode(struct super_block *sb)
+{
+	struct rpc_inode *rpci;
+	rpci = (struct rpc_inode *)kmem_cache_alloc(rpc_inode_cachep, SLAB_KERNEL);
+	if (!rpci)
+		return NULL;
+	return &rpci->vfs_inode;
+}
+
+static void
+rpc_destroy_inode(struct inode *inode)
+{
+	kmem_cache_free(rpc_inode_cachep, RPC_I(inode));
+}
+
+static int
+rpc_pipe_open(struct inode *inode, struct file *filp)
+{
+	struct rpc_inode *rpci = RPC_I(inode);
+	int res = 0;
+
+	down(&inode->i_sem);
+	if (rpci->rpc_client != NULL) {
+		if (filp->f_mode & FMODE_READ)
+			rpci->nreaders ++;
+		res = -ENXIO;
+	}
+	up(&inode->i_sem);
+	return res;
+}
+
+static int
+rpc_pipe_release(struct inode *inode, struct file *filp)
+{
+	struct rpc_inode *rpci = RPC_I(filp->f_dentry->d_inode);
+	struct rpc_pipe_msg *msg;
+
+	msg = (struct rpc_pipe_msg *)filp->private_data;
+	if (msg != NULL) {
+		msg->errno = -EPIPE;
+		rpci->ops->destroy_msg(msg);
+	}
+	down(&inode->i_sem);
+	if (filp->f_mode & FMODE_READ)
+		rpci->nreaders --;
+	if (!rpci->nreaders)
+		__rpc_purge_upcall(inode, -EPIPE);
+	up(&inode->i_sem);
+	return 0;
+}
+
+static ssize_t
+rpc_pipe_read(struct file *filp, char *buf, size_t len, loff_t *offset)
+{
+	struct inode *inode = filp->f_dentry->d_inode;
+	struct rpc_inode *rpci = RPC_I(inode);
+	struct rpc_pipe_msg *msg;
+	int res = 0;
+
+	down(&inode->i_sem);
+	msg = filp->private_data;
+	if (msg == NULL) {
+		if (!list_empty(&rpci->pipe)) {
+			msg = list_entry(rpci->pipe.next,
+					struct rpc_pipe_msg,
+					list);
+			list_del_init(&msg->list);
+			rpci->pipelen -= msg->len;
+			filp->private_data = msg;
+		}
+		if (msg == NULL)
+			goto out_unlock;
+	}
+	res = rpci->ops->upcall(filp, msg, buf, len);
+	if (res < 0 || msg->len == msg->copied) {
+		filp->private_data = NULL;
+		msg->errno = 0;
+		rpci->ops->destroy_msg(msg);
+	}
+out_unlock:
+	up(&inode->i_sem);
+	return res;
+}
+
+static ssize_t
+rpc_pipe_write(struct file *filp, const char *buf, size_t len, loff_t *offset)
+{
+	struct inode *inode = filp->f_dentry->d_inode;
+	struct rpc_inode *rpci = RPC_I(inode);
+	int res;
+
+	down(&inode->i_sem);
+	res = rpci->ops->downcall(filp, buf, len);
+	up(&inode->i_sem);
+	return res;
+}
+
+static unsigned int
+rpc_pipe_poll(struct file *filp, struct poll_table_struct *wait)
+{
+	struct rpc_inode *rpci = RPC_I(filp->f_dentry->d_inode);
+	unsigned int mask = 0;
+
+	poll_wait(filp, &rpci->waitq, wait);
+
+	mask = POLLOUT | POLLWRNORM;
+	if (rpci->rpc_client == NULL)
+		mask |= POLLERR | POLLHUP;
+	if (!list_empty(&rpci->pipe))
+		mask |= POLLIN | POLLRDNORM;
+	return mask;
+}
+
+static int
+rpc_pipe_ioctl(struct inode *ino, struct file *filp,
+		unsigned int cmd, unsigned long arg)
+{
+	struct rpc_inode *rpci = RPC_I(filp->f_dentry->d_inode);
+	int len;
+
+	switch (cmd) {
+	case FIONREAD:
+		len = rpci->pipelen;
+		if (filp->private_data) {
+			struct rpc_pipe_msg *msg;
+			msg = (struct rpc_pipe_msg *)filp->private_data;
+			len += msg->len - msg->copied;
+		}
+		return put_user(len, (int *)arg);
+	default:
+		return -EINVAL;
+	}
+}
+
+struct inode_operations rpc_pipe_iops = {
+	.lookup		= simple_lookup,
+};
+
+
+struct file_operations rpc_pipe_fops = {
+	.owner		= THIS_MODULE,
+	.llseek		= no_llseek,
+	.read		= rpc_pipe_read,
+	.write		= rpc_pipe_write,
+	.poll		= rpc_pipe_poll,
+	.ioctl		= rpc_pipe_ioctl,
+	.open		= rpc_pipe_open,
+	.release	= rpc_pipe_release,
+};
+
+static int
+rpc_show_info(struct seq_file *m, void *v)
+{
+	struct rpc_clnt *clnt = m->private;
+
+	seq_printf(m, "RPC server: %s\n", clnt->cl_server);
+	seq_printf(m, "service: %s (%d) version %d\n", clnt->cl_protname,
+			clnt->cl_prog, clnt->cl_vers);
+	seq_printf(m, "address: %u.%u.%u.%u\n",
+			NIPQUAD(clnt->cl_xprt->addr.sin_addr.s_addr));
+	return 0;
+}
+
+static int
+rpc_info_open(struct inode *inode, struct file *file)
+{
+	struct rpc_clnt *clnt;
+	int ret = single_open(file, rpc_show_info, NULL);
+
+	if (!ret) {
+		struct seq_file *m = file->private_data;
+		down(&inode->i_sem);
+		clnt = RPC_I(inode)->rpc_client;
+		if (clnt) {
+			atomic_inc(&clnt->cl_users);
+			m->private = clnt;
+		} else {
+			single_release(inode, file);
+			ret = -EINVAL;
+		}
+		up(&inode->i_sem);
+	}
+	return ret;
+}
+
+static int
+rpc_info_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *m = file->private_data;
+	struct rpc_clnt *clnt = (struct rpc_clnt *)m->private;
+
+	if (clnt)
+		rpc_release_client(clnt);
+	return single_release(inode, file);
+}
+
+static struct file_operations rpc_info_operations = {
+	.open		= rpc_info_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= rpc_info_release,
+};
+
+
+/*
+ * We have a single directory with 1 node in it.
+ */
+enum {
+	RPCAUTH_Root = 1,
+	RPCAUTH_lockd,
+	RPCAUTH_nfs,
+	RPCAUTH_portmap,
+	RPCAUTH_statd,
+	RPCAUTH_RootEOF
+};
+
+/*
+ * Description of fs contents.
+ */
+struct rpc_filelist {
+	char *name;
+	struct file_operations *i_fop;
+	int mode;
+};
+
+static struct rpc_filelist files[] = {
+	[RPCAUTH_lockd] = {
+		.name = "lockd",
+		.mode = S_IFDIR | S_IRUSR | S_IXUSR,
+	},
+	[RPCAUTH_nfs] = {
+		.name = "nfs",
+		.mode = S_IFDIR | S_IRUSR | S_IXUSR,
+	},
+	[RPCAUTH_portmap] = {
+		.name = "portmap",
+		.mode = S_IFDIR | S_IRUSR | S_IXUSR,
+	},
+	[RPCAUTH_statd] = {
+		.name = "statd",
+		.mode = S_IFDIR | S_IRUSR | S_IXUSR,
+	},
+};
+
+enum {
+	RPCAUTH_info = 2,
+	RPCAUTH_EOF
+};
+
+static struct rpc_filelist authfiles[] = {
+	[RPCAUTH_info] = {
+		.name = "info",
+		.i_fop = &rpc_info_operations,
+		.mode = S_IFREG | S_IRUSR,
+	},
+};
+
+static int
+rpc_get_mount(void)
+{
+	struct vfsmount * mnt = NULL;
+
+	spin_lock(&rpc_mount_lock);
+	if (rpc_mount)
+		goto out_get;
+	spin_unlock(&rpc_mount_lock);
+	mnt = kern_mount(&rpc_pipe_fs_type);
+	if (IS_ERR(mnt))
+		return -ENODEV;
+	spin_lock(&rpc_mount_lock);
+	if (!rpc_mount) {
+		rpc_mount = mnt;
+		mnt = NULL;
+		goto out_dontget;
+	}
+out_get:
+	mntget(rpc_mount);
+out_dontget:
+	++rpc_mount_count;
+	spin_unlock(&rpc_mount_lock);
+	if (mnt)
+		mntput(mnt);
+	return 0;
+}
+
+static void
+rpc_put_mount(void)
+{
+	struct vfsmount *mnt;
+
+	spin_lock(&rpc_mount_lock);
+	mnt = rpc_mount;
+	--rpc_mount_count;
+	if (rpc_mount_count == 0)
+		rpc_mount = NULL;
+	else
+		mnt = NULL;
+	spin_unlock(&rpc_mount_lock);
+	if (mnt)
+		mntput(mnt);
+}
+
+static int
+rpc_lookup_path(char *path, struct nameidata *nd, int flags)
+{
+	if (rpc_get_mount()) {
+		printk(KERN_WARNING "%s: %s failed to mount "
+			       "pseudofilesystem \n", __FILE__, __FUNCTION__);
+		return -ENODEV;
+	}
+	nd->mnt = mntget(rpc_mount);
+	nd->dentry = dget(rpc_mount->mnt_sb->s_root);
+	nd->last_type = LAST_ROOT;
+	nd->flags = flags;
+
+	if (path_walk(path, nd)) {
+		printk(KERN_WARNING "%s: %s failed to find path %s\n",
+				__FILE__, __FUNCTION__, path);
+		rpc_put_mount();
+		return -ENOENT;
+	}
+	return 0;
+}
+
+static void
+rpc_release_path(struct nameidata *nd)
+{
+	path_release(nd);
+	rpc_put_mount();
+}
+
+static struct inode *
+rpc_get_inode(struct super_block *sb, int mode)
+{
+	struct inode *inode = new_inode(sb);
+	if (!inode)
+		return NULL;
+	inode->i_mode = mode;
+	inode->i_uid = inode->i_gid = 0;
+	inode->i_blksize = PAGE_CACHE_SIZE;
+	inode->i_blocks = 0;
+	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+	switch(mode & S_IFMT) {
+		case S_IFDIR:
+			inode->i_fop = &simple_dir_operations;
+			inode->i_op = &simple_dir_inode_operations;
+			inode->i_nlink++;
+		default:
+			break;
+	}
+	return inode;
+}
+
+/*
+ * FIXME: This probably has races.
+ */
+static void
+rpc_depopulate(struct dentry *dir)
+{
+	LIST_HEAD(head);
+	struct list_head *pos, *next;
+	struct dentry *dentry;
+
+	down(&dir->d_inode->i_sem);
+	spin_lock(&dcache_lock);
+	list_for_each_safe(pos, next, &dir->d_subdirs) {
+		dentry = list_entry(pos, struct dentry, d_child);
+		dget_locked(dentry);
+		if (!d_unhashed(dentry))
+			list_del(&dentry->d_hash);
+		list_add(&dentry->d_hash, &head);
+	}
+	spin_unlock(&dcache_lock);
+	while (!list_empty(&head)) {
+		dentry = list_entry(head.next, struct dentry, d_hash);
+		list_del_init(&dentry->d_hash);
+		rpc_inode_setowner(dentry->d_inode, NULL);
+		simple_unlink(dir->d_inode, dentry);
+		dput(dentry);
+	}
+	up(&dir->d_inode->i_sem);
+	shrink_dcache_parent(dir);
+}
+
+static int
+rpc_populate(struct dentry *dir,
+		struct rpc_filelist *files,
+		int start, int eof)
+{
+	struct rpc_clnt *clnt = RPC_I(dir->d_inode)->rpc_client;
+	struct qstr name;
+	struct dentry *dentry;
+	struct inode *inode;
+	int mode, i;
+	for (i = start; i < eof; i++) {
+		name.name = files[i].name;
+		name.len = strlen(name.name);
+		name.hash = full_name_hash(name.name, name.len);
+		dentry = d_alloc(dir, &name);
+		if (!dentry)
+			goto out_bad;
+		mode = files[i].mode;
+		inode = rpc_get_inode(dir->d_inode->i_sb, mode);
+		if (!inode) {
+			dput(dentry);
+			goto out_bad;
+		}
+		inode->i_ino = i;
+		if (files[i].i_fop)
+			inode->i_fop = files[i].i_fop;
+		if (clnt)
+			rpc_inode_setowner(inode, clnt);
+		if (S_ISDIR(mode))
+			dir->d_inode->i_nlink++;
+		d_add(dentry, inode);
+	}
+	return 0;
+out_bad:
+	printk(KERN_WARNING "%s: %s failed to populate directory %s\n",
+			__FILE__, __FUNCTION__, dir->d_name.name);
+	return -ENOMEM;
+}
+
+static int
+__rpc_mkdir(struct inode *dir, struct dentry *dentry)
+{
+	struct inode *inode;
+
+	inode = rpc_get_inode(dir->i_sb, S_IFDIR | S_IRUSR | S_IXUSR);
+	if (!inode)
+		goto out_err;
+	inode->i_ino = iunique(dir->i_sb, 100);
+	d_instantiate(dentry, inode);
+	dir->i_nlink++;
+	inode_dir_notify(dir, DN_CREATE);
+	rpc_get_mount();
+	return 0;
+out_err:
+	printk(KERN_WARNING "%s: %s failed to allocate inode for dentry %s\n",
+			__FILE__, __FUNCTION__, dentry->d_name.name);
+	return -ENOMEM;
+}
+
+static int
+__rpc_rmdir(struct inode *dir, struct dentry *dentry)
+{
+	int error;
+
+	rpc_inode_setowner(dentry->d_inode, NULL);
+	if ((error = simple_rmdir(dir, dentry)) != 0)
+		return error;
+	if (!error) {
+		inode_dir_notify(dir, DN_DELETE);
+		d_delete(dentry);
+		rpc_put_mount();
+	}
+	return 0;
+}
+
+struct dentry *
+rpc_lookup_negative(char *path, struct nameidata *nd)
+{
+	struct dentry *dentry;
+	struct inode *dir;
+	int error;
+
+	if ((error = rpc_lookup_path(path, nd, LOOKUP_PARENT)) != 0)
+		return ERR_PTR(error);
+	dir = nd->dentry->d_inode;
+	down(&dir->i_sem);
+	dentry = lookup_hash(&nd->last, nd->dentry);
+	if (IS_ERR(dentry))
+		goto out_err;
+	if (dentry->d_inode) {
+		dput(dentry);
+		dentry = ERR_PTR(-EEXIST);
+		goto out_err;
+	}
+	return dentry;
+out_err:
+	up(&dir->i_sem);
+	rpc_release_path(nd);
+	return dentry;
+}
+
+
+struct dentry *
+rpc_mkdir(char *path, struct rpc_clnt *clnt)
+{
+	struct nameidata nd;
+	struct dentry *dentry;
+	struct inode *dir;
+	int error;
+
+	dentry = rpc_lookup_negative(path, &nd);
+	if (IS_ERR(dentry))
+		return dentry;
+	dir = nd.dentry->d_inode;
+	if ((error = __rpc_mkdir(dir, dentry)) != 0)
+		goto err_dput;
+	RPC_I(dentry->d_inode)->rpc_client = clnt;
+	error = rpc_populate(dentry, authfiles,
+			RPCAUTH_info, RPCAUTH_EOF);
+	if (error)
+		goto err_depopulate;
+out:
+	up(&dir->i_sem);
+	rpc_release_path(&nd);
+	return dentry;
+err_depopulate:
+	rpc_depopulate(dentry);
+	__rpc_rmdir(dir, dentry);
+err_dput:
+	dput(dentry);
+	printk(KERN_WARNING "%s: %s() failed to create directory %s (errno = %d)\n",
+			__FILE__, __FUNCTION__, path, error);
+	dentry = ERR_PTR(error);
+	goto out;
+}
+
+int
+rpc_rmdir(char *path)
+{
+	struct nameidata nd;
+	struct dentry *dentry;
+	struct inode *dir;
+	int error;
+
+	if ((error = rpc_lookup_path(path, &nd, LOOKUP_PARENT)) != 0)
+		return error;
+	dir = nd.dentry->d_inode;
+	down(&dir->i_sem);
+	dentry = lookup_hash(&nd.last, nd.dentry);
+	if (IS_ERR(dentry)) {
+		error = PTR_ERR(dentry);
+		goto out_release;
+	}
+	rpc_depopulate(dentry);
+	error = __rpc_rmdir(dir, dentry);
+	dput(dentry);
+out_release:
+	up(&dir->i_sem);
+	rpc_release_path(&nd);
+	return error;
+}
+
+struct dentry *
+rpc_mkpipe(char *path, struct rpc_clnt *clnt, struct rpc_pipe_ops *ops)
+{
+	struct nameidata nd;
+	struct dentry *dentry;
+	struct inode *dir, *inode;
+	struct rpc_inode *rpci;
+
+	dentry = rpc_lookup_negative(path, &nd);
+	if (IS_ERR(dentry))
+		return dentry;
+	dir = nd.dentry->d_inode;
+	inode = rpc_get_inode(dir->i_sb, S_IFSOCK | S_IRUSR | S_IXUSR);
+	if (!inode)
+		goto err_dput;
+	inode->i_ino = iunique(dir->i_sb, 100);
+	d_instantiate(dentry, inode);
+	rpci = RPC_I(inode);
+	rpci->rpc_client = clnt;
+	rpci->ops = ops;
+	inode_dir_notify(dir, DN_CREATE);
+out:
+	up(&dir->i_sem);
+	rpc_release_path(&nd);
+	return dentry;
+err_dput:
+	dput(dentry);
+	dentry = ERR_PTR(-ENOMEM);
+	printk(KERN_WARNING "%s: %s() failed to create pipe %s (errno = %d)\n",
+			__FILE__, __FUNCTION__, path, -ENOMEM);
+	goto out;
+}
+
+int
+rpc_unlink(char *path)
+{
+	struct nameidata nd;
+	struct dentry *dentry;
+	struct inode *dir;
+	int error;
+
+	if ((error = rpc_lookup_path(path, &nd, LOOKUP_PARENT)) != 0)
+		return error;
+	dir = nd.dentry->d_inode;
+	down(&dir->i_sem);
+	dentry = lookup_hash(&nd.last, nd.dentry);
+	if (IS_ERR(dentry)) {
+		error = PTR_ERR(dentry);
+		goto out_release;
+	}
+	d_drop(dentry);
+	rpc_inode_setowner(dentry->d_inode, NULL);
+	error = simple_unlink(dir, dentry);
+	dput(dentry);
+	inode_dir_notify(dir, DN_DELETE);
+out_release:
+	up(&dir->i_sem);
+	rpc_release_path(&nd);
+	return error;
+}
+
+/*
+ * populate the filesystem
+ */
+static struct super_operations s_ops = {
+	.alloc_inode	= rpc_alloc_inode,
+	.destroy_inode	= rpc_destroy_inode,
+	.statfs		= simple_statfs,
+};
+
+#define RPCAUTH_GSSMAGIC 0x67596969
+
+static int
+rpc_fill_super(struct super_block *sb, void *data, int silent)
+{
+	struct inode *inode;
+	struct dentry *root;
+
+	sb->s_blocksize = PAGE_CACHE_SIZE;
+	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_magic = RPCAUTH_GSSMAGIC;
+	sb->s_op = &s_ops;
+
+	inode = rpc_get_inode(sb, S_IFDIR | 0755);
+	if (!inode)
+		return -ENOMEM;
+	root = d_alloc_root(inode);
+	if (!root) {
+		iput(inode);
+		return -ENOMEM;
+	}
+	if (rpc_populate(root, files, RPCAUTH_Root + 1, RPCAUTH_RootEOF))
+		goto out;
+	sb->s_root = root;
+	return 0;
+out:
+	d_genocide(root);
+	dput(root);
+	return -ENOMEM;
+}
+
+static struct super_block *
+rpc_get_sb(struct file_system_type *fs_type,
+		int flags, char *dev_name, void *data)
+{
+	return get_sb_single(fs_type, flags, data, rpc_fill_super);
+}
+
+static struct file_system_type rpc_pipe_fs_type = {
+	.owner		= THIS_MODULE,
+	.name		= "rpc_pipefs",
+	.get_sb		= rpc_get_sb,
+	.kill_sb	= kill_litter_super,
+};
+
+static void
+init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+{
+	struct rpc_inode *rpci = (struct rpc_inode *) foo;
+
+	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
+	    SLAB_CTOR_CONSTRUCTOR) {
+		inode_init_once(&rpci->vfs_inode);
+		rpci->rpc_client = NULL;
+		rpci->nreaders = 0;
+		INIT_LIST_HEAD(&rpci->pipe);
+		rpci->pipelen = 0;
+		init_waitqueue_head(&rpci->waitq);
+		rpci->ops = NULL;
+	}
+}
+
+int register_rpc_pipefs(void)
+{
+	rpc_inode_cachep = kmem_cache_create("rpc_inode_cache",
+                                             sizeof(struct rpc_inode),
+                                             0, SLAB_HWCACHE_ALIGN,
+                                             init_once, NULL);
+	if (!rpc_inode_cachep)
+		return -ENOMEM;
+	register_filesystem(&rpc_pipe_fs_type);
+	return 0;
+}
+
+void unregister_rpc_pipefs(void)
+{
+	if (kmem_cache_destroy(rpc_inode_cachep))
+		printk(KERN_WARNING "RPC: unable to free inode cache\n");
+	unregister_filesystem(&rpc_pipe_fs_type);
+}
diff -u --recursive --new-file linux-2.5.45-05-rpc_gss/net/sunrpc/sunrpc_syms.c linux-2.5.45-06-auth_upcall/net/sunrpc/sunrpc_syms.c
--- linux-2.5.45-05-rpc_gss/net/sunrpc/sunrpc_syms.c	2002-10-31 10:20:55.000000000 -0500
+++ linux-2.5.45-06-auth_upcall/net/sunrpc/sunrpc_syms.c	2002-10-31 10:23:24.000000000 -0500
@@ -126,9 +126,15 @@
 EXPORT_SYMBOL(nlm_debug);
 #endif
 
+extern int register_rpc_pipefs(void);
+extern void unregister_rpc_pipefs(void);
+
 static int __init
 init_sunrpc(void)
 {
+	int err = register_rpc_pipefs();
+	if (err)
+		goto out;
 #ifdef RPC_DEBUG
 	rpc_register_sysctl();
 #endif
@@ -137,12 +143,14 @@
 #endif
 	cache_register(&auth_domain_cache);
 	cache_register(&ip_map_cache);
-	return 0;
+out:
+	return err;
 }
 
 static void __exit
 cleanup_sunrpc(void)
 {
+	unregister_rpc_pipefs();
 	cache_unregister(&auth_domain_cache);
 	cache_unregister(&ip_map_cache);
 #ifdef RPC_DEBUG


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
