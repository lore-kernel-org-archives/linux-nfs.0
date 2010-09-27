Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18080 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933447Ab0I0U3T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 16:29:19 -0400
Date: Mon, 27 Sep 2010 16:28:31 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, pbunyan@redhat.com
Subject: Re: [PATCH] NFS: initialize nfs_open_context.list member at
 allocation time
Message-ID: <20100927162831.23412a2f@tlielax.poochiereds.net>
In-Reply-To: <1285618199.25777.21.camel@heimdal.trondhjem.org>
References: <1285355683-7244-1-git-send-email-jlayton@redhat.com>
	<1285618199.25777.21.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 27 Sep 2010 16:09:59 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2010-09-24 at 15:14 -0400, Jeff Layton wrote:
> > alloc_nfs_open_context creates a nfs_open_context struct, but doesn't
> > initialize the list_head embedded in it. In newer kernels, this is
> > harmless since the ctx is always put on a list soon after creation. In
> > an older RHEL4 kernel however, it's possible (though unlikely) for a ctx
> > to be passed to put_nfs_open_context without ever being put on a list,
> > which can cause an oops.
> > 
> > Since it's hard to predict how this code will change in the future,
> > let's go ahead and initialize the list.
> > 
> > Reported-by: Paul Bunyan <pbunyan@redhat.com>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/inode.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> > index 7d2d6c7..3185fc2 100644
> > --- a/fs/nfs/inode.c
> > +++ b/fs/nfs/inode.c
> > @@ -638,6 +638,7 @@ static struct nfs_open_context *alloc_nfs_open_context(struct path *path, struct
> >  		ctx->dir_cookie = 0;
> >  		nfs_init_lock_context(&ctx->lock_context);
> >  		ctx->lock_context.open_context = ctx;
> > +		INIT_LIST_HEAD(&ctx->list);
> >  	}
> >  	return ctx;
> >  }
> 
> Hi Jeff,
> 
> I'm really too keen to merge stuff into 2.6.37 with the sole
> justification being that it is needed to keep kernel 2.6.9 in sync.
> 
> That said, you appear to be in luck today: I found a reason to apply
> something like the above in 2.6.37 too. Please see the patch below, that
> appears to need to be applied to the nfs-for-2.6.37 branch.
> 
> Cheers
>   Trond
> -------------------------------------------------------------------------------------------
> commit 2128d32b4fbb85bba129ca7b6d4c8e118d4a325b
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Mon Sep 27 15:51:20 2010 -0400
> 
>     NFS: Really fix put_nfs_open_context()
>     
>     In nfs_open_revalidate(), if the open_context() call returns an inode that
>     is not the same as dentry->d_inode, then we will call
>     put_nfs_open_context() with a valid dentry->d_inode, but without the
>     context being part of the nfsi->open_files list.
>     
>     In this case too, we want to just skip the list removal, but we do want to
>     call the ->close_context() callback in order to close the NFSv4 state.
>     
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index cc22ef5..fca63b9 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -635,6 +635,7 @@ struct nfs_open_context *alloc_nfs_open_context(struct path *path, struct rpc_cr
>  		ctx->dir_cookie = 0;
>  		nfs_init_lock_context(&ctx->lock_context);
>  		ctx->lock_context.open_context = ctx;
> +		INIT_LIST_HEAD(&ctx->list);
>  	}
>  	return ctx;
>  }
> @@ -650,14 +651,15 @@ static void __put_nfs_open_context(struct nfs_open_context *ctx, int is_sync)
>  {
>  	struct inode *inode = ctx->path.dentry->d_inode;
>  
> -	if (inode) {
> +	if (!list_empty(&ctx->list)) {
>  		if (!atomic_dec_and_lock(&ctx->lock_context.count, &inode->i_lock))
>  			return;
>  		list_del(&ctx->list);
>  		spin_unlock(&inode->i_lock);
> -		NFS_PROTO(inode)->close_context(ctx, is_sync);
>  	} else if (!atomic_dec_and_test(&ctx->lock_context.count))
>  		return;
> +	if (inode != NULL)
> +		NFS_PROTO(inode)->close_context(ctx, is_sync);
>  	if (ctx->cred != NULL)
>  		put_rpccred(ctx->cred);
>  	path_put(&ctx->path);
> 

Thanks, Trond. For the record, my concern here was more for the
"defensive coding" aspect rather than a desire to keep RHEL4 in sync
with upstream (which is really, really a lost cause).

Patch looks good to me.

Acked-by: Jeff Layton <jlayton@redhat.com>
