From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [pnfs] [RFC 02/39] nfs41: Skip past the RPC call direction
Date: Wed, 03 Jun 2009 17:30:24 -0400
Message-ID: <1244064624.5603.53.camel@heimdal.trondhjem.org>
References: <49FA3180.5030404@panasas.com>
	 <1241133549-348-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10035 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbZFCVaj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 17:30:39 -0400
In-Reply-To: <1241133549-348-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-01 at 02:19 +0300, Benny Halevy wrote:
> From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> 
> xs_tcp_read_calldir() is now responsible for reading the RPC call
> direction and determining whether it is a reply or a callback request.
> The call to xdr_skb_read_bits() inside xs_tcp_read_calldir() moves the
> xdr_skb_reader offset past the RPC call direction (offset should be
> equal to 8).  Therefore xs_tcp_read_common() called from
> xs_tcp_ready_reply() should be copying the TCP buffer starting past the
> RPC call direction.  It is now necessary to read the RPC call direction
> earlier to determine whether to call the reply handler or the callback
> handler.
> 
> call_verify() should therefore skip past the XID and call/reply flag.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  net/sunrpc/clnt.c |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index d00e813..76d7d46 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1390,13 +1390,14 @@ rpc_verify_header(struct rpc_task *task)
>  	}
>  	if ((len -= 3) < 0)
>  		goto out_overflow;
> -	p += 1;	/* skip XID */
>  
> -	if ((n = ntohl(*p++)) != RPC_REPLY) {
> -		dprintk("RPC: %5u %s: not an RPC reply: %x\n",
> -				task->tk_pid, __func__, n);
> -		goto out_garbage;
> -	}
> +	/*
> +	 * Skip the XID and call direction.
> +	 * The underlying transport has read the XID and RPC call direction
> +	 * to determine this is an RPC reply.
> +	 */
> +	p += 2;
> +
>  	if ((n = ntohl(*p++)) != RPC_MSG_ACCEPTED) {
>  		if (--len < 0)
>  			goto out_overflow;

Err... No... The above comment is true only for the case of TCP. Why
don't you simply copy the RPC call direction into the buffer?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
