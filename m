Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:37297 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367AbaANTGE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jan 2014 14:06:04 -0500
Received: by mail-ie0-f171.google.com with SMTP id to1so933306ieb.2
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jan 2014 11:06:03 -0800 (PST)
Message-ID: <1389726356.6420.5.camel@leira.trondhjem.org>
Subject: Re: [PATCH v2] pnfs: Proper delay for NFS4ERR_RECALLCONFLICT in
 layout_get_done
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>, Stable Tree <stable@vger.kernel.org>
Date: Tue, 14 Jan 2014 14:05:56 -0500
In-Reply-To: <52D5589A.7090507@panasas.com>
References: <52D5589A.7090507@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2014-01-14 at 17:32 +0200, Boaz Harrosh wrote:
> An NFS4ERR_RECALLCONFLICT is returned by server from a GET_LAYOUT
> only when a Server Sent a RECALL do to that GET_LAYOUT, or
> the RECALL and GET_LAYOUT crossed on the wire.
> In any way this means we want to wait at most until in-flight IO
> is finished and the RECALL can be satisfied.
> 
> So a proper wait here is more like 1/10 of a second, not 15 seconds
> like we have now. (We use NFS4_POLL_RETRY_MIN here)
> 
> Current code totally craps out performance of very large files on
> most pnfs-objects layouts, because of how the map changes when the
> file has grown beyond a raid group.
> 
> CC: Stable Tree <stable@vger.kernel.org>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/nfs4proc.c | 22 +++++++++++++++++++---
>  1 file changed, 19 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index d53d678..3264fca 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -7058,7 +7058,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
>  	struct nfs4_state *state = NULL;
>  	unsigned long timeo, giveup;
>  
> -	dprintk("--> %s\n", __func__);
> +	dprintk("--> %s tk_status => %d\n", __func__, task->tk_status);
>  
>  	if (!nfs41_sequence_done(task, &lgp->res.seq_res))
>  		goto out;
> @@ -7067,11 +7067,27 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
>  	case 0:
>  		goto out;
>  	case -NFS4ERR_LAYOUTTRYLATER:
> +	/* NFS4ERR_RECALLCONFLICT is always a minimal delay (conflict with
> +	 * self)
> +	 * TODO: NFS4ERR_LAYOUTTRYLATER is a conflict with another client
> +	 * (or clients). What we should do is randomize a short delay like on a
> +	 * network broadcast burst, and raise the random max every failure.
> +	 * For now leave it stateless and do this polling.
> +	 */
>  	case -NFS4ERR_RECALLCONFLICT:
>  		timeo = rpc_get_timeout(task->tk_client);
>  		giveup = lgp->args.timestamp + timeo;
> -		if (time_after(giveup, jiffies))
> -			task->tk_status = -NFS4ERR_DELAY;
> +		if (time_after(giveup, jiffies)) {
> +			/* Do a minimum delay, We are actually waiting for our
> +			 * own IO to finish (In most cases)
> +			 */
> +			dprintk("%s: NFS4ERR_RECALLCONFLICT waiting\n",
> +				__func__);
> +			rpc_delay(task, NFS4_POLL_RETRY_MIN);
> +			task->tk_status = 0;
> +			rpc_restart_call_prepare(task);
> +			goto out; /* Do not call nfs4_async_handle_error() */
> +		}
>  

For the default mount option of 'timeo=600', and the default #define
NFS4_POLL_RETRY_MIN==HZ/10, this means we can end up pounding the server
with 600 LAYOUTGET requests within the space of 1 minute, before giving
up. Is that reasonable?

-- 
Trond Myklebust
Linux NFS client maintainer

