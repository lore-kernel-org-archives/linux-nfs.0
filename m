From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd4: Use FIRST_NFS4_OP in nfsd4_decode_compound()
Date: Thu, 17 Dec 2009 11:50:53 -0500
Message-ID: <20091217165053.GB15866@fieldses.org>
References: <1260590607-9905-1-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59759 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415AbZLQQur (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Dec 2009 11:50:47 -0500
In-Reply-To: <1260590607-9905-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 11, 2009 at 08:03:27PM -0800, Ricardo Labiaga wrote:
> Since we're checking for LAST_NFS4_OP, use FIRST_NFS4_OP to be consistent.

Got it, thanks.--b.

> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> ---
>  fs/nfsd/nfs4xdr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index b83a24c..3fe0a00 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1442,7 +1442,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>  		}
>  		op->opnum = ntohl(*argp->p++);
>  
> -		if (op->opnum >= OP_ACCESS && op->opnum <= LAST_NFS4_OP)
> +		if (op->opnum >= FIRST_NFS4_OP && op->opnum <= LAST_NFS4_OP)
>  			op->status = ops->decoders[op->opnum](argp, &op->u);
>  		else {
>  			op->opnum = OP_ILLEGAL;
> -- 
> 1.5.4.3
> 
