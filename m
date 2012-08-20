Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:45873 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756583Ab2HTWgq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 18:36:46 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 20 Aug 2012 18:36:43 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 36DAE38C8045
	for <linux-nfs@vger.kernel.org>; Mon, 20 Aug 2012 18:36:24 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7KMZ7fZ153468
	for <linux-nfs@vger.kernel.org>; Mon, 20 Aug 2012 18:35:07 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7KMZ7ep018348
	for <linux-nfs@vger.kernel.org>; Mon, 20 Aug 2012 18:35:07 -0400
Date: Mon, 20 Aug 2012 17:35:06 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Subject: Re: [PATCH] svcrpc: sends on closed socket should stop immediately
Message-ID: <20120820223506.GB30155@us.ibm.com>
References: <20120820215210.GJ5779@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120820215210.GJ5779@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields [bfields@fieldses.org] wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> svc_tcp_sendto sets XPT_CLOSE if we fail to transmit the entire reply.
> However, the XPT_CLOSE won't be acted on immediately.  Meanwhile other
> threads could send further replies before the socket is really shut
> down.  This can manifest as data corruption: for example, if a truncated
> read reply is followed by another rpc reply, that second reply will look
> to the client like further read data.
> 
> Symptoms were data corruption preceded by svc_tcp_sendto logging
> something like
> 
> 	kernel: rpc-srv/tcp: nfsd: sent only 963696 when sending 1048708 bytes - shutting down socket
> 
> Cc: stable@vger.kernel.org
> Reported-by: Malahal Naineni <malahal@us.ibm.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  net/sunrpc/svc_xprt.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Can anyone see a reason *not* to fail the send on a socket marked with
> XPT_CLOSE?
> 
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 88f2bf6..0d693a8 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -794,7 +794,8 @@ int svc_send(struct svc_rqst *rqstp)
> 
>  	/* Grab mutex to serialize outgoing data. */
>  	mutex_lock(&xprt->xpt_mutex);
> -	if (test_bit(XPT_DEAD, &xprt->xpt_flags))
> +	if (test_bit(XPT_DEAD, &xprt->xpt_flags)
> +			|| test_bit(XPT_CLOSE, &xprt->xpt_flags))
>  		len = -ENOTCONN;
>  	else
>  		len = xprt->xpt_ops->xpo_sendto(rqstp);
> -- 
> 1.7.9.5

Instrumented svc_send_common() to send partial read replies, was able
reproduce the corruption easily. After applying this patch, I wasn't
able to reproduce the corruption. The patch looks good.

Reviewed-by: Malahal Naineni <malahal@us.ibm.com>
Tested-by: Malahal Naineni <malahal@us.ibm.com>

