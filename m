From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: nfsd stuckage
Date: Tue, 6 Jan 2009 16:23:28 -0800
Message-ID: <20090106162328.1b4511a6.akpm@linux-foundation.org>
References: <20090106145612.d4d9948d.akpm@linux-foundation.org>
	<20090106230244.GB13785@fieldses.org>
	<20090106230356.GA31520@lst.de>
	<20090106230551.GC13785@fieldses.org>
	<20090107001501.GH13785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: hch@lst.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, neilb@suse.de, snakebyte@gmx.de
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49927 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752350AbZAGAYT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 19:24:19 -0500
In-Reply-To: <20090107001501.GH13785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 6 Jan 2009 19:15:01 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

>     nfsd: fix double-locks of directory mutex

grumble.

>  
> +/*
> + * Sync a file
> + * As this calls fsync (not fdatasync) there is no need for a write_inode
> + * after it.
> + */
> +static inline int nfsd_dosync(struct file *filp, struct dentry *dp,
> +			      const struct file_operations *fop)
> +{
> +	struct inode *inode = dp->d_inode;
> +	int (*fsync) (struct file *, struct dentry *, int);
> +	int err;
> +
> +	err = filemap_fdatawrite(inode->i_mapping);
> +	if (err == 0 && fop && (fsync = fop->fsync))
> +		err = fsync(filp, dp, 0);
> +	if (err == 0)
> +		err = filemap_fdatawait(inode->i_mapping);
> +
> +	return err;
> +}

This function is HUGE!  And hardly a fastpath.

>  static int
>  nfsd_sync(struct file *filp)
>  {
> -	return vfs_fsync(filp, filp->f_path.dentry, 0);
> +        int err;
> +	struct inode *inode = filp->f_path.dentry->d_inode;
> +	dprintk("nfsd: sync file %s\n", filp->f_path.dentry->d_name.name);
> +	mutex_lock(&inode->i_mutex);
> +	err=nfsd_dosync(filp, filp->f_path.dentry, filp->f_op);

(checkpatch?)

> +	mutex_unlock(&inode->i_mutex);
> +
> +	return err;
>  }
>  
>  int
> -nfsd_sync_dir(struct dentry *dentry)
> +nfsd_sync_dir(struct dentry *dp)
>  {
> -	return vfs_fsync(NULL, dentry, 0);
> +	return nfsd_dosync(NULL, dp, dp->d_inode->i_fop);
>  }

And we expand it twice.  
