Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:44863 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751894AbeCWS4N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Mar 2018 14:56:13 -0400
Subject: Re: [PATCH net-next nfs 1/6] net: Convert rpcsec_gss_net_ops
To: Kirill Tkhai <ktkhai@virtuozzo.com>, <davem@davemloft.net>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>,
        <jlayton@kernel.org>, <dhowells@redhat.com>,
        <keescook@chromium.org>, <dwindsor@gmail.com>,
        <ishkamiel@gmail.com>, <elena.reshetova@intel.com>,
        <linux-nfs@vger.kernel.org>, <linux-afs@lists.infradead.org>,
        <netdev@vger.kernel.org>
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
 <152093815494.8636.6607369744413088370.stgit@localhost.localdomain>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <28c32fa9-17e1-0399-d7bf-760441128cf8@Netapp.com>
Date: Fri, 23 Mar 2018 14:53:34 -0400
MIME-Version: 1.0
In-Reply-To: <152093815494.8636.6607369744413088370.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/13/2018 06:49 AM, Kirill Tkhai wrote:
> These pernet_operations initialize and destroy sunrpc_net_id
> refered per-net items. Only used global list is cache_list,
> and accesses already serialized.
> 
> sunrpc_destroy_cache_detail() check for list_empty() without
> cache_list_lock, but when it's called from unregister_pernet_subsys(),
> there can't be callers in parallel, so we won't miss list_empty()
> in this case.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

It might make sense to take these and the other NFS patches through the net tree, since the pernet_operations don't yet have the async field in my tree (and I therefore can't compile once these are applied).

Acked-by: Anna Schumaker <Anna.Schumaker@netapp.com>

> ---
>  net/sunrpc/auth_gss/auth_gss.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 9463af4b32e8..44f939cb6bc8 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -2063,6 +2063,7 @@ static __net_exit void rpcsec_gss_exit_net(struct net *net)
>  static struct pernet_operations rpcsec_gss_net_ops = {
>  	.init = rpcsec_gss_init_net,
>  	.exit = rpcsec_gss_exit_net,
> +	.async = true,
>  };
>  
>  /*
> 
