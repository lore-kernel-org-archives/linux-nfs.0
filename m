Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47070 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751415AbbIVLpB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Sep 2015 07:45:01 -0400
Date: Tue, 22 Sep 2015 13:44:04 +0200
From: David Sterba <dsterba@suse.cz>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
        zab@zabbo.net, viro@zeniv.linux.org.uk, clm@fb.com,
        darrick.wong@oracle.com, mtk.manpages@gmail.com, andros@netapp.com,
        hch@infradead.org
Subject: Re: [PATCH v2 1/9] vfs: add copy_file_range syscall and vfs helper
Message-ID: <20150922114404.GF8891@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1442003423-6884-2-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1442003423-6884-2-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 11, 2015 at 04:30:14PM -0400, Anna Schumaker wrote:
> From: Zach Brown <zab@redhat.com>
> +/*
> + * copy_file_range() differs from regular file read and write in that it
> + * specifically allows return partial success.  When it does so is up to
> + * the copy_file_range method.
> + */
> +ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
> +			    struct file *file_out, loff_t pos_out,
> +			    size_t len, int flags)

Is the signed type for flags correct? I had the impression that it's
usually good to have unsigned int/long for flags, this can be seen
frequently in the vfs/fs code. Mainly for consistency.

> +	ret = file_in->f_op->copy_file_range(file_in, pos_in, file_out, pos_out,
> +					     len, flags);

int -> unsigned int

> +}
> +EXPORT_SYMBOL(vfs_copy_file_range);
> +
> +SYSCALL_DEFINE6(copy_file_range, int, fd_in, loff_t __user *, off_in,
> +		int, fd_out, loff_t __user *, off_out,
> +		size_t, len, unsigned int, flags)

the syscal takes unsigned int

> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1642,6 +1642,7 @@ struct file_operations {
>  #ifndef CONFIG_MMU
>  	unsigned (*mmap_capabilities)(struct file *);
>  #endif
> +	ssize_t (*copy_file_range)(struct file *, loff_t, struct file *, loff_t, size_t, int);

switch to unsigned

> +extern ssize_t vfs_copy_file_range(struct file *, loff_t , struct file *,
> +				   loff_t, size_t, int);

and here
