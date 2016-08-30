Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35721 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751998AbcH3VHa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2016 17:07:30 -0400
Received: by mail-qt0-f194.google.com with SMTP id q11so1071246qtb.2
        for <linux-nfs@vger.kernel.org>; Tue, 30 Aug 2016 14:07:29 -0700 (PDT)
Message-ID: <1472591243.4095.7.camel@poochiereds.net>
Subject: Re: [PATCH v2] fs/nfsd/nfs4callback: Remove deprecated
 create_singlethread_workqueue
From: Jeff Layton <jlayton@poochiereds.net>
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tejun Heo <tj@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Tue, 30 Aug 2016 17:07:23 -0400
In-Reply-To: <20160830205348.GA31915@Karyakshetra>
References: <20160830205348.GA31915@Karyakshetra>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-08-31 at 02:23 +0530, Bhaktipriya Shridhar wrote:
> The workqueue "callback_wq" queues a single work item &cb->cb_work
> per
> nfsd4_callback instance and thus, it doesn't require execution
> ordering.
> Hence, alloc_workqueue has been used to replace the
> deprecated create_singlethread_workqueue instance.
> 
> The WQ_MEM_RECLAIM flag has not been set since this is an in-kernel
> nfs
> server and isn't involved in memory reclaim operations on the local
> host.
> 
> Since there are fixed number of work items, explicit concurrency
> limit is unnecessary here.
> 
> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
> ---
>  Changes in v2:
> 	- No change. Made this a separate patch (categorised based on
> 	  directories).
> 
>  fs/nfsd/nfs4callback.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 7389cb1..a6611c6 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -1021,7 +1021,7 @@ static const struct rpc_call_ops nfsd4_cb_ops =
> {
> 
>  int nfsd4_create_callback_queue(void)
>  {
> -	callback_wq =
> create_singlethread_workqueue("nfsd4_callbacks");
> +	callback_wq = alloc_workqueue("nfsd4_callbacks", 0, 0);
>  	if (!callback_wq)
>  		return -ENOMEM;
>  	return 0;
> --
> 2.1.4
> 

Hah! I have almost exactly the same patch in my tree. I've only not
sent it because I haven't had the chance to test it well.

The only difference in mine is that it passes in WQ_UNBOUND. ISTM that
we don't really need a bound workqueue here since we only use this to
kick off callbacks to the client. I doubt we'd get much out of strictly
maintaining cache locality here, and we're better off just sending it
the callback as quickly as possible.

Thoughts?
-- 
Jeff Layton <jlayton@poochiereds.net>
