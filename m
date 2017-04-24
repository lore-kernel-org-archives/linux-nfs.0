Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44898 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1046512AbdDXMSi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 24 Apr 2017 08:18:38 -0400
Date: Mon, 24 Apr 2017 08:18:18 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Kinglong Mee <kinglongmee@gmail.com>
cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v2 1/2] NFSv4.x/callback: Create the callback service
 through svc_create_pooled
In-Reply-To: <322d5c7d-d3b4-1e02-de3f-8e1a900cb150@gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1704240805530.29615@planck.local>
References: <322d5c7d-d3b4-1e02-de3f-8e1a900cb150@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 19 Jan 2017, Kinglong Mee wrote:

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

Thanks!

Reviewed-by: Benjamin Coddington <bcodding@redhat.com>
Tested-by: Benjamin Coddington <bcodding@redhat.com>

Ben

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
> --
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
