Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34135 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935621AbaH0VQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Aug 2014 17:16:50 -0400
Date: Wed, 27 Aug 2014 17:16:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] sunrpc: fix byte-swapping of displayed XID
Message-ID: <20140827211649.GA18393@fieldses.org>
References: <20140822190835.3883.7581.stgit@klimt.1015granger.net>
 <20140822191050.3883.53374.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140822191050.3883.53374.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 22, 2014 at 03:10:50PM -0400, Chuck Lever wrote:
> xprt_lookup_rqst() and bc_send_request() display a byte-swapped XID,
> but receive_cb_reply() does not.

Thanks, applying.--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/svcsock.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index c24a8ff..6ed8729 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1036,7 +1036,7 @@ static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
>  			"%s: Got unrecognized reply: "
>  			"calldir 0x%x xpt_bc_xprt %p xid %08x\n",
>  			__func__, ntohl(calldir),
> -			bc_xprt, xid);
> +			bc_xprt, ntohl(xid));
>  		return -EAGAIN;
>  	}
>  
> 
