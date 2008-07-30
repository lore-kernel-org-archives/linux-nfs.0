From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] fs/nfsd/export.c: Adjust error handling code involving
	auth_domain_put
Date: Wed, 30 Jul 2008 13:24:52 -0400
Message-ID: <20080730172451.GF12364@fieldses.org>
References: <Pine.LNX.4.64.0807252207160.1602@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49483 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752703AbYG3RY4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jul 2008 13:24:56 -0400
In-Reply-To: <Pine.LNX.4.64.0807252207160.1602-QfmoRoYWmW9knbxzx/v8hQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 25, 2008 at 10:08:09PM +0200, Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> Once clp is assigned, it never becomes NULL, so we can make a label for it
> in the error handling code.  Because the call to path_lookup follows the
> call to auth_domain_find, its error handling code should jump to this new
> label.

Yes, that looks correct to me; thanks!  Applied.--b.

> 
> The semantic match that finds this problem is as follows:
> (http://www.emn.fr/x-info/coccinelle/)
> 
> // <smpl>
> @r@
> expression x,E;
> statement S;
> position p1,p2,p3;
> @@
> 
> (
> if ((x = auth_domain_find@p1(...)) == NULL || ...) S
> |
> x = auth_domain_find@p1(...)
> ... when != x
> if (x == NULL || ...) S
> )
> <...
> if@p3 (...) { ... when != auth_domain_put(x)
>                   when != if (x) { ... auth_domain_put(x); ...}
>     return@p2 ...;
> }
> ...>
> (
> return x;
> |
> return 0;
> |
> x = E
> |
> E = x
> |
> auth_domain_put(x)
> )
> 
> @exists@
> position r.p1,r.p2,r.p3;
> expression x;
> int ret != 0;
> statement S;
> @@
> 
> * x = auth_domain_find@p1(...)
>   <...
> * if@p3 (...)
>   S
>   ...>
> * return@p2 \(NULL\|ret\);
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> ---
>  fs/nfsd/export.c              |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index 33bfcf0..9dc036f 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -1023,7 +1023,7 @@ exp_export(struct nfsctl_export *nxp)
>  	/* Look up the dentry */
>  	err = path_lookup(nxp->ex_path, 0, &nd);
>  	if (err)
> -		goto out_unlock;
> +		goto out_put_clp;
>  	err = -EINVAL;
>  
>  	exp = exp_get_by_name(clp, nd.path.mnt, nd.path.dentry, NULL);
> @@ -1090,9 +1090,9 @@ finish:
>  		exp_put(exp);
>  	if (fsid_key && !IS_ERR(fsid_key))
>  		cache_put(&fsid_key->h, &svc_expkey_cache);
> -	if (clp)
> -		auth_domain_put(clp);
>  	path_put(&nd.path);
> +out_put_clp:
> +	auth_domain_put(clp);
>  out_unlock:
>  	exp_writeunlock();
>  out:
