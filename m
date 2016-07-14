Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38936 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278AbcGNSvn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jul 2016 14:51:43 -0400
Date: Thu, 14 Jul 2016 14:51:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd/blocklayout: Make sure calculate
 signature/designator length aligned
Message-ID: <20160714185141.GA16311@fieldses.org>
References: <53d87a05-76c2-d1f5-4c48-52290468a6e7@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53d87a05-76c2-d1f5-4c48-52290468a6e7@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks to me like sig_len and designator_len can only be multiples of 4,
so there's no change in behavior here.

But, it's probably safer to do this anyway.  I'll apply with a note in
the changelog.

--b.

On Thu, Jul 14, 2016 at 12:01:17PM +0800, Kinglong Mee wrote:
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/blocklayoutxdr.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/blocklayoutxdr.c b/fs/nfsd/blocklayoutxdr.c
> index 6c3b316..d72467e 100644
> --- a/fs/nfsd/blocklayoutxdr.c
> +++ b/fs/nfsd/blocklayoutxdr.c
> @@ -43,7 +43,7 @@ nfsd4_block_encode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
>  
>  	switch (b->type) {
>  	case PNFS_BLOCK_VOLUME_SIMPLE:
> -		len = 4 + 4 + 8 + 4 + b->simple.sig_len;
> +		len = 4 + 4 + 8 + 4 + (XDR_QUADLEN(b->simple.sig_len) << 2);
>  		p = xdr_reserve_space(xdr, len);
>  		if (!p)
>  			return -ETOOSMALL;
> @@ -54,7 +54,7 @@ nfsd4_block_encode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
>  		p = xdr_encode_opaque(p, b->simple.sig, b->simple.sig_len);
>  		break;
>  	case PNFS_BLOCK_VOLUME_SCSI:
> -		len = 4 + 4 + 4 + 4 + b->scsi.designator_len + 8;
> +		len = 4 + 4 + 4 + 4 + (XDR_QUADLEN(b->scsi.designator_len) << 2) + 8;
>  		p = xdr_reserve_space(xdr, len);
>  		if (!p)
>  			return -ETOOSMALL;
> -- 
> 2.7.4
