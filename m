Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36824 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751962Ab1J1KCH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Oct 2011 06:02:07 -0400
Date: Fri, 28 Oct 2011 06:02:04 -0400
To: Benny Halevy <benny@tonian.com>
Cc: bfields@netapp.com, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@tonian.com>
Subject: Re: [PATCH] nfsd4: typo logical vs bitwise negate in
 nfsd4_decode_share_access
Message-ID: <20111028100204.GB2604@fieldses.org>
References: <1319740981-3338-1-git-send-email-benny@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319740981-3338-1-git-send-email-benny@tonian.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Oh cripes, another one.  Thanks for catching this one too.

--b.

On Thu, Oct 27, 2011 at 08:43:01PM +0200, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@tonian.com>
> 
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfsd/nfs4xdr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 66d095d..b6fa792 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -655,7 +655,7 @@ static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *x)
>  	default:
>  		return nfserr_bad_xdr;
>  	}
> -	w &= !NFS4_SHARE_ACCESS_MASK;
> +	w &= ~NFS4_SHARE_ACCESS_MASK;
>  	if (!w)
>  		return nfs_ok;
>  	if (!argp->minorversion)
> -- 
> 1.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
