Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:34547 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751354AbdECShR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 14:37:17 -0400
Received: by mail-qt0-f171.google.com with SMTP id c45so145112711qtb.1
        for <linux-nfs@vger.kernel.org>; Wed, 03 May 2017 11:37:17 -0700 (PDT)
Message-ID: <1493836633.3180.9.camel@poochiereds.net>
Subject: Re: [PATCH 4/9] Implement fsopen() to prepare for a mount
From: Jeff Layton <jlayton@poochiereds.net>
To: David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Date: Wed, 03 May 2017 14:37:13 -0400
In-Reply-To: <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
         <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-05-03 at 17:05 +0100, David Howells wrote:
> Provide an fsopen() system call that starts the process of preparing to
> mount, using an fd as a context handle.  fsopen() is given the name of the
> filesystem that will be used:
> 
> 	int mfd = fsopen(const char *fsname, int reserved,
> 			 int open_flags);
> 
> where reserved should be -1 for the moment (it will be used to pass the
> namespace information in future) and open_flags can be 0 or O_CLOEXEC.
> 
> For example:
> 
> 	mfd = fsopen("ext4", -1, O_CLOEXEC);
> 	write(mfd, "d /dev/sdb1"); // note I'm ignoring write's length arg
> 	write(mfd, "o noatime");
> 	write(mfd, "o acl");
> 	write(mfd, "o user_attr");
> 	write(mfd, "o iversion");
> 	write(mfd, "o ");
> 	write(mfd, "r /my/container"); // root inside the fs
> 	fsmount(mfd, container_fd, "/mnt", AT_NO_FOLLOW);
> 
>	mfd = fsopen("afs", -1);
> 	write(mfd, "d %grand.central.org:root.cell");
> 	write(mfd, "o cell=grand.central.org");
> 	write(mfd, "r /");
> 	fsmount(mfd, AT_FDCWD, "/mnt", 0);
> 

I think one of the neat things here is that we can now error out as
soon as a bogus mount option is passed in.

That takes out some of the guesswork on which option is the problem
when you get back something like -EINVAL. On something like CIFS (which
has a lot of crazy mount options) that is much more useful.

> If an error is reported at any step, an error message may be available to be
> read() back (ENODATA will be reported if there isn't an error available) in
> the form:
> 
> 	"e <subsys>:<problem>"
> 	"e SELinux:Mount on mountpoint not permitted"
> 

I like this too. No need to printk stuff when there is a problem
mounting. The error goes straight to the caller who initiated the
mount.

That's a very nice thing in heavily containerized environments, for
instance. If you're doing mounts in a container and they fail, then
trying to scrape dmesg and figure out which messages refer to _your_
mount attempt seems like it could be rather nasty. This solves that
problem in a much more sane way, IMO.

> Once fsmount() has been called, further write() calls will incur EBUSY,
> even if the fsmount() fails.  read() is still possible to retrieve error
> information.
> 

What's the rationale for the above behavior?

A failed attempt to graft it into the tree doesn't seem like it would
have any real effect on the mount_context. While I can't think of a use
case for being able to try fsmount() again, I don't quite understand
why we'd prohibit someone from doing it.

> The fsopen() syscall creates a mount context and hangs it of the fd that it
> returns.
> 
> Netlink is not used because it is optional.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  arch/x86/entry/syscalls/syscall_32.tbl |    1 
>  arch/x86/entry/syscalls/syscall_64.tbl |    1 
>  fs/Makefile                            |    2 
>  fs/fsopen.c                            |  295 ++++++++++++++++++++++++++++++++
>  include/linux/syscalls.h               |    1 
>  include/uapi/linux/magic.h             |    1 
>  kernel/sys_ni.c                        |    3 
>  7 files changed, 303 insertions(+), 1 deletion(-)
>  create mode 100644 fs/fsopen.c
> 
> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
> index 448ac2161112..9bf8d4c62f85 100644
> --- a/arch/x86/entry/syscalls/syscall_32.tbl
> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> @@ -391,3 +391,4 @@
>  382	i386	pkey_free		sys_pkey_free
>  383	i386	statx			sys_statx
>  384	i386	arch_prctl		sys_arch_prctl			compat_sys_arch_prctl
> +385	i386	fsopen			sys_fsopen
> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
> index 5aef183e2f85..9b198c5fc412 100644
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -339,6 +339,7 @@
>  330	common	pkey_alloc		sys_pkey_alloc
>  331	common	pkey_free		sys_pkey_free
>  332	common	statx			sys_statx
> +333	common	fsopen			sys_fsopen
>  
>  #
>  # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/fs/Makefile b/fs/Makefile
> index 308a104a9a07..b79024dbb37c 100644
> --- a/fs/Makefile
> +++ b/fs/Makefile
> @@ -12,7 +12,7 @@ obj-y :=	open.o read_write.o file_table.o super.o \
>  		seq_file.o xattr.o libfs.o fs-writeback.o \
>  		pnode.o splice.o sync.o utimes.o \
>  		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o \
> -		mount_context.o
> +		mount_context.o fsopen.o
>  
>  ifeq ($(CONFIG_BLOCK),y)
>  obj-y +=	buffer.o block_dev.o direct-io.o mpage.o
> diff --git a/fs/fsopen.c b/fs/fsopen.c
> new file mode 100644
> index 000000000000..f02ea7d265db
> --- /dev/null
> +++ b/fs/fsopen.c
> @@ -0,0 +1,295 @@
> +/* fsopen.c: description
> + *
> + * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
> + * Written by David Howells (dhowells@redhat.com)
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public Licence
> + * as published by the Free Software Foundation; either version
> + * 2 of the Licence, or (at your option) any later version.
> + */
> +
> +#include <linux/mount.h>
> +#include <linux/slab.h>
> +#include <linux/uaccess.h>
> +#include <linux/file.h>
> +#include <linux/magic.h>
> +#include <linux/syscalls.h>
> +
> +static struct vfsmount *fs_fs_mnt __read_mostly;
> +static struct qstr empty_name = { .name = "" };
> +
> +static int fs_fs_release(struct inode *inode, struct file *file)
> +{
> +	struct mount_context *mc = file->private_data;
> +
> +	file->private_data = NULL;
> +
> +	put_mount_context(mc);
> +	return 0;
> +}
> +
> +/*
> + * Read any error message back from the fd.  Will be prefixed by "e ".
> + */
> +static ssize_t fs_fs_read(struct file *file, char __user *_buf, size_t len, loff_t *pos)
> +{
> +	struct mount_context *mc = file->private_data;
> +	const char *msg;
> +	size_t mlen;
> +
> +	msg = mc->error;
> +	if (!msg)
> +		return -ENODATA;
> +
> +	mlen = strlen(msg);
> +	if (mlen + 2 > len)
> +		return -ETOOSMALL;
> +	if (copy_to_user(_buf, "e ", 2) != 0 ||
> +	    copy_to_user(_buf + 2, msg, mlen) != 0)
> +		return -EFAULT;
> +	return mlen + 2;
> +}
> +
> +/*
> + * Userspace writes configuration data to the fd and we parse it here.  For the
> + * moment, we assume a single option per write.  Each line written is of the form
> + *
> + *	<option_type><space><stuff...>
> + *
> + *	d /dev/sda1				-- Device name
> + *	o noatime				-- Option without value
> + *	o cell=grand.central.org		-- Option with value
> + *	r /					-- Dir within device to mount
> + */
> +static ssize_t fs_fs_write(struct file *file,
> +			   const char __user *_buf, size_t len, loff_t *pos)
> +{
> +	struct mount_context *mc = file->private_data;
> +	struct inode *inode = file_inode(file);
> +	char opt[2], *data;
> +	ssize_t ret;
> +
> +	if (len < 3 || len > 4095)
> +		return -EINVAL;
> +
> +	if (copy_from_user(opt, _buf, 2) != 0)
> +		return -EFAULT;
> +	switch (opt[0]) {
> +	case 'd':
> +	case 'o':
> +	case 'r':
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +	if (opt[1] != ' ')
> +		return -EINVAL;
> +
> +	data = kmalloc(len - 2 + 1, GFP_KERNEL);
> +	if (!data)
> +		return -ENOMEM;
> +
> +	ret = -EFAULT;
> +	if (copy_from_user(data, _buf + 2, len - 2) != 0)
> +		goto err_free;
> +	data[len - 2] = 0;
> +
> +	/* From this point onwards we need to lock the fd against someone
> +	 * trying to mount it.
> +	 */
> +	ret = inode_lock_killable(inode);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = -EBUSY;
> +	if (mc->mounted)
> +		goto err_unlock;
> +
> +	ret = -EINVAL;
> +	switch (opt[0]) {
> +	case 'd':
> +		if (mc->device)
> +			goto err_unlock;
> +		mc->device = data;
> +		data = NULL;
> +		break;
> +
> +	case 'o':
> +		ret = vfs_mount_option(mc, data);
> +		if (ret < 0)
> +			goto err_unlock;
> +		break;
> +
> +	case 'r':
> +		if (mc->root_path)
> +			goto err_unlock;
> +		mc->root_path = data;
> +		data = NULL;
> +		break;
> +
> +	default:
> +		goto err_unlock;
> +	}
> +
> +	ret = len;
> +err_unlock:
> +	inode_unlock(inode);
> +err_free:
> +	kfree(data);
> +	return ret;
> +}
> +
> +const struct file_operations fs_fs_fops = {
> +	.read		= fs_fs_read,
> +	.write		= fs_fs_write,
> +	.release	= fs_fs_release,
> +	.llseek		= no_llseek,
> +};
> +
> +/*
> + * Indicate the name we want to display the filesystem file as.
> + */
> +static char *fs_fs_dname(struct dentry *dentry, char *buffer, int buflen)
> +{
> +	return dynamic_dname(dentry, buffer, buflen, "fs:[%lu]",
> +			     d_inode(dentry)->i_ino);
> +}
> +
> +static const struct dentry_operations fs_fs_dentry_operations = {
> +	.d_dname	= fs_fs_dname,
> +};
> +
> +/*
> + * Create a file that can be used to configure a new mount.
> + */
> +static struct file *create_fs_file(struct mount_context *mc)
> +{
> +	struct inode *inode;
> +	struct file *f;
> +	struct path path;
> +	int ret;
> +
> +	inode = alloc_anon_inode(fs_fs_mnt->mnt_sb);
> +	if (!inode)
> +		return ERR_PTR(-ENFILE);
> +	inode->i_fop = &fs_fs_fops;
> +
> +	ret = -ENOMEM;
> +	path.dentry = d_alloc_pseudo(fs_fs_mnt->mnt_sb, &empty_name);
> +	if (!path.dentry)
> +		goto err_inode;
> +	path.mnt = mntget(fs_fs_mnt);
> +
> +	d_instantiate(path.dentry, inode);
> +
> +	f = alloc_file(&path, FMODE_READ | FMODE_WRITE, &fs_fs_fops);
> +	if (IS_ERR(f)) {
> +		ret = PTR_ERR(f);
> +		goto err_file;
> +	}
> +
> +	f->private_data = mc;
> +	return f;
> +
> +err_file:
> +	path_put(&path);
> +	return ERR_PTR(ret);
> +
> +err_inode:
> +	iput(inode);
> +	return ERR_PTR(ret);
> +}
> +
> +static const struct super_operations fs_fs_ops = {
> +	.drop_inode	= generic_delete_inode,
> +	.destroy_inode	= free_inode_nonrcu,
> +	.statfs		= simple_statfs,
> +};
> +
> +static struct dentry *fs_fs_mount(struct file_system_type *fs_type,
> +				  int flags, const char *dev_name,
> +				  void *data)
> +{
> +	return mount_pseudo(fs_type, "fs_fs:", &fs_fs_ops,
> +			    &fs_fs_dentry_operations, FS_FS_MAGIC);
> +}
> +
> +static struct file_system_type fs_fs_type = {
> +	.name		= "fs_fs",
> +	.mount		= fs_fs_mount,
> +	.kill_sb	= kill_anon_super,
> +};
> +
> +static int __init init_fs_fs(void)
> +{
> +	int ret;
> +
> +	ret = register_filesystem(&fs_fs_type);
> +	if (ret < 0)
> +		panic("Cannot register fs_fs\n");
> +
> +	fs_fs_mnt = kern_mount(&fs_fs_type);
> +	if (IS_ERR(fs_fs_mnt))
> +		panic("Cannot mount fs_fs: %ld\n", PTR_ERR(fs_fs_mnt));
> +	return 0;
> +}
> +
> +fs_initcall(init_fs_fs);
> +
> +/*
> + * Open a filesystem by name so that it can be configured for mounting.
> + *
> + * We are allowed to specify a container in which the filesystem will be
> + * opened, thereby indicating which namespaces will be used (notably, which
> + * network namespace will be used for network filesystems).
> + */
> +SYSCALL_DEFINE3(fsopen, const char __user *, _fs_name, int, reserved,
> +		unsigned int, flags)
> +{
> +	struct mount_context *mc;
> +	struct file *file;
> +	const char *fs_name;
> +	int fd, ret;
> +
> +	if (flags & ~O_CLOEXEC || reserved != -1)
> +		return -EINVAL;
> +
> +	fs_name = strndup_user(_fs_name, PAGE_SIZE);
> +	if (IS_ERR(fs_name))
> +		return PTR_ERR(fs_name);
> +
> +	mc = vfs_fsopen(fs_name);
> +	if (IS_ERR(mc)) {
> +		ret = PTR_ERR(mc);
> +		goto err_fs_name;
> +	}
> +
> +	ret = -ENOTSUPP;
> +	if (!mc->ops)
> +		goto err_mc;
> +
> +	file = create_fs_file(mc);
> +	if (IS_ERR(file)) {
> +		ret = PTR_ERR(file);
> +		goto err_mc;
> +	}
> +
> +	ret = get_unused_fd_flags(flags & O_CLOEXEC);
> +	if (ret < 0)
> +		goto err_file;
> +
> +	fd = ret;
> +	fd_install(fd, file);
> +	return fd;
> +
> +err_file:
> +	fput(file);
> +	return ret;
> +
> +err_mc:
> +	put_mount_context(mc);
> +err_fs_name:
> +	kfree(fs_name);
> +	return ret;
> +}
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index 980c3c9b06f8..91ec8802ad5d 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -905,5 +905,6 @@ asmlinkage long sys_pkey_alloc(unsigned long flags, unsigned long init_val);
>  asmlinkage long sys_pkey_free(int pkey);
>  asmlinkage long sys_statx(int dfd, const char __user *path, unsigned flags,
>  			  unsigned mask, struct statx __user *buffer);
> +asmlinkage long sys_fsopen(const char *fs_name, int containerfd, unsigned int flags);
>  
>  #endif
> diff --git a/include/uapi/linux/magic.h b/include/uapi/linux/magic.h
> index e230af2e6855..88ae83492f7c 100644
> --- a/include/uapi/linux/magic.h
> +++ b/include/uapi/linux/magic.h
> @@ -84,5 +84,6 @@
>  #define UDF_SUPER_MAGIC		0x15013346
>  #define BALLOON_KVM_MAGIC	0x13661366
>  #define ZSMALLOC_MAGIC		0x58295829
> +#define FS_FS_MAGIC		0x66736673
>  
>  #endif /* __LINUX_MAGIC_H__ */
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index 8acef8576ce9..de1dc63e7e47 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -258,3 +258,6 @@ cond_syscall(sys_membarrier);
>  cond_syscall(sys_pkey_mprotect);
>  cond_syscall(sys_pkey_alloc);
>  cond_syscall(sys_pkey_free);
> +
> +/* fd-based mount */
> +cond_syscall(sys_fsopen);
> 

-- 
Jeff Layton <jlayton@poochiereds.net>
