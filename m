Return-Path: <jlayton@redhat.com>
Message-ID: <1491054476.18117.1.camel@redhat.com>
Subject: Re: [PATCH 1/6] NFS4: remove a redundant lock range check
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>, Trond Myklebust
 <trond.myklebust@primarydata.com>, Anna Schumaker
 <anna.schumaker@netapp.com>,  bfields@fieldses.org, Miklos Szeredi
 <miklos@szeredi.hu>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Date: Sat, 01 Apr 2017 09:47:56 -0400
In-Reply-To: <65bfbbf71119f151f320d47f2e5fe423eb640e78.1491015671.git.bcodding@redhat.com>
References: <cover.1491015671.git.bcodding@redhat.com>
	 <65bfbbf71119f151f320d47f2e5fe423eb640e78.1491015671.git.bcodding@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-03-31 at 23:15 -0400, Benjamin Coddington wrote:
> flock64_to_posix_lock() is already doing this check
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/nfs4proc.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 0a0eaecf9676..9388899e4050 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6570,9 +6570,6 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
>  	ctx = nfs_file_open_context(filp);
>  	state = ctx->state;
>  
> -	if (request->fl_start < 0 || request->fl_end < 0)
> -		return -EINVAL;
> -
>  	if (IS_GETLK(cmd)) {
>  		if (state != NULL)
>  			return nfs4_proc_getlk(state, F_GETLK, request);


Reviewed-by: Jeff Layton <jlayton@redhat.com>
