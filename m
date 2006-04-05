From: Daniel Phillips <phillips@google.com>
Subject: [RFC] Turn rpc_pipefs into a library
Date: Tue, 04 Apr 2006 23:05:27 -0700
Message-ID: <44335E27.6030900@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FR19G-0004S4-EJ
	for nfs@lists.sourceforge.net; Tue, 04 Apr 2006 23:05:46 -0700
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FR19F-0000rn-70
	for nfs@lists.sourceforge.net; Tue, 04 Apr 2006 23:05:46 -0700
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

Executive summary: rpc_pipefs is a one-off virtual filesystem Trond invented
for connecting kernel components of nfs to userspace helpers.  It provides a
nice set of capabilities that I would like to use for my own project, which is
to split nbd-server into a userspace server and a kernel transfer component.
Rather than just forking rpc_pipefs I thought I would see if I could make a
library out of it that can be used with a thin upper layer both in its current
role and for my new application.  This turned out to be pretty easy.

Changes are minimal:

   * Pass various structures as parameters instead of using statics
   * Add some temporary shims in rpc_pipe_fs.h to keep changes local
   * Move generic rpc_pipe.c code to fs/pipefs.c module
   * Move generic rpc_pipe_fs.h code to include/linux/pipefs.h
   * Miscellaneous renames

Over 80% of the original rpc_pipe.c code turned out to be generic, leaving
about 130 lines needed to define the specialized rpc interface.

I stopped here for comment, resisting the temptation to tackle the odd slight
imperfection.  For example, it is lucky that rpc never attempts to create any
directories or pipes before userspace mounts the virtual filesystem, because
they would have disappeared again immediately.  This is easily fixed, but I
thought I should see what people think of the effort so far.  What do you
think, does this seem to be heading in a useful direction?

Regards,

Daniel

 fs/Kconfig                         |   10
 fs/Makefile                        |    1
 fs/pipefs.c                        |  705 ++++++++++++++++++++++++++++++++
 include/linux/pipefs.h             |   63 ++
 include/linux/sunrpc/rpc_pipe_fs.h |   65 +-
 net/sunrpc/rpc_pipe.c              |  810 +------------------------------------
 6 files changed, 841 insertions(+), 813 deletions(-)

diff -urp 2.6.16.clean/fs/Kconfig 2.6.16/fs/Kconfig
--- 2.6.16.clean/fs/Kconfig	2006-03-19 21:53:29.000000000 -0800
+++ 2.6.16/fs/Kconfig	2006-04-04 15:52:55.000000000 -0700
@@ -859,6 +859,16 @@ config RAMFS
 	  To compile this as a module, choose M here: the module will be called
 	  ramfs.
 
+config PIPEFS
+	tristate "Pipefs filesystem support"
+	---help---
+	  Pipefs is a quick hack and who knows where its going
+
+	  To compile this code as a module, choose M here: the module will be
+	  called pipefs.
+
+	  If unsure, say N.
+
 config RELAYFS_FS
 	tristate "Relayfs file system support"
 	---help---
diff -urp 2.6.16.clean/fs/Makefile 2.6.16/fs/Makefile
--- 2.6.16.clean/fs/Makefile	2006-03-19 21:53:29.000000000 -0800
+++ 2.6.16/fs/Makefile	2006-04-04 15:52:55.000000000 -0700
@@ -46,6 +46,7 @@ obj-$(CONFIG_PROC_FS)		+= proc/
 obj-y				+= partitions/
 obj-$(CONFIG_SYSFS)		+= sysfs/
 obj-y				+= devpts/
+obj-$(CONFIG_PIPEFS)		+= pipefs.o
 
 obj-$(CONFIG_PROFILING)		+= dcookies.o
  
diff -urp 2.6.16.clean/fs/pipefs.c 2.6.16/fs/pipefs.c
--- 2.6.16.clean/fs/pipefs.c	2006-04-04 16:08:01.000000000 -0700
+++ 2.6.16/fs/pipefs.c	2006-04-04 19:10:25.000000000 -0700
@@ -0,0 +1,705 @@
+/*
+ * A library for creating virtual filesystems to communicate with
+ * kernel subsystems from userspace.
+ *
+ * Started life as a userland/kernel interface for rpcauth_gss.
+ * Code shamelessly plagiarized from fs/nfsd/nfsctl.c
+ * and fs/sysfs/inode.c.
+ *
+ * Copyright (c) 2002, Trond Myklebust <trond.myklebust@fys.uio.no>
+ * Copyright (c) 2006, Daniel Phillips <phillips@google.com>
+ */
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/pagemap.h>
+#include <linux/mount.h>
+#include <linux/namei.h>
+#include <linux/dnotify.h>
+#include <linux/kernel.h>
+#include <asm/ioctls.h>
+#include <linux/fs.h>
+#include <linux/poll.h>
+#include <linux/seq_file.h>
+#include <linux/workqueue.h>
+#include <linux/pipefs.h>
+
+static kmem_cache_t *pipefs_inode_cachep __read_mostly;
+
+#define RPC_UPCALL_TIMEOUT (30*HZ)
+
+static void pipefs_purge_list(struct pipefs_inode *pi, struct list_head *head,
+		void (*destroy_msg)(struct pipefs_msg *), int err)
+{
+	struct pipefs_msg *msg;
+
+	if (list_empty(head))
+		return;
+	do {
+		msg = list_entry(head->next, struct pipefs_msg, list);
+		list_del(&msg->list);
+		msg->errno = err;
+		destroy_msg(msg);
+	} while (!list_empty(head));
+	wake_up(&pi->waitq);
+}
+
+static void pipefs_timeout_upcall_queue(void *data)
+{
+	LIST_HEAD(free_list);
+	struct pipefs_inode *pi = (struct pipefs_inode *)data;
+	struct inode *inode = &pi->vfs_inode;
+	void (*destroy_msg)(struct pipefs_msg *);
+
+	spin_lock(&inode->i_lock);
+	if (pi->ops == NULL) {
+		spin_unlock(&inode->i_lock);
+		return;
+	}
+	destroy_msg = pi->ops->destroy_msg;
+	if (pi->nreaders == 0) {
+		list_splice_init(&pi->pipe, &free_list);
+		pi->pipelen = 0;
+	}
+	spin_unlock(&inode->i_lock);
+	pipefs_purge_list(pi, &free_list, destroy_msg, -ETIMEDOUT);
+}
+
+int pipefs_queue_upcall(struct inode *inode, struct pipefs_msg *msg)
+{
+	struct pipefs_inode *pi = pipefs_inode(inode);
+	int res = -EPIPE;
+
+	spin_lock(&inode->i_lock);
+	if (pi->ops == NULL)
+		goto out;
+	if (pi->nreaders) {
+		list_add_tail(&msg->list, &pi->pipe);
+		pi->pipelen += msg->len;
+		res = 0;
+	} else if (pi->flags & RPC_PIPE_WAIT_FOR_OPEN) {
+		if (list_empty(&pi->pipe))
+			schedule_delayed_work(&pi->queue_timeout,
+					RPC_UPCALL_TIMEOUT);
+		list_add_tail(&msg->list, &pi->pipe);
+		pi->pipelen += msg->len;
+		res = 0;
+	}
+out:
+	spin_unlock(&inode->i_lock);
+	wake_up(&pi->waitq);
+	return res;
+}
+
+static inline void pipefs_inode_setowner(struct inode *inode, void *private)
+{
+	pipefs_inode(inode)->private = private;
+}
+
+static void pipefs_close_pipes(struct inode *inode)
+{
+	struct pipefs_inode *pi = pipefs_inode(inode);
+	struct pipefs_pipe_ops *ops;
+
+	mutex_lock(&inode->i_mutex);
+	ops = pi->ops;
+	if (ops != NULL) {
+		LIST_HEAD(free_list);
+
+		spin_lock(&inode->i_lock);
+		pi->nreaders = 0;
+		list_splice_init(&pi->in_upcall, &free_list);
+		list_splice_init(&pi->pipe, &free_list);
+		pi->pipelen = 0;
+		pi->ops = NULL;
+		spin_unlock(&inode->i_lock);
+		pipefs_purge_list(pi, &free_list, ops->destroy_msg, -EPIPE);
+		pi->nwriters = 0;
+		if (ops->release_pipe)
+			ops->release_pipe(inode);
+		cancel_delayed_work(&pi->queue_timeout);
+		flush_scheduled_work();
+	}
+	pipefs_inode_setowner(inode, NULL);
+	mutex_unlock(&inode->i_mutex);
+}
+
+static struct inode *pipefs_alloc_inode(struct super_block *sb)
+{
+	struct pipefs_inode *pi;
+	pi = (struct pipefs_inode *)kmem_cache_alloc(pipefs_inode_cachep, SLAB_KERNEL);
+	if (!pi)
+		return NULL;
+	return &pi->vfs_inode;
+}
+
+static void pipefs_destroy_inode(struct inode *inode)
+{
+	kmem_cache_free(pipefs_inode_cachep, pipefs_inode(inode));
+}
+
+static int pipefs_pipe_open(struct inode *inode, struct file *filp)
+{
+	struct pipefs_inode *pi = pipefs_inode(inode);
+	int res = -ENXIO;
+
+	mutex_lock(&inode->i_mutex);
+	if (pi->ops != NULL) {
+		if (filp->f_mode & FMODE_READ)
+			pi->nreaders ++;
+		if (filp->f_mode & FMODE_WRITE)
+			pi->nwriters ++;
+		res = 0;
+	}
+	mutex_unlock(&inode->i_mutex);
+	return res;
+}
+
+static int pipefs_pipe_release(struct inode *inode, struct file *filp)
+{
+	struct pipefs_inode *pi = pipefs_inode(inode);
+	struct pipefs_msg *msg;
+
+	mutex_lock(&inode->i_mutex);
+	if (pi->ops == NULL)
+		goto out;
+	msg = (struct pipefs_msg *)filp->private_data;
+	if (msg != NULL) {
+		spin_lock(&inode->i_lock);
+		msg->errno = -EAGAIN;
+		list_del(&msg->list);
+		spin_unlock(&inode->i_lock);
+		pi->ops->destroy_msg(msg);
+	}
+	if (filp->f_mode & FMODE_WRITE)
+		pi->nwriters --;
+	if (filp->f_mode & FMODE_READ) {
+		pi->nreaders --;
+		if (pi->nreaders == 0) {
+			LIST_HEAD(free_list);
+			spin_lock(&inode->i_lock);
+			list_splice_init(&pi->pipe, &free_list);
+			pi->pipelen = 0;
+			spin_unlock(&inode->i_lock);
+			pipefs_purge_list(pi, &free_list,
+					pi->ops->destroy_msg, -EAGAIN);
+		}
+	}
+	if (pi->ops->release_pipe)
+		pi->ops->release_pipe(inode);
+out:
+	mutex_unlock(&inode->i_mutex);
+	return 0;
+}
+
+static ssize_t pipefs_pipe_read(struct file *filp, char __user *buf, size_t len, loff_t *offset)
+{
+	struct inode *inode = filp->f_dentry->d_inode;
+	struct pipefs_inode *pi = pipefs_inode(inode);
+	struct pipefs_msg *msg;
+	int res = 0;
+
+	mutex_lock(&inode->i_mutex);
+	if (pi->ops == NULL) {
+		res = -EPIPE;
+		goto out_unlock;
+	}
+	msg = filp->private_data;
+	if (msg == NULL) {
+		spin_lock(&inode->i_lock);
+		if (!list_empty(&pi->pipe)) {
+			msg = list_entry(pi->pipe.next,
+					struct pipefs_msg,
+					list);
+			list_move(&msg->list, &pi->in_upcall);
+			pi->pipelen -= msg->len;
+			filp->private_data = msg;
+			msg->copied = 0;
+		}
+		spin_unlock(&inode->i_lock);
+		if (msg == NULL)
+			goto out_unlock;
+	}
+	/* NOTE: it is up to the callback to update msg->copied */
+	res = pi->ops->upcall(filp, msg, buf, len);
+	if (res < 0 || msg->len == msg->copied) {
+		filp->private_data = NULL;
+		spin_lock(&inode->i_lock);
+		list_del(&msg->list);
+		spin_unlock(&inode->i_lock);
+		pi->ops->destroy_msg(msg);
+	}
+out_unlock:
+	mutex_unlock(&inode->i_mutex);
+	return res;
+}
+
+static ssize_t pipefs_pipe_write(struct file *filp, const char __user *buf, size_t len, loff_t *offset)
+{
+	struct inode *inode = filp->f_dentry->d_inode;
+	struct pipefs_inode *pi = pipefs_inode(inode);
+	int res;
+
+	mutex_lock(&inode->i_mutex);
+	res = -EPIPE;
+	if (pi->ops != NULL)
+		res = pi->ops->downcall(filp, buf, len);
+	mutex_unlock(&inode->i_mutex);
+	return res;
+}
+
+static unsigned int pipefs_pipe_poll(struct file *filp, struct poll_table_struct *wait)
+{
+	struct pipefs_inode *pi;
+	unsigned int mask = 0;
+
+	pi = pipefs_inode(filp->f_dentry->d_inode);
+	poll_wait(filp, &pi->waitq, wait);
+
+	mask = POLLOUT | POLLWRNORM;
+	if (pi->ops == NULL)
+		mask |= POLLERR | POLLHUP;
+	if (!list_empty(&pi->pipe))
+		mask |= POLLIN | POLLRDNORM;
+	return mask;
+}
+
+static int pipefs_pipe_ioctl(struct inode *ino, struct file *filp, unsigned int cmd, unsigned long arg)
+{
+	struct pipefs_inode *pi = pipefs_inode(filp->f_dentry->d_inode);
+	int len;
+
+	switch (cmd) {
+	case FIONREAD:
+		if (pi->ops == NULL)
+			return -EPIPE;
+		len = pi->pipelen;
+		if (filp->private_data) {
+			struct pipefs_msg *msg;
+			msg = (struct pipefs_msg *)filp->private_data;
+			len += msg->len - msg->copied;
+		}
+		return put_user(len, (int __user *)arg);
+	default:
+		return -EINVAL;
+	}
+}
+
+static struct file_operations pipefs_pipe_fops = {
+	.owner		= THIS_MODULE,
+	.llseek		= no_llseek,
+	.read		= pipefs_pipe_read,
+	.write		= pipefs_pipe_write,
+	.poll		= pipefs_pipe_poll,
+	.ioctl		= pipefs_pipe_ioctl,
+	.open		= pipefs_pipe_open,
+	.release	= pipefs_pipe_release,
+};
+
+int pipefs_get_mount(struct pipefs *pipefs)
+{
+	return simple_pin_fs(pipefs->type->name, &pipefs->mount, &pipefs->count);
+}
+
+void pipefs_put_mount(struct pipefs *pipefs)
+{
+	simple_release_fs(&pipefs->mount, &pipefs->count);
+}
+
+static int pipefs_lookup_parent(struct pipefs *pipefs, char *path, struct nameidata *nd)
+{
+	if (path[0] == '\0')
+		return -ENOENT;
+	if (pipefs_get_mount(pipefs)) {
+		printk(KERN_WARNING "%s: %s failed to mount "
+			       "pseudofilesystem \n", __FILE__, __FUNCTION__);
+		return -ENODEV;
+	}
+	nd->mnt = mntget(pipefs->mount);
+	nd->dentry = dget(pipefs->mount->mnt_root);
+	nd->last_type = LAST_ROOT;
+	nd->flags = LOOKUP_PARENT;
+	nd->depth = 0;
+
+	if (path_walk(path, nd)) {
+		printk(KERN_WARNING "%s: %s failed to find path %s\n",
+				__FILE__, __FUNCTION__, path);
+		pipefs_put_mount(pipefs);
+		return -ENOENT;
+	}
+	return 0;
+}
+
+static void pipefs_release_path(struct pipefs *pipefs, struct nameidata *nd)
+{
+	path_release(nd);
+	pipefs_put_mount(pipefs);
+}
+
+static struct inode *pipefs_get_inode(struct super_block *sb, int mode)
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
+static void pipefs_depopulate(struct dentry *parent)
+{
+	struct inode *dir = parent->d_inode;
+	struct list_head *pos, *next;
+	struct dentry *dentry, *dvec[10];
+	int n = 0;
+
+	mutex_lock(&dir->i_mutex);
+repeat:
+	spin_lock(&dcache_lock);
+	list_for_each_safe(pos, next, &parent->d_subdirs) {
+		dentry = list_entry(pos, struct dentry, d_u.d_child);
+		spin_lock(&dentry->d_lock);
+		if (!d_unhashed(dentry)) {
+			dget_locked(dentry);
+			__d_drop(dentry);
+			spin_unlock(&dentry->d_lock);
+			dvec[n++] = dentry;
+			if (n == ARRAY_SIZE(dvec))
+				break;
+		} else
+			spin_unlock(&dentry->d_lock);
+	}
+	spin_unlock(&dcache_lock);
+	if (n) {
+		do {
+			dentry = dvec[--n];
+			if (dentry->d_inode) {
+				pipefs_close_pipes(dentry->d_inode);
+				simple_unlink(dir, dentry);
+			}
+			dput(dentry);
+		} while (n);
+		goto repeat;
+	}
+	mutex_unlock(&dir->i_mutex);
+}
+
+static int pipefs_populate(struct dentry *parent, struct pipefiles *files)
+{
+	struct inode *inode, *dir = parent->d_inode;
+	void *private = pipefs_inode(dir)->private;
+	struct dentry *dentry;
+	int mode, i;
+
+	mutex_lock(&dir->i_mutex);
+	for (i = 0; i < files->count; i++) {
+		dentry = d_alloc_name(parent, files->vec[i].name);
+		if (!dentry)
+			goto out_bad;
+		mode = files->vec[i].mode;
+		inode = pipefs_get_inode(dir->i_sb, mode);
+		if (!inode) {
+			dput(dentry);
+			goto out_bad;
+		}
+		inode->i_ino = files->start + i;
+		if (files->vec[i].i_fop)
+			inode->i_fop = files->vec[i].i_fop;
+		if (private)
+			pipefs_inode_setowner(inode, private);
+		if (S_ISDIR(mode))
+			dir->i_nlink++;
+		d_add(dentry, inode);
+	}
+	mutex_unlock(&dir->i_mutex);
+	return 0;
+out_bad:
+	mutex_unlock(&dir->i_mutex);
+	printk(KERN_WARNING "%s: %s failed to populate directory %s\n",
+			__FILE__, __FUNCTION__, parent->d_name.name);
+	return -ENOMEM;
+}
+
+static int __pipefs_mkdir(struct pipefs *pipefs, struct inode *dir, struct dentry *dentry)
+{
+	struct inode *inode;
+
+	inode = pipefs_get_inode(dir->i_sb, S_IFDIR | S_IRUSR | S_IXUSR);
+	if (!inode)
+		goto out_err;
+	inode->i_ino = iunique(dir->i_sb, 100);
+	d_instantiate(dentry, inode);
+	dir->i_nlink++;
+	inode_dir_notify(dir, DN_CREATE);
+	pipefs_get_mount(pipefs);
+	return 0;
+out_err:
+	printk(KERN_WARNING "%s: %s failed to allocate inode for dentry %s\n",
+			__FILE__, __FUNCTION__, dentry->d_name.name);
+	return -ENOMEM;
+}
+
+static int __pipefs_rmdir(struct pipefs *pipefs, struct inode *dir, struct dentry *dentry)
+{
+	int error;
+
+	shrink_dcache_parent(dentry);
+	if (dentry->d_inode)
+		pipefs_close_pipes(dentry->d_inode);
+	if ((error = simple_rmdir(dir, dentry)) != 0)
+		return error;
+	if (!error) {
+		inode_dir_notify(dir, DN_DELETE);
+		d_drop(dentry);
+		pipefs_put_mount(pipefs);
+	}
+	return 0;
+}
+
+static struct dentry *pipefs_lookup_negative(struct pipefs *pipefs, char *path, struct nameidata *nd)
+{
+	struct dentry *dentry;
+	struct inode *dir;
+	int error;
+
+	if ((error = pipefs_lookup_parent(pipefs, path, nd)) != 0)
+		return ERR_PTR(error);
+	dir = nd->dentry->d_inode;
+	mutex_lock(&dir->i_mutex);
+	dentry = lookup_one_len(nd->last.name, nd->dentry, nd->last.len);
+	if (IS_ERR(dentry))
+		goto out_err;
+	if (dentry->d_inode) {
+		dput(dentry);
+		dentry = ERR_PTR(-EEXIST);
+		goto out_err;
+	}
+	return dentry;
+out_err:
+	mutex_unlock(&dir->i_mutex);
+	pipefs_release_path(pipefs, nd);
+	return dentry;
+}
+
+struct dentry *pipefs_mkdir(struct pipefs *pipefs, char *path, void *private, struct pipefiles *files)
+{
+	struct nameidata nd;
+	struct dentry *dentry;
+	struct inode *dir;
+	int error;
+
+	dentry = pipefs_lookup_negative(pipefs, path, &nd);
+	if (IS_ERR(dentry))
+		return dentry;
+	dir = nd.dentry->d_inode;
+	if ((error = __pipefs_mkdir(pipefs, dir, dentry)) != 0)
+		goto err_dput;
+	pipefs_inode(dentry->d_inode)->private = private;
+	error = pipefs_populate(dentry, files);
+	if (error)
+		goto err_depopulate;
+out:
+	mutex_unlock(&dir->i_mutex);
+	pipefs_release_path(pipefs, &nd);
+	return dentry;
+err_depopulate:
+	pipefs_depopulate(dentry);
+	__pipefs_rmdir(pipefs, dir, dentry);
+err_dput:
+	dput(dentry);
+	printk(KERN_WARNING "%s: %s() failed to create directory %s (errno = %d)\n",
+			__FILE__, __FUNCTION__, path, error);
+	dentry = ERR_PTR(error);
+	goto out;
+}
+
+int pipefs_rmdir(struct pipefs *pipefs, char *path)
+{
+	struct nameidata nd;
+	struct dentry *dentry;
+	struct inode *dir;
+	int error;
+
+	if ((error = pipefs_lookup_parent(pipefs, path, &nd)) != 0)
+		return error;
+	dir = nd.dentry->d_inode;
+	mutex_lock(&dir->i_mutex);
+	dentry = lookup_one_len(nd.last.name, nd.dentry, nd.last.len);
+	if (IS_ERR(dentry)) {
+		error = PTR_ERR(dentry);
+		goto out_release;
+	}
+	pipefs_depopulate(dentry);
+	error = __pipefs_rmdir(pipefs, dir, dentry);
+	dput(dentry);
+out_release:
+	mutex_unlock(&dir->i_mutex);
+	pipefs_release_path(pipefs, &nd);
+	return error;
+}
+
+struct dentry *pipefs_mkpipe(struct pipefs *pipefs, char *path, void *private, struct pipefs_pipe_ops *ops, int flags)
+{
+	struct nameidata nd;
+	struct dentry *dentry;
+	struct inode *dir, *inode;
+	struct pipefs_inode *pi;
+
+	dentry = pipefs_lookup_negative(pipefs, path, &nd);
+	if (IS_ERR(dentry))
+		return dentry;
+	dir = nd.dentry->d_inode;
+	inode = pipefs_get_inode(dir->i_sb, S_IFSOCK | S_IRUSR | S_IWUSR);
+	if (!inode)
+		goto err_dput;
+	inode->i_ino = iunique(dir->i_sb, 100);
+	inode->i_fop = &pipefs_pipe_fops;
+	d_instantiate(dentry, inode);
+	pi = pipefs_inode(inode);
+	pi->private = private;
+	pi->flags = flags;
+	pi->ops = ops;
+	inode_dir_notify(dir, DN_CREATE);
+out:
+	mutex_unlock(&dir->i_mutex);
+	pipefs_release_path(pipefs, &nd);
+	return dentry;
+err_dput:
+	dput(dentry);
+	dentry = ERR_PTR(-ENOMEM);
+	printk(KERN_WARNING "%s: %s() failed to create pipe %s (errno = %d)\n",
+			__FILE__, __FUNCTION__, path, -ENOMEM);
+	goto out;
+}
+
+int pipefs_unlink(struct pipefs *pipefs, char *path)
+{
+	struct nameidata nd;
+	struct dentry *dentry;
+	struct inode *dir;
+	int error;
+
+	if ((error = pipefs_lookup_parent(pipefs, path, &nd)) != 0)
+		return error;
+	dir = nd.dentry->d_inode;
+	mutex_lock(&dir->i_mutex);
+	dentry = lookup_one_len(nd.last.name, nd.dentry, nd.last.len);
+	if (IS_ERR(dentry)) {
+		error = PTR_ERR(dentry);
+		goto out_release;
+	}
+	d_drop(dentry);
+	if (dentry->d_inode) {
+		pipefs_close_pipes(dentry->d_inode);
+		error = simple_unlink(dir, dentry);
+	}
+	dput(dentry);
+	inode_dir_notify(dir, DN_DELETE);
+out_release:
+	mutex_unlock(&dir->i_mutex);
+	pipefs_release_path(pipefs, &nd);
+	return error;
+}
+
+static struct super_operations s_ops = {
+	.alloc_inode	= pipefs_alloc_inode,
+	.destroy_inode	= pipefs_destroy_inode,
+	.statfs		= simple_statfs,
+};
+
+int pipefs_fill_super(struct super_block *sb, void *data, int silent, struct pipefiles *files)
+{
+	struct inode *inode;
+	struct dentry *root;
+
+	sb->s_blocksize = PAGE_CACHE_SIZE;
+	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_magic = 0x67596969;
+	sb->s_op = &s_ops;
+	sb->s_time_gran = 1;
+
+	inode = pipefs_get_inode(sb, S_IFDIR | 0755);
+	if (!inode)
+		return -ENOMEM;
+	root = d_alloc_root(inode);
+	if (!root) {
+		iput(inode);
+		return -ENOMEM;
+	}
+	if (pipefs_populate(root, files))
+		goto out;
+	sb->s_root = root;
+	return 0;
+out:
+	d_genocide(root);
+	dput(root);
+	return -ENOMEM;
+}
+
+static void init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
+{
+	struct pipefs_inode *pi = (struct pipefs_inode *) foo;
+
+	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
+	    SLAB_CTOR_CONSTRUCTOR) {
+		inode_init_once(&pi->vfs_inode);
+		pi->private = NULL;
+		pi->nreaders = 0;
+		pi->nwriters = 0;
+		INIT_LIST_HEAD(&pi->in_upcall);
+		INIT_LIST_HEAD(&pi->pipe);
+		pi->pipelen = 0;
+		init_waitqueue_head(&pi->waitq);
+		INIT_WORK(&pi->queue_timeout, pipefs_timeout_upcall_queue, pi);
+		pi->ops = NULL;
+	}
+}
+
+static int __init init_pipefs(void)
+{
+	pipefs_inode_cachep = kmem_cache_create("pipefs inodes",
+		sizeof(struct pipefs_inode),
+		0, SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT,
+		init_once, NULL);
+
+	if (!pipefs_inode_cachep)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void __exit exit_pipefs(void)
+{
+	if (kmem_cache_destroy(pipefs_inode_cachep))
+		printk(KERN_WARNING "pipefs: inode cache free failed\n");
+}
+
+module_init(init_pipefs)
+module_exit(exit_pipefs)
+
+EXPORT_SYMBOL_GPL(pipefs_get_mount);
+EXPORT_SYMBOL_GPL(pipefs_put_mount);
+EXPORT_SYMBOL_GPL(pipefs_fill_super);
+EXPORT_SYMBOL_GPL(pipefs_queue_upcall);
+EXPORT_SYMBOL_GPL(pipefs_mkdir);
+EXPORT_SYMBOL_GPL(pipefs_rmdir);
+EXPORT_SYMBOL_GPL(pipefs_mkpipe);
+EXPORT_SYMBOL_GPL(pipefs_unlink);
+
+MODULE_AUTHOR("Trond Myklebust <Trond.Myklebust@netapp.com> and Daniel Phillips <phillips@google.com>");
+MODULE_DESCRIPTION("Pipefs Library");
+MODULE_LICENSE("GPL");
diff -urp 2.6.16.clean/include/linux/pipefs.h 2.6.16/include/linux/pipefs.h
--- 2.6.16.clean/include/linux/pipefs.h	2006-04-04 16:08:13.000000000 -0700
+++ 2.6.16/include/linux/pipefs.h	2006-04-04 19:08:08.000000000 -0700
@@ -0,0 +1,63 @@
+#ifndef _LINUX_PIPEFS_H
+#define _LINUX_PIPEFS_H
+
+struct pipefs_msg {
+	struct list_head list;
+	void *data;
+	size_t len;
+	size_t copied;
+	int errno;
+};
+
+struct pipefs_pipe_ops {
+	ssize_t (*upcall)(struct file *, struct pipefs_msg *, char __user *, size_t);
+	ssize_t (*downcall)(struct file *, const char __user *, size_t);
+	void (*release_pipe)(struct inode *);
+	void (*destroy_msg)(struct pipefs_msg *);
+};
+
+struct pipefs_inode {
+	struct inode vfs_inode;
+	void *private;
+	struct list_head pipe;
+	struct list_head in_upcall;
+	int pipelen;
+	int nreaders;
+	int nwriters;
+	wait_queue_head_t waitq;
+#define RPC_PIPE_WAIT_FOR_OPEN	1
+	int flags;
+	struct pipefs_pipe_ops *ops;
+	struct work_struct queue_timeout;
+};
+
+static inline struct pipefs_inode *pipefs_inode(struct inode *inode)
+{
+	return container_of(inode, struct pipefs_inode, vfs_inode);
+}
+
+struct pipefs {
+	struct file_system_type *type;
+	struct vfsmount *mount;
+	int count;
+};
+
+struct pipefiles {
+	int start, count;
+	struct pipefs_file {
+		char *name;
+		struct file_operations *i_fop;
+		int mode;
+	} vec[];
+};
+
+int pipefs_get_mount(struct pipefs *pipefs);
+void pipefs_put_mount(struct pipefs *pipefs);
+int pipefs_fill_super(struct super_block *sb, void *data, int silent, struct pipefiles *files);
+int pipefs_queue_upcall(struct inode *, struct pipefs_msg *);
+struct dentry *pipefs_mkdir(struct pipefs *pipefs, char *path, void *private, struct pipefiles *files);
+struct dentry *pipefs_mkpipe(struct pipefs *pipefs, char *path, void *private, struct pipefs_pipe_ops *ops, int flags);
+int pipefs_rmdir(struct pipefs *pipefs, char *path);
+int pipefs_unlink(struct pipefs *pipefs, char *path);
+
+#endif
diff -urp 2.6.16.clean/include/linux/sunrpc/rpc_pipe_fs.h 2.6.16/include/linux/sunrpc/rpc_pipe_fs.h
--- 2.6.16.clean/include/linux/sunrpc/rpc_pipe_fs.h	2006-03-19 21:53:29.000000000 -0800
+++ 2.6.16/include/linux/sunrpc/rpc_pipe_fs.h	2006-04-04 15:52:55.000000000 -0700
@@ -1,50 +1,35 @@
-#ifndef _LINUX_SUNRPC_RPC_PIPE_FS_H
+#ifndef _LINUX_SUNRPC_RPC_PIPEFS_H
 #define _LINUX_SUNRPC_RPC_PIPE_FS_H
 
-#ifdef __KERNEL__
+#include <linux/pipefs.h>
 
-struct rpc_pipe_msg {
-	struct list_head list;
-	void *data;
-	size_t len;
-	size_t copied;
-	int errno;
-};
-
-struct rpc_pipe_ops {
-	ssize_t (*upcall)(struct file *, struct rpc_pipe_msg *, char __user *, size_t);
-	ssize_t (*downcall)(struct file *, const char __user *, size_t);
-	void (*release_pipe)(struct inode *);
-	void (*destroy_msg)(struct rpc_pipe_msg *);
-};
-
-struct rpc_inode {
-	struct inode vfs_inode;
-	void *private;
-	struct list_head pipe;
-	struct list_head in_upcall;
-	int pipelen;
-	int nreaders;
-	int nwriters;
-	wait_queue_head_t waitq;
-#define RPC_PIPE_WAIT_FOR_OPEN	1
-	int flags;
-	struct rpc_pipe_ops *ops;
-	struct work_struct queue_timeout;
-};
+extern struct pipefiles authfiles;
+extern struct pipefs rpc_pipefs;
 
-static inline struct rpc_inode *
-RPC_I(struct inode *inode)
+static inline struct dentry *rpc_mkdir(char *path, struct rpc_clnt *rpc_client)
 {
-	return container_of(inode, struct rpc_inode, vfs_inode);
+	return pipefs_mkdir(&rpc_pipefs, path, rpc_client, &authfiles);
 }
 
-extern int rpc_queue_upcall(struct inode *, struct rpc_pipe_msg *);
+static inline struct dentry *rpc_mkpipe(char *path, void *private, struct pipefs_pipe_ops *ops, int flags)
+{
+	return pipefs_mkpipe(&rpc_pipefs, path, private, ops, flags);
+}
 
-extern struct dentry *rpc_mkdir(char *, struct rpc_clnt *);
-extern int rpc_rmdir(char *);
-extern struct dentry *rpc_mkpipe(char *, void *, struct rpc_pipe_ops *, int flags);
-extern int rpc_unlink(char *);
+static inline int rpc_rmdir(char *path)
+{
+	return pipefs_rmdir(&rpc_pipefs, path);
+}
+
+static inline int rpc_unlink(char *path)
+{
+	return pipefs_unlink(&rpc_pipefs, path);
+}
+
+#define rpc_queue_upcall pipefs_queue_upcall
+#define rpc_pipe_ops pipefs_pipe_ops
+#define rpc_pipe_msg pipefs_msg
+#define rpc_inode pipefs_inode
+#define RPC_I pipefs_inode
 
-#endif
 #endif
diff -urp 2.6.16.clean/net/sunrpc/rpc_pipe.c 2.6.16/net/sunrpc/rpc_pipe.c
--- 2.6.16.clean/net/sunrpc/rpc_pipe.c	2006-03-19 21:53:29.000000000 -0800
+++ 2.6.16/net/sunrpc/rpc_pipe.c	2006-04-04 18:04:17.000000000 -0700
@@ -8,319 +8,36 @@
  * Copyright (c) 2002, Trond Myklebust <trond.myklebust@fys.uio.no>
  *
  */
-#include <linux/config.h>
 #include <linux/module.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/pagemap.h>
-#include <linux/mount.h>
-#include <linux/namei.h>
-#include <linux/dnotify.h>
-#include <linux/kernel.h>
-
-#include <asm/ioctls.h>
-#include <linux/fs.h>
-#include <linux/poll.h>
-#include <linux/wait.h>
 #include <linux/seq_file.h>
-
 #include <linux/sunrpc/clnt.h>
-#include <linux/workqueue.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 
-static struct vfsmount *rpc_mount __read_mostly;
-static int rpc_mount_count;
-
-static struct file_system_type rpc_pipe_fs_type;
-
-
-static kmem_cache_t *rpc_inode_cachep __read_mostly;
-
-#define RPC_UPCALL_TIMEOUT (30*HZ)
-
-static void rpc_purge_list(struct rpc_inode *rpci, struct list_head *head,
-		void (*destroy_msg)(struct rpc_pipe_msg *), int err)
-{
-	struct rpc_pipe_msg *msg;
-
-	if (list_empty(head))
-		return;
-	do {
-		msg = list_entry(head->next, struct rpc_pipe_msg, list);
-		list_del(&msg->list);
-		msg->errno = err;
-		destroy_msg(msg);
-	} while (!list_empty(head));
-	wake_up(&rpci->waitq);
-}
-
-static void
-rpc_timeout_upcall_queue(void *data)
-{
-	LIST_HEAD(free_list);
-	struct rpc_inode *rpci = (struct rpc_inode *)data;
-	struct inode *inode = &rpci->vfs_inode;
-	void (*destroy_msg)(struct rpc_pipe_msg *);
-
-	spin_lock(&inode->i_lock);
-	if (rpci->ops == NULL) {
-		spin_unlock(&inode->i_lock);
-		return;
-	}
-	destroy_msg = rpci->ops->destroy_msg;
-	if (rpci->nreaders == 0) {
-		list_splice_init(&rpci->pipe, &free_list);
-		rpci->pipelen = 0;
-	}
-	spin_unlock(&inode->i_lock);
-	rpc_purge_list(rpci, &free_list, destroy_msg, -ETIMEDOUT);
-}
-
-int
-rpc_queue_upcall(struct inode *inode, struct rpc_pipe_msg *msg)
-{
-	struct rpc_inode *rpci = RPC_I(inode);
-	int res = -EPIPE;
-
-	spin_lock(&inode->i_lock);
-	if (rpci->ops == NULL)
-		goto out;
-	if (rpci->nreaders) {
-		list_add_tail(&msg->list, &rpci->pipe);
-		rpci->pipelen += msg->len;
-		res = 0;
-	} else if (rpci->flags & RPC_PIPE_WAIT_FOR_OPEN) {
-		if (list_empty(&rpci->pipe))
-			schedule_delayed_work(&rpci->queue_timeout,
-					RPC_UPCALL_TIMEOUT);
-		list_add_tail(&msg->list, &rpci->pipe);
-		rpci->pipelen += msg->len;
-		res = 0;
-	}
-out:
-	spin_unlock(&inode->i_lock);
-	wake_up(&rpci->waitq);
-	return res;
-}
-
-static inline void
-rpc_inode_setowner(struct inode *inode, void *private)
-{
-	RPC_I(inode)->private = private;
-}
-
-static void
-rpc_close_pipes(struct inode *inode)
-{
-	struct rpc_inode *rpci = RPC_I(inode);
-	struct rpc_pipe_ops *ops;
-
-	mutex_lock(&inode->i_mutex);
-	ops = rpci->ops;
-	if (ops != NULL) {
-		LIST_HEAD(free_list);
-
-		spin_lock(&inode->i_lock);
-		rpci->nreaders = 0;
-		list_splice_init(&rpci->in_upcall, &free_list);
-		list_splice_init(&rpci->pipe, &free_list);
-		rpci->pipelen = 0;
-		rpci->ops = NULL;
-		spin_unlock(&inode->i_lock);
-		rpc_purge_list(rpci, &free_list, ops->destroy_msg, -EPIPE);
-		rpci->nwriters = 0;
-		if (ops->release_pipe)
-			ops->release_pipe(inode);
-		cancel_delayed_work(&rpci->queue_timeout);
-		flush_scheduled_work();
-	}
-	rpc_inode_setowner(inode, NULL);
-	mutex_unlock(&inode->i_mutex);
-}
-
-static struct inode *
-rpc_alloc_inode(struct super_block *sb)
-{
-	struct rpc_inode *rpci;
-	rpci = (struct rpc_inode *)kmem_cache_alloc(rpc_inode_cachep, SLAB_KERNEL);
-	if (!rpci)
-		return NULL;
-	return &rpci->vfs_inode;
-}
-
-static void
-rpc_destroy_inode(struct inode *inode)
-{
-	kmem_cache_free(rpc_inode_cachep, RPC_I(inode));
-}
-
-static int
-rpc_pipe_open(struct inode *inode, struct file *filp)
-{
-	struct rpc_inode *rpci = RPC_I(inode);
-	int res = -ENXIO;
-
-	mutex_lock(&inode->i_mutex);
-	if (rpci->ops != NULL) {
-		if (filp->f_mode & FMODE_READ)
-			rpci->nreaders ++;
-		if (filp->f_mode & FMODE_WRITE)
-			rpci->nwriters ++;
-		res = 0;
-	}
-	mutex_unlock(&inode->i_mutex);
-	return res;
-}
-
-static int
-rpc_pipe_release(struct inode *inode, struct file *filp)
-{
-	struct rpc_inode *rpci = RPC_I(inode);
-	struct rpc_pipe_msg *msg;
-
-	mutex_lock(&inode->i_mutex);
-	if (rpci->ops == NULL)
-		goto out;
-	msg = (struct rpc_pipe_msg *)filp->private_data;
-	if (msg != NULL) {
-		spin_lock(&inode->i_lock);
-		msg->errno = -EAGAIN;
-		list_del(&msg->list);
-		spin_unlock(&inode->i_lock);
-		rpci->ops->destroy_msg(msg);
-	}
-	if (filp->f_mode & FMODE_WRITE)
-		rpci->nwriters --;
-	if (filp->f_mode & FMODE_READ) {
-		rpci->nreaders --;
-		if (rpci->nreaders == 0) {
-			LIST_HEAD(free_list);
-			spin_lock(&inode->i_lock);
-			list_splice_init(&rpci->pipe, &free_list);
-			rpci->pipelen = 0;
-			spin_unlock(&inode->i_lock);
-			rpc_purge_list(rpci, &free_list,
-					rpci->ops->destroy_msg, -EAGAIN);
-		}
-	}
-	if (rpci->ops->release_pipe)
-		rpci->ops->release_pipe(inode);
-out:
-	mutex_unlock(&inode->i_mutex);
-	return 0;
-}
-
-static ssize_t
-rpc_pipe_read(struct file *filp, char __user *buf, size_t len, loff_t *offset)
-{
-	struct inode *inode = filp->f_dentry->d_inode;
-	struct rpc_inode *rpci = RPC_I(inode);
-	struct rpc_pipe_msg *msg;
-	int res = 0;
-
-	mutex_lock(&inode->i_mutex);
-	if (rpci->ops == NULL) {
-		res = -EPIPE;
-		goto out_unlock;
-	}
-	msg = filp->private_data;
-	if (msg == NULL) {
-		spin_lock(&inode->i_lock);
-		if (!list_empty(&rpci->pipe)) {
-			msg = list_entry(rpci->pipe.next,
-					struct rpc_pipe_msg,
-					list);
-			list_move(&msg->list, &rpci->in_upcall);
-			rpci->pipelen -= msg->len;
-			filp->private_data = msg;
-			msg->copied = 0;
-		}
-		spin_unlock(&inode->i_lock);
-		if (msg == NULL)
-			goto out_unlock;
-	}
-	/* NOTE: it is up to the callback to update msg->copied */
-	res = rpci->ops->upcall(filp, msg, buf, len);
-	if (res < 0 || msg->len == msg->copied) {
-		filp->private_data = NULL;
-		spin_lock(&inode->i_lock);
-		list_del(&msg->list);
-		spin_unlock(&inode->i_lock);
-		rpci->ops->destroy_msg(msg);
-	}
-out_unlock:
-	mutex_unlock(&inode->i_mutex);
-	return res;
-}
-
-static ssize_t
-rpc_pipe_write(struct file *filp, const char __user *buf, size_t len, loff_t *offset)
-{
-	struct inode *inode = filp->f_dentry->d_inode;
-	struct rpc_inode *rpci = RPC_I(inode);
-	int res;
-
-	mutex_lock(&inode->i_mutex);
-	res = -EPIPE;
-	if (rpci->ops != NULL)
-		res = rpci->ops->downcall(filp, buf, len);
-	mutex_unlock(&inode->i_mutex);
-	return res;
-}
-
-static unsigned int
-rpc_pipe_poll(struct file *filp, struct poll_table_struct *wait)
-{
-	struct rpc_inode *rpci;
-	unsigned int mask = 0;
-
-	rpci = RPC_I(filp->f_dentry->d_inode);
-	poll_wait(filp, &rpci->waitq, wait);
-
-	mask = POLLOUT | POLLWRNORM;
-	if (rpci->ops == NULL)
-		mask |= POLLERR | POLLHUP;
-	if (!list_empty(&rpci->pipe))
-		mask |= POLLIN | POLLRDNORM;
-	return mask;
-}
-
-static int
-rpc_pipe_ioctl(struct inode *ino, struct file *filp,
-		unsigned int cmd, unsigned long arg)
-{
-	struct rpc_inode *rpci = RPC_I(filp->f_dentry->d_inode);
-	int len;
-
-	switch (cmd) {
-	case FIONREAD:
-		if (rpci->ops == NULL)
-			return -EPIPE;
-		len = rpci->pipelen;
-		if (filp->private_data) {
-			struct rpc_pipe_msg *msg;
-			msg = (struct rpc_pipe_msg *)filp->private_data;
-			len += msg->len - msg->copied;
-		}
-		return put_user(len, (int __user *)arg);
-	default:
-		return -EINVAL;
+static struct pipefiles rootfiles = { 2, 5, {
+	{
+		.name = "lockd",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
+	{
+		.name = "mount",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
+	{
+		.name = "nfs",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
+	{
+		.name = "portmap",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
+	{
+		.name = "statd",
+		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
+	},
 	}
-}
-
-static struct file_operations rpc_pipe_fops = {
-	.owner		= THIS_MODULE,
-	.llseek		= no_llseek,
-	.read		= rpc_pipe_read,
-	.write		= rpc_pipe_write,
-	.poll		= rpc_pipe_poll,
-	.ioctl		= rpc_pipe_ioctl,
-	.open		= rpc_pipe_open,
-	.release	= rpc_pipe_release,
 };
 
-static int
-rpc_show_info(struct seq_file *m, void *v)
+static int rpc_show_info(struct seq_file *m, void *v)
 {
 	struct rpc_clnt *clnt = m->private;
 
@@ -334,8 +51,7 @@ rpc_show_info(struct seq_file *m, void *
 	return 0;
 }
 
-static int
-rpc_info_open(struct inode *inode, struct file *file)
+static int rpc_info_open(struct inode *inode, struct file *file)
 {
 	struct rpc_clnt *clnt;
 	int ret = single_open(file, rpc_show_info, NULL);
@@ -356,8 +72,7 @@ rpc_info_open(struct inode *inode, struc
 	return ret;
 }
 
-static int
-rpc_info_release(struct inode *inode, struct file *file)
+static int rpc_info_release(struct inode *inode, struct file *file)
 {
 	struct seq_file *m = file->private_data;
 	struct rpc_clnt *clnt = (struct rpc_clnt *)m->private;
@@ -375,445 +90,12 @@ static struct file_operations rpc_info_o
 	.release	= rpc_info_release,
 };
 
-
-/*
- * We have a single directory with 1 node in it.
- */
-enum {
-	RPCAUTH_Root = 1,
-	RPCAUTH_lockd,
-	RPCAUTH_mount,
-	RPCAUTH_nfs,
-	RPCAUTH_portmap,
-	RPCAUTH_statd,
-	RPCAUTH_RootEOF
-};
-
-/*
- * Description of fs contents.
- */
-struct rpc_filelist {
-	char *name;
-	struct file_operations *i_fop;
-	int mode;
-};
-
-static struct rpc_filelist files[] = {
-	[RPCAUTH_lockd] = {
-		.name = "lockd",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
-	},
-	[RPCAUTH_mount] = {
-		.name = "mount",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
-	},
-	[RPCAUTH_nfs] = {
-		.name = "nfs",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
-	},
-	[RPCAUTH_portmap] = {
-		.name = "portmap",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
-	},
-	[RPCAUTH_statd] = {
-		.name = "statd",
-		.mode = S_IFDIR | S_IRUGO | S_IXUGO,
-	},
-};
-
-enum {
-	RPCAUTH_info = 2,
-	RPCAUTH_EOF
-};
-
-static struct rpc_filelist authfiles[] = {
-	[RPCAUTH_info] = {
-		.name = "info",
-		.i_fop = &rpc_info_operations,
-		.mode = S_IFREG | S_IRUSR,
-	},
-};
-
-static int
-rpc_get_mount(void)
-{
-	return simple_pin_fs("rpc_pipefs", &rpc_mount, &rpc_mount_count);
-}
-
-static void
-rpc_put_mount(void)
-{
-	simple_release_fs(&rpc_mount, &rpc_mount_count);
-}
-
-static int
-rpc_lookup_parent(char *path, struct nameidata *nd)
-{
-	if (path[0] == '\0')
-		return -ENOENT;
-	if (rpc_get_mount()) {
-		printk(KERN_WARNING "%s: %s failed to mount "
-			       "pseudofilesystem \n", __FILE__, __FUNCTION__);
-		return -ENODEV;
-	}
-	nd->mnt = mntget(rpc_mount);
-	nd->dentry = dget(rpc_mount->mnt_root);
-	nd->last_type = LAST_ROOT;
-	nd->flags = LOOKUP_PARENT;
-	nd->depth = 0;
-
-	if (path_walk(path, nd)) {
-		printk(KERN_WARNING "%s: %s failed to find path %s\n",
-				__FILE__, __FUNCTION__, path);
-		rpc_put_mount();
-		return -ENOENT;
-	}
-	return 0;
-}
-
-static void
-rpc_release_path(struct nameidata *nd)
-{
-	path_release(nd);
-	rpc_put_mount();
-}
-
-static struct inode *
-rpc_get_inode(struct super_block *sb, int mode)
-{
-	struct inode *inode = new_inode(sb);
-	if (!inode)
-		return NULL;
-	inode->i_mode = mode;
-	inode->i_uid = inode->i_gid = 0;
-	inode->i_blksize = PAGE_CACHE_SIZE;
-	inode->i_blocks = 0;
-	inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
-	switch(mode & S_IFMT) {
-		case S_IFDIR:
-			inode->i_fop = &simple_dir_operations;
-			inode->i_op = &simple_dir_inode_operations;
-			inode->i_nlink++;
-		default:
-			break;
-	}
-	return inode;
-}
-
-/*
- * FIXME: This probably has races.
- */
-static void
-rpc_depopulate(struct dentry *parent)
-{
-	struct inode *dir = parent->d_inode;
-	struct list_head *pos, *next;
-	struct dentry *dentry, *dvec[10];
-	int n = 0;
-
-	mutex_lock(&dir->i_mutex);
-repeat:
-	spin_lock(&dcache_lock);
-	list_for_each_safe(pos, next, &parent->d_subdirs) {
-		dentry = list_entry(pos, struct dentry, d_u.d_child);
-		spin_lock(&dentry->d_lock);
-		if (!d_unhashed(dentry)) {
-			dget_locked(dentry);
-			__d_drop(dentry);
-			spin_unlock(&dentry->d_lock);
-			dvec[n++] = dentry;
-			if (n == ARRAY_SIZE(dvec))
-				break;
-		} else
-			spin_unlock(&dentry->d_lock);
-	}
-	spin_unlock(&dcache_lock);
-	if (n) {
-		do {
-			dentry = dvec[--n];
-			if (dentry->d_inode) {
-				rpc_close_pipes(dentry->d_inode);
-				simple_unlink(dir, dentry);
-			}
-			dput(dentry);
-		} while (n);
-		goto repeat;
-	}
-	mutex_unlock(&dir->i_mutex);
-}
-
-static int
-rpc_populate(struct dentry *parent,
-		struct rpc_filelist *files,
-		int start, int eof)
-{
-	struct inode *inode, *dir = parent->d_inode;
-	void *private = RPC_I(dir)->private;
-	struct dentry *dentry;
-	int mode, i;
-
-	mutex_lock(&dir->i_mutex);
-	for (i = start; i < eof; i++) {
-		dentry = d_alloc_name(parent, files[i].name);
-		if (!dentry)
-			goto out_bad;
-		mode = files[i].mode;
-		inode = rpc_get_inode(dir->i_sb, mode);
-		if (!inode) {
-			dput(dentry);
-			goto out_bad;
-		}
-		inode->i_ino = i;
-		if (files[i].i_fop)
-			inode->i_fop = files[i].i_fop;
-		if (private)
-			rpc_inode_setowner(inode, private);
-		if (S_ISDIR(mode))
-			dir->i_nlink++;
-		d_add(dentry, inode);
-	}
-	mutex_unlock(&dir->i_mutex);
-	return 0;
-out_bad:
-	mutex_unlock(&dir->i_mutex);
-	printk(KERN_WARNING "%s: %s failed to populate directory %s\n",
-			__FILE__, __FUNCTION__, parent->d_name.name);
-	return -ENOMEM;
-}
-
-static int
-__rpc_mkdir(struct inode *dir, struct dentry *dentry)
-{
-	struct inode *inode;
-
-	inode = rpc_get_inode(dir->i_sb, S_IFDIR | S_IRUSR | S_IXUSR);
-	if (!inode)
-		goto out_err;
-	inode->i_ino = iunique(dir->i_sb, 100);
-	d_instantiate(dentry, inode);
-	dir->i_nlink++;
-	inode_dir_notify(dir, DN_CREATE);
-	rpc_get_mount();
-	return 0;
-out_err:
-	printk(KERN_WARNING "%s: %s failed to allocate inode for dentry %s\n",
-			__FILE__, __FUNCTION__, dentry->d_name.name);
-	return -ENOMEM;
-}
-
-static int
-__rpc_rmdir(struct inode *dir, struct dentry *dentry)
-{
-	int error;
-
-	shrink_dcache_parent(dentry);
-	if (dentry->d_inode)
-		rpc_close_pipes(dentry->d_inode);
-	if ((error = simple_rmdir(dir, dentry)) != 0)
-		return error;
-	if (!error) {
-		inode_dir_notify(dir, DN_DELETE);
-		d_drop(dentry);
-		rpc_put_mount();
-	}
-	return 0;
-}
-
-static struct dentry *
-rpc_lookup_negative(char *path, struct nameidata *nd)
-{
-	struct dentry *dentry;
-	struct inode *dir;
-	int error;
-
-	if ((error = rpc_lookup_parent(path, nd)) != 0)
-		return ERR_PTR(error);
-	dir = nd->dentry->d_inode;
-	mutex_lock(&dir->i_mutex);
-	dentry = lookup_one_len(nd->last.name, nd->dentry, nd->last.len);
-	if (IS_ERR(dentry))
-		goto out_err;
-	if (dentry->d_inode) {
-		dput(dentry);
-		dentry = ERR_PTR(-EEXIST);
-		goto out_err;
-	}
-	return dentry;
-out_err:
-	mutex_unlock(&dir->i_mutex);
-	rpc_release_path(nd);
-	return dentry;
-}
-
-
-struct dentry *
-rpc_mkdir(char *path, struct rpc_clnt *rpc_client)
-{
-	struct nameidata nd;
-	struct dentry *dentry;
-	struct inode *dir;
-	int error;
-
-	dentry = rpc_lookup_negative(path, &nd);
-	if (IS_ERR(dentry))
-		return dentry;
-	dir = nd.dentry->d_inode;
-	if ((error = __rpc_mkdir(dir, dentry)) != 0)
-		goto err_dput;
-	RPC_I(dentry->d_inode)->private = rpc_client;
-	error = rpc_populate(dentry, authfiles,
-			RPCAUTH_info, RPCAUTH_EOF);
-	if (error)
-		goto err_depopulate;
-out:
-	mutex_unlock(&dir->i_mutex);
-	rpc_release_path(&nd);
-	return dentry;
-err_depopulate:
-	rpc_depopulate(dentry);
-	__rpc_rmdir(dir, dentry);
-err_dput:
-	dput(dentry);
-	printk(KERN_WARNING "%s: %s() failed to create directory %s (errno = %d)\n",
-			__FILE__, __FUNCTION__, path, error);
-	dentry = ERR_PTR(error);
-	goto out;
-}
-
-int
-rpc_rmdir(char *path)
-{
-	struct nameidata nd;
-	struct dentry *dentry;
-	struct inode *dir;
-	int error;
-
-	if ((error = rpc_lookup_parent(path, &nd)) != 0)
-		return error;
-	dir = nd.dentry->d_inode;
-	mutex_lock(&dir->i_mutex);
-	dentry = lookup_one_len(nd.last.name, nd.dentry, nd.last.len);
-	if (IS_ERR(dentry)) {
-		error = PTR_ERR(dentry);
-		goto out_release;
-	}
-	rpc_depopulate(dentry);
-	error = __rpc_rmdir(dir, dentry);
-	dput(dentry);
-out_release:
-	mutex_unlock(&dir->i_mutex);
-	rpc_release_path(&nd);
-	return error;
-}
-
-struct dentry *
-rpc_mkpipe(char *path, void *private, struct rpc_pipe_ops *ops, int flags)
-{
-	struct nameidata nd;
-	struct dentry *dentry;
-	struct inode *dir, *inode;
-	struct rpc_inode *rpci;
-
-	dentry = rpc_lookup_negative(path, &nd);
-	if (IS_ERR(dentry))
-		return dentry;
-	dir = nd.dentry->d_inode;
-	inode = rpc_get_inode(dir->i_sb, S_IFSOCK | S_IRUSR | S_IWUSR);
-	if (!inode)
-		goto err_dput;
-	inode->i_ino = iunique(dir->i_sb, 100);
-	inode->i_fop = &rpc_pipe_fops;
-	d_instantiate(dentry, inode);
-	rpci = RPC_I(inode);
-	rpci->private = private;
-	rpci->flags = flags;
-	rpci->ops = ops;
-	inode_dir_notify(dir, DN_CREATE);
-out:
-	mutex_unlock(&dir->i_mutex);
-	rpc_release_path(&nd);
-	return dentry;
-err_dput:
-	dput(dentry);
-	dentry = ERR_PTR(-ENOMEM);
-	printk(KERN_WARNING "%s: %s() failed to create pipe %s (errno = %d)\n",
-			__FILE__, __FUNCTION__, path, -ENOMEM);
-	goto out;
-}
-
-int
-rpc_unlink(char *path)
-{
-	struct nameidata nd;
-	struct dentry *dentry;
-	struct inode *dir;
-	int error;
-
-	if ((error = rpc_lookup_parent(path, &nd)) != 0)
-		return error;
-	dir = nd.dentry->d_inode;
-	mutex_lock(&dir->i_mutex);
-	dentry = lookup_one_len(nd.last.name, nd.dentry, nd.last.len);
-	if (IS_ERR(dentry)) {
-		error = PTR_ERR(dentry);
-		goto out_release;
-	}
-	d_drop(dentry);
-	if (dentry->d_inode) {
-		rpc_close_pipes(dentry->d_inode);
-		error = simple_unlink(dir, dentry);
-	}
-	dput(dentry);
-	inode_dir_notify(dir, DN_DELETE);
-out_release:
-	mutex_unlock(&dir->i_mutex);
-	rpc_release_path(&nd);
-	return error;
-}
-
-/*
- * populate the filesystem
- */
-static struct super_operations s_ops = {
-	.alloc_inode	= rpc_alloc_inode,
-	.destroy_inode	= rpc_destroy_inode,
-	.statfs		= simple_statfs,
-};
-
-#define RPCAUTH_GSSMAGIC 0x67596969
-
-static int
-rpc_fill_super(struct super_block *sb, void *data, int silent)
+static int rpc_fill_super(struct super_block *sb, void *data, int silent)
 {
-	struct inode *inode;
-	struct dentry *root;
-
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
-	sb->s_magic = RPCAUTH_GSSMAGIC;
-	sb->s_op = &s_ops;
-	sb->s_time_gran = 1;
-
-	inode = rpc_get_inode(sb, S_IFDIR | 0755);
-	if (!inode)
-		return -ENOMEM;
-	root = d_alloc_root(inode);
-	if (!root) {
-		iput(inode);
-		return -ENOMEM;
-	}
-	if (rpc_populate(root, files, RPCAUTH_Root + 1, RPCAUTH_RootEOF))
-		goto out;
-	sb->s_root = root;
-	return 0;
-out:
-	d_genocide(root);
-	dput(root);
-	return -ENOMEM;
+	return pipefs_fill_super(sb, data, silent, &rootfiles);
 }
 
-static struct super_block *
-rpc_get_sb(struct file_system_type *fs_type,
+static struct super_block *rpc_get_sb(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *data)
 {
 	return get_sb_single(fs_type, flags, data, rpc_fill_super);
@@ -826,41 +108,23 @@ static struct file_system_type rpc_pipe_
 	.kill_sb	= kill_litter_super,
 };
 
-static void
-init_once(void * foo, kmem_cache_t * cachep, unsigned long flags)
-{
-	struct rpc_inode *rpci = (struct rpc_inode *) foo;
+struct pipefiles authfiles = { 2, 1, {
+	{
+		.name = "info",
+		.i_fop = &rpc_info_operations,
+		.mode = S_IFREG | S_IRUSR,
+	}, }
+};
 
-	if ((flags & (SLAB_CTOR_VERIFY|SLAB_CTOR_CONSTRUCTOR)) ==
-	    SLAB_CTOR_CONSTRUCTOR) {
-		inode_init_once(&rpci->vfs_inode);
-		rpci->private = NULL;
-		rpci->nreaders = 0;
-		rpci->nwriters = 0;
-		INIT_LIST_HEAD(&rpci->in_upcall);
-		INIT_LIST_HEAD(&rpci->pipe);
-		rpci->pipelen = 0;
-		init_waitqueue_head(&rpci->waitq);
-		INIT_WORK(&rpci->queue_timeout, rpc_timeout_upcall_queue, rpci);
-		rpci->ops = NULL;
-	}
-}
+struct pipefs rpc_pipefs = { .type = &rpc_pipe_fs_type };
+EXPORT_SYMBOL_GPL(rpc_pipefs);
 
 int register_rpc_pipefs(void)
 {
-	rpc_inode_cachep = kmem_cache_create("rpc_inode_cache",
-                                             sizeof(struct rpc_inode),
-                                             0, SLAB_HWCACHE_ALIGN|SLAB_RECLAIM_ACCOUNT,
-                                             init_once, NULL);
-	if (!rpc_inode_cachep)
-		return -ENOMEM;
-	register_filesystem(&rpc_pipe_fs_type);
-	return 0;
+	return register_filesystem(&rpc_pipe_fs_type);
 }
 
 void unregister_rpc_pipefs(void)
 {
-	if (kmem_cache_destroy(rpc_inode_cachep))
-		printk(KERN_WARNING "RPC: unable to free inode cache\n");
 	unregister_filesystem(&rpc_pipe_fs_type);
 }



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
