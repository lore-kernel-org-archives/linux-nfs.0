Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:55427 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbaAQSTH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2014 13:19:07 -0500
Date: Fri, 17 Jan 2014 18:18:47 +0000
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        wine-devel@winehq.org
Subject: Re: [PATCH v7 1/7] VFS: Introduce new O_DENY* open flags
Message-ID: <20140117181847.6c1f3831@alan.etchedpixels.co.uk>
In-Reply-To: <1389953232-9428-2-git-send-email-piastry@etersoft.ru>
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
	<1389953232-9428-2-git-send-email-piastry@etersoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +#define ESHAREDENIED	258	/* File is locked with a sharelock */

Have you prepared C library patches to match this ?

(and why not just use EPERM, it has the meaning you want already)


> + * Check to see if there's a share_reservation conflict. LOCK_READ/LOCK_WRITE
> + * tell us whether the reservation allows other readers and writers.
> + */
> +static int
> +locks_mand_conflict(struct file_lock *caller_fl, struct file_lock *sys_fl)
> +{

Shouldn't this also check for CAP_SYS_DAC or some similar permission so
that root can override such a mess (eg to fix full disks in an
emergency) ?


> +
> +	/*
> +	 * For sharelock mounts if a file was created but not opened, we need
> +	 * to keep parent i_mutex until we finish the open to prevent races when
> +	 * somebody opens newly created by us file and locks it with a sharelock
> +	 * before we open it.
> +	 */
> +	if (IS_SHARELOCK(dir->d_inode) && error > 0 && *opened & FILE_CREATED) {
> +		/* Don't check for write permission, don't truncate */
> +		open_flag &= ~O_TRUNC;
> +		will_truncate = false;
> +		acc_mode = MAY_OPEN;
> +		path_to_nameidata(path, nd);
> +
> +		error = may_open(&nd->path, acc_mode, open_flag);
> +		if (error) {
> +			mutex_unlock(&dir->d_inode->i_mutex);
> +			goto out;
> +		}
> +		file->f_path.mnt = nd->path.mnt;
> +		error = finish_open(file, nd->path.dentry, NULL, opened);
> +		if (error) {
> +			mutex_unlock(&dir->d_inode->i_mutex);
> +			if (error == -EOPENSTALE)
> +				goto stale_open;
> +			goto out;
> +		}
> +		error = sharelock_lock_file(file);
> +		mutex_unlock(&dir->d_inode->i_mutex);
> +		if (error)
> +			goto exit_fput;
> +		goto opened;
> +	}
> +
>  	mutex_unlock(&dir->d_inode->i_mutex);

What stops the file system changing mount flags via a remount between
these two ?

>  
>  	if (error <= 0) {
> @@ -3034,6 +3073,18 @@ finish_open_created:
>  			goto stale_open;
>  		goto out;
>  	}
> +
> +	if (IS_SHARELOCK(dir->d_inode)) {
> +		/*
> +		 * Lock parent i_mutex to prevent races with sharelocks on
> +		 * newly created files.
> +		 */
> +		mutex_lock(&dir->d_inode->i_mutex);
> +		error = sharelock_lock_file(file);
> +		mutex_unlock(&dir->d_inode->i_mutex);
> +		if (error)
> +			goto exit_fput;
> +	}
>  opened:
