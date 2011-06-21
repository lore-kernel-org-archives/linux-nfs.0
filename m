Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41381 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756665Ab1FUWoU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2011 18:44:20 -0400
Date: Tue, 21 Jun 2011 18:44:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
        linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com, neilb@suse.de,
        davem@davemloft.net
Subject: Re: [PATCH] svcsock.c: include sunrpc.h to quite sparse noise
Message-ID: <20110621224418.GB28047@fieldses.org>
References: <201106201754.51704.hartleys@visionengravers.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <201106201754.51704.hartleys@visionengravers.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jun 20, 2011 at 05:54:51PM -0700, H Hartley Sweeten wrote:
> Include the private header sunrpc.h to pickup the declaration of the
> function svc_send_common to quiet the following sparse noise:
> 
> warning: symbol 'svc_send_common' was not declared. Should it be static?

Thanks, applying for 3.1--b.

> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: Neil Brown <neilb@suse.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> 
> ---
> 
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index af04f77..f2cb5b8 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -51,6 +51,8 @@
>  #include <linux/sunrpc/stats.h>
>  #include <linux/sunrpc/xprt.h>
>  
> +#include "sunrpc.h"
> +
>  #define RPCDBG_FACILITY	RPCDBG_SVCXPRT
>  
>  
