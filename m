Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45770 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753645Ab2EUVwk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 May 2012 17:52:40 -0400
Date: Mon, 21 May 2012 17:52:39 -0400
To: Simo Sorce <simo@redhat.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] SUNRPC: conditionally return endtime from
 import_sec_context
Message-ID: <20120521215239.GC28221@fieldses.org>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
 <1337087550-9821-2-git-send-email-simo@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337087550-9821-2-git-send-email-simo@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 09:12:27AM -0400, Simo Sorce wrote:
> We expose this parameter for a future caller.
> It will be used to extract the endtime from the gss-proxy upcall mechanism,
> in order to set the rsc cache expiration time.

Looks fine, thanks.--b.

> 
> Signed-off-by: Simo Sorce <simo@redhat.com>
> ---
>  include/linux/sunrpc/gss_api.h        |    2 ++
>  net/sunrpc/auth_gss/auth_gss.c        |    2 +-
>  net/sunrpc/auth_gss/gss_krb5_mech.c   |    3 +++
>  net/sunrpc/auth_gss/gss_mech_switch.c |    5 +++--
>  net/sunrpc/auth_gss/svcauth_gss.c     |    3 ++-
>  5 files changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/sunrpc/gss_api.h b/include/linux/sunrpc/gss_api.h
> index 332da61cf8b71fc73d802b2609210f46641a9ea1..7bd486d50f0861b45c98e695751c2f92f1b3bdfa 100644
> --- a/include/linux/sunrpc/gss_api.h
> +++ b/include/linux/sunrpc/gss_api.h
> @@ -36,6 +36,7 @@ int gss_import_sec_context(
>  		size_t			bufsize,
>  		struct gss_api_mech	*mech,
>  		struct gss_ctx		**ctx_id,
> +		time_t			*endtime,
>  		gfp_t			gfp_mask);
>  u32 gss_get_mic(
>  		struct gss_ctx		*ctx_id,
> @@ -91,6 +92,7 @@ struct gss_api_ops {
>  			const void		*input_token,
>  			size_t			bufsize,
>  			struct gss_ctx		*ctx_id,
> +			time_t			*endtime,
>  			gfp_t			gfp_mask);
>  	u32 (*gss_get_mic)(
>  			struct gss_ctx		*ctx_id,
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index d3ad81f8da5b79551c36b17a7d53007406946699..836cbecb1947235d38c62eadf79ae96ad73906e6 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -232,7 +232,7 @@ gss_fill_context(const void *p, const void *end, struct gss_cl_ctx *ctx, struct
>  		p = ERR_PTR(-EFAULT);
>  		goto err;
>  	}
> -	ret = gss_import_sec_context(p, seclen, gm, &ctx->gc_gss_ctx, GFP_NOFS);
> +	ret = gss_import_sec_context(p, seclen, gm, &ctx->gc_gss_ctx, NULL, GFP_NOFS);
>  	if (ret < 0) {
>  		p = ERR_PTR(ret);
>  		goto err;
> diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
> index 8eff8c32d1b9b403c2365326c16e44df7c0923e6..329c36b9aa269a414932df86d89650c7a39528fd 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
> @@ -679,6 +679,7 @@ out_err:
>  static int
>  gss_import_sec_context_kerberos(const void *p, size_t len,
>  				struct gss_ctx *ctx_id,
> +				time_t *endtime,
>  				gfp_t gfp_mask)
>  {
>  	const void *end = (const void *)((const char *)p + len);
> @@ -696,6 +697,8 @@ gss_import_sec_context_kerberos(const void *p, size_t len,
>  
>  	if (ret == 0)
>  		ctx_id->internal_ctx_id = ctx;
> +		if (endtime)
> +			*endtime = ctx->endtime;
>  	else
>  		kfree(ctx);
>  
> diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
> index ca8cad8251c7ff1c13c9bff6757e098c4f1cd9b2..b22cc24fac482351876c8f4a6c10d8b203a95045 100644
> --- a/net/sunrpc/auth_gss/gss_mech_switch.c
> +++ b/net/sunrpc/auth_gss/gss_mech_switch.c
> @@ -312,14 +312,15 @@ int
>  gss_import_sec_context(const void *input_token, size_t bufsize,
>  		       struct gss_api_mech	*mech,
>  		       struct gss_ctx		**ctx_id,
> +		       time_t			*endtime,
>  		       gfp_t gfp_mask)
>  {
>  	if (!(*ctx_id = kzalloc(sizeof(**ctx_id), gfp_mask)))
>  		return -ENOMEM;
>  	(*ctx_id)->mech_type = gss_mech_get(mech);
>  
> -	return mech->gm_ops
> -		->gss_import_sec_context(input_token, bufsize, *ctx_id, gfp_mask);
> +	return mech->gm_ops->gss_import_sec_context(input_token, bufsize,
> +						*ctx_id, endtime, gfp_mask);
>  }
>  
>  /* gss_get_mic: compute a mic over message and return mic_token. */
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index f0a0cd4470b7a23ab46a08a68b4ef78c7400db4c..aa1b649749741c82e60f0f528ac645197fd7ab35 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -489,7 +489,8 @@ static int rsc_parse(struct cache_detail *cd,
>  		len = qword_get(&mesg, buf, mlen);
>  		if (len < 0)
>  			goto out;
> -		status = gss_import_sec_context(buf, len, gm, &rsci.mechctx, GFP_KERNEL);
> +		status = gss_import_sec_context(buf, len, gm, &rsci.mechctx,
> +						NULL, GFP_KERNEL);
>  		if (status)
>  			goto out;
>  
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
