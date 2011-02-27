Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:3554 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551Ab1B0Mou (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Feb 2011 07:44:50 -0500
Message-ID: <4D6A4741.3080706@panasas.com>
Date: Sun, 27 Feb 2011 14:44:49 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: andros@netapp.com
CC: iisaman@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSv4.1 reclaim complete must wait for completion
References: <1298542269-2477-1-git-send-email-andros@netapp.com> <1298542269-2477-3-git-send-email-andros@netapp.com>
In-Reply-To: <1298542269-2477-3-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-24 02:11, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Reported-by: Trond Myklebust <trond.myklebust@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 7d80e78..388817b 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5385,6 +5385,9 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp)
>  		status = PTR_ERR(task);
>  		goto out;
>  	}
> +        status = nfs4_wait_for_completion_rpc_task(task);
> +        if (status == 0)
> +                status = task->tk_status;

nit: please use tabs rather than spaces to indent.

Benny

>  	rpc_put_task(task);
>  	return 0;
>  out:
