Return-Path: <SRS0=D8Fn=N2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 039CEC43441
	for <linux-nfs@archiver.kernel.org>; Thu, 15 Nov 2018 16:32:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C5D402086C
	for <linux-nfs@archiver.kernel.org>; Thu, 15 Nov 2018 16:32:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5D402086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388351AbeKPClS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 15 Nov 2018 21:41:18 -0500
Received: from fieldses.org ([173.255.197.46]:50292 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726910AbeKPClS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Nov 2018 21:41:18 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 469CA2014; Thu, 15 Nov 2018 11:32:46 -0500 (EST)
Date:   Thu, 15 Nov 2018 11:32:46 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 3/4] NFSD: Refactor the generic write vector fill
 helper
Message-ID: <20181115163246.GB9022@fieldses.org>
References: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
 <20180727151905.21878.62693.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180727151905.21878.62693.stgit@klimt.1015granger.net>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Um, I somehow managed to overlook a pynfs regression till just now:

On Fri, Jul 27, 2018 at 11:19:05AM -0400, Chuck Lever wrote:
> fill_in_write_vector() is nearly the same logic as
> svc_fill_write_vector(), but there are a few differences so that
> the former can handle multiple WRITE payloads in a single COMPOUND.
> 
> svc_fill_write_vector() can be adjusted so that it can be used in
> the NFSv4 WRITE code path too. Instead of assuming the pages are
> coming from rq_args.pages, have the caller pass in the page list.
> 
> The immediate benefit is a reduction of code duplication. It also
> prevents the NFSv4 WRITE decoder from passing an empty vector
> element when the transport has provided the payload in the xdr_buf's
> page array.
> 
...
> @@ -1027,7 +1009,10 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
>  	write->wr_how_written = write->wr_stable_how;
>  	gen_boot_verifier(&write->wr_verifier, SVC_NET(rqstp));
>  
> -	nvecs = fill_in_write_vector(rqstp->rq_vec, write);
> +	nvecs = svc_fill_write_vector(rqstp, write->wr_pagelist,
> +				      &write->wr_head, write->wr_buflen);
> +	if (!nvecs)
> +		return nfserr_io;

Do you remember why you added this check?

It's causing zero-length writes to fail, in violation of the spec:

	"If the count is zero, the WRITE will succeed and return a count
	of zero subject to permissions checking."

I'm not seeing a reason why it wouldn't be safe just to remove that
check.

--b.

>  	WARN_ON_ONCE(nvecs > ARRAY_SIZE(rqstp->rq_vec));
>  
>  	status = nfsd_vfs_write(rqstp, &cstate->current_fh, filp,
> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
> index f107f9f..a6faee5 100644
> --- a/fs/nfsd/nfsproc.c
> +++ b/fs/nfsd/nfsproc.c
> @@ -218,7 +218,8 @@
>  		SVCFH_fmt(&argp->fh),
>  		argp->len, argp->offset);
>  
> -	nvecs = svc_fill_write_vector(rqstp, &argp->first, cnt);
> +	nvecs = svc_fill_write_vector(rqstp, rqstp->rq_arg.pages,
> +				      &argp->first, cnt);
>  	if (!nvecs)
>  		return nfserr_io;
>  	nfserr = nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh),
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 574368e..43f88bd 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -496,6 +496,7 @@ int		   svc_register(const struct svc_serv *, struct net *, const int,
>  struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
>  char *		   svc_print_addr(struct svc_rqst *, char *, size_t);
>  unsigned int	   svc_fill_write_vector(struct svc_rqst *rqstp,
> +					 struct page **pages,
>  					 struct kvec *first, size_t total);
>  char		  *svc_fill_symlink_pathname(struct svc_rqst *rqstp,
>  					     struct kvec *first, size_t total);
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index 30a4226..2194ed5 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1537,16 +1537,16 @@ u32 svc_max_payload(const struct svc_rqst *rqstp)
>  /**
>   * svc_fill_write_vector - Construct data argument for VFS write call
>   * @rqstp: svc_rqst to operate on
> + * @pages: list of pages containing data payload
>   * @first: buffer containing first section of write payload
>   * @total: total number of bytes of write payload
>   *
> - * Returns the number of elements populated in the data argument array.
> + * Fills in rqstp::rq_vec, and returns the number of elements.
>   */
> -unsigned int svc_fill_write_vector(struct svc_rqst *rqstp, struct kvec *first,
> -				   size_t total)
> +unsigned int svc_fill_write_vector(struct svc_rqst *rqstp, struct page **pages,
> +				   struct kvec *first, size_t total)
>  {
>  	struct kvec *vec = rqstp->rq_vec;
> -	struct page **pages;
>  	unsigned int i;
>  
>  	/* Some types of transport can present the write payload
> @@ -1560,14 +1560,11 @@ unsigned int svc_fill_write_vector(struct svc_rqst *rqstp, struct kvec *first,
>  		++i;
>  	}
>  
> -	WARN_ON_ONCE(rqstp->rq_arg.page_base != 0);
> -	pages = rqstp->rq_arg.pages;
>  	while (total) {
>  		vec[i].iov_base = page_address(*pages);
>  		vec[i].iov_len = min_t(size_t, total, PAGE_SIZE);
>  		total -= vec[i].iov_len;
>  		++i;
> -
>  		++pages;
>  	}
>  
