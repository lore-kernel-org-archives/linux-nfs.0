Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([209.166.131.148]:44882 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777AbaAVSxa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jan 2014 13:53:30 -0500
Message-ID: <52E013A1.50301@panasas.com>
Date: Wed, 22 Jan 2014 20:53:21 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS list <linux-nfs@vger.kernel.org>
CC: Stable Tree <stable@vger.kernel.org>
Subject: Re: [PATCH v3] pnfs: Proper delay for NFS4ERR_RECALLCONFLICT in layout_get_done
References: <52E00F4E.40804@panasas.com>
In-Reply-To: <52E00F4E.40804@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/22/2014 08:34 PM, Boaz Harrosh wrote:
> 
> An NFS4ERR_RECALLCONFLICT is returned by server from a GET_LAYOUT
> only when a Server Sent a RECALL do to that GET_LAYOUT, or
> the RECALL and GET_LAYOUT crossed on the wire.
> In any way this means we want to wait at most until in-flight IO
> is finished and the RECALL can be satisfied.
> 
> So a proper wait here is more like 1/10 of a second, not 15 seconds
> like we have now. In case of a server bug we delay exponentially
> longer on each retry.
> 
> Current code totally craps out performance of very large files on
> most pnfs-objects layouts, because of how the map changes when the
> file has grown into the next raid group.
> 
> [Stable: This will patch back to 3.9. If there are earlier still
>  maintained trees, please tell me I'll send a patch]
> 
> CC: Stable Tree <stable@vger.kernel.org>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/nfs4proc.c | 28 +++++++++++++++++++++++++---
>  1 file changed, 25 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d53d678..3ba882c 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7058,7 +7058,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
>  	struct nfs4_state *state = NULL;
>  	unsigned long timeo, giveup;
>  
> -	dprintk("--> %s\n", __func__);
> +	dprintk("--> %s tk_status => %d\n", __func__, -task->tk_status);
>  
>  	if (!nfs41_sequence_done(task, &lgp->res.seq_res))
>  		goto out;
> @@ -7068,10 +7068,32 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
>  		goto out;
>  	case -NFS4ERR_LAYOUTTRYLATER:
>  	case -NFS4ERR_RECALLCONFLICT:
> +	/* NFS4ERR_RECALLCONFLICT is when conflict with self (must recall
> +	 * existing layout before getting a new one).
> +	 * NFS4ERR_LAYOUTTRYLATER is a conflict with another client
> +	 * (or clients) writing to the same RAID stripe
> +	 */
>  		timeo = rpc_get_timeout(task->tk_client);
>  		giveup = lgp->args.timestamp + timeo;
> -		if (time_after(giveup, jiffies))
> -			task->tk_status = -NFS4ERR_DELAY;
> +		if (time_after(giveup, jiffies)) {
> +			unsigned long delay;
> +
> +			/* Delay for:
> +			 * - Not less then NFS4_POLL_RETRY_MIN.
> +			 * - One last time a jiffie before we give up
> +			 * - exponential backoff (time_now minus start_attempt)
> +			 */
> +			delay = max_t(unsigned long, NFS4_POLL_RETRY_MIN,
> +				    min((giveup - jiffies - 1),
> +					jiffies - lgp->args.timestamp));
> +
> +			dprintk("%s: NFS4ERR_RECALLCONFLICT waiting %lu\n",
> +				__func__, delay);

Hi Trond. Thanks

I've produced a bug in exofs to ever get stuck in NFS4ERR_RECALLCONFLICT
after the first one. And I see good exponential delay:

Jan 21 11:56:46 fc18-buml18 kernel: nfs4_layoutget_done: NFS4ERR_RECALLCONFLICT waiting 149
Jan 21 11:56:49 fc18-buml18 kernel: nfs4_layoutget_done: NFS4ERR_RECALLCONFLICT waiting 425
Jan 21 11:56:55 fc18-buml18 kernel: nfs4_layoutget_done: NFS4ERR_RECALLCONFLICT waiting 970
Jan 21 11:57:06 fc18-buml18 kernel: nfs4_layoutget_done: NFS4ERR_RECALLCONFLICT waiting 2069
Jan 21 11:57:28 fc18-buml18 kernel: nfs4_layoutget_done: NFS4ERR_RECALLCONFLICT waiting 1713
 
Now I wish the first one would start at 15 but I see a general delay in all operations on my
setup so for now I blame it on Ganesha and would imagine that nfs4_layoutget_done does not
usually returns after 149 Jiffis.

Is that what you meant?

BTW: Now I have a new problem that when time_after(giveup, jiffies) expires I get an EIO
at dd instead of write through MDS. Investigating ... wish me luck

Thanks
Boaz

> +			rpc_delay(task, delay);
> +			task->tk_status = 0;
> +			rpc_restart_call_prepare(task);
> +			goto out; /* Do not call nfs4_async_handle_error() */
> +		}
>  		break;
>  	case -NFS4ERR_EXPIRED:
>  	case -NFS4ERR_BAD_STATEID:
> 

