Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51059 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760080Ab0LNVT1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 16:19:27 -0500
Date: Tue, 14 Dec 2010 16:19:22 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Joe Perches <joe@perches.com>
Cc: Neil Brown <neilb@suse.de>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] net/sunrpc/auth_gss/gss_krb5_crypto.c: Use normal
 negative error value return
Message-ID: <20101214211922.GJ24828@fieldses.org>
References: <1289786891.16461.102.camel@Joe-Laptop>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1289786891.16461.102.camel@Joe-Laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Nov 14, 2010 at 06:08:11PM -0800, Joe Perches wrote:
> And remove unnecessary double semicolon too.
> 
> No effect to code, as test is != 0.

Hm, the error return's actually ignored.  But OK.  Applying to my tree
for 2.6.38 assuming nobody else has picked it up.

--b.

> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/sunrpc/auth_gss/gss_krb5_crypto.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> index 75ee993..9576f35 100644
> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
> @@ -137,7 +137,7 @@ arcfour_hmac_md5_usage_to_salt(unsigned int usage, u8 salt[4])
>  		ms_usage = 13;
>  		break;
>  	default:
> -		return EINVAL;;
> +		return -EINVAL;
>  	}
>  	salt[0] = (ms_usage >> 0) & 0xff;
>  	salt[1] = (ms_usage >> 8) & 0xff;
> 
> 
