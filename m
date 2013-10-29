Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32771 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab3J2Ask (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 20:48:40 -0400
Date: Mon, 28 Oct 2013 20:48:37 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH 1/2] SUNRPC: gss_alloc_msg - choose _either_ a v0 message
 or a v1 message
Message-ID: <20131029004836.GA20393@fieldses.org>
References: <1383001027-62282-1-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1383001027-62282-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 28, 2013 at 06:57:06PM -0400, Trond Myklebust wrote:
> Add the missing 'break' to ensure that we don't corrupt a legacy 'v0' type
> message by appending the 'v1'.

ACK.  Looks like that was a regression from
bd4a3eb15bb42296e61d0fd16f2c7f8cc171b681 "RPCSEC_GSS: Clean up upcall
message allocation" ?

And it looks like it's overwriting, not appending, so the 'v0' case has
probably been broken since then.

--b.

> 
> Cc: Bruce Fields <bfields@fieldses.org>
> Cc: stable@vger.kernel.org
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 084656671d6e..cc24323d3045 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -482,6 +482,7 @@ gss_alloc_msg(struct gss_auth *gss_auth,
>  	switch (vers) {
>  	case 0:
>  		gss_encode_v0_msg(gss_msg);
> +		break;
>  	default:
>  		gss_encode_v1_msg(gss_msg, service_name, gss_auth->target_name);
>  	};
> -- 
> 1.8.3.1
> 
