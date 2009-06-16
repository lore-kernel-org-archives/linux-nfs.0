From: "Halevy, Benny" <bhalevy@panasas.com>
Subject: RE: [pnfs] [RFC 25/39] nfs41: decode minorversion 1 cb_compound header
Date: Mon, 15 Jun 2009 21:07:57 -0400
Message-ID: <7225594ED4A1304C9E43D030A886D221F4C557@daytona.int.panasas.com>
References: <49FA3180.5030404@panasas.com><1241133796-1118-1-git-send-email-bhalevy@panasas.com> <1245111238.7470.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:1978
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752568AbZFPBH4 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jun 2009 21:07:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> What is the point of splitting the read_buf() here? That seems very
> unnecessary...

Agreed.
I'll revert that.

For the record, my original thinking was that you don't want to read
the rest of the header if you don't support its minorversion.
However, minorversion can't change the compound header's format
so its safe to read it all.

Benny

-----Original Message-----
From: Trond Myklebust [mailto:Trond.Myklebust@netapp.com]
Sent: Tue 2009-06-16 03:13
To: Halevy, Benny
Cc: linux-nfs@vger.kernel.org; pnfs@linux-nfs.org
Subject: Re: [pnfs] [RFC 25/39] nfs41: decode minorversion 1 cb_compound header
 
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

