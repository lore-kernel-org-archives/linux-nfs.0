From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [pnfs] [RFC 25/39] nfs41: decode minorversion 1 cb_compound
 header
Date: Mon, 15 Jun 2009 17:13:58 -0700
Message-ID: <1245111238.7470.1.camel@heimdal.trondhjem.org>
References: <49FA3180.5030404@panasas.com>
	 <1241133796-1118-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22656 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742AbZFPAN4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2009 20:13:56 -0400
In-Reply-To: <1241133796-1118-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-01 at 02:23 +0300, Benny Halevy wrote:
> decode cb_compound header conforming to
> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
> 
> Get rid of cb_compound_hdr_arg.callback_ident
> 
> callback_ident is not used anywhere so we shouldn't waste any memory to
> store it.
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/callback.h     |    1 -
>  fs/nfs/callback_xdr.c |   12 ++++++++----
>  2 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
> index 21881d9..e0f4e6b 100644
> --- a/fs/nfs/callback.h
> +++ b/fs/nfs/callback.h
> @@ -27,7 +27,6 @@ struct cb_compound_hdr_arg {
>  	unsigned int taglen;
>  	const char *tag;
>  	unsigned int minorversion;
> -	unsigned int callback_ident;
>  	unsigned nops;
>  };
>  
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 91f6f74..e141a7e 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -143,18 +143,22 @@ static __be32 decode_compound_hdr_arg(struct xdr_stream *xdr, struct cb_compound
>  				__func__, hdr->taglen);
>  		return htonl(NFS4ERR_RESOURCE);
>  	}
> -	p = read_buf(xdr, 12);
> +	p = read_buf(xdr, 4);
>  	if (unlikely(p == NULL))
>  		return htonl(NFS4ERR_RESOURCE);
>  	hdr->minorversion = ntohl(*p++);
> -	/* Check minor version is zero. */
> -	if (hdr->minorversion != 0) {
> +	/* Check minor version is zero or one. */
> +	if (hdr->minorversion <= 1) {
> +		p = read_buf(xdr, 8);

What is the point of splitting the read_buf() here? That seems very
unnecessary...

> +		if (unlikely(p == NULL))
> +			return htonl(NFS4ERR_RESOURCE);
> +		p++;	/* skip callback_ident */
> +	} else {
>  		printk(KERN_WARNING "%s: NFSv4 server callback with "
>  			"illegal minor version %u!\n",
>  			__func__, hdr->minorversion);
>  		return htonl(NFS4ERR_MINOR_VERS_MISMATCH);
>  	}
> -	hdr->callback_ident = ntohl(*p++);
>  	hdr->nops = ntohl(*p);
>  	dprintk("%s: minorversion %d nops %d\n", __func__,
>  		hdr->minorversion, hdr->nops);

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
