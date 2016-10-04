Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:35395 "EHLO
        mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750908AbcJDKnu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2016 06:43:50 -0400
Received: by mail-yw0-f193.google.com with SMTP id t193so941772ywc.2
        for <linux-nfs@vger.kernel.org>; Tue, 04 Oct 2016 03:43:50 -0700 (PDT)
Message-ID: <1475577825.2645.1.camel@poochiereds.net>
Subject: Re: [PATCH] NFSv4.2: Fix a reference leak in
 nfs42_proc_layoutstats_generic
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 04 Oct 2016 06:43:45 -0400
In-Reply-To: <1475554063-8219-1-git-send-email-trond.myklebust@primarydata.com>
References: <1475554063-8219-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-10-04 at 00:07 -0400, Trond Myklebust wrote:
> From: Jeff Layton <jlayton@poochiereds.net>
> 
> The caller of rpc_run_task also gets a reference that must be put.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> Cc: stable@vger.kernel.org # 4.2+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/nfs42proc.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index 64b43b4ad9dd..608501971fe0 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -443,6 +443,7 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *server,
>  	task = rpc_run_task(&task_setup);
>  	if (IS_ERR(task))
>  		return PTR_ERR(task);
> +	rpc_put_task(task);
>  	return 0;
>  }
>  

Ouch, good catch. I thought I had sent this upstream long ago, but I
guess it slipped through the cracks.

Thanks,
-- 
Jeff Layton <jlayton@poochiereds.net>
