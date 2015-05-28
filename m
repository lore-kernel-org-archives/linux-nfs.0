Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53725 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909AbbE1TwG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 May 2015 15:52:06 -0400
Date: Thu, 28 May 2015 15:52:05 -0400
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 33/45] nfsd: Keep list of acls to dispose of in
 compoundargs
Message-ID: <20150528195205.GC31663@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <4f0168389120bf67cf69ce4ac7bb8ce878aa0f5d.1429868795.git.agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4f0168389120bf67cf69ce4ac7bb8ce878aa0f5d.1429868795.git.agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2015 at 01:04:30PM +0200, Andreas Gruenbacher wrote:
> We will decode acls in requests into richacls; those need to be richacl_put()
> at the end of the request instead of kfree()d; this allows the vfs to cache
> them whenever possible.
> 
> NOTE: If we allow only a single acl per request, we can get rid of the list
> here.

Technically I guess we're supposed to allow it, and maybe someday
someone will come up with a reason....  So I'm not inclined to drop the
list.

--b.

> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/nfsd/nfs4xdr.c | 26 ++++++++++++++++++++++++++
>  fs/nfsd/xdr4.h    |  6 ++++++
>  2 files changed, 32 insertions(+)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index e2d602d..f25d1e7 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -39,6 +39,7 @@
>  #include <linux/utsname.h>
>  #include <linux/pagemap.h>
>  #include <linux/sunrpc/svcauth_gss.h>
> +#include <linux/richacl.h>
>  
>  #include "idmap.h"
>  #include "acl.h"
> @@ -195,6 +196,24 @@ svcxdr_tmpalloc(struct nfsd4_compoundargs *argp, u32 len)
>  	return tb->buf;
>  }
>  
> +static struct richacl *
> +svcxdr_alloc_richacl(struct nfsd4_compoundargs *argp, u32 nace)
> +{
> +	struct svcxdr_richacl *acls;
> +
> +	acls = kmalloc(sizeof(*acls), GFP_KERNEL);
> +	if (!acls)
> +		return NULL;
> +	acls->acl = richacl_alloc(nace, GFP_KERNEL);
> +	if (!acls->acl) {
> +		kfree(acls);
> +		return NULL;
> +	}
> +	acls->next = argp->acls;
> +	argp->acls = acls;
> +	return acls->acl;
> +}
> +
>  /*
>   * For xdr strings that need to be passed to other kernel api's
>   * as null-terminated strings.
> @@ -4390,6 +4409,12 @@ int nfsd4_release_compoundargs(void *rq, __be32 *p, void *resp)
>  		args->to_free = tb->next;
>  		kfree(tb);
>  	}
> +	while (args->acls) {
> +		struct svcxdr_richacl *acls = args->acls;
> +		args->acls = acls->next;
> +		richacl_put(acls->acl);
> +		kfree(acls);
> +	}
>  	return 1;
>  }
>  
> @@ -4408,6 +4433,7 @@ nfs4svc_decode_compoundargs(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_comp
>  	args->pagelen = rqstp->rq_arg.page_len;
>  	args->tmpp = NULL;
>  	args->to_free = NULL;
> +	args->acls = NULL;
>  	args->ops = args->iops;
>  	args->rqstp = rqstp;
>  
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 0bda93e..4ed4db0 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -569,6 +569,11 @@ struct svcxdr_tmpbuf {
>  	char buf[];
>  };
>  
> +struct svcxdr_richacl {
> +	struct svcxdr_richacl *next;
> +	struct richacl *acl;
> +};
> +
>  struct nfsd4_compoundargs {
>  	/* scratch variables for XDR decode */
>  	__be32 *			p;
> @@ -578,6 +583,7 @@ struct nfsd4_compoundargs {
>  	__be32				tmp[8];
>  	__be32 *			tmpp;
>  	struct svcxdr_tmpbuf		*to_free;
> +	struct svcxdr_richacl		*acls;
>  
>  	struct svc_rqst			*rqstp;
>  
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
