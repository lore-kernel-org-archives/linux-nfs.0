Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60606 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751109AbaGGSP5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jul 2014 14:15:57 -0400
Date: Mon, 7 Jul 2014 14:15:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix bad reserving space for encoding rdattr_error
Message-ID: <20140707181556.GC8630@fieldses.org>
References: <53B8C3D3.7080201@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53B8C3D3.7080201@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 06, 2014 at 11:34:43AM +0800, Kinglong Mee wrote:
> Introduced by commit 561f0ed498 (nfsd4: allow large readdirs).

Whoops, thanks.  Queueing up for 3.16.--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4xdr.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 3540462..5a1d088 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -2646,7 +2646,7 @@ nfsd4_encode_rdattr_error(struct xdr_stream *xdr, __be32 nfserr)
>  {
>  	__be32 *p;
>  
> -	p = xdr_reserve_space(xdr, 6);
> +	p = xdr_reserve_space(xdr, 20);
>  	if (!p)
>  		return NULL;
>  	*p++ = htonl(2);
> -- 
> 1.9.3
> 
