Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44986 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755625AbbJIVZB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2015 17:25:01 -0400
Date: Fri, 9 Oct 2015 17:24:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: use a multithreaded workqueue for nfsd4_callbacks
Message-ID: <20151009212459.GF8188@fieldses.org>
References: <1443875882-12089-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443875882-12089-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 03, 2015 at 08:38:02AM -0400, Jeff Layton wrote:
> I don't see any need to order callbacks with respect to one another.

I thought the code in nfsd4_process_cb_update really depended on this.
The locking it has is against nfsd threads, it probably assumes it's
only run from a cb thread and that it's the only one running at a time.

But I haven't reviewed it lately.

--b.

> Also, these are generally not involved in memory reclaim, so I don't see
> the need for a rescuer thread here either.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfsd/nfs4callback.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index e7f50c4081d6..7dabbb436290 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -1017,7 +1017,7 @@ static const struct rpc_call_ops nfsd4_cb_ops = {
>  
>  int nfsd4_create_callback_queue(void)
>  {
> -	callback_wq = create_singlethread_workqueue("nfsd4_callbacks");
> +	callback_wq = alloc_workqueue("%s", WQ_UNBOUND, 0, "nfsd4_callbacks");
>  	if (!callback_wq)
>  		return -ENOMEM;
>  	return 0;
> -- 
> 2.4.3
