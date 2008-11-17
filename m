From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 01/85] sunrpc: get rid of rpc_rqst.rq_bufsize
Date: Mon, 17 Nov 2008 15:17:57 +0200
Message-ID: <49216F05.4090706@panasas.com>
References: <1226347159-6561-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.26]:7440 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbYKQNSF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 08:18:05 -0500
Received: by qw-out-2122.google.com with SMTP id 3so1177320qwe.37
        for <linux-nfs@vger.kernel.org>; Mon, 17 Nov 2008 05:18:04 -0800 (PST)
In-Reply-To: <1226347159-6561-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 21:59 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> rq_bufsize is not used.
> 
> Signed-off-by: Mike Sager <Mike.Sager@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  include/linux/sunrpc/xprt.h |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 4d80a11..11fc71d 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -76,8 +76,7 @@ struct rpc_rqst {
>  	struct list_head	rq_list;
>  
>  	__u32 *			rq_buffer;	/* XDR encode buffer */
> -	size_t			rq_bufsize,

review 11-14: this was used in the past as a sanity check.
find out when/why this functionality was ripped out.

> -				rq_callsize,
> +	size_t			rq_callsize,
>  				rq_rcvsize;
>  
>  	struct xdr_buf		rq_private_buf;		/* The receive buffer
> -- 
> 1.6.0.1
> 
