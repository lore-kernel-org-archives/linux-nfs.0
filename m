Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49708 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959Ab1CDVZC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2011 16:25:02 -0500
Subject: Re: [PATCH] nfs4: Ensure that ACL pages sent over NFS were not
 allocated from the slab (v2)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Neil Horman <nhorman@tuxdriver.com>
Cc: linux-nfs@vger.kernel.org, security@kernel.org,
        Jeff Layton <jlayton@redhat.com>
In-Reply-To: <1299272960-16582-1-git-send-email-nhorman@tuxdriver.com>
References: <1299266730.2901.15.camel@heimdal.trondhjem.org>
	 <1299272960-16582-1-git-send-email-nhorman@tuxdriver.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Mar 2011 16:25:00 -0500
Message-ID: <1299273900.2901.49.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-03-04 at 16:09 -0500, Neil Horman wrote: 
> +static int buf_to_pages_noslab(const void *buf, size_t buflen,
> +		struct page **pages, unsigned int *pgbase)
> +{
> +	struct page *newpage, **spages;
> +	int rc = 0;
> +	size_t len;
> +	spages = pages;
> +
> +	do {
> +		len = min(PAGE_CACHE_SIZE, buflen);
> +		newpage = alloc_page(GFP_KERNEL);
> +
> +		if (newpage == NULL)
> +			goto unwind;
> +		memcpy(page_address(newpage), buf, len);
> +                buf += len;
> +                buflen -= len;
> +		*(pages++) = newpage;

Nit: the brackets aren't needed here.

> +		rc++;
> +	} while (buflen != 0);
> +
> +	*pgbase = 0;
> +	return rc;
> +
> +unwind:
> +	for(; rc > 0; rc--)
> +		__free_page(spages[rc-1]);
> +	return -ENOMEM;
> +}
> +
>  struct nfs4_cached_acl {
>  	int cached;
>  	size_t len;
> @@ -3420,13 +3451,23 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
>  		.rpc_argp	= &arg,
>  		.rpc_resp	= &res,
>  	};
> -	int ret;
> +	int ret, i;
>  
>  	if (!nfs4_server_supports_acls(server))
>  		return -EOPNOTSUPP;
> +	i = buf_to_pages_noslab(buf, buflen, arg.acl_pages, &arg.acl_pgbase);

NIT: arg.acl_pgbase is already initialised to 0.

> +	if (i < 0)
> +		return i;
>  	nfs_inode_return_delegation(inode);
> -	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
>  	ret = nfs4_call_sync(server, &msg, &arg, &res, 1);
> +
> +	/*
> +	 * Free each page after tx, so the only ref left is 
> +	 * held by the network stack
> +	 */
> +	for (; i > 0; i--)
> +		put_page(pages[i-1]);
> +
>  	/*
>  	 * Acl update can result in inode attribute update.
>  	 * so mark the attribute cache invalid.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

