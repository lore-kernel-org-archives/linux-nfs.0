Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37439 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750716AbdECUol (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 16:44:41 -0400
Received: by mail-wm0-f48.google.com with SMTP id m123so128955wma.0
        for <linux-nfs@vger.kernel.org>; Wed, 03 May 2017 13:44:40 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Subject: Re: [PATCH 4/9] Implement fsopen() to prepare for a mount
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
        <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
Date: Wed, 03 May 2017 22:44:37 +0200
In-Reply-To: <149382750838.30481.8003919639826341255.stgit@warthog.procyon.org.uk>
        (David Howells's message of "Wed, 03 May 2017 17:05:08 +0100")
Message-ID: <87fugl3c22.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 03 2017, David Howells <dhowells@redhat.com> wrote:

> --- /dev/null
> +++ b/fs/fsopen.c
> @@ -0,0 +1,295 @@
> +/* fsopen.c: description
> + *

leftover from some template?

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
> +
> +	if (copy_to_user(_buf, "e ", 2) != 0 ||
> +	    copy_to_user(_buf + 2, msg, mlen) != 0)
> +		return -EFAULT;
> +	return mlen + 2;
> +}

OK, mc->error must be static data, so no lifetime problems. But is it
possible for the compiler to mess this up and reload msg from mc->error
when it's about to do the user copy, so that if some other thread has
managed to change mc->error (or is the error state sticky and no further
operations allowed?) we'd copy from a string with a different length?

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

This hunk seems to be equivalent to

data = memdup_user_nul(_buf + 2, len - 2);
if (IS_ERR(data))
  return PTR_ERR(data);

plus the err_free: label gets killed...

> 
> +	/* From this point onwards we need to lock the fd against someone
> +	 * trying to mount it.
> +	 */
> +	ret = inode_lock_killable(inode);
> +	if (ret < 0)
> +		return ret;

...except that we need to jump to it here to avoid leaking data.

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

static const struct ?

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

Where does fs_name now get freed? vfs_fsopen doesn't seem to do it on
success? (If it did, the fallthrough from err_mc: to err_fs_name: would
be wrong.)

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
