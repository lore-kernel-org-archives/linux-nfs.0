Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53130 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750876AbaGPU6r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2014 16:58:47 -0400
Date: Wed, 16 Jul 2014 16:58:46 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: xdr_get_next_encode_buffer should be declared
 static
Message-ID: <20140716205846.GE2397@fieldses.org>
References: <1405202462-50244-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405202462-50244-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 12, 2014 at 06:01:02PM -0400, Trond Myklebust wrote:
> Quell another sparse warning.

I think jlayton sent you the same fix with his set of sunrpc sparse
fixes--could you just take that instead?

(Or I can take this if you still want, I don't really care.)

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/xdr.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index 23fb4e75e245..290af97bf6f9 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -509,7 +509,8 @@ void xdr_commit_encode(struct xdr_stream *xdr)
>  }
>  EXPORT_SYMBOL_GPL(xdr_commit_encode);
>  
> -__be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr, size_t nbytes)
> +static __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
> +		size_t nbytes)
>  {
>  	static __be32 *p;
>  	int space_left;
> -- 
> 1.9.3
> 
