Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59136 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750707AbdEIU5A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 May 2017 16:57:00 -0400
Date: Tue, 9 May 2017 16:56:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@Netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Fix up the "supattr_exclcreat" attributes
Message-ID: <20170509205659.GC6289@fieldses.org>
References: <20170509202459.117361-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170509202459.117361-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 09, 2017 at 04:24:59PM -0400, Trond Myklebust wrote:
> If an NFSv4 client asks us for the supattr_exclcreat, then we must
> not return attributes that are unsupported by this minor version.

Thanks!  Applying with a stable cc.

--b.

> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Fixes: 75976de6556f ("NFSD: Return word2 bitmask if setting security..,")
> ---
>  fs/nfsd/nfs4xdr.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 33017d652b1d..187498db0aa9 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2831,9 +2831,14 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  	}
>  #endif /* CONFIG_NFSD_PNFS */
>  	if (bmval2 & FATTR4_WORD2_SUPPATTR_EXCLCREAT) {
> -		status = nfsd4_encode_bitmap(xdr, NFSD_SUPPATTR_EXCLCREAT_WORD0,
> -						  NFSD_SUPPATTR_EXCLCREAT_WORD1,
> -						  NFSD_SUPPATTR_EXCLCREAT_WORD2);
> +		u32 supp[3];
> +
> +		memcpy(supp, nfsd_suppattrs[minorversion], sizeof(supp));
> +		supp[0] &= NFSD_SUPPATTR_EXCLCREAT_WORD0;
> +		supp[1] &= NFSD_SUPPATTR_EXCLCREAT_WORD1;
> +		supp[2] &= NFSD_SUPPATTR_EXCLCREAT_WORD2;
> +
> +		status = nfsd4_encode_bitmap(xdr, supp[0], supp[1], supp[2]);
>  		if (status)
>  			goto out;
>  	}
> -- 
> 2.9.3
