Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:43496 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753756AbcAVOjT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jan 2016 09:39:19 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH 2/2] pNFS/flexfiles: Fix an XDR encoding bug in
 layoutreturn
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        <linux-nfs@vger.kernel.org>
References: <1453409713-15878-1-git-send-email-trond.myklebust@primarydata.com>
 <1453409713-15878-2-git-send-email-trond.myklebust@primarydata.com>
Message-ID: <56A23EF7.6000107@Netapp.com>
Date: Fri, 22 Jan 2016 09:38:47 -0500
MIME-Version: 1.0
In-Reply-To: <1453409713-15878-2-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On 01/21/2016 03:55 PM, Trond Myklebust wrote:
> We must not skip encoding the statistics, or the server will see an
> XDR encoding error.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> Cc: stable@vger.kernel.org # 4.0+
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 405f46ba490e..82959409b9a6 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -1859,9 +1859,7 @@ ff_layout_encode_layoutreturn(struct pnfs_layout_hdr *lo,
>  	start = xdr_reserve_space(xdr, 4);
>  	BUG_ON(!start);
>  
> -	if (ff_layout_encode_ioerr(flo, xdr, args))
> -		goto out;

Can you remove the label "out", too?  GCC tells me:

fs/nfs/flexfilelayout/flexfilelayout.c:1953:1: error: label 'out' defined but not used [-Werror=unused-label]

Thanks,
Anna

> -
> +	ff_layout_encode_ioerr(flo, xdr, args);
>  	ff_layout_encode_iostats(flo, xdr, args);
>  out:
>  	*start = cpu_to_be32((xdr->p - start - 1) * 4);
> 

