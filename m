Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:24523 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031332AbdADVLz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 16:11:55 -0500
Subject: Re: [PATCH Version 3 01/16] SUNRPC handle unsupported
 RPC_GSS_SVC_CHANNEL_PROT
To: <andros@netapp.com>
References: <1482509068-24516-1-git-send-email-andros@netapp.com>
 <1482509068-24516-2-git-send-email-andros@netapp.com>
CC: <bfieldses.org@netapp.com>, <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <c55d67f4-b141-cca9-068b-7e5cffc39e21@Netapp.com>
Date: Wed, 4 Jan 2017 16:11:45 -0500
MIME-Version: 1.0
In-Reply-To: <1482509068-24516-2-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="windows-1252"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Andy,

On 12/23/2016 11:04 AM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 16cea00..96135da 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -1869,6 +1869,11 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
>  	case RPC_GSS_SVC_PRIVACY:
>  		status = gss_wrap_req_priv(cred, ctx, encode, rqstp, p, obj);
>  		break;
> +	case RPC_GSS_SVC_CHANNEL_PROT:

Would it make more sense to simply use "default:" here instead?  That way we do the right thing if an invalid value is somehow set for gc_service.

> +		status = -EIO;
> +		pr_warn("RPC    Unsupported service level %d\n",
> +			gss_cred->gc_service);
> +		break;
>  	}
>  out:
>  	gss_put_ctx(ctx);
> @@ -1979,6 +1984,11 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
>  		if (status)
>  			goto out;
>  		break;
> +	case RPC_GSS_SVC_CHANNEL_PROT:
> +		status = -EIO;
> +		pr_warn("RPC    Unsupported service level %d\n",
> +			gss_cred->gc_service);

Same question here.

Thanks,
Anna

> +		goto out;
>  	}
>  	/* take into account extra slack for integrity and privacy cases: */
>  	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + (p - savedp)
> 
