Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37196 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726663AbeJSXWz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Oct 2018 19:22:55 -0400
Date: Fri, 19 Oct 2018 11:16:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, jlayton@kernel.org
Subject: Re: [PATCH] nfsd: correctly decrement odstate refcount in error path
Message-ID: <20181019151623.GC5613@fieldses.org>
References: <20181005133208.72315-1-aweits@rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20181005133208.72315-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks!  I guess I'll queue it up for 4.20 but also add a stable cc.

The one thing I'm not sure about is why we're freeing some things by
hand here and some in nfs4_free_deleg.  Maybe we could be more
consistent, if only I was sure what the right rule was.

Anyway, looks obviously correct.

--b.

On Fri, Oct 05, 2018 at 09:32:08AM -0400, Andrew Elble wrote:
> alloc_init_deleg() both allocates an nfs4_delegation, and
> bumps the refcount on odstate. So after this point, we need to
> put_clnt_odstate() and nfs4_put_stid() to not leave the odstate
> refcount inappropriately bumped.
> 
> Signed-off-by: Andrew Elble <aweits@rit.edu>
> ---
>  fs/nfsd/nfs4state.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 7484f04e09a2..9067bff1233d 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4365,7 +4365,7 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp,
>  
>  	fl = nfs4_alloc_init_lease(dp, NFS4_OPEN_DELEGATE_READ);
>  	if (!fl)
> -		goto out_stid;
> +		goto out_clnt_odstate;
>  
>  	status = vfs_setlease(fp->fi_deleg_file, fl->fl_type, &fl, NULL);
>  	if (fl)
> @@ -4400,7 +4400,6 @@ static struct file_lock *nfs4_alloc_init_lease(struct nfs4_delegation *dp,
>  	vfs_setlease(fp->fi_deleg_file, F_UNLCK, NULL, (void **)&dp);
>  out_clnt_odstate:
>  	put_clnt_odstate(dp->dl_clnt_odstate);
> -out_stid:
>  	nfs4_put_stid(&dp->dl_stid);
>  out_delegees:
>  	put_deleg_file(fp);
> -- 
> 1.8.3.1
