Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:56186 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758014Ab0IGSgL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 14:36:11 -0400
Subject: Re: [PATCH 2/2]gss:spkm3 miss returning error to caller when
 import security context
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4C846223.5050609@cn.fujitsu.com>
References: <4C846162.40305@cn.fujitsu.com>
	 <4C846223.5050609@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Sep 2010 14:36:06 -0400
Message-ID: <1283884566.2788.61.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-09-06 at 11:38 +0800, Bian Naimeng wrote:
> spkm3 miss returning error to up layer when import security context, 
> it may be return ok though it has failed to import security context.
> 
> Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>
> 
> 
> ---
>  net/sunrpc/auth_gss/gss_spkm3_mech.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_spkm3_mech.c b/net/sunrpc/auth_gss/gss_spkm3_mech.c
> index dc3f1f5..adade3d 100644
> --- a/net/sunrpc/auth_gss/gss_spkm3_mech.c
> +++ b/net/sunrpc/auth_gss/gss_spkm3_mech.c
> @@ -100,6 +100,7 @@ gss_import_sec_context_spkm3(const void *p, size_t len,
>  	if (version != 1) {
>  		dprintk("RPC:       unknown spkm3 token format: "
>  				"obsolete nfs-utils?\n");
> +		p = ERR_PTR(-EINVAL);
>  		goto out_err_free_ctx;
>  	}
>  
> @@ -135,8 +136,10 @@ gss_import_sec_context_spkm3(const void *p, size_t len,
>  	if (IS_ERR(p))
>  		goto out_err_free_intg_alg;
>  
> -	if (p != end)
> +	if (p != end) {
> +		p = ERR_PTR(-EFAULT);
>  		goto out_err_free_intg_key;
> +	}
>  
>  	ctx_id->internal_ctx_id = ctx;
>  
> -- 
> 1.7.0
> 
> 

Ditto. Although, I'm wondering if we shouldn't just start ripping out
the spkm stuff at this point. It is pretty much dead as far as the IETF
is concerned.

Cheers
  Trond

