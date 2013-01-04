Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44475 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753796Ab3ADSaA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2013 13:30:00 -0500
Date: Fri, 4 Jan 2013 13:29:58 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>,
        Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] NFS: Ensure that we free the rpc_task after read and
 write cleanups are done
Message-ID: <20130104182958.GA13471@fieldses.org>
References: <0EC8763B847DB24D9ADF5EBD9CD7B419125A16A9@SACEXCMBX02-PRD.hq.netapp.com>
 <1357323302-12944-1-git-send-email-Trond.Myklebust@netapp.com>
 <1357323302-12944-2-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1357323302-12944-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 04, 2013 at 01:15:01PM -0500, Trond Myklebust wrote:
> This patch ensures that we free the rpc_task after the cleanup callbacks
> are done in order to avoid a deadlock problem that can be triggered if
> the callback needs to wait for another workqueue item to complete.

Makes sense to me!

(Dumb question: so read and write data are the only two cases where the
calldata embeds an rpc task?  Why is that?)

--b.

> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Weston Andros Adamson <dros@netapp.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Bruce Fields <bfields@fieldses.org>
> Cc: stable@vger.kernel.org [>= 3.5]
> ---
>  fs/nfs/read.c  | 10 +++++++---
>  fs/nfs/write.c | 10 +++++++---
>  2 files changed, 14 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/read.c b/fs/nfs/read.c
> index b6bdb18..a5e5d98 100644
> --- a/fs/nfs/read.c
> +++ b/fs/nfs/read.c
> @@ -91,12 +91,16 @@ void nfs_readdata_release(struct nfs_read_data *rdata)
>  	put_nfs_open_context(rdata->args.context);
>  	if (rdata->pages.pagevec != rdata->pages.page_array)
>  		kfree(rdata->pages.pagevec);
> -	if (rdata != &read_header->rpc_data)
> -		kfree(rdata);
> -	else
> +	if (rdata == &read_header->rpc_data) {
>  		rdata->header = NULL;
> +		rdata = NULL;
> +	}
>  	if (atomic_dec_and_test(&hdr->refcnt))
>  		hdr->completion_ops->completion(hdr);
> +	/* Note: we only free the rpc_task after callbacks are done.
> +	 * See the comment in rpc_free_task() for why
> +	 */
> +	kfree(rdata);
>  }
>  EXPORT_SYMBOL_GPL(nfs_readdata_release);
>  
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index b673be3..c483cc5 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -126,12 +126,16 @@ void nfs_writedata_release(struct nfs_write_data *wdata)
>  	put_nfs_open_context(wdata->args.context);
>  	if (wdata->pages.pagevec != wdata->pages.page_array)
>  		kfree(wdata->pages.pagevec);
> -	if (wdata != &write_header->rpc_data)
> -		kfree(wdata);
> -	else
> +	if (wdata == &write_header->rpc_data) {
>  		wdata->header = NULL;
> +		wdata = NULL;
> +	}
>  	if (atomic_dec_and_test(&hdr->refcnt))
>  		hdr->completion_ops->completion(hdr);
> +	/* Note: we only free the rpc_task after callbacks are done.
> +	 * See the comment in rpc_free_task() for why
> +	 */
> +	kfree(wdata);
>  }
>  EXPORT_SYMBOL_GPL(nfs_writedata_release);
>  
> -- 
> 1.7.11.7
> 
