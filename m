Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga03-in.huawei.com ([119.145.14.66]:1285 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711Ab3JXMcF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Oct 2013 08:32:05 -0400
Message-ID: <526912C1.6070502@huawei.com>
Date: Thu, 24 Oct 2013 20:29:53 +0800
From: Ding Tianhong <dingtianhong@huawei.com>
MIME-Version: 1.0
To: wangweidong <wangweidong1@huawei.com>
CC: <davem@davemloft.net>, <Trond.Myklebust@netapp.com>,
        <bfields@fieldses.org>, <netdev@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PACTH net-next] SUNRPC: remove an unnecessary if statement
References: <52688768.9020703@huawei.com>
In-Reply-To: <52688768.9020703@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013/10/24 10:35, wangweidong wrote:
> If req allocated failed just goto out_free, no need to check the
> 'i < num_prealloc'. There is just code simplification, no
> functional changes.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/sunrpc/xprt.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 095363e..a8e20de 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1087,11 +1087,9 @@ struct rpc_xprt *xprt_alloc(struct net *net, size_t size,
>  	for (i = 0; i < num_prealloc; i++) {
>  		req = kzalloc(sizeof(struct rpc_rqst), GFP_KERNEL);
>  		if (!req)
> -			break;
> +			goto out_free;
>  		list_add(&req->rq_list, &xprt->free);
>  	}
> -	if (i < num_prealloc)
> -		goto out_free;
>  	if (max_alloc > num_prealloc)
>  		xprt->max_reqs = max_alloc;
>  	else
> -- 1.7.12
> 
> 

Acked-by: Ding Tianhong <dingtianhong@huawei.com>

> 
> 
> .
> 


