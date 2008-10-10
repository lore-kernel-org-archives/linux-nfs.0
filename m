From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: cb_recall error handling on server
Date: Fri, 10 Oct 2008 16:22:53 -0400
Message-ID: <20081010202253.GD19415@fieldses.org>
References: <48EF256E.3060806@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35227 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760696AbYJJUXD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Oct 2008 16:23:03 -0400
In-Reply-To: <48EF256E.3060806@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 10, 2008 at 11:50:38AM +0200, Benny Halevy wrote:
> Bruce, I was looking into nfsd4_cb_recall and I noticed
> that in case the first try erred with -EIO we
> retry via the following path:
> 
> 	while (retries--) {
> 		switch (status) {
> 		case -EIO:
> 			/* Network partition? */
> 			atomic_set(&clp->cl_callback.cb_set, 0);
> 		case -EBADHANDLE:
> 		case -NFS4ERR_BAD_STATEID:
> 			/* Race: client probably got cb_recall
> 			 * before open reply granting delegation */
> 			break;
> 
> The problem I see is that nobody seem to set clp->cl_callback.cb_set
> back to one in case the retry succeeds.

This is a bit delicate.

We use cb_set in part to decide when to send nfserr_cb_path_down (see
nfsd4_renew()).

We depend on the cb_path_down error to notify the client in the case
where the callback goes down.  So we'd like to make sure the client gets
that error before we give up and revoke the delegation, which we do
after a lease period.

If the lease period is l seconds, and we wait t seconds before setting
cb_set, then we'd better hope the client is polling at least every l-t
seconds.

So actually we should be setting the timeouts so that first delay (t) is
small enough that l-t will be larger than any client's polling interval.
Unfortunately, while clients *are* supposed to renew more frequently
than l, there's not really any guarantee of how much more frequently.

After this patch I think (looking at the retry settings) we could be
waiting up to a whole lease period before starting to return
nfserr_cb_path_down, which is clearly bad.  But even before it the
delay's probably too big.

The consequences, though, are harsher than necessary currently: one
timeout and we turn off delegations for that client permanently.  Two
possible improvements come to mind:

	- Turn off delegations provisionally on the first hint of
	  trouble, but turn them back on if later retries succeed.
	- Allow the decision about when to turn off delegations and the
	  decision about when to return cb_path_down separately, and
	  maybe do the latter a little sooner.

--b.

> 
> How about this:
> 
> From: Benny Halevy <bhalevy@panasas.com>
> Date: Fri, 10 Oct 2008 11:49:12 +0200
> Subject: [PATCH] nfsd: reset cl_callback.cb_set only if all retries failed
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4callback.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index e198ead..aec4a34 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -467,7 +467,6 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
>  		switch (status) {
>  			case -EIO:
>  				/* Network partition? */
> -				atomic_set(&clp->cl_callback.cb_set, 0);
>  			case -EBADHANDLE:
>  			case -NFS4ERR_BAD_STATEID:
>  				/* Race: client probably got cb_recall
> @@ -479,6 +478,8 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
>  		ssleep(2);
>  		status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
>  	}
> +	if (status == -EIO)
> +		atomic_set(&clp->cl_callback.cb_set, 0);
>  out_put_cred:
>  	/*
>  	 * Success or failure, now we're either waiting for lease expiration
> -- 
> 1.6.0.2
> 
