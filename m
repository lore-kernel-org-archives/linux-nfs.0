From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH version2] nfsd41: Fix a crash when a callback is retried
Date: Thu, 01 Jul 2010 21:28:59 +0300
Message-ID: <4C2CDE6B.2050702@panasas.com>
References: <4C28DCE0.7050201@panasas.com> <4C29DA23.90200@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	"Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:60284 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758157Ab0GAS3B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 14:29:01 -0400
In-Reply-To: <4C29DA23.90200@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 29, 2010, 14:33 +0300, Boaz Harrosh <bharrosh@panasas.com> wrote:
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

Merged at pnfs-all-2.6.35-rc3-2010-07-01

Thanks!

Benny

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
