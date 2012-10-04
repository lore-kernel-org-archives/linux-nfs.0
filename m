Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-out.m-online.net ([212.18.0.10]:35807 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964926Ab2JDOZb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Oct 2012 10:25:31 -0400
From: Marek Vasut <marex@denx.de>
To: Fabio Estevam <fabio.estevam@freescale.com>
Subject: Re: [PATCH] net: sunrpc: xdr: Change message to pr_debug level
Date: Thu, 4 Oct 2012 16:25:23 +0200
Cc: davem@davemloft.net, Trond.Myklebust@netapp.com, netdev@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <1349360495-29325-1-git-send-email-fabio.estevam@freescale.com>
In-Reply-To: <1349360495-29325-1-git-send-email-fabio.estevam@freescale.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Message-Id: <201210041625.23710.marex@denx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Fabio Estevam,

> commit 49f6189 (SUNRPC: Optimise away unnecessary data moves in
> xdr_align_pages) has added a pr_info that floods dmesg when booting via
> NFS.
> 
> There is also a note in the commit log: "Warning! Contains debugging
> printks!"
> 
> ,so change it to pr_debug instead.
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Reviewed-by: Marek Vasut <marex@denx.de>

> ---
>  net/sunrpc/xdr.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index e30842b..6983efc 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -749,7 +749,7 @@ static unsigned int xdr_align_pages(struct xdr_stream
> *xdr, unsigned int len) xdr_shrink_pagelen(buf, buf->page_len - len);
>  		xdr->nwords = XDR_QUADLEN(buf->len - cur);
>  	} else
> -		pr_info("%s: Optimised away a data move!\n", __func__);
> +		pr_debug("%s: Optimised away a data move!\n", __func__);
>  	return len;
>  }

Best regards,
Marek Vasut
