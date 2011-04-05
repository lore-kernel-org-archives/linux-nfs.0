Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:62957 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287Ab1DEDBC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Apr 2011 23:01:02 -0400
Date: Mon, 4 Apr 2011 22:01:01 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Rob Landley <rlandley@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        containers@lists.linux-foundation.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Tim Spriggs <tims@uahirise.org>, Kir Kolyshkin <kir@parallels.com>,
        Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 2/3] Supply network namespace to rpcbind.
Message-ID: <20110405030101.GB6764@hallyn.com>
References: <4D94319F.8040005@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D94319F.8040005@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Quoting Rob Landley (rlandley@parallels.com):
> From: Rob Landley <rlandley@parallels.com>
> 
> The sunrpc code already has some support for network namespaces,
> but rpcb_create() is still using init_net.  Its arguments include
> a sockaddr and a port, but not a struct net *.  Add one, and
> pass in the value from rpc_xprt when calling it.
> 
> Signed-off-by: Rob Landley <rlandley@parallels.com>

Acked-by: Serge Hallyn <serge.hallyn@ubuntu.com>

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
