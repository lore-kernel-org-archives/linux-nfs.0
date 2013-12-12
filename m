Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48225 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789Ab3LLQfu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Dec 2013 11:35:50 -0500
Date: Thu, 12 Dec 2013 11:35:49 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: clean up unnecessary temporary variable in
 nfsd4_decode_fattr
Message-ID: <20131212163549.GI11521@fieldses.org>
References: <52A59A32.10500@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52A59A32.10500@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Mon, Dec 09, 2013 at 06:23:46PM +0800, Kinglong Mee wrote:
> host_err was only used for nfs4_acl_new.
> This patch delete it, and return nfserr_jukebox directly.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4xdr.c | 12 +++---------
>  1 file changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index fd48536..91afb1c 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -252,7 +252,6 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  	int expected_len, len = 0;
>  	u32 dummy32;
>  	char *buf;
> -	int host_err;
>  
>  	DECODE_HEAD;
>  	iattr->ia_valid = 0;
> @@ -279,10 +278,9 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  			return nfserr_resource;
>  
>  		*acl = nfs4_acl_new(nace);
> -		if (*acl == NULL) {
> -			host_err = -ENOMEM;
> -			goto out_nfserr;
> -		}
> +		if (*acl == NULL)
> +			return nfserr_jukebox;
> +
>  		defer_free(argp, kfree, *acl);
>  
>  		(*acl)->naces = nace;
> @@ -420,10 +418,6 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  		goto xdr_error;
>  
>  	DECODE_TAIL;
> -
> -out_nfserr:
> -	status = nfserrno(host_err);
> -	goto out;
>  }
>  
>  static __be32
> -- 
> 1.8.4.2
