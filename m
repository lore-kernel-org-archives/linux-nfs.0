Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59138 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752466AbdCIWBm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Mar 2017 17:01:42 -0500
Date: Thu, 9 Mar 2017 16:54:52 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: andros@netapp.com
Cc: trond.myklebust@primarydata.com, schumaker.anna@gmail.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH Version 5 01/17] SUNRPC handle unsupported RPCSEC_GSS
 security service
Message-ID: <20170309215452.GC12553@fieldses.org>
References: <20170224221953.5502-1-andros@netapp.com>
 <20170224221953.5502-2-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170224221953.5502-2-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I don't think these cases are possible; ->gc_service is set from a
gss_auth->service, which is set to the return value from
gss_pseudoflavor_to_service, which shouldn't return arbitrary values.

Well, maybe there's no great harm in checking anyway, but I probably
wouldn't.

--b.

On Fri, Feb 24, 2017 at 05:19:37PM -0500, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index cdeb1d8..d8395ce 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -1869,6 +1869,11 @@ gss_wrap_req(struct rpc_task *task,
>  	case RPC_GSS_SVC_PRIVACY:
>  		status = gss_wrap_req_priv(cred, ctx, encode, rqstp, p, obj);
>  		break;
> +	default:
> +		status = -EIO;
> +		pr_warn("RPC    Unsupported service level %d\n",
> +			gss_cred->gc_service);
> +		break;
>  	}
>  out:
>  	gss_put_ctx(ctx);
> @@ -1979,6 +1984,11 @@ gss_unwrap_resp(struct rpc_task *task,
>  		if (status)
>  			goto out;
>  		break;
> +	default:
> +		status = -EIO;
> +		pr_warn("RPC    Unsupported service level %d\n",
> +			gss_cred->gc_service);
> +		goto out;
>  	}
>  	/* take into account extra slack for integrity and privacy cases: */
>  	cred->cr_auth->au_rslack = cred->cr_auth->au_verfsize + (p - savedp)
> -- 
> 2.9.3
