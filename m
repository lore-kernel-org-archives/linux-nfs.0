Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45691 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807Ab3KUQqV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Nov 2013 11:46:21 -0500
Date: Thu, 21 Nov 2013 11:46:15 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: start documenting some XDR handling functions
Message-ID: <20131121164615.GD27364@fieldses.org>
References: <20131120082411.GA30072@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131120082411.GA30072@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 20, 2013 at 12:24:11AM -0800, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Thanks, applying for 3.14.

--b.

> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index fc10dd7..9423522 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -193,6 +193,15 @@ static int zero_clientid(clientid_t *clid)
>  	return (clid->cl_boot == 0) && (clid->cl_id == 0);
>  }
>  
> +/**
> + * defer_free - mark an allocation as deferred freed
> + * @argp: NFSv4 compound argument structure to be freed with
> + * @release: release callback to free @p, typically kfree()
> + * @p: pointer to be freed
> + *
> + * Marks @p to be freed when processing the compound operation
> + * described in @argp finishes.
> + */
>  static int
>  defer_free(struct nfsd4_compoundargs *argp,
>  		void (*release)(const void *), void *p)
> @@ -209,6 +218,16 @@ defer_free(struct nfsd4_compoundargs *argp,
>  	return 0;
>  }
>  
> +/**
> + * savemem - duplicate a chunk of memory for later processing
> + * @argp: NFSv4 compound argument structure to be freed with
> + * @p: pointer to be duplicated
> + * @nbytes: length to be duplicated
> + *
> + * Returns a pointer to a copy of @nbytes bytes of memory at @p
> + * that are preserved until processing of the NFSv4 compound
> + * operation described by @argp finishes.
> + */
>  static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
>  {
>  	if (p == argp->tmp) {
