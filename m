From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 02/22] Don't expect blocksize to always be 8 when
 calculating padding
Date: Mon, 15 Mar 2010 12:02:10 -0400
Message-ID: <1268668930.2993.91.camel@localhost.localdomain>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>
	 <1268655627-18712-3-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:54272 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965216Ab0COQCP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Mar 2010 12:02:15 -0400
In-Reply-To: <1268655627-18712-3-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-03-15 at 08:20 -0400, steved@redhat.com wrote: 
> From: Kevin Coffman <kwc@citi.umich.edu>
> 
> Allow blocksizes other than 8 when calculating padding
> 
> Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  net/sunrpc/auth_gss/gss_krb5_wrap.c |    5 +----
>  1 files changed, 1 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> index a0660f5..4c14b0a 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
> @@ -13,10 +13,7 @@
>  static inline int
>  gss_krb5_padding(int blocksize, int length)
>  {
> -	/* Most of the code is block-size independent but currently we
> -	 * use only 8: */
> -	BUG_ON(blocksize != 8);
> -	return 8 - (length & 7);
> +	return blocksize - (length & (blocksize - 1));
>  }
>  

What happens if blocksize is not a power of 2?



