Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794834466;
	b=KGtEDc/TxMDOMw+0AiMLHPMwGl4Zw2NbbYLv5lCTZbbwohsl4jH3xpM4r+HCnXY4M+hG
	 LKLb5DB+AvpU2ihX6nXDJts//PLqtTkR3P+VrePwUbS/PtrYvUMPExi+ZcKQGN2PAFPpU
	 W+59eJaXTjIB0uxeM6tv3+e+9/53yiKRqKiWu2UOKhXE1lD2gF2jx6u/2KlNAtM/njlJF
	 f7Jm7yQRJH8vPlYNvcCtyafnm8F5QLMm8pEPHxz+JozijqR3gjNw8b7YjtDpjaJxjLXzX
	 x8Akm4zdVd7dhGVH7AjBQhO71gRRVVRPK3pLJL3kn+MhO6Uh6uXRv1a4lEZolEVFs5g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794834466;
	h=DMARC-Filter:Received:Received:Received:Received:Date:From:To:Cc:
	 Subject:Message-ID:References:MIME-Version:Content-Type:
	 Content-Disposition:In-Reply-To:X-Rspamd-Pre-Result:X-Rspamd-Queue-Id:
	 X-Rspamd-Pre-Result:X-Rspamd-Action:X-Rspamd-Server:X-Spam-Level:
	 X-Spamd-Result:X-Spam-Flag:X-Spam-Score;
	bh=/79yD/ePkhOWtFp46GUyu6ts/vcC2MmXQ7vdqbMevlI=;
	b=vEHDvFYyvgdnD1Y+jx93AZMPCgvvL6MoPTJMcAC8BZ6SJuDYM55/Z/q7hx/9yBuSggXH
	 OQusekW48FW4iv3GDo9N5euk+XaFSwEyhR8DkQV6dl1OVrJIUw5CNvoKgopDL1KwC54Pd
	 tx1y2vY/q92EQhBHM/nrbgSnGlsu4QRtywI3YpDVNYbd5cP/Bv0LSqWw1Ve2K17Y9S8eY
	 8Obluy/ETsyN3EOWnh5LOPAM8KNivlDWKu5FAeD4cBt/sgTIe6XV0bKFGcxJdNfb0tnEi
	 RQLOAU1ccCnzrvzFtZtOTfhRTcwaRIWjVE0RYfGhCEp+ZfsyTENVBzQw7ccosh89a+w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC42A606A334;
	Mon, 16 Nov 2026 13:07:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DC42A606A334
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 19E8621DC4;
	Mon, 16 Nov 2026 13:07:44 +0000 (UTC)
Authentication-Results: smtp-out1.suse.de;
	none
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id DE2B51334C;
	Mon, 16 Nov 2026 13:07:43 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id BvIgLh8A+2pNEgAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 13:07:43 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id 6CC7424E06; Mon, 16 Nov 2026 14:07:43 +0100 (CET)
Date: Mon, 16 Nov 2026 14:07:43 +0100
From: Jan Kara <jack@suse.cz>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, Jann Horn <jannh@google.com>, 
	Chris Mason <mason@kernel.org>, Josef Bacik <josef@toxicpanda.com>, 
	Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
	driver-core@lists.linux.dev, linux-mm@kvack.org, bpf@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org, apparmor@lists.ubuntu.com, 
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
	linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, ocfs2-devel@lists.linux.dev, 
	linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
	Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org
Subject: Re: [PATCH RFC v3 35/44] fs: add file_check_backing()
Message-ID: <fvmgoq6g3orrcbz5j7xoxrqkz4kc4jiopndjfar4cv45pj2y4g@bfgcucrsffnm>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
 <20261116-work-loop-pseudo-v3-35-8cbbea1cf34f@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261116-work-loop-pseudo-v3-35-8cbbea1cf34f@kernel.org>
X-Rspamd-Pre-Result: action=no action;
	module=replies;
	Message is reply to one we originated
X-Rspamd-Queue-Id: 19E8621DC4
X-Rspamd-Pre-Result: action=no action;
	module=replies;
	Message is reply to one we originated
X-Rspamd-Action: no action
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Spam-Level: 
X-Spamd-Result: default: False [-4.00 / 50.00];
	REPLY(-4.00)[]
X-Spam-Flag: NO
X-Spam-Score: -4.00

On Mon 16-11-26 12:05:08, Christian Brauner wrote:
> Loop, zloop, the nvme target, the scsi target, fuse passthrough, the usb
> mass storage gadget, erofs and acct all take a file from userspace and
> use it as storage. Currently, each of them has its own idea of what to
> check before using a file like that:
> 
> - loop and the gadget check for a regular file or a block device, the
>   nvme target, the scsi target and zloop take any file type
> - loop checks the open mode, the gadget checks FMODE_CAN_READ, the nvme
>   target, the scsi target and zloop only check for ->read_iter() and
>   ->write_iter()
> - apart from acct which refuses procfs and sysfs files none of them
>   cares whether the file is a kernel interface
> 
> Add a helper that does all of it in one place. It only accepts regular
> files and, if the caller passes S_IFBLK, block devices. It refuses files
> on pseudo filesystems. And it checks that the file is open for what the
> caller is going to do with it and implements ->read_iter() for reading
> and ->write_iter() for writing.
> 
> O_PATH files are refused unless the caller passes FMODE_PATH. That is
> for callers that only need the path of the file. fuse passthrough is
> one of them and has accepted O_PATH file descriptors since commit
> efad7153bf93 ("fuse: allow O_PATH fd for FUSE_DEV_IOC_BACKING_OPEN").
> 
> Block devices are fine even though bdevfs is a pseudo filesystem. A
> block device that userspace hands in is a device node on devtmpfs or
> some other filesystem. Files on bdevfs only come from
> bdev_file_open_by_*() and never end up here.
> 
> The pseudo filesystem check looks at the inode that actually provides
> the data via d_real_data_inode(). overlayfs accepts sysfs, cgroup2,
> debugfs, tracefs, configfs and securityfs as lower layers and reads of
> such an overlayfs file are served by the file on the pseudo filesystem.
> Checking the overlayfs inode would miss that.
> 
> For an O_PATH file nothing might have looked up the data yet. overlayfs
> only looks up the data of a metacopy file in a data-only layer when the
> file is opened. d_real_data_inode() does the lookup then and if that
> fails we return the error.
> 
> Note that the file type is taken from the inode of the file and not from
> the host of ->f_mapping like loop and the gadget do it. A driver can
> point ->f_mapping somewhere else in ->open(). It makes no difference for
> block devices as both inodes are block devices.
> 
> No functional changes. Nothing calls the helper yet.
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Looks good to me. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/read_write.c    | 53 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/fs.h |  2 ++
>  2 files changed, 55 insertions(+)
> 
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 6767283108991..9f1e7bfcbd4f1 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -866,6 +866,59 @@ static ssize_t do_loop_readv_writev(struct file *filp, struct iov_iter *iter,
>  	return ret;
>  }
>  
> +/**
> + * file_check_backing - check that the kernel can use a file as storage
> + * @file: file that userspace handed in
> + * @mode: FMODE_READ and/or FMODE_WRITE the kernel will do I/O with, or
> + *        FMODE_PATH if only the path of @file is used
> + * @type: S_IFBLK if a block device is fine as well, 0 otherwise
> + *
> + * Call this where a file from userspace is taken as a backing file. Only
> + * regular files and, if @type is S_IFBLK, block devices are storage. Files
> + * on pseudo filesystems are kernel interfaces and are refused. The file
> + * must be open for @mode and implement ->read_iter() for reading and
> + * ->write_iter() for writing. O_PATH files are only fine with FMODE_PATH.
> + *
> + * Return: 0 on success, -EBADF if @file isn't open for @mode, -EINVAL if it
> + * can't be used as storage, or the error from looking up the data of @file
> + * on a stacking filesystem.
> + */
> +int file_check_backing(const struct file *file, fmode_t mode, umode_t type)
> +{
> +	fmode_t io = mode & (FMODE_READ | FMODE_WRITE);
> +	/* Drivers may point ->f_mapping at something else. */
> +	umode_t fmt = file_inode(file)->i_mode & S_IFMT;
> +	struct inode *real_inode;
> +
> +	/* O_PATH files are only fine for callers that just use the path. */
> +	if ((file->f_mode & FMODE_PATH) && !(mode & FMODE_PATH))
> +		return -EBADF;
> +
> +	if ((file->f_mode & io) != io)
> +		return -EBADF;
> +
> +	if (fmt != S_IFREG && !(type == S_IFBLK && fmt == S_IFBLK))
> +		return -EINVAL;
> +
> +	/* Look through stacking filesystems at the inode with the data. */
> +	real_inode = d_real_data_inode(file->f_path.dentry);
> +	if (IS_ERR(real_inode))
> +		return PTR_ERR(real_inode);
> +	if (real_inode->i_sb->s_iflags & SB_I_PSEUDO)
> +		return -EINVAL;
> +
> +	if ((mode & FMODE_READ) &&
> +	    (!(file->f_mode & FMODE_CAN_READ) || !file->f_op->read_iter))
> +		return -EINVAL;
> +
> +	if ((mode & FMODE_WRITE) &&
> +	    (!(file->f_mode & FMODE_CAN_WRITE) || !file->f_op->write_iter))
> +		return -EINVAL;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(file_check_backing);
> +
>  ssize_t vfs_iocb_iter_read(struct file *file, struct kiocb *iocb,
>  			   struct iov_iter *iter)
>  {
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 99caef43ff3c4..b1c7ebafbadbe 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2553,6 +2553,8 @@ static inline const struct inode *file_user_inode(const struct file *f)
>  	return file_inode(f);
>  }
>  
> +int file_check_backing(const struct file *file, fmode_t mode, umode_t type);
> +
>  static inline struct file *file_clone_open(struct file *file)
>  {
>  	return dentry_open(&file->f_path, file->f_flags, file->f_cred);
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
