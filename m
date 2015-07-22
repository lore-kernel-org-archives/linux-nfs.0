Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35630 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173AbbGVUkw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 16:40:52 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] SUNRPC: Fix a backchannel deadlock
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1437597373-19455-1-git-send-email-trond.myklebust@primarydata.com>
Date: Wed, 22 Jul 2015 16:40:47 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0E5E2AA6-6FCF-4A0E-94E3-91A2D529B58B@oracle.com>
References: <1437597373-19455-1-git-send-email-trond.myklebust@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-


On Jul 22, 2015, at 4:36 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> xprt_alloc_bc_request() cannot call xprt_free_bc_request() without
> deadlocking, since it already holds the xprt->bc_pa_lock.
> 
> Reported-by: Chuck Lever <chuck.lever@oracle.com>
> Fixes: 0d2a970d0ae55 ("SUNRPC: Fix a backchannel race")
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

That’s exactly what I did as a basic fix, and I can report that
it successfully avoids the deadlock.

If xprt_alloc_bc_request() no longer calls xprt_free_bc_request(),
are the accounting changes introduced by 0d2a970d0ae55 still
necessary?


> ---
> net/sunrpc/backchannel_rqst.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
> index 9825ff0f91d6..5a3b50aec397 100644
> --- a/net/sunrpc/backchannel_rqst.c
> +++ b/net/sunrpc/backchannel_rqst.c
> @@ -240,8 +240,8 @@ static struct rpc_rqst *xprt_alloc_bc_request(struct rpc_xprt *xprt, __be32 xid)
> 		req = xprt_alloc_bc_req(xprt, GFP_ATOMIC);
> 		if (!req)
> 			goto not_found;
> -		/* Note: this 'free' request adds it to xprt->bc_pa_list */
> -		xprt_free_bc_request(req);
> +		list_add_tail(&req->rq_bc_pa_list, &xprt->bc_pa_list);
> +		xprt->bc_alloc_count++;
> 	}
> 	req = list_first_entry(&xprt->bc_pa_list, struct rpc_rqst,
> 				rq_bc_pa_list);
> -- 
> 2.4.3
> 

--
Chuck Lever



