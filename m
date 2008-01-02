From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: add newline to kernel warning message in auth_gss
	code
Date: Wed, 02 Jan 2008 14:04:56 -0500
Message-ID: <1199300696.16403.0.camel@heimdal.trondhjem.org>
References: <Xine.LNX.4.64.0712261117290.16520@us.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:51079 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934AbYABTFD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jan 2008 14:05:03 -0500
In-Reply-To: <Xine.LNX.4.64.0712261117290.16520-RC8Ws/H8zzudju81dFSl6rpzq4S04n8Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2007-12-26 at 11:20 +1100, James Morris wrote:
> Add newline to kernel warning message in gss_create().
> 
> Signed-off-by: James Morris <jmorris@namei.org>
> ---
>  net/sunrpc/auth_gss/auth_gss.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index a6e57d1..1f2d85e 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -625,7 +625,7 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
>  	err = -EINVAL;
>  	gss_auth->mech = gss_mech_get_by_pseudoflavor(flavor);
>  	if (!gss_auth->mech) {
> -		printk(KERN_WARNING "%s: Pseudoflavor %d not found!",
> +		printk(KERN_WARNING "%s: Pseudoflavor %d not found!\n",
>  				__FUNCTION__, flavor);
>  		goto err_free;
>  	}

Thanks James! Applied...

Trond

