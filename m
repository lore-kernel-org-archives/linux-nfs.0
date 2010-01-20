From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [RFC][PATCH] nfs: don't assume fscache_acquire_cookie will
 always succeed
Date: Wed, 20 Jan 2010 16:35:06 -0500
Message-ID: <1264023306.7799.9.camel@localhost>
References: <4B56F565.7080104@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Howells <dhowells@redhat.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43963 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752998Ab0ATVf5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jan 2010 16:35:57 -0500
In-Reply-To: <4B56F565.7080104@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-01-20 at 17:51 +0530, Suresh Jayaraman wrote: 
> We seem to be assuming fscache_acquire_cookie will always succeed and will
> obtain a valid cookie. But, under low memory conditions kmem_cache_alloc
> could fail and that would leave nfsi->fscache being set to NULL.
> 
> This could lead to a possibility of a page with PG_fscache flag set but
> cookie not set(i.e. NULL). This inconsistency could trigger a kernel BUG in
> nfs_fscache_release_page() and other places as we do BUG_ON(!cookie), I think.
> 
> I'm aware that there are other places where we would need such checks, but
> wanted to validate this patch before getting on to them.
> 
> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
> ---
> 
>  fs/nfs/client.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index ee77713..7776e8a 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -155,6 +155,8 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
>  		clp->cl_machine_cred = cred;
>  
>  	nfs_fscache_get_client_cookie(clp);
> +	if (!clp->fscache)
> +		goto error_cleanup;
>  
>  	return clp;
>  

That looks like it will always fail when mounting without -ofscache
and/or compiling without CONFIG_NFS_FSCACHE.

It seems like a better idea to have nfs_fscache_get_client_cookie()
explicitly set clp->fscache to ERR_PTR(-ENOMEM) value if the
fscache_acquire_cookie fails.

Cheers
  Trond
