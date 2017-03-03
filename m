Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34295 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751459AbdCCQht (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Mar 2017 11:37:49 -0500
Received: by mail-it0-f65.google.com with SMTP id r141so2868048ita.1
        for <linux-nfs@vger.kernel.org>; Fri, 03 Mar 2017 08:37:08 -0800 (PST)
Subject: Re: [PATCH v2 1/2] NFSv4.x/callback: Create the callback service
 through svc_create_pooled
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
References: <322d5c7d-d3b4-1e02-de3f-8e1a900cb150@gmail.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <db71aa4b-5c9f-0280-9e9c-336b28cdf803@gmail.com>
Date: Fri, 3 Mar 2017 21:34:50 +0800
MIME-Version: 1.0
In-Reply-To: <322d5c7d-d3b4-1e02-de3f-8e1a900cb150@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ping...

The state? 

thanks,
Kinglong Mee

On 1/19/2017 16:36, Kinglong Mee wrote:
> As the comments for svc_set_num_threads() said, 
> " Destroying threads relies on the service threads filling in
> rqstp->rq_task, which only the nfs ones do.  Assumes the serv
> has been created using svc_create_pooled()."
> 
> If creating service through svc_create(), the svc_pool_map_put()
> will be called in svc_destroy(), but the pool map isn't used.
> So that, the reference of pool map will be drop, the next using
> of pool map will get a zero npools. 
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfs/callback.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index 484bebc..0a21150 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -279,7 +279,7 @@ static struct svc_serv *nfs_callback_create_svc(int minorversion)
>  		printk(KERN_WARNING "nfs_callback_create_svc: no kthread, %d users??\n",
>  			cb_info->users);
>  
> -	serv = svc_create(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, sv_ops);
> +	serv = svc_create_pooled(&nfs4_callback_program, NFS4_CALLBACK_BUFSIZE, sv_ops);
>  	if (!serv) {
>  		printk(KERN_ERR "nfs_callback_create_svc: create service failed\n");
>  		return ERR_PTR(-ENOMEM);
> 
