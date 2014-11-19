Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55582 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756792AbaKSUtO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Nov 2014 15:49:14 -0500
Date: Wed, 19 Nov 2014 15:49:14 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Fix slot wake up race in the nfsv4.1 callback code
Message-ID: <20141119204914.GA14207@fieldses.org>
References: <1416419270-8964-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1416419270-8964-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 19, 2014 at 12:47:50PM -0500, Trond Myklebust wrote:
> The currect code for nfsd41_cb_get_slot() and nfsd4_cb_done() has no
> locking in order to guarantee atomicity, and so allows for races of
> the form.

Makes sense, thanks.  Applying for 3.18 and stable.

--b.

> 
> Task 1                                  Task 2
> ======                                  ======
> if (test_and_set_bit(0) != 0) {
>                                         clear_bit(0)
>                                         rpc_wake_up_next(queue)
>         rpc_sleep_on(queue)
>         return false;
> }
> 
> This patch breaks the race condition by adding a retest of the bit
> after the call to rpc_sleep_on().
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Cc: stable@vger.kernel.org
> ---
>  fs/nfsd/nfs4callback.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index ed2b1151b171..7cbdf1b2e4ab 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -774,8 +774,12 @@ static bool nfsd41_cb_get_slot(struct nfs4_client *clp, struct rpc_task *task)
>  {
>  	if (test_and_set_bit(0, &clp->cl_cb_slot_busy) != 0) {
>  		rpc_sleep_on(&clp->cl_cb_waitq, task, NULL);
> -		dprintk("%s slot is busy\n", __func__);
> -		return false;
> +		/* Race breaker */
> +		if (test_and_set_bit(0, &clp->cl_cb_slot_busy) != 0) {
> +			dprintk("%s slot is busy\n", __func__);
> +			return false;
> +		}
> +		rpc_wake_up_queued_task(&clp->cl_cb_waitq, task);
>  	}
>  	return true;
>  }
> -- 
> 1.9.3
> 
