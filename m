From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] nfsd: potential ERR_PTR dereference on exp_export()
	error paths.
Date: Thu, 22 Apr 2010 11:59:48 -0400
Message-ID: <20100422155948.GE5926@fieldses.org>
References: <20100422093059.GJ29647@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47017 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755913Ab0DVP7v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 11:59:51 -0400
In-Reply-To: <20100422093059.GJ29647@bicker>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 22, 2010 at 11:30:59AM +0200, Dan Carpenter wrote:
> We "goto finish" from several places where "exp" is an ERR_PTR.  Also I 
> changed the check for "fsid_key" so that it was consistent with the check
> I added.

OK, thanks; applied.

--b.

> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
> index 872a5ef..bfe6f3f 100644
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -1071,9 +1071,9 @@ exp_export(struct nfsctl_export *nxp)
>  		err = 0;
>  finish:
>  	kfree(new.ex_pathname);
> -	if (exp)
> +	if (!IS_ERR_OR_NULL(exp))
>  		exp_put(exp);
> -	if (fsid_key && !IS_ERR(fsid_key))
> +	if (!IS_ERR_OR_NULL(fsid_key))
>  		cache_put(&fsid_key->h, &svc_expkey_cache);
>  	path_put(&path);
>  out_put_clp:
