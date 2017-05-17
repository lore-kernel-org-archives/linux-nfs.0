Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60084 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752165AbdEQMzD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 May 2017 08:55:03 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 23E4A81F01
        for <linux-nfs@vger.kernel.org>; Wed, 17 May 2017 12:55:03 +0000 (UTC)
Date: Wed, 17 May 2017 20:55:00 +0800
From: Eryu Guan <eguan@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Revert "nfsd: check for oversized NFSv2/v3
 arguments"
Message-ID: <20170517125500.GH7250@eguan.usersys.redhat.com>
References: <20170515112638.GU7250@eguan.usersys.redhat.com>
 <20170515154424.GC9697@parsley.fieldses.org>
 <20170516201944.GC28537@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170516201944.GC28537@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 16, 2017 at 04:19:44PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> This reverts commit 51f567777799 "nfsd: check for oversized NFSv2/v3
> arguments", which breaks support for NFSv3 ACLs.
> 
> That patch was actually an earlier draft of a fix for the problem that
> was eventually fixed by e6838a29ecb "nfsd: check for oversized NFSv2/v3
> arguments".  But somehow I accidentally left this earlier draft in the
> branch that was part of my 2.12 pull request.
> 
> Reported-by: Eryu Guan <eguan@redhat.com>
> Cc: stable@vger.kernel.org
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Tested with generic/053 generic/105 generic/307 generic/319 and all
passed with NFSv3. Thanks!

Tested-by: Eryu Guan <eguan@redhat.com>

> ---
>  fs/nfsd/nfs3xdr.c          | 23 ++++++-----------------
>  fs/nfsd/nfsxdr.c           | 13 +++----------
>  include/linux/sunrpc/svc.h |  3 ++-
>  3 files changed, 11 insertions(+), 28 deletions(-)
> 
> The stable cc may be overkill as I don't *think* the original's been
> backported to stable yet, but it's there just in case I miss NAK'ing the
> backports....
> 
> diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
> index 12feac6ee2fd..452334694a5d 100644
> --- a/fs/nfsd/nfs3xdr.c
> +++ b/fs/nfsd/nfs3xdr.c
> @@ -334,11 +334,8 @@ nfs3svc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
>  	if (!p)
>  		return 0;
>  	p = xdr_decode_hyper(p, &args->offset);
> -	args->count = ntohl(*p++);
> -
> -	if (!xdr_argsize_check(rqstp, p))
> -		return 0;
>  
> +	args->count = ntohl(*p++);
>  	len = min(args->count, max_blocksize);
>  
>  	/* set up the kvec */
> @@ -352,7 +349,7 @@ nfs3svc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
>  		v++;
>  	}
>  	args->vlen = v;
> -	return 1;
> +	return xdr_argsize_check(rqstp, p);
>  }
>  
>  int
> @@ -544,11 +541,9 @@ nfs3svc_decode_readlinkargs(struct svc_rqst *rqstp, __be32 *p,
>  	p = decode_fh(p, &args->fh);
>  	if (!p)
>  		return 0;
> -	if (!xdr_argsize_check(rqstp, p))
> -		return 0;
>  	args->buffer = page_address(*(rqstp->rq_next_page++));
>  
> -	return 1;
> +	return xdr_argsize_check(rqstp, p);
>  }
>  
>  int
> @@ -574,14 +569,10 @@ nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p,
>  	args->verf   = p; p += 2;
>  	args->dircount = ~0;
>  	args->count  = ntohl(*p++);
> -
> -	if (!xdr_argsize_check(rqstp, p))
> -		return 0;
> -
>  	args->count  = min_t(u32, args->count, PAGE_SIZE);
>  	args->buffer = page_address(*(rqstp->rq_next_page++));
>  
> -	return 1;
> +	return xdr_argsize_check(rqstp, p);
>  }
>  
>  int
> @@ -599,9 +590,6 @@ nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, __be32 *p,
>  	args->dircount = ntohl(*p++);
>  	args->count    = ntohl(*p++);
>  
> -	if (!xdr_argsize_check(rqstp, p))
> -		return 0;
> -
>  	len = args->count = min(args->count, max_blocksize);
>  	while (len > 0) {
>  		struct page *p = *(rqstp->rq_next_page++);
> @@ -609,7 +597,8 @@ nfs3svc_decode_readdirplusargs(struct svc_rqst *rqstp, __be32 *p,
>  			args->buffer = page_address(p);
>  		len -= PAGE_SIZE;
>  	}
> -	return 1;
> +
> +	return xdr_argsize_check(rqstp, p);
>  }
>  
>  int
> diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
> index 6a4947a3f4fa..de07ff625777 100644
> --- a/fs/nfsd/nfsxdr.c
> +++ b/fs/nfsd/nfsxdr.c
> @@ -257,9 +257,6 @@ nfssvc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
>  	len = args->count     = ntohl(*p++);
>  	p++; /* totalcount - unused */
>  
> -	if (!xdr_argsize_check(rqstp, p))
> -		return 0;
> -
>  	len = min_t(unsigned int, len, NFSSVC_MAXBLKSIZE_V2);
>  
>  	/* set up somewhere to store response.
> @@ -275,7 +272,7 @@ nfssvc_decode_readargs(struct svc_rqst *rqstp, __be32 *p,
>  		v++;
>  	}
>  	args->vlen = v;
> -	return 1;
> +	return xdr_argsize_check(rqstp, p);
>  }
>  
>  int
> @@ -365,11 +362,9 @@ nfssvc_decode_readlinkargs(struct svc_rqst *rqstp, __be32 *p, struct nfsd_readli
>  	p = decode_fh(p, &args->fh);
>  	if (!p)
>  		return 0;
> -	if (!xdr_argsize_check(rqstp, p))
> -		return 0;
>  	args->buffer = page_address(*(rqstp->rq_next_page++));
>  
> -	return 1;
> +	return xdr_argsize_check(rqstp, p);
>  }
>  
>  int
> @@ -407,11 +402,9 @@ nfssvc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p,
>  	args->cookie = ntohl(*p++);
>  	args->count  = ntohl(*p++);
>  	args->count  = min_t(u32, args->count, PAGE_SIZE);
> -	if (!xdr_argsize_check(rqstp, p))
> -		return 0;
>  	args->buffer = page_address(*(rqstp->rq_next_page++));
>  
> -	return 1;
> +	return xdr_argsize_check(rqstp, p);
>  }
>  
>  /*
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 94631026f79c..11cef5a7bc87 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -336,7 +336,8 @@ xdr_argsize_check(struct svc_rqst *rqstp, __be32 *p)
>  {
>  	char *cp = (char *)p;
>  	struct kvec *vec = &rqstp->rq_arg.head[0];
> -	return cp == (char *)vec->iov_base + vec->iov_len;
> +	return cp >= (char*)vec->iov_base
> +		&& cp <= (char*)vec->iov_base + vec->iov_len;
>  }
>  
>  static inline int
> -- 
> 2.9.3
> 
