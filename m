Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:51924 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758499Ab0GTOhj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 10:37:39 -0400
Message-ID: <4C45B4B0.2020208@panasas.com>
Date: Tue, 20 Jul 2010 17:37:36 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
CC: Benny Halevy <bhalevy@panasas.com>,
        "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH version2] nfsd41: Fix a crash when a callback is retried
References: <4C28DCE0.7050201@panasas.com> <4C29DA23.90200@panasas.com>
In-Reply-To: <4C29DA23.90200@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/29/2010 02:33 PM, Boaz Harrosh wrote:
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

Bruce hi.

This is a crash fix for current 4.1 code. Perhaps you have missed it.
(If not, sorry. Just that I've not seen any response)

Thanks
Boaz

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

