Return-Path: <jeff.layton@primarydata.com>
Date: Mon, 28 Dec 2015 14:35:37 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker
 <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 01/10] NFS4: remove a redundant lock range check
Message-ID: <20151228143537.62b16eae@tlielax.poochiereds.net>
In-Reply-To: <09543a9efd73eb12bf7c8421b5fe5377f139e3db.1451319354.git.bcodding@redhat.com>
References: <cover.1451319354.git.bcodding@redhat.com>
	<09543a9efd73eb12bf7c8421b5fe5377f139e3db.1451319354.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 28 Dec 2015 11:27:57 -0500
Benjamin Coddington <bcodding@redhat.com> wrote:

> flock64_to_posix_lock() is already doing this check
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/nfs4proc.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8981803..2231d7d 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6108,9 +6108,6 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
>  	ctx = nfs_file_open_context(filp);
>  	state = ctx->state;
>  
> -	if (request->fl_start < 0 || request->fl_end < 0)
> -		return -EINVAL;
> -
>  	if (IS_GETLK(cmd)) {
>  		if (state != NULL)
>  			return nfs4_proc_getlk(state, F_GETLK, request);

Reviewed-by: Jeff Layton <jeff.layton@primarydata.com>
