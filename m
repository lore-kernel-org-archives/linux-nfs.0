Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55144 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760574Ab0HEOXz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 10:23:55 -0400
Date: Thu, 5 Aug 2010 10:22:26 -0400
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>,
        "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH version2] nfsd41: Fix a crash when a callback is retried
Message-ID: <20100805142226.GA27141@fieldses.org>
References: <4C28DCE0.7050201@panasas.com>
 <4C29DA23.90200@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C29DA23.90200@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jun 29, 2010 at 02:33:55PM +0300, Boaz Harrosh wrote:
> 
> If a callback is retried at nfsd4_cb_recall_done() do to
> some error. The returned rpc reply would then crash here:
> 
> @@ -514,6 +514,7 @@ decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
>  	u32 dummy;
>  	__be32 *p;
> 
>  +	BUG_ON(!res);
>  	if (res->cbs_minorversion == 0)
>  		return 0;

Thanks, applied.  There may be a delay before it shows up in my
for-2.6.36 queue, while I sort out a few other bugs.

(We still have problems here: getting a new slot isn't always the
correct thing to do, depending on the error.  But this seems an
improvement....).

--b.

> 
> [BUG_ON added for demonstration]
> 
> This is because the nfsd4_cb_done_sequence() has NULLed out
> the task->tk_msg.rpc_resp pointer.
> 
> Also eventually the rpc would use the new slot without making
> sure it is free by calling nfsd41_cb_setup_sequence().
> 
> This problem was introduced by a 4.1 protocol addition patch:
> 	[0421b5c5] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
> 
> Which was overlooking the possibility of an RPC callback retries.
> For not-4.1 case redoing the _prepare is harmless.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfsd/nfs4callback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index f3b5015..3bbeae8 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -913,7 +913,7 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
>  	if (dp->dl_retries--) {
>  		rpc_delay(task, 2*HZ);
>  		task->tk_status = 0;
> -		rpc_restart_call(task);
> +		rpc_restart_call_prepare(task);
>  		return;
>  	} else {
>  		atomic_set(&clp->cl_cb_set, 0);
> -- 
> 1.6.6.1
> 
> 
