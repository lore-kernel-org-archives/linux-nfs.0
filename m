From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd41: nfsd4_decode_compound() does not recognize all
	ops
Date: Thu, 17 Dec 2009 10:54:03 -0500
Message-ID: <20091217155403.GA15866@fieldses.org>
References: <1260587449-29538-1-git-send-email-Ricardo.Labiaga@netapp.com> <1260587449-29538-2-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37670 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999AbZLQPx6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Dec 2009 10:53:58 -0500
In-Reply-To: <1260587449-29538-2-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 11, 2009 at 07:10:49PM -0800, Ricardo Labiaga wrote:
> The server incorrectly assumes that the operations in the
> array start with value 0.  The first operation (OP_ACCESS)
> has a value of 3, causing the check in nfsd4_decode_compound
> to be off.
> 
> Instead of comparing that the operation number is less than
> the number of elements in the array, the server should verify
> that it is less than the maximum valid operation number
> defined by LAST_NFS4_OP.

Thanks.  So the effect of this was to return an OP_ILLEGAL in some cases
where we should have been returning a NOTSUPP error?

--b.

> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> ---
>  fs/nfsd/nfs4xdr.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 0fbd50c..b83a24c 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1442,7 +1442,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>  		}
>  		op->opnum = ntohl(*argp->p++);
>  
> -		if (op->opnum >= OP_ACCESS && op->opnum < ops->nops)
> +		if (op->opnum >= OP_ACCESS && op->opnum <= LAST_NFS4_OP)
>  			op->status = ops->decoders[op->opnum](argp, &op->u);
>  		else {
>  			op->opnum = OP_ILLEGAL;
> -- 
> 1.5.4.3
> 
