Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37607 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933664AbaJ2PiN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Oct 2014 11:38:13 -0400
Date: Wed, 29 Oct 2014 11:38:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] SUNRPC: off by one in BUG_ON()
Message-ID: <20141029153806.GB1133@fieldses.org>
References: <20141029084416.GC8939@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141029084416.GC8939@mwanda>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 29, 2014 at 11:44:16AM +0300, Dan Carpenter wrote:
> The m->pool_to[] array has "maxpools" number of elements.  It's
> allocated in svc_pool_map_alloc_arrays() which we called earlier in the
> function.  This test should be >= instead of >.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> This is very old code, but hopefully the off by one doesn't affect
> runtime.

Yeah, doesn't look like a big deal, but thanks, applying for 3.19.--b.

> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index ca8a795..349c98f 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -189,7 +189,7 @@ svc_pool_map_init_percpu(struct svc_pool_map *m)
>  		return err;
>  
>  	for_each_online_cpu(cpu) {
> -		BUG_ON(pidx > maxpools);
> +		BUG_ON(pidx >= maxpools);
>  		m->to_pool[cpu] = pidx;
>  		m->pool_to[pidx] = cpu;
>  		pidx++;
