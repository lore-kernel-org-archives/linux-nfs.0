Return-Path: linux-nfs-owner@vger.kernel.org
Received: from li207-46.members.linode.com ([173.255.197.46]:55565 "EHLO
	fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473AbbAVUPt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jan 2015 15:15:49 -0500
Date: Thu, 22 Jan 2015 15:15:49 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 04/20] nfsd: factor out a helper to decode nfstime4 values
Message-ID: <20150122201549.GK898@fieldses.org>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
 <1421925006-24231-5-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421925006-24231-5-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'll go ahead and take this one.--b.

On Thu, Jan 22, 2015 at 12:09:50PM +0100, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfs4xdr.c | 43 ++++++++++++++++++++++++++-----------------
>  1 file changed, 26 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 15f7b73..884ffa3 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -234,6 +234,26 @@ static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
>  	return ret;
>  }
>  
> +/*
> + * We require the high 32 bits of 'seconds' to be 0, and
> + * we ignore all 32 bits of 'nseconds'.
> + */
> +static __be32
> +nfsd4_decode_time(struct nfsd4_compoundargs *argp, struct timespec *tv)
> +{
> +	DECODE_HEAD;
> +	u64 sec;
> +
> +	READ_BUF(12);
> +	p = xdr_decode_hyper(p, &sec);
> +	tv->tv_sec = sec;
> +	tv->tv_nsec = be32_to_cpup(p++);
> +	if (tv->tv_nsec >= (u32)1000000000)
> +		return nfserr_inval;
> +
> +	DECODE_TAIL;
> +}
> +
>  static __be32
>  nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
>  {
> @@ -267,7 +287,6 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  {
>  	int expected_len, len = 0;
>  	u32 dummy32;
> -	u64 sec;
>  	char *buf;
>  
>  	DECODE_HEAD;
> @@ -358,15 +377,10 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  		dummy32 = be32_to_cpup(p++);
>  		switch (dummy32) {
>  		case NFS4_SET_TO_CLIENT_TIME:
> -			/* We require the high 32 bits of 'seconds' to be 0, and we ignore
> -			   all 32 bits of 'nseconds'. */
> -			READ_BUF(12);
>  			len += 12;
> -			p = xdr_decode_hyper(p, &sec);
> -			iattr->ia_atime.tv_sec = (time_t)sec;
> -			iattr->ia_atime.tv_nsec = be32_to_cpup(p++);
> -			if (iattr->ia_atime.tv_nsec >= (u32)1000000000)
> -				return nfserr_inval;
> +			status = nfsd4_decode_time(argp, &iattr->ia_atime);
> +			if (status)
> +				return status;
>  			iattr->ia_valid |= (ATTR_ATIME | ATTR_ATIME_SET);
>  			break;
>  		case NFS4_SET_TO_SERVER_TIME:
> @@ -382,15 +396,10 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  		dummy32 = be32_to_cpup(p++);
>  		switch (dummy32) {
>  		case NFS4_SET_TO_CLIENT_TIME:
> -			/* We require the high 32 bits of 'seconds' to be 0, and we ignore
> -			   all 32 bits of 'nseconds'. */
> -			READ_BUF(12);
>  			len += 12;
> -			p = xdr_decode_hyper(p, &sec);
> -			iattr->ia_mtime.tv_sec = sec;
> -			iattr->ia_mtime.tv_nsec = be32_to_cpup(p++);
> -			if (iattr->ia_mtime.tv_nsec >= (u32)1000000000)
> -				return nfserr_inval;
> +			status = nfsd4_decode_time(argp, &iattr->ia_mtime);
> +			if (status)
> +				return status;
>  			iattr->ia_valid |= (ATTR_MTIME | ATTR_MTIME_SET);
>  			break;
>  		case NFS4_SET_TO_SERVER_TIME:
> -- 
> 1.9.1
