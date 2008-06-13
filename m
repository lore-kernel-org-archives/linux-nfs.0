From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 05/37] SUNRPC: An ENOMEM error from call_encode is
	always fatal
Date: Fri, 13 Jun 2008 17:10:58 -0400
Message-ID: <20080613211058.GO8501@fieldses.org>
References: <20080612192159.24528.43756.stgit@localhost.localdomain> <20080612192200.24528.71693.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59953 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754358AbYFMVK7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 17:10:59 -0400
In-Reply-To: <20080612192200.24528.71693.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 12, 2008 at 03:22:00PM -0400, Trond Myklebust wrote:
> The special 'ENOMEM' case that was previously flagged as non-fatal is
> bogus: auth_gss always returns EAGAIN for non-fatal errors, and may in fact
> return ENOMEM in the special case where xdr_buf_read_netobj runs out of
> preallocated buffer space (invariably a _fatal_ error, since there is no
> provision for preallocating larger buffers).

For a minute I was worried about the krb5p code that tries to do some
allocations that may fail, but you're right, it takes care to return
EAGAIN in that case (in alloc_enc_pages).  Makes sense to me.

--b.

> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  net/sunrpc/clnt.c |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 9503b4c..1af4f16 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -888,10 +888,6 @@ call_encode(struct rpc_task *task)
>  
>  	task->tk_status = rpcauth_wrap_req(task, encode, req, p,
>  			task->tk_msg.rpc_argp);
> -	if (task->tk_status == -ENOMEM) {
> -		/* XXX: Is this sane? */
> -		task->tk_status = -EAGAIN;
> -	}
>  }
>  
>  /*
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
