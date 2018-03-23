Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:52177 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752048AbeCWSyF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Mar 2018 14:54:05 -0400
Subject: Re: [PATCH net-next nfs 2/6] net: Convert sunrpc_net_ops
To: Kirill Tkhai <ktkhai@virtuozzo.com>, <davem@davemloft.net>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>,
        <jlayton@kernel.org>, <dhowells@redhat.com>,
        <keescook@chromium.org>, <dwindsor@gmail.com>,
        <ishkamiel@gmail.com>, <elena.reshetova@intel.com>,
        <linux-nfs@vger.kernel.org>, <linux-afs@lists.infradead.org>,
        <netdev@vger.kernel.org>
References: <152093778442.8636.10592672493816457119.stgit@localhost.localdomain>
 <152093816841.8636.4371549856827439735.stgit@localhost.localdomain>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <c822c555-ffe1-b160-9f9f-7387ed5eeb83@Netapp.com>
Date: Fri, 23 Mar 2018 14:53:45 -0400
MIME-Version: 1.0
In-Reply-To: <152093816841.8636.4371549856827439735.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/13/2018 06:49 AM, Kirill Tkhai wrote:
> These pernet_operations look similar to rpcsec_gss_net_ops,
> they just create and destroy another caches. So, they also
> can be async.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Acked-by: Anna Schumaker <Anna.Schumaker@netapp.com>

> ---
>  net/sunrpc/sunrpc_syms.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
> index 56f9eff74150..68287e921847 100644
> --- a/net/sunrpc/sunrpc_syms.c
> +++ b/net/sunrpc/sunrpc_syms.c
> @@ -79,6 +79,7 @@ static struct pernet_operations sunrpc_net_ops = {
>  	.exit = sunrpc_exit_net,
>  	.id = &sunrpc_net_id,
>  	.size = sizeof(struct sunrpc_net),
> +	.async = true,
>  };
>  
>  static int __init
> 
