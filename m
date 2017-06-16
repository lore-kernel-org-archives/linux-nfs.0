Return-Path: <jlayton@redhat.com>
Message-ID: <1497624882.29103.3.camel@redhat.com>
Subject: Re: [PATCH v3 2/2] NFS: nfs_rename() - revalidate directories on
 -ERESTARTSYS
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>, Trond Myklebust
 <trond.myklebust@primarydata.com>, Anna Schumaker
 <anna.schumaker@netapp.com>
Cc: mszeredi@redhat.com, bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Fri, 16 Jun 2017 10:54:42 -0400
In-Reply-To: <4ce88bdb84d0c2b5cf1db551ff9a90cc23f294ae.1497620860.git.bcodding@redhat.com>
References: <cover.1497620860.git.bcodding@redhat.com>
	 <4ce88bdb84d0c2b5cf1db551ff9a90cc23f294ae.1497620860.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-06-16 at 09:50 -0400, Benjamin Coddington wrote:
> An interrupted rename will leave the old dentry behind if the rename
> succeeds.  Fix this by forcing a lookup the next time through
> ->d_revalidate.
> 
> A previous attempt at solving this problem took the approach to complete
> the work of the rename asynchronously, however that approach was wrong
> since it would allow the d_move() to occur after the directory's i_mutex
> had been dropped by the original process.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/dir.c            |  6 +++++-
>  fs/nfs/unlink.c         | 11 +++++++++++
>  include/linux/nfs_xdr.h |  1 +
>  3 files changed, 17 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 2ac00bf4ecf1..7108d272bc87 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -2035,7 +2035,11 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
>  	}
>  
>  	error = rpc_wait_for_completion_task(task);
> -	if (error == 0)
> +	if (error != 0) {
> +		((struct nfs_renamedata *)task->tk_calldata)->cancelled = 1;
> +		/* Paired with the atomic_dec_and_test() barrier in rpc_do_put_task() */
> +		smp_wmb();
> +	} else
>  		error = task->tk_status;
>  	rpc_put_task(task);
>  	nfs_mark_for_revalidate(old_inode);
> diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
> index 191aa577dd1f..28628dde38b9 100644
> --- a/fs/nfs/unlink.c
> +++ b/fs/nfs/unlink.c
> @@ -288,6 +288,17 @@ static void nfs_async_rename_release(void *calldata)
>  	if (d_really_is_positive(data->old_dentry))
>  		nfs_mark_for_revalidate(d_inode(data->old_dentry));
>  
> +	/* The result of the rename is unknown. Play it safe by
> +	 * forcing a new lookup */
> +	if (data->cancelled) {
> +		spin_lock(&data->old_dir->i_lock);
> +		nfs_force_lookup_revalidate(data->old_dir);
> +		spin_unlock(&data->old_dir->i_lock);
> +		spin_lock(&data->new_dir->i_lock);
> +		nfs_force_lookup_revalidate(data->new_dir);
> +		spin_unlock(&data->new_dir->i_lock);
> +	}
> +

One more minor nit:

It's quite possible that old_dir == new_dir. If that's the case you'll
be doing the same operation twice here. Maybe add a check for that and
only mess with new_dir here if old_dir != new_dir?


>  	dput(data->old_dentry);
>  	dput(data->new_dentry);
>  	iput(data->old_dir);
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index b28c83475ee8..1aca3d7c1810 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -1533,6 +1533,7 @@ struct nfs_renamedata {
>  	struct nfs_fattr	new_fattr;
>  	void (*complete)(struct rpc_task *, struct nfs_renamedata *);
>  	long timeout;
> +	bool cancelled;
>  };
>  
>  struct nfs_access_entry;

This looks good to me though. You can add this to both patches.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
