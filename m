Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38584 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755815AbaAFSt1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 13:49:27 -0500
Date: Mon, 6 Jan 2014 13:49:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: fix a memory leak for tcp NFSv4.1 backchannel
Message-ID: <20140106184926.GC31764@fieldses.org>
References: <52CA7862.1020203@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52CA7862.1020203@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 06, 2014 at 05:33:22PM +0800, Kinglong Mee wrote:
> xs_setup_bc_tcp may return an existing xprt with non-NULL servername.
> xprt_create_transport should not kstrdup servername for it.
> Otherwise, those memory for servername will be leaked.

OK.  Applying to my tree if Trond has no objection.

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  net/sunrpc/xprt.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index ddd198e..6fa966f 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1339,7 +1339,11 @@ found:
>  		xprt_destroy(xprt);
>  		return ERR_PTR(-EINVAL);
>  	}
> -	xprt->servername = kstrdup(args->servername, GFP_KERNEL);
> +
> +	/* servername may not be NULL for tcp NFSv4.1 backchannel */
> +	if (xprt->servername == NULL)
> +		xprt->servername = kstrdup(args->servername, GFP_KERNEL);
> +
>  	if (xprt->servername == NULL) {
>  		xprt_destroy(xprt);
>  		return ERR_PTR(-ENOMEM);
> -- 
> 1.8.4.2
