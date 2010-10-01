Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50933 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757027Ab0JAOuc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 10:50:32 -0400
Date: Fri, 1 Oct 2010 10:50:18 -0400
From: " J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd4: adjust buflen for encoded attrs bitmap
 based on actual bitmap length
Message-ID: <20101001145018.GD17310@fieldses.org>
References: <1285872466-21013-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1285872466-21013-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 30, 2010 at 08:47:46PM +0200, Benny Halevy wrote:
> The existing code adjusted it based on the worst case scenario for the returned
> bitmap and the best case scenario for the supported attrs attribute.

Looks fine, thanks.  Mind if I just ditch the unlikely()s?  I know,
they've been there for a while, but I'm just skeptical of their value on
anything but the most unbelievably hot optimized-to-death code paths.

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4xdr.c |   14 ++++++++++----
>  1 files changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 1a468bb..f48d891 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1805,19 +1805,23 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>  				goto out_nfserr;
>  		}
>  	}
> -	if ((buflen -= 16) < 0)
> -		goto out_resource;
>  
>  	if (unlikely(bmval2)) {
> +		if ((buflen -= 16) < 0)
> +			goto out_resource;
>  		WRITE32(3);
>  		WRITE32(bmval0);
>  		WRITE32(bmval1);
>  		WRITE32(bmval2);
>  	} else if (likely(bmval1)) {
> +		if ((buflen -= 12) < 0)
> +			goto out_resource;
>  		WRITE32(2);
>  		WRITE32(bmval0);
>  		WRITE32(bmval1);
>  	} else {
> +		if ((buflen -= 8) < 0)
> +			goto out_resource;
>  		WRITE32(1);
>  		WRITE32(bmval0);
>  	}
> @@ -1828,15 +1832,17 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>  		u32 word1 = nfsd_suppattrs1(minorversion);
>  		u32 word2 = nfsd_suppattrs2(minorversion);
>  
> -		if ((buflen -= 12) < 0)
> -			goto out_resource;
>  		if (!aclsupport)
>  			word0 &= ~FATTR4_WORD0_ACL;
>  		if (!word2) {
> +			if ((buflen -= 12) < 0)
> +				goto out_resource;
>  			WRITE32(2);
>  			WRITE32(word0);
>  			WRITE32(word1);
>  		} else {
> +			if ((buflen -= 16) < 0)
> +				goto out_resource;
>  			WRITE32(3);
>  			WRITE32(word0);
>  			WRITE32(word1);
> -- 
> 1.7.2.3
> 
