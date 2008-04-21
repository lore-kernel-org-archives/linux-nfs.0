From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 03/33] SUNRPC: Don't attempt to destroy expired RPCSEC_GSS credentials..
Date: Mon, 21 Apr 2008 13:50:49 -0400
Message-ID: <FB8780E7-FE92-40D6-8DFE-0663DF1B0162@oracle.com>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080419204047.14124.64969.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:23852 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754480AbYDURvO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 13:51:14 -0400
In-Reply-To: <20080419204047.14124.64969.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

On Apr 19, 2008, at 4:40 PM, Trond Myklebust wrote:
> ..and always destroy using a 'soft' RPC call. Destroying GSS  
> credentials
> isn't mandatory; the server can always cope with a few credentials not
> getting destroyed in a timely fashion.

These two changes may have different side-effects, but backing out  
this patch will revert both changes.  Should these be split into  
separate patches to facilitate git bisect?

> This actually fixes a hang situation. Basically, some servers will  
> decide
> that the client is crazy if it tries to destroy an RPC context for  
> which
> they have sent an RPCSEC_GSS_CREDPROBLEM, and so will refuse to talk  
> to it
> for a while.

That seems unfriendly.  Is this server-side behavior mandated?  Why  
wouldn't the server just treat an extraneous context destruction  
request as a successful no-op?

You definitely should include an explanation of this server-side  
behavior in the documenting comment for gss_destroying_context.

> The regression therefor probably was introduced by commit
> 0df7fb74fbb709591301871a38aac7735a1d6583.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>
> net/sunrpc/auth_gss/auth_gss.c |    4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/ 
> auth_gss.c
> index d34f6df..55948cd 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -710,7 +710,7 @@ gss_destroying_context(struct rpc_cred *cred)
> 	struct rpc_task *task;
>
> 	if (gss_cred->gc_ctx == NULL ||
> -			gss_cred->gc_ctx->gc_proc == RPC_GSS_PROC_DESTROY)
> +	    test_and_clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) == 0)
> 		return 0;
>
> 	gss_cred->gc_ctx->gc_proc = RPC_GSS_PROC_DESTROY;
> @@ -720,7 +720,7 @@ gss_destroying_context(struct rpc_cred *cred)
> 	 * by the RPC call or by the put_rpccred() below */
> 	get_rpccred(cred);
>
> -	task = rpc_call_null(gss_auth->client, cred, RPC_TASK_ASYNC);
> +	task = rpc_call_null(gss_auth->client, cred, RPC_TASK_ASYNC| 
> RPC_TASK_SOFT);
> 	if (!IS_ERR(task))
> 		rpc_put_task(task);
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



