From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/2] nfs: nfs_retry_request
Date: Wed, 19 Mar 2008 10:48:07 -0400
Message-ID: <1205938087.8388.48.camel@heimdal.trondhjem.org>
References: <1205936000-9336-1-git-send-email-iisaman@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:46066 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756181AbYCSTgk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 15:36:40 -0400
In-Reply-To: <1205936000-9336-1-git-send-email-iisaman@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-03-19 at 10:13 -0400, Fred Isaman wrote:
> From: Fred <iisaman@citi.umich.edu>
> 
> Both flush functions have the same error handling routine.  Pull
> it out as a function.
> 
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> ---
>  fs/nfs/write.c |   19 +++++++++++++------
>  1 files changed, 13 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 80c61fd..01bf68e 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -845,6 +845,17 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
>  		rpc_put_task(task);
>  }
>  
> +/* If a nfs_flush_* function fails, it should remove reqs from @head and
> + * call this on each, which will prepare them to be retried on next
> + * writeback using standard nfs.
> + */
> +static void nfs_retry_request(struct nfs_page *req)
> +{
> +	nfs_redirty_request(req);
> +	nfs_end_page_writeback(req->wb_page);
> +	nfs_clear_page_tag_locked(req);
> +}
> +
>  /*
>   * Generate multiple small requests to write out a single
>   * contiguous dirty area on one page.
> @@ -899,9 +910,7 @@ out_bad:
>  		list_del(&data->pages);
>  		nfs_writedata_release(data);
>  	}
> -	nfs_redirty_request(req);
> -	nfs_end_page_writeback(req->wb_page);
> -	nfs_clear_page_tag_locked(req);
> +	nfs_retry_request(req);
>  	return -ENOMEM;
>  }
>  
> @@ -941,9 +950,7 @@ static int nfs_flush_one(struct inode *inode, struct list_head *head, unsigned i
>  	while (!list_empty(head)) {
>  		req = nfs_list_entry(head->next);
>  		nfs_list_remove_request(req);
> -		nfs_redirty_request(req);
> -		nfs_end_page_writeback(req->wb_page);
> -		nfs_clear_page_tag_locked(req);
> +		nfs_retry_request(req);
>  	}
>  	return -ENOMEM;
>  }

My one nit is with the name of your function: it isn't really retrying
the flush, but rather requeuing it on the dirty list after an attempt to
flush failed.

How about renaming the current 'nfs_redirty_request()' as
'nfs_mark_request_dirty()', and then using the name
nfs_redirty_request() for your new helper?

Cheers
  Trond

