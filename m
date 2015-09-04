Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26695 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933638AbbIDVOz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2015 17:14:55 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH v2 2/2] Revert "NFS: Make close(2) asynchronous when closing NFS O_DIRECT files"
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1441400510-19688-2-git-send-email-trond.myklebust@primarydata.com>
Date: Fri, 4 Sep 2015 17:14:43 -0400
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FEB469CD-AF68-4F60-B8D1-C1BF163D7DAC@oracle.com>
References: <1441400510-19688-1-git-send-email-trond.myklebust@primarydata.com> <1441400510-19688-2-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 4, 2015, at 5:01 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> This reverts commit f895c53f8ace3c3e49ebf9def90e63fc6d46d2bf.
> 
> This commit causes a NFSv4 regression in that close()+unlink() can end
> up failing. The reason is that we no longer have a guarantee that the
> CLOSE has completed on the server, meaning that the subsequent call to
> REMOVE may fail with NFS4ERR_FILE_OPEN if the server implements Windows
> unlink() semantics.
> 
> Reported-by: <Olga Kornievskaia <aglo@umich.edu>
> Cc: Chuck Lever <chuck.lever@oracle.com>

I'm fine with this as long as the current NFSv3 behavior stays
the same. I haven't tested, but I believe 1/2 will guarantee
that NFSv3 close(2) behavior does not change.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
> fs/nfs/inode.c | 7 ++++++-
> 1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 6307d8de103d..326d9e10d833 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -853,6 +853,11 @@ void put_nfs_open_context(struct nfs_open_context *ctx)
> }
> EXPORT_SYMBOL_GPL(put_nfs_open_context);
> 
> +static void put_nfs_open_context_sync(struct nfs_open_context *ctx)
> +{
> +	__put_nfs_open_context(ctx, 1);
> +}
> +
> /*
>  * Ensure that mmap has a recent RPC credential for use when writing out
>  * shared pages
> @@ -908,7 +913,7 @@ void nfs_file_clear_open_context(struct file *filp)
> 		spin_lock(&inode->i_lock);
> 		list_move_tail(&ctx->list, &NFS_I(inode)->open_files);
> 		spin_unlock(&inode->i_lock);
> -		__put_nfs_open_context(ctx, filp->f_flags & O_DIRECT ? 0 : 1);
> +		put_nfs_open_context_sync(ctx);
> 	}
> }
> 
> -- 
> 2.4.3
> 

--
Chuck Lever



