Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58168 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932225AbcFOU1Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2016 16:27:16 -0400
Date: Wed, 15 Jun 2016 16:27:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH RESEND] sunrpc: add gss minor status to
 svcauth_gss_proxy_init
Message-ID: <20160615202716.GD3848@fieldses.org>
References: <1465998031-53086-1-git-send-email-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1465998031-53086-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 15, 2016 at 09:40:31AM -0400, Scott Mayhew wrote:
> GSS-Proxy doesn't produce very much debug logging at all.  Printing out
> the gss minor status will aid in troubleshooting if the
> GSS_Accept_sec_context upcall fails.

Thanks.  It'd be nice to have some better debugging tools for gss-proxy
communication, though.  Either logging in gssd, or maybe a tool that
traced gss-proxy IO and helped interpret it?

Anyway, no harm to this, I guess, applying.

--b.

> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  net/sunrpc/auth_gss/svcauth_gss.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index e085f5a..1d28181 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -1230,8 +1230,9 @@ static int svcauth_gss_proxy_init(struct svc_rqst *rqstp,
>  	if (status)
>  		goto out;
>  
> -	dprintk("RPC:       svcauth_gss: gss major status = %d\n",
> -			ud.major_status);
> +	dprintk("RPC:       svcauth_gss: gss major status = %d "
> +			"minor status = %d\n",
> +			ud.major_status, ud.minor_status);
>  
>  	switch (ud.major_status) {
>  	case GSS_S_CONTINUE_NEEDED:
> -- 
> 2.4.11
