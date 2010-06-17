From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] SQUASHME: Support for cb_layout returning NFS4ERR_DELAY
Date: Thu, 17 Jun 2010 17:56:29 -0400
Message-ID: <4C1A9A0D.2040305@panasas.com>
References: <4C1A4DED.50702@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:7978 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753582Ab0FQV4X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 17:56:23 -0400
In-Reply-To: <4C1A4DED.50702@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged at pnfs-all-2.6.35-rc3-2010-06-17-1

Thanks!

Benny

On Jun. 17, 2010, 12:31 -0400, Boaz Harrosh <bharrosh@panasas.com> wrote:
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
> +		break;
>  	case -NFS4ERR_NOMATCHING_LAYOUT:
>  		nomatching_layout(clr);
>  	}
