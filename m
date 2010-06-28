From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfsd41: Fix a crash when a callback is retried
Date: Mon, 28 Jun 2010 21:50:08 +0300
Message-ID: <4C28EEE0.70502@panasas.com>
References: <4C28DCE0.7050201@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	"Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:52127 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872Ab0F1SuP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jun 2010 14:50:15 -0400
Received: by wwd20 with SMTP id 20so246030wwd.19
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jun 2010 11:50:14 -0700 (PDT)
In-Reply-To: <4C28DCE0.7050201@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 28, 2010, 20:33 +0300, Boaz Harrosh <bharrosh@panasas.com> wrote:
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

It looks like we have a more fundamental problem that
nfsd41_cb_setup_sequence is not called on the retry path
meaning that not only the message isn't reinitialized properly
but the single slot is not allocated as it should.
Boaz, I think you saw multiple callbacks going out concurrently, right?

rpc_restart_call_prepare() should be called instead of rpc_restart_call()

