Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39820 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751355AbaE1TgB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 May 2014 15:36:01 -0400
Date: Wed, 28 May 2014 15:35:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: getattr for FATTR4_WORD0_FILES_AVAIL needs the
 statfs buffer
Message-ID: <20140528193555.GD22210@fieldses.org>
References: <1401266773-19048-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401266773-19048-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying for 3.16 and stable.

But, I don't get it: we've been returning random uninitialized data in
FILES_AVAIL since forever, and nobody's noticed till now?

Oh, I see: probably every client requests at least one other thing on
that list at the same time it requests FILES_AVAIL.

--b.

On Wed, May 28, 2014 at 10:46:13AM +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/nfs4xdr.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index d23412e..4bfe880c 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2049,8 +2049,8 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  	err = vfs_getattr(&path, &stat);
>  	if (err)
>  		goto out_nfserr;
> -	if ((bmval0 & (FATTR4_WORD0_FILES_FREE | FATTR4_WORD0_FILES_TOTAL |
> -			FATTR4_WORD0_MAXNAME)) ||
> +	if ((bmval0 & (FATTR4_WORD0_FILES_AVAIL | FATTR4_WORD0_FILES_FREE |
> +			FATTR4_WORD0_FILES_TOTAL | FATTR4_WORD0_MAXNAME)) ||
>  	    (bmval1 & (FATTR4_WORD1_SPACE_AVAIL | FATTR4_WORD1_SPACE_FREE |
>  		       FATTR4_WORD1_SPACE_TOTAL))) {
>  		err = vfs_statfs(&path, &statfs);
> -- 
> 1.7.10.4
> 
