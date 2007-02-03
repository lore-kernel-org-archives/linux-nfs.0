From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/14] locks: factor out generic/filesystem switch from setlock code
Date: Sat, 3 Feb 2007 08:51:36 +0000
Message-ID: <20070203085136.GC18828@infradead.org>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu> <1dd47bf9aeb6f19c82a59efb2f4236f23f73019d.1170479265.git.bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1dd47bf9aeb6f19c82a59efb2f4236f23f73019d.1170479265.git.bfields@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Feb 03, 2007 at 12:33:59AM -0500, J. Bruce Fields wrote:
> + */
> +int vfs_lock_file(struct file *filp, unsigned int cmd, struct file_lock *fl)
> +{
> +	if (filp->f_op && filp->f_op->lock)
> +		return filp->f_op->lock(filp, cmd, fl);
> +	else
> +		return posix_lock_file(filp, fl);
> +}
> +EXPORT_SYMBOL(vfs_lock_file);

_GPL please (and same for the last patch)

> +	for (;;) {
> +		error = vfs_lock_file(filp, cmd, file_lock);
> +		if ((error != -EAGAIN) || (cmd == F_SETLK))

No need for the inside braces here.

> +		error = vfs_lock_file(filp, cmd, file_lock);
> +		if ((error != -EAGAIN) || (cmd == F_SETLK64))

again.

