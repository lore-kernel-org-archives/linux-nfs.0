Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49667 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030AbbCaUrC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2015 16:47:02 -0400
Date: Tue, 31 Mar 2015 16:47:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Remove duplicate macro define for max sec label
 length
Message-ID: <20150331204701.GR6901@fieldses.org>
References: <5516CCC1.2090608@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5516CCC1.2090608@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 28, 2015 at 11:46:09PM +0800, Kinglong Mee wrote:
> NFS4_MAXLABELLEN has defined for sec label max length, use it directly.

Thanks, applying for 4.1--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4proc.c | 2 +-
>  fs/nfsd/nfs4xdr.c  | 2 +-
>  fs/nfsd/xdr4.h     | 1 -
>  3 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index d30bea8..6bd4391 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1815,7 +1815,7 @@ static inline u32 nfsd4_getattr_rsize(struct svc_rqst *rqstp,
>  		bmap0 &= ~FATTR4_WORD0_FILEHANDLE;
>  	}
>  	if (bmap2 & FATTR4_WORD2_SECURITY_LABEL) {
> -		ret += NFSD4_MAX_SEC_LABEL_LEN + 12;
> +		ret += NFS4_MAXLABELLEN + 12;
>  		bmap2 &= ~FATTR4_WORD2_SECURITY_LABEL;
>  	}
>  	/*
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index df5e66c..eff0a94 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -424,7 +424,7 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
>  		len += 4;
>  		dummy32 = be32_to_cpup(p++);
>  		READ_BUF(dummy32);
> -		if (dummy32 > NFSD4_MAX_SEC_LABEL_LEN)
> +		if (dummy32 > NFS4_MAXLABELLEN)
>  			return nfserr_badlabel;
>  		len += (XDR_QUADLEN(dummy32) << 2);
>  		READMEM(buf, dummy32);
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 0bda93e..8bae5d8 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -40,7 +40,6 @@
>  #include "state.h"
>  #include "nfsd.h"
>  
> -#define NFSD4_MAX_SEC_LABEL_LEN	2048
>  #define NFSD4_MAX_TAGLEN	128
>  #define XDR_LEN(n)                     (((n) + 3) & ~3)
>  
> -- 
> 2.3.4
