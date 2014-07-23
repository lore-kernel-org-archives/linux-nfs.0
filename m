Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47880 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936AbaGWO6z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jul 2014 10:58:55 -0400
Date: Wed, 23 Jul 2014 10:58:54 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Himangi Saraogi <himangi774@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        julia.lawall@lip6.fr
Subject: Re: [PATCH] infsd4: convert comma to semicolon
Message-ID: <20140723145854.GU8438@fieldses.org>
References: <20140723144231.GA3229@himangi-Dell>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140723144231.GA3229@himangi-Dell>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 23, 2014 at 08:12:31PM +0530, Himangi Saraogi wrote:
> Replace a comma between expression statements by a semicolon. This changes
> the semantics of the code, but given the current indentation appears to be
> what is intended.
> 
> A simplified version of the Coccinelle semantic patch that performs this
> transformation is as follows:
> // <smpl>
> @r@
> expression e1,e2;
> @@
> 
>  e1
> -,
> +;
>  e2;
> // </smpl>

Thanks, applying for 3.17.--b.

> 
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>
> ---
>  fs/nfsd/nfs4callback.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 564d723..c393d6c 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -678,7 +678,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
>  				(clp->cl_cred.cr_flavor >= RPC_AUTH_GSS_KRB5))
>  			return -EINVAL;
>  		args.client_name = clp->cl_cred.cr_principal;
> -		args.prognumber	= conn->cb_prog,
> +		args.prognumber	= conn->cb_prog;
>  		args.protocol = XPRT_TRANSPORT_TCP;
>  		args.authflavor = clp->cl_cred.cr_flavor;
>  		clp->cl_cb_ident = conn->cb_ident;
> -- 
> 1.9.1
> 
