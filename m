From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH] nfsd41: Fix a crash when a callback is retried
Date: Mon, 28 Jun 2010 20:38:36 +0300
Message-ID: <4C28DE1C.3030907@panasas.com>
References: <4C28DCE0.7050201@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>,
	"Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:51932 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751495Ab0F1Rij (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jun 2010 13:38:39 -0400
In-Reply-To: <4C28DCE0.7050201@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/28/2010 08:33 PM, Boaz Harrosh wrote:
> 
> If a callback is retried at nfsd4_cb_recall_done() do to
> some error. The returned rpc reply would then crash here:
> 
>  @@ -514,6 +514,7 @@ decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
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
> This problem was introduced by a 4.1 protocol addition patch:
> 	[0421b5c5] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
> 
> Which was overlooking the possibility of an RPC callback retries.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Bruce do we need a CC: stable@kernel.org here. Is any code actually
exercising callbacks? And with 4.1?

It is an existing bug but an highly theoretical one. I'd say:
innocent until proven guilty in this case. 

Boaz

> ---
>  fs/nfsd/nfs4callback.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index f3b5015..dace7e2 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -869,9 +869,6 @@ static void nfsd4_cb_done_sequence(struct rpc_task *task,
>  		rpc_wake_up_next(&clp->cl_cb_waitq);
>  		dprintk("%s: freed slot, new seqid=%d\n", __func__,
>  			clp->cl_cb_seq_nr);
> -
> -		/* We're done looking into the sequence information */
> -		task->tk_msg.rpc_resp = NULL;
>  	}
>  }
>  

