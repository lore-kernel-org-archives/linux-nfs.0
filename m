From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] SQUASHME: into [SQUASHME: pnfsd: Support for cb_layout
 returning NFS4ERR_DELAY]
Date: Thu, 01 Jul 2010 21:28:40 +0300
Message-ID: <4C2CDE58.5050205@panasas.com>
References: <4C1A4DED.50702@panasas.com> <4C28D829.5070706@panasas.com> <4C29DAD8.1060809@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	"Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:18161 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757689Ab0GAS2n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 14:28:43 -0400
In-Reply-To: <4C29DAD8.1060809@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 29, 2010, 14:36 +0300, Boaz Harrosh <bharrosh@panasas.com> wrote:
> 
> This is the correct code.
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
> index 3bbeae8..60c719c 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -1046,7 +1046,7 @@ static void nfsd4_cb_layout_done(struct rpc_task *task, void *calldata)
>  		/* Pole the client until it's done with the layout */
>  		rpc_delay(task, HZ/100); /* 10 mili-seconds */
>  		task->tk_status = 0;
> -		rpc_restart_call(task);
> +		rpc_restart_call_prepare(task);
>  		break;
>  	case -NFS4ERR_NOMATCHING_LAYOUT:
>  		task->tk_status = 0;
