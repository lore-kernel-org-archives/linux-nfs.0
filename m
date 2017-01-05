Return-Path: <jlayton@redhat.com>
Message-ID: <1483630530.2599.1.camel@redhat.com>
Subject: Re: [PATCH] nfs: Don't take a reference on fl->fl_file for LOCK
 operation
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>,
        Trond Myklebust
 <trond.myklebust@primarydata.com>,
        Anna Schumaker
 <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 05 Jan 2017 10:35:30 -0500
In-Reply-To: <c036782ffa4f4acdf67b980995d698de5c25eb8f.1483629239.git.bcodding@redhat.com>
References: 
	<c036782ffa4f4acdf67b980995d698de5c25eb8f.1483629239.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-01-05 at 10:20 -0500, Benjamin Coddington wrote:
> I have reports of a crash that look like __fput() was called twice for
> a NFSv4.0 file.  It seems possible that the state manager could try to
> reclaim a lock and take a reference on the fl->fl_file at the same time the
> file is being released if, during the close(), a signal interrupts the wait
> for outstanding IO while removing locks which then skips the removal
> of that lock.
> 
> Since 83bfff23e9ed ("nfs4: have do_vfs_lock take an inode pointer") has
> removed the need to traverse fl->fl_file->f_inode in nfs4_lock_done(),
> taking that reference is no longer necessary.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/nfs4proc.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 6dcbc5defb7a..700ed1fc1075 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -38,7 +38,6 @@
>  #include <linux/mm.h>
>  #include <linux/delay.h>
>  #include <linux/errno.h>
> -#include <linux/file.h>
>  #include <linux/string.h>
>  #include <linux/ratelimit.h>
>  #include <linux/printk.h>
> @@ -6127,7 +6126,6 @@ static struct nfs4_lockdata *nfs4_alloc_lockdata(struct file_lock *fl,
>  	p->server = server;
>  	atomic_inc(&lsp->ls_count);
>  	p->ctx = get_nfs_open_context(ctx);
> -	get_file(fl->fl_file);
>  	memcpy(&p->fl, fl, sizeof(p->fl));
>  	return p;
>  out_free_seqid:
> @@ -6240,7 +6238,6 @@ static void nfs4_lock_release(void *calldata)
>  		nfs_free_seqid(data->arg.lock_seqid);
>  	nfs4_put_lock_state(data->lsp);
>  	put_nfs_open_context(data->ctx);
> -	fput(data->fl.fl_file);
>  	kfree(data);
>  	dprintk("%s: done!\n", __func__);
>  }

Nice catch. Patch looks good to me. You can add:

Reviewed-by: Jeff Layton <jlayton@redhat.com>
