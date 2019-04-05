Return-Path: <SRS0=4THU=SH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 798BEC282CE
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 20:40:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 500DC2173C
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 20:40:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726218AbfDEUkp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 5 Apr 2019 16:40:45 -0400
Received: from fieldses.org ([173.255.197.46]:60822 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725946AbfDEUkp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 Apr 2019 16:40:45 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id B9304571; Fri,  5 Apr 2019 16:40:44 -0400 (EDT)
Date:   Fri, 5 Apr 2019 16:40:44 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Scott Mayhew <smayhew@redhat.com>
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v3 4/5] nfsd: re-order client tracking method
 selection
Message-ID: <20190405204044.GC8397@fieldses.org>
References: <20190326220630.2911-1-smayhew@redhat.com>
 <20190326220630.2911-5-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326220630.2911-5-smayhew@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Mar 26, 2019 at 06:06:29PM -0400, Scott Mayhew wrote:
> The new order is first nfsdcld, then the UMH upcall, and finally the
> legacy tracking method.  Added some printk's to the tracking

I'm hesitant to add printk's (as opposed to dprintk's or tracepoints),
but this is just one line on nfsd startup, and maybe it's helpful
figuring out what's going on if for example nfsdcld isn't starting when
it should.  OK.

--b.

> initialization functions so it's clear which tracking method was
> ultimately selected.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfsd/nfs4recover.c | 80 +++++++++++++++++++++++++++++++++++--------
>  1 file changed, 65 insertions(+), 15 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 09e3c9352778..d60001da1dbf 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -628,6 +628,7 @@ nfsd4_legacy_tracking_init(struct net *net)
>  	status = nfsd4_load_reboot_recovery_data(net);
>  	if (status)
>  		goto err;
> +	printk("NFSD: Using legacy client tracking operations.\n");
>  	return 0;
>  
>  err:
> @@ -937,7 +938,7 @@ nfsd4_cld_unregister_net(struct net *net, struct rpc_pipe *pipe)
>  
>  /* Initialize rpc_pipefs pipe for communication with client tracking daemon */
>  static int
> -nfsd4_init_cld_pipe(struct net *net)
> +__nfsd4_init_cld_pipe(struct net *net)
>  {
>  	int ret;
>  	struct dentry *dentry;
> @@ -980,6 +981,17 @@ nfsd4_init_cld_pipe(struct net *net)
>  	return ret;
>  }
>  
> +static int
> +nfsd4_init_cld_pipe(struct net *net)
> +{
> +	int status;
> +
> +	status = __nfsd4_init_cld_pipe(net);
> +	if (!status)
> +		printk("NFSD: Using old nfsdcld client tracking operations.\n");
> +	return status;
> +}
> +
>  static void
>  nfsd4_remove_cld_pipe(struct net *net)
>  {
> @@ -1285,27 +1297,55 @@ nfs4_cld_state_shutdown(struct net *net)
>  	kfree(nn->reclaim_str_hashtbl);
>  }
>  
> +static bool
> +cld_running(struct nfsd_net *nn)
> +{
> +	struct cld_net *cn = nn->cld_net;
> +	struct rpc_pipe *pipe = cn->cn_pipe;
> +
> +	return pipe->nreaders || pipe->nwriters;
> +}
> +
>  static int
>  nfsd4_cld_tracking_init(struct net *net)
>  {
>  	int status;
>  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> +	bool running;
> +	int retries = 10;
>  
>  	status = nfs4_cld_state_init(net);
>  	if (status)
>  		return status;
>  
> -	status = nfsd4_init_cld_pipe(net);
> +	status = __nfsd4_init_cld_pipe(net);
>  	if (status)
>  		goto err_shutdown;
>  
> +	/*
> +	 * rpc pipe upcalls take 30 seconds to time out, so we don't want to
> +	 * queue an upcall unless we know that nfsdcld is running (because we
> +	 * want this to fail fast so that nfsd4_client_tracking_init() can try
> +	 * the next client tracking method).  nfsdcld should already be running
> +	 * before nfsd is started, so the wait here is for nfsdcld to open the
> +	 * pipefs file we just created.
> +	 */
> +	while (!(running = cld_running(nn)) && retries--)
> +		msleep(100);
> +
> +	if (!running) {
> +		status = -ETIMEDOUT;
> +		goto err_remove;
> +	}
> +
>  	status = nfsd4_cld_grace_start(nn);
>  	if (status) {
>  		if (status == -EOPNOTSUPP)
>  			printk(KERN_WARNING "NFSD: Please upgrade nfsdcld.\n");
>  		nfs4_release_reclaim(nn);
>  		goto err_remove;
> -	}
> +	} else
> +		printk("NFSD: Using nfsdcld client tracking operations.\n");
>  	return 0;
>  
>  err_remove:
> @@ -1552,6 +1592,8 @@ nfsd4_umh_cltrack_init(struct net *net)
>  
>  	ret = nfsd4_umh_cltrack_upcall("init", NULL, grace_start, NULL);
>  	kfree(grace_start);
> +	if (!ret)
> +		printk("NFSD: Using UMH upcall client tracking operations.\n");
>  	return ret;
>  }
>  
> @@ -1701,9 +1743,20 @@ nfsd4_client_tracking_init(struct net *net)
>  	if (nn->client_tracking_ops)
>  		goto do_init;
>  
> +	/* First, try to use nfsdcld */
> +	nn->client_tracking_ops = &nfsd4_cld_tracking_ops;
> +	status = nn->client_tracking_ops->init(net);
> +	if (!status)
> +		return status;
> +	if (status != -ETIMEDOUT) {
> +		nn->client_tracking_ops = &nfsd4_cld_tracking_ops_v0;
> +		status = nn->client_tracking_ops->init(net);
> +		if (!status)
> +			return status;
> +	}
> +
>  	/*
> -	 * First, try a UMH upcall. It should succeed or fail quickly, so
> -	 * there's little harm in trying that first.
> +	 * Next, try the UMH upcall.
>  	 */
>  	nn->client_tracking_ops = &nfsd4_umh_tracking_ops;
>  	status = nn->client_tracking_ops->init(net);
> @@ -1711,26 +1764,23 @@ nfsd4_client_tracking_init(struct net *net)
>  		return status;
>  
>  	/*
> -	 * See if the recoverydir exists and is a directory. If it is,
> -	 * then use the legacy ops.
> +	 * Finally, See if the recoverydir exists and is a directory.
> +	 * If it is, then use the legacy ops.
>  	 */
>  	nn->client_tracking_ops = &nfsd4_legacy_tracking_ops;
>  	status = kern_path(nfs4_recoverydir(), LOOKUP_FOLLOW, &path);
>  	if (!status) {
>  		status = d_is_dir(path.dentry);
>  		path_put(&path);
> -		if (status)
> -			goto do_init;
> +		if (!status) {
> +			status = -EINVAL;
> +			goto out;
> +		}
>  	}
>  
> -	/* Finally, try to use nfsdcld */
> -	nn->client_tracking_ops = &nfsd4_cld_tracking_ops;
> -	status = nn->client_tracking_ops->init(net);
> -	if (!status)
> -		return status;
> -	nn->client_tracking_ops = &nfsd4_cld_tracking_ops_v0;
>  do_init:
>  	status = nn->client_tracking_ops->init(net);
> +out:
>  	if (status) {
>  		printk(KERN_WARNING "NFSD: Unable to initialize client "
>  				    "recovery tracking! (%d)\n", status);
> -- 
> 2.17.2
