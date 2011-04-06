Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:52517 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752639Ab1DFA5o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Apr 2011 20:57:44 -0400
Date: Wed, 6 Apr 2011 03:57:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Rob Landley <rlandley@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        containers@lists.linux-foundation.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Tim Spriggs <tims@uahirise.org>, Kir Kolyshkin <kir@parallels.com>,
        Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 2/3] Supply network namespace to rpcbind.
Message-ID: <20110406005743.GB27844@shutemov.name>
References: <4D94319F.8040005@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D94319F.8040005@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 31, 2011 at 02:47:43AM -0500, Rob Landley wrote:
> From: Rob Landley <rlandley@parallels.com>
> 
> The sunrpc code already has some support for network namespaces,
> but rpcb_create() is still using init_net.  Its arguments include
> a sockaddr and a port, but not a struct net *.  Add one, and
> pass in the value from rpc_xprt when calling it.
> 
> Signed-off-by: Rob Landley <rlandley@parallels.com>

Acked-by: Kirill A. Shutemov <kas@openvz.org>

BTW, it seems conflicts with my rpc_pipefs patchset. I'll rebase my
patchset, if your patches will be merged first.

> ---
> 
>  net/sunrpc/rpcb_clnt.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index c652e4c..25bb8f9 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -223,10 +223,11 @@ out:
>  }
>  
>  static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
> -				    size_t salen, int proto, u32 version)
> +				    size_t salen, int proto, struct net *net,
> +				    u32 version)
>  {
>  	struct rpc_create_args args = {
> -		.net		= &init_net,
> +		.net		= net,
>  		.protocol	= proto,
>  		.address	= srvaddr,
>  		.addrsize	= salen,
> @@ -591,7 +592,7 @@ void rpcb_getport_async(struct rpc_task *task)
>  		task->tk_pid, __func__, bind_version);
>  
>  	rpcb_clnt = rpcb_create(clnt->cl_server, sap, salen, xprt->prot,
> -				bind_version);
> +				xprt->xprt_net, bind_version);
>  	if (IS_ERR(rpcb_clnt)) {
>  		status = PTR_ERR(rpcb_clnt);
>  		dprintk("RPC: %5u %s: rpcb_create failed, error %ld\n",
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

-- 
 Kirill A. Shutemov
