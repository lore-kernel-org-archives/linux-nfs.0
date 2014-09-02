Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:62602 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088AbaIBSNO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 14:13:14 -0400
Received: by mail-qg0-f47.google.com with SMTP id z60so6897682qgd.20
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 11:13:13 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 2 Sep 2014 14:13:08 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] lockd: Do not start the lockd thread before we've
 set nlmsvc_rqst->rq_task
Message-ID: <20140902141308.24a1aebc@tlielax.poochiereds.net>
In-Reply-To: <1409680738-12491-1-git-send-email-trond.myklebust@primarydata.com>
References: <1409680738-12491-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue,  2 Sep 2014 13:58:57 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> This fixes an Oopsable race when starting lockd.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  fs/lockd/svc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 673668a9eec1..c35cd43a06e6 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -306,7 +306,7 @@ static int lockd_start_svc(struct svc_serv *serv)
>  	svc_sock_update_bufs(serv);
>  	serv->sv_maxconn = nlm_max_connections;
>  
> -	nlmsvc_task = kthread_run(lockd, nlmsvc_rqst, "%s", serv->sv_name);
> +	nlmsvc_task = kthread_create(lockd, nlmsvc_rqst, "%s", serv->sv_name);
>  	if (IS_ERR(nlmsvc_task)) {
>  		error = PTR_ERR(nlmsvc_task);
>  		printk(KERN_WARNING
> @@ -314,6 +314,7 @@ static int lockd_start_svc(struct svc_serv *serv)
>  		goto out_task;
>  	}
>  	nlmsvc_rqst->rq_task = nlmsvc_task;
> +	wake_up_process(nlmsvc_task);
>  
>  	dprintk("lockd_up: service started\n");
>  	return 0;


Reviewed-by: Jeff Layton <jlayton@primarydata.com>
