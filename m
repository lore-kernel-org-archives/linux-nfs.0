Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-jnhn.mail.uoguelph.ca ([131.104.91.44]:45411 "EHLO
	esa-jnhn.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027Ab3GQWfa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jul 2013 18:35:30 -0400
Date: Wed, 17 Jul 2013 18:25:55 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        Andre Heider <a.heider@gmail.com>
Message-ID: <1951743871.894488.1374099955918.JavaMail.root@uoguelph.ca>
In-Reply-To: <1374098347-30196-1-git-send-email-Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] NFSv4: Fix a regression against the FreeBSD server
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> Technically, the Linux client is allowed by the NFSv4 spec to send
> 3 word bitmaps as part of an OPEN request. However, this causes the
> current FreeBSD server to return NFS4ERR_ATTRNOTSUPP errors.
> 
Yep. The code in the FreeBSD distros is only NFSv4.0, which only had
bits up to 56. I suppose it should just ignore high order bitmap
words. (My current code, which isn't in a distro yet, does handle
3 word bitmaps as a part of the NFSv4.1 support. Maybe I'll change it
to allow any number of bitmap words, so long as the high order words
are 0.)

Thanks for patching this, since it will be some time before the newer
FreeBSD server code gets released, rick

> Fix the regression by making the Linux client use a 2 word bitmap
> unless
> doing NFSv4.2 with labeled NFS.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/nfs4xdr.c | 21 ++++++++++++++-------
>  1 file changed, 14 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 0abfb846..c74d616 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -999,6 +999,7 @@ static void encode_attrs(struct xdr_stream *xdr,
> const struct iattr *iap,
>  	__be32 *p;
>  	__be32 *q;
>  	int len;
> +	uint32_t bmval_len = 2;
>  	uint32_t bmval0 = 0;
>  	uint32_t bmval1 = 0;
>  	uint32_t bmval2 = 0;
> @@ -1010,7 +1011,7 @@ static void encode_attrs(struct xdr_stream
> *xdr, const struct iattr *iap,
>  	 * = 40 bytes, plus any contribution from variable-length fields
>  	 *            such as owner/group.
>  	 */
> -	len = 20;
> +	len = 8;
>  
>  	/* Sigh */
>  	if (iap->ia_valid & ATTR_SIZE)
> @@ -1040,8 +1041,6 @@ static void encode_attrs(struct xdr_stream
> *xdr, const struct iattr *iap,
>  		}
>  		len += 4 + (XDR_QUADLEN(owner_grouplen) << 2);
>  	}
> -	if (label)
> -		len += 4 + 4 + 4 + (XDR_QUADLEN(label->len) << 2);
>  	if (iap->ia_valid & ATTR_ATIME_SET)
>  		len += 16;
>  	else if (iap->ia_valid & ATTR_ATIME)
> @@ -1050,15 +1049,22 @@ static void encode_attrs(struct xdr_stream
> *xdr, const struct iattr *iap,
>  		len += 16;
>  	else if (iap->ia_valid & ATTR_MTIME)
>  		len += 4;
> +	if (label) {
> +		len += 4 + 4 + 4 + (XDR_QUADLEN(label->len) << 2);
> +		bmval_len = 3;
> +	}
> +
> +	len += bmval_len << 2;
>  	p = reserve_space(xdr, len);
>  
>  	/*
>  	 * We write the bitmap length now, but leave the bitmap and the
>  	 attribute
>  	 * buffer length to be backfilled at the end of this routine.
>  	 */
> -	*p++ = cpu_to_be32(3);
> +	*p++ = cpu_to_be32(bmval_len);
>  	q = p;
> -	p += 4;
> +	/* Skip bitmap entries + attrlen */
> +	p += bmval_len + 1;
>  
>  	if (iap->ia_valid & ATTR_SIZE) {
>  		bmval0 |= FATTR4_WORD0_SIZE;
> @@ -1112,10 +1118,11 @@ static void encode_attrs(struct xdr_stream
> *xdr, const struct iattr *iap,
>  				len, ((char *)p - (char *)q) + 4);
>  		BUG();
>  	}
> -	len = (char *)p - (char *)q - 16;
> +	len = (char *)p - (char *)q - (bmval_len << 2);
>  	*q++ = htonl(bmval0);
>  	*q++ = htonl(bmval1);
> -	*q++ = htonl(bmval2);
> +	if (bmval_len == 3)
> +		*q++ = htonl(bmval2);
>  	*q = htonl(len);
>  
>  /* out: */
> --
> 1.8.3.1
> 
> 
