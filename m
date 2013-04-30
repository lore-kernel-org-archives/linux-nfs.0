Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37663 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753781Ab3D3WOd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Apr 2013 18:14:33 -0400
Date: Tue, 30 Apr 2013 18:14:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Cc: Trond.Myklebust@netapp.com, ebiederm@xmission.com,
        skinsbursky@parallels.com, jlayton@redhat.com, simo@redhat.com,
        yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcauth_gss: fix error return code in rsc_parse()
Message-ID: <20130430221424.GE30768@fieldses.org>
References: <CAPgLHd92VAMpeRhdmWSy_SdPwJqeVPDike6pCyV9b_WEPmK0gg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAPgLHd92VAMpeRhdmWSy_SdPwJqeVPDike6pCyV9b_WEPmK0gg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applying, thanks.--b.

On Thu, Apr 18, 2013 at 10:49:09AM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as returned elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  net/sunrpc/auth_gss/svcauth_gss.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 5ead605..c2156fb 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -505,8 +505,10 @@ static int rsc_parse(struct cache_detail *cd,
>  		len = qword_get(&mesg, buf, mlen);
>  		if (len > 0) {
>  			rsci.cred.cr_principal = kstrdup(buf, GFP_KERNEL);
> -			if (!rsci.cred.cr_principal)
> +			if (!rsci.cred.cr_principal) {
> +				status = -ENOMEM;
>  				goto out;
> +			}
>  		}
>  
>  	}
> 
