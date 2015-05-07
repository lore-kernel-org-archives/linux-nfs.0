Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44052 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751135AbbEGHks (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 03:40:48 -0400
Date: Thu, 7 May 2015 09:40:46 +0200
From: Thorsten Kukuk <kukuk@suse.de>
To: Mike Frysinger <vapier@gentoo.org>
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH libtirpc] fix build w/gssapi disabled
Message-ID: <20150507074046.GA13973@suse.de>
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1430983149-22199-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

On Thu, May 07, Mike Frysinger wrote:

> Starting with commit d5259e751111cb108c784b044296185f543fc0be (Add header
> definitions for rpc_gss_*() APIs), the gss headers were pulled in all the
> time leading to build failures like so:
>   CC       libtirpc_la-bindresvport.lo
> In file included from ../tirpc/rpc/svc_auth.h:44:0,
>                  from ../tirpc/rpc/rpc.h:68,
>                  from bindresvport.c:46:
> ../tirpc/rpc/rpcsec_gss.h:38:27: fatal error: gssapi/gssapi.h: No such file or directory

This will not work since this headers will be installed in
/usr/include and other appliations compiled against libtirpc
will never define HAVE_RPCSEC_GSS, thus never see this interfaces.

We need something like the glibc features.h file, which will always
be included and defines, how tirpc was configured.

  Thorsten

> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  tirpc/rpc/svc_auth.h | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/tirpc/rpc/svc_auth.h b/tirpc/rpc/svc_auth.h
> index 44b38bf..998b13a 100644
> --- a/tirpc/rpc/svc_auth.h
> +++ b/tirpc/rpc/svc_auth.h
> @@ -41,6 +41,8 @@
>  #ifndef _RPC_SVC_AUTH_H
>  #define _RPC_SVC_AUTH_H
>  
> +#ifdef HAVE_RPCSEC_GSS
> +
>  #include <rpc/rpcsec_gss.h>
>  
>  typedef struct {
> @@ -51,6 +53,8 @@ typedef struct {
>  	u_int			seq_num;
>  } svc_rpc_gss_parms_t;
>  
> +#endif
> +
>  /*
>   * Interface to server-side authentication flavors.
>   */
> @@ -63,8 +67,10 @@ typedef struct SVCAUTH {
>  		int     (*svc_ah_destroy)(struct SVCAUTH *);
>  		} *svc_ah_ops;
>  	caddr_t svc_ah_private;
> +#ifdef HAVE_RPCSEC_GSS
>  	svc_rpc_gss_parms_t svc_gss_params;
>  	rpc_gss_rawcred_t raw_cred;
> +#endif
>  } SVCAUTH;
>  
>  #define SVCAUTH_WRAP(auth, xdrs, xfunc, xwhere) \
> -- 
> 2.4.0
> 
> 
> ------------------------------------------------------------------------------
> One dashboard for servers and applications across Physical-Virtual-Cloud 
> Widest out-of-the-box monitoring support with 50+ applications
> Performance metrics, stats and reports that give you Actionable Insights
> Deep dive visibility with transaction tracing using APM Insight.
> http://ad.doubleclick.net/ddm/clk/290420510;117567292;y
> _______________________________________________
> Libtirpc-devel mailing list
> Libtirpc-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel

-- 
Thorsten Kukuk, Senior Architect SLES & Common Code Base
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nuernberg, Germany
GF: Felix Imendörffer, Jane Smithard, Jennifer Guild, Dilip Upmanyu, Graham Norton, HRB 21284 (AG Nürnberg)
