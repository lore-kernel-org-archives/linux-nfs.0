Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38336 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751980AbcKHVjN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Nov 2016 16:39:13 -0500
Date: Tue, 8 Nov 2016 16:39:11 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, Tejun Heo <tj@kernel.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] fs/nfsd/nfs4callback: Remove deprecated
 create_singlethread_workqueue
Message-ID: <20161108213911.GA27681@fieldses.org>
References: <20160830205348.GA31915@Karyakshetra>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160830205348.GA31915@Karyakshetra>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apologies, just cleaning out old mail and finding some I should have
responded to long ago:

On Wed, Aug 31, 2016 at 02:23:48AM +0530, Bhaktipriya Shridhar wrote:
> The workqueue "callback_wq" queues a single work item &cb->cb_work per
> nfsd4_callback instance and thus, it doesn't require execution ordering.

What's "execution ordering"?

We definitely do depend on the fact that at most one of these is running
at a time.

--b.

> Hence, alloc_workqueue has been used to replace the
> deprecated create_singlethread_workqueue instance.

> 
> The WQ_MEM_RECLAIM flag has not been set since this is an in-kernel nfs
> server and isn't involved in memory reclaim operations on the local
> host.
> 
> Since there are fixed number of work items, explicit concurrency
> limit is unnecessary here.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
> ---
>  Changes in v2:
> 	- No change. Made this a separate patch (categorised based on
> 	  directories).
> 
>  fs/nfsd/nfs4callback.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 7389cb1..a6611c6 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -1021,7 +1021,7 @@ static const struct rpc_call_ops nfsd4_cb_ops = {
> 
>  int nfsd4_create_callback_queue(void)
>  {
> -	callback_wq = create_singlethread_workqueue("nfsd4_callbacks");
> +	callback_wq = alloc_workqueue("nfsd4_callbacks", 0, 0);
>  	if (!callback_wq)
>  		return -ENOMEM;
>  	return 0;
> --
> 2.1.4
