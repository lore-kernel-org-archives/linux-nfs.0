Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48226 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751510Ab3LLQgV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Dec 2013 11:36:21 -0500
Date: Thu, 12 Dec 2013 11:36:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: get rid of unused macro definition
Message-ID: <20131212163621.GJ11521@fieldses.org>
References: <52A5972D.7080705@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52A5972D.7080705@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 09, 2013 at 06:10:53PM +0800, Kinglong Mee wrote:
> Since defined in Linux-2.6.12-rc2, READTIME has not been used.

Thanks, applying.--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfsd/nfs4xdr.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index ee7237f..fd48536 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -103,11 +103,6 @@ xdr_error:					\
>  	(x) = (u64)ntohl(*p++) << 32;		\
>  	(x) |= ntohl(*p++);			\
>  } while (0)
> -#define READTIME(x)       do {			\
> -	p++;					\
> -	(x) = ntohl(*p++);			\
> -	p++;					\
> -} while (0)
>  #define READMEM(x,nbytes) do {			\
>  	x = (char *)p;				\
>  	p += XDR_QUADLEN(nbytes);		\
> -- 
> 1.8.4.2
