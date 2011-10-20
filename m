Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55794 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806Ab1JTLxh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 07:53:37 -0400
Date: Thu, 20 Oct 2011 07:53:36 -0400
To: Benny Halevy <benny@tonian.com>
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@tonian.com>
Subject: Re: [PATCH 6/7] nfsd4: typo logical vs bitwise negate for want_mask
Message-ID: <20111020115336.GI5444@fieldses.org>
References: <4E9F82FC.2000904@tonian.com>
 <1319076809-13512-1-git-send-email-benny@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1319076809-13512-1-git-send-email-benny@tonian.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yep, bad mistake on my part--but someone else already caught this, and
it's already committed to my 3.2 branch.--b.

On Wed, Oct 19, 2011 at 07:13:29PM -0700, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@tonian.com>
> 
> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
> ---
>  fs/nfsd/nfs4xdr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 1a419c0..1a5cb7e 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -671,7 +671,7 @@ static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *x)
>  	default:
>  		return nfserr_bad_xdr;
>  	}
> -	w &= !NFS4_SHARE_WANT_MASK;
> +	w &= ~NFS4_SHARE_WANT_MASK;
>  	if (!w)
>  		return nfs_ok;
>  	switch (w) {
> -- 
> 1.7.6
> 
