Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:44600 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242Ab1CJGzm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 01:55:42 -0500
Message-ID: <4D7875E8.4030400@panasas.com>
Date: Wed, 09 Mar 2011 22:55:36 -0800
From: Benny Halevy <bhalevy@panasas.com>
To: andros@netapp.com
CC: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH Cthon2011 fixes 3/3] NFSv4.1 reclaim complete must wait
 for completion
References: <1299694426-5620-1-git-send-email-andros@netapp.com> <1299694426-5620-2-git-send-email-andros@netapp.com> <1299694426-5620-3-git-send-email-andros@netapp.com>
In-Reply-To: <1299694426-5620-3-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-03-09 10:13, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 8edb1fc..0bce091 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5435,6 +5435,9 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp)
>  		status = PTR_ERR(task);
>  		goto out;
>  	}
> +        status = nfs4_wait_for_completion_rpc_task(task);
> +        if (status == 0)
> +                status = task->tk_status;

nit: spaces => tabs

Benny

>  	rpc_put_task(task);
>  	return 0;
>  out:
