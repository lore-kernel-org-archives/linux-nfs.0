Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751123AbbKCJXV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2015 04:23:21 -0500
Subject: Re: [Libtirpc-devel] [PATCH] handle_reply: Don't use the xp_auth
 pointer directly
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
References: <1446502376-8252-1-git-send-email-steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56387D08.4070900@RedHat.com>
Date: Tue, 3 Nov 2015 04:23:20 -0500
MIME-Version: 1.0
In-Reply-To: <1446502376-8252-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/02/2015 05:12 PM, Steve Dickson wrote:
> In the latest libtirpc version to access the xp_auth
> one must use the SVC_XP_AUTH macro. To be backwards
> compatible a couple ifdefs were added to use the
> macro when it exists.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.

> ---
>  src/rpcb_svc_com.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/src/rpcb_svc_com.c b/src/rpcb_svc_com.c
> index 4ae93f1..22d6c84 100644
> --- a/src/rpcb_svc_com.c
> +++ b/src/rpcb_svc_com.c
> @@ -1295,10 +1295,17 @@ handle_reply(int fd, SVCXPRT *xprt)
>  	a.rmt_localvers = fi->versnum;
>  
>  	xprt_set_caller(xprt, fi);
> +#if defined(SVC_XP_AUTH)
> +	SVC_XP_AUTH(xprt) = svc_auth_none;
> +#else 
>  	xprt->xp_auth = &svc_auth_none;
> +#endif
>  	svc_sendreply(xprt, (xdrproc_t) xdr_rmtcall_result, (char *) &a);
> +#if !defined(SVC_XP_AUTH)
>  	SVCAUTH_DESTROY(xprt->xp_auth);
>  	xprt->xp_auth = NULL;
> +#endif
> +
>  done:
>  	if (buffer)
>  		free(buffer);
> 
