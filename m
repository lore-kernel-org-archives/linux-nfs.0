Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53235 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423029Ab3CVUxy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Mar 2013 16:53:54 -0400
Date: Fri, 22 Mar 2013 16:53:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kent Overstreet <koverstreet@google.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Al Viro <viro@zeniv.linux.org.uk>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Zach Brown <zab@redhat.com>
Subject: Re: [PATCH] nfsd: fix bad offset use
Message-ID: <20130322205353.GA14438@fieldses.org>
References: <1363976304-26093-1-git-send-email-koverstreet@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1363976304-26093-1-git-send-email-koverstreet@google.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 22, 2013 at 11:18:24AM -0700, Kent Overstreet wrote:
> vfs_writev() updates the offset argument - but the code then passes the
> offset to vfs_fsync_range(). Since offset now points to the offset after
> what was just written, this is probably not what was intended

Whoops--thanks!  Looks like this was introduced by my
face15025ffdf664de95e86ae831544154d26c9c "nfsd: use vfs_fsync_range(),
not O_SYNC, for stable writes", in 3.8.

I'll queue up for 3.9 and stable.

--b.

> 
> Signed-off-by: Kent Overstreet <koverstreet@google.com>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Cc: Zach Brown <zab@redhat.com>
> ---
>  fs/nfsd/vfs.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 2a7eb53..2b2e239 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1013,6 +1013,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>  	int			host_err;
>  	int			stable = *stablep;
>  	int			use_wgather;
> +	loff_t			pos = offset;
>  
>  	dentry = file->f_path.dentry;
>  	inode = dentry->d_inode;
> @@ -1025,7 +1026,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>  
>  	/* Write the data. */
>  	oldfs = get_fs(); set_fs(KERNEL_DS);
> -	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
> +	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &pos);
>  	set_fs(oldfs);
>  	if (host_err < 0)
>  		goto out_nfserr;
> -- 
> 1.8.1.3
> 
