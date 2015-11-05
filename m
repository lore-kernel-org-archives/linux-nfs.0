Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:25751 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161471AbbKEOJF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2015 09:09:05 -0500
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [patch 2/2] xprtrdma: checking for NULL instead of IS_ERR()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20151105083952.GB19405@mwanda>
Date: Thu, 5 Nov 2015 09:08:57 -0500
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
Message-Id: <D1BD3A48-A199-45F4-97E3-0FF18BAB4C5F@oracle.com>
References: <20151105083952.GB19405@mwanda>
To: Dan Carpenter <dan.carpenter@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 5, 2015, at 3:39 AM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
> The rpcrdma_create_req() function returns error pointers or success.  It
> never returns NULL.
> 
> Fixes: f531a5dbc451 ('xprtrdma: Pre-allocate backward rpc_rqst and send/receive buffers')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
> index 2dcb44f..97554ca 100644
> --- a/net/sunrpc/xprtrdma/backchannel.c
> +++ b/net/sunrpc/xprtrdma/backchannel.c
> @@ -42,8 +42,8 @@ static int rpcrdma_bc_setup_rqst(struct rpcrdma_xprt *r_xprt,
> 	size_t size;
> 
> 	req = rpcrdma_create_req(r_xprt);
> -	if (!req)
> -		return -ENOMEM;
> +	if (IS_ERR(req))
> +		return PTR_ERR(req);
> 	req->rl_backchannel = true;
> 
> 	size = RPCRDMA_INLINE_WRITE_THRESHOLD(rqst);

—
Chuck Lever



