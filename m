From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCH] SQUASHME: Support for cb_layout returning NFS4ERR_DELAY
Date: Mon, 28 Jun 2010 20:13:13 +0300
Message-ID: <4C28D829.5070706@panasas.com>
References: <4C1A4DED.50702@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	"Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:1055 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752799Ab0F1RNX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jun 2010 13:13:23 -0400
In-Reply-To: <4C1A4DED.50702@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/17/2010 07:31 PM, Boaz Harrosh wrote:
> 
> On a recall, a client may return NFS4ERR_DELAY to indicate
> that it is busy with the layout and wants to be poled.
> 
> TODO: If the client is stuck he would probably be cleaned
>       at expire client. But it is possible that the client
>       is active/renewing but would not acknowledge the
>       recall. We should take a time stamp on first recall
>       and expire the client if a lease time has passed.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

So I was still crashing on callbacks all during bakethon even
with this patch and Benny's fixes. (See below)

> ---
>  fs/nfsd/nfs4callback.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index e1faad4..8374ebd 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -1044,6 +1044,12 @@ static void nfsd4_cb_layout_done(struct rpc_task *task, void *calldata)
>  		 */
>  		expire_client_lock(clp);
>  		break;
> +	case -NFS4ERR_DELAY:
> +		/* Pole the client until it's done with the layout */
> +		rpc_delay(task, HZ/100); /* 10 mili-seconds */
> +		task->tk_status = 0;
> +		rpc_restart_call(task);

When using rpc_restart_call here I get an hard crash at:

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index f3b5015..7529f9a 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -514,6 +514,7 @@ decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
 	u32 dummy;
 	__be32 *p;
 
+	BUG_ON(!res);
 	if (res->cbs_minorversion == 0)
 		return 0;

[BUG_ON added for demonstration]

The below code would fix it. (Obviously)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index f3b5015..7529f9a 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -869,9 +870,6 @@ static void nfsd4_cb_done_sequence(struct rpc_task *task,
 		rpc_wake_up_next(&clp->cl_cb_waitq);
 		dprintk("%s: freed slot, new seqid=%d\n", __func__,
 			clp->cl_cb_seq_nr);
-
-		/* We're done looking into the sequence information */
-		task->tk_msg.rpc_resp = NULL;
 	}
 }

This is because when the second rpc, that was retried above in nfsd4_cb_layout_done()
has a NULL ->rpc_resp. (Which is the struct nfsd4_cb_sequence *res parameter to
decode_cb_sequence on reply from server).

Now this above nfsd4_cb_layout_done() is new pNFS code, but the same problem (crash) should apply
when a retry is attempted in nfsd4_cb_recall_done(). So this hunk should go into current tree.
(and stable)

The code was introduced by this patch:
	0421b5c55acd0e88920cb9a5bcea6ed738186853
	From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
	Subject: [PATCH] nfsd41: Backchannel: Implement cb_recall over NFSv4.1

I guess it was never tested with error on callback and retry attempt.
Ricardo what was the original intention of the line above (plus the comment)

[I'll send an official patch to Bruce as well]

Thanks
Boaz

> +		break;
>  	case -NFS4ERR_NOMATCHING_LAYOUT:
>  		nomatching_layout(clr);
>  	}

