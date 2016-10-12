Return-Path: <jlayton@redhat.com>
Message-ID: <1476271705.2541.8.camel@redhat.com>
Subject: Re: [PATCH 1/5] NFS: remove l_pid field from nfs_lockowner
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>,
        Trond Myklebust
 <trond.myklebust@primarydata.com>,
        Anna Schumaker
 <anna.schumaker@netapp.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List
	 <linux-nfs@vger.kernel.org>
Date: Wed, 12 Oct 2016 07:28:25 -0400
In-Reply-To: <147623995844.19592.4907099762700740448.stgit@noble>
References: <147623977637.19592.12766016823334433969.stgit@noble>
	 <147623995844.19592.4907099762700740448.stgit@noble>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-10-12 at 13:39 +1100, NeilBrown wrote:
> this field is not used in any important way and probably should
> have been removed by
> 
> Commit: 8003d3c4aaa5 ("nfs4: treat lock owners as opaque values")
> 
> which removed the pid argument from nfs4_get_lock_state.
> 
> Except in unusual and uninteresting cases, two threads with the same
> ->tgid will have the same ->files pointer, so keeping them both
> for comparison brings no benefit.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfs/inode.c         |    3 ---
>  fs/nfs/nfs4proc.c      |    1 -
>  fs/nfs/pagelist.c      |    3 +--
>  fs/nfs/write.c         |    3 +--
>  include/linux/nfs_fs.h |    1 -
>  5 files changed, 2 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index bf4ec5ecc97e..1752fc7c0024 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -703,7 +703,6 @@ static void nfs_init_lock_context(struct nfs_lock_context *l_ctx)
>  {
>  	atomic_set(&l_ctx->count, 1);
>  	l_ctx->lockowner.l_owner = current->files;
> -	l_ctx->lockowner.l_pid = current->tgid;
>  	INIT_LIST_HEAD(&l_ctx->list);
>  	atomic_set(&l_ctx->io_count, 0);
>  }
> @@ -716,8 +715,6 @@ static struct nfs_lock_context *__nfs_find_lock_context(struct nfs_open_context
>  	do {
>  		if (pos->lockowner.l_owner != current->files)
>  			continue;
> -		if (pos->lockowner.l_pid != current->tgid)
> -			continue;
>  		atomic_inc(&pos->count);
>  		return pos;
>  	} while ((pos = list_entry(pos->list.next, typeof(*pos), list)) != head);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 0e327528a3ce..b7df3ef84fc3 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2766,7 +2766,6 @@ static int _nfs4_do_setattr(struct inode *inode,
>  	} else if (truncate && state != NULL) {
>  		struct nfs_lockowner lockowner = {
>  			.l_owner = current->files,
> -			.l_pid = current->tgid,
>  		};
>  		if (!nfs4_valid_open_stateid(state))
>  			return -EBADF;
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 965db474f4b0..161f8b13bbaa 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -867,8 +867,7 @@ static void nfs_pageio_cleanup_mirroring(struct nfs_pageio_descriptor *pgio)
>  static bool nfs_match_lock_context(const struct nfs_lock_context *l1,
>  		const struct nfs_lock_context *l2)
>  {
> -	return l1->lockowner.l_owner == l2->lockowner.l_owner
> -		&& l1->lockowner.l_pid == l2->lockowner.l_pid;
> +	return l1->lockowner.l_owner == l2->lockowner.l_owner;
>  }
>  
>  /**
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 53211838f72a..4d5897e6d6cb 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1151,8 +1151,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
>  		if (l_ctx && flctx &&
>  		    !(list_empty_careful(&flctx->flc_posix) &&
>  		      list_empty_careful(&flctx->flc_flock))) {
> -			do_flush |= l_ctx->lockowner.l_owner != current->files
> -				|| l_ctx->lockowner.l_pid != current->tgid;
> +			do_flush |= l_ctx->lockowner.l_owner != current->files;
>  		}
>  		nfs_release_request(req);
>  		if (!do_flush)
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 810124b33327..bf8a713c45b4 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -57,7 +57,6 @@ struct nfs_access_entry {
>  
>  struct nfs_lockowner {
>  	fl_owner_t l_owner;
> -	pid_t l_pid;
>  };
>  
>  struct nfs_lock_context {
> 
> 

Looks ok. For my own knowledge though, in what situations would you have
the same files pointer but a different tgid?

Acked-by: Jeff Layton <jlayton@redhat.com>
