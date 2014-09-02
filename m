Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:55779 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125AbaIBSNh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 14:13:37 -0400
Received: by mail-qa0-f51.google.com with SMTP id j7so6521446qaq.38
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 11:13:36 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 2 Sep 2014 14:13:34 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfs: do not start the callback thread until we set
 rqstp->rq_task
Message-ID: <20140902141334.5fa604e5@tlielax.poochiereds.net>
In-Reply-To: <1409680738-12491-2-git-send-email-trond.myklebust@primarydata.com>
References: <1409680738-12491-1-git-send-email-trond.myklebust@primarydata.com>
	<1409680738-12491-2-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue,  2 Sep 2014 13:58:58 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> This fixes an Oopsable race when starting up the callback server.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/nfs/callback.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index e3dd1cd175d9..b8fb3a4ef649 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -235,7 +235,7 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
>  
>  	cb_info->serv = serv;
>  	cb_info->rqst = rqstp;
> -	cb_info->task = kthread_run(callback_svc, cb_info->rqst,
> +	cb_info->task = kthread_create(callback_svc, cb_info->rqst,
>  				    "nfsv4.%u-svc", minorversion);
>  	if (IS_ERR(cb_info->task)) {
>  		ret = PTR_ERR(cb_info->task);
> @@ -245,6 +245,7 @@ static int nfs_callback_start_svc(int minorversion, struct rpc_xprt *xprt,
>  		return ret;
>  	}
>  	rqstp->rq_task = cb_info->task;
> +	wake_up_process(cb_info->task);
>  	dprintk("nfs_callback_up: service started\n");
>  	return 0;
>  }


Reviewed-by: Jeff Layton <jlayton@primarydata.com>
