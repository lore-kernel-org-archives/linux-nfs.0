From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 7/7] SUNRPC: Use soft connect semantics when performing
 RPC ping
Date: Wed, 07 Oct 2009 18:42:56 -0400
Message-ID: <1254955376.7045.41.camel@heimdal.trondhjem.org>
References: <20091007215019.1844.17414.stgit@matisse.1015granger.net>
	 <20091007220310.1844.39266.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25214 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754472AbZJGWne (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Oct 2009 18:43:34 -0400
In-Reply-To: <20091007220310.1844.39266.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-10-07 at 18:03 -0400, Chuck Lever wrote:
> Currently, if a remote RPC service is unreachable, an RPC ping will
> hang until the underlying transport connect attempt times out.  A more
> desirable behavior might be to have the ping fail immediately so upper
> layers can recover appropriately.
> 
> In the case of an NFS mount, for instance, this would mean the
> mount(2) system call could fail immediately if the server isn't
> listening, rather than hanging uninterruptibly for more than 3
> minutes.
> 
> With the new soft connect flag, we can get this behavior.  After
> this patch, rpc_create() with TCP will fail immediately if an RPC ping
> was requested and the server is not reachable.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/clnt.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index dc75289..ba52326 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1703,7 +1703,7 @@ static int rpc_ping(struct rpc_clnt *clnt, int flags)
>  	};
>  	int err;
>  	msg.rpc_cred = authnull_ops.lookup_cred(NULL, NULL, 0);
> -	err = rpc_call_sync(clnt, &msg, flags);
> +	err = rpc_call_sync(clnt, &msg, flags | RPC_TASK_SOFTCONN);
>  	put_rpccred(msg.rpc_cred);
>  	return err;
>  }

Currently, all callers already set RPC_TASK_SOFT. Why not move that too
into rpc_ping at the same time?
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
