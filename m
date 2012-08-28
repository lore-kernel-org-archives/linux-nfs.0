Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59497 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942Ab2H1Boo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Aug 2012 21:44:44 -0400
Date: Mon, 27 Aug 2012 21:44:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/6] fs/nfsd/nfs4idmap.c: adjust inconsistent IS_ERR
 and PTR_ERR
Message-ID: <20120828014436.GB20035@fieldses.org>
References: <1345924629-16584-1-git-send-email-Julia.Lawall@lip6.fr>
 <1345924629-16584-2-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1345924629-16584-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 25, 2012 at 09:57:04PM +0200, Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Change the call to PTR_ERR to access the value just tested by IS_ERR.

Applying for 3.7, thanks.--b.

> 
> The semantic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> expression e,e1;
> @@
> 
> (
> if (IS_ERR(e)) { ... PTR_ERR(e) ... }
> |
> if (IS_ERR(e=e1)) { ... PTR_ERR(e) ... }
> |
> *if (IS_ERR(e))
>  { ...
> *  PTR_ERR(e1)
>    ... }
> )
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
>  fs/nfsd/nfs4idmap.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
> index fdc91a6..11df4ac 100644
> --- a/fs/nfsd/nfs4idmap.c
> +++ b/fs/nfsd/nfs4idmap.c
> @@ -478,7 +478,7 @@ nfsd_idmap_init(struct net *net)
>  		goto destroy_idtoname_cache;
>  	nn->nametoid_cache = cache_create_net(&nametoid_cache_template, net);
>  	if (IS_ERR(nn->nametoid_cache)) {
> -		rv = PTR_ERR(nn->idtoname_cache);
> +		rv = PTR_ERR(nn->nametoid_cache);
>  		goto unregister_idtoname_cache;
>  	}
>  	rv = cache_register_net(nn->nametoid_cache, net);
> 
