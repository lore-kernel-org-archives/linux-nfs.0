From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 4/14] locks: add locking function that returns conflicting lock
Date: Sat, 3 Feb 2007 08:54:50 +0000
Message-ID: <20070203085450.GD18828@infradead.org>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu> <96a0abaf64b433a7e7450e7e35d0baf2c44103db.1170479265.git.bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <96a0abaf64b433a7e7450e7e35d0baf2c44103db.1170479265.git.bfields@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, Feb 03, 2007 at 12:34:00AM -0500, J. Bruce Fields wrote:
> From: Marc Eshel <eshel@almaden.ibm.com> - unquoted
> 
> The nfsv4 protocol's lock operation, in the case of a conflict, returns
> information about the conflicting lock.
> 
> It's unclear how clients can use this, so for now we're not going so far as to
> add a filesystem method that can return a conflicting lock, but we may as well
> return something in the local case when it's easy to.
> 
> Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
> ---
>  fs/locks.c                 |   18 ++++++++++++++++++
>  include/linux/lockd/bind.h |    1 +
>  2 files changed, 19 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index c88139d..1bd6418 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1706,6 +1706,24 @@ int vfs_lock_file(struct file *filp, unsigned int cmd, struct file_lock *fl)
>  }
>  EXPORT_SYMBOL(vfs_lock_file);
>  
> +/**
> + * vfs_lock_file_conf - file byte range lock
> + * @filp: The file to apply the lock to
> + * @fl: The lock to be applied
> + * @conf: Place to return a copy of the conflicting lock, if found.
> + *
> + * read comments for vfs_lock_file()
> + */
> +int vfs_lock_file_conf(struct file *filp, struct file_lock *fl, struct file_lock *conf)
> +{
> +	if (filp->f_op && filp->f_op->lock) {
> +		__locks_copy_lock(conf, fl);
> +		return filp->f_op->lock(filp, F_SETLK, fl);
> +	} else
> +		return posix_lock_file_conf(filp, fl, conf);
> +}
> +EXPORT_SYMBOL(vfs_lock_file_conf);

Is there any reason we want to have both variants?  I think vfs_lock_file
should simple get the last argument and we shouldn't have a separate
vfs_lock_file_conf (which btw doesn't have an exactly descriptive name).
The also allows you to kill __posix_lock_file_conf and only keep a single
posix_lock_file routines that gets the argument aswell.


And btw, in case you ask why I demand all these addition cleanuos:
you're touching an already more than messy codebase and make it more
complex, that needs some cleanups to counterbalance :)
