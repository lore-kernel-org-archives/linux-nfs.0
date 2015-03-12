Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:35210 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbCLP7q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2015 11:59:46 -0400
Received: by ieclw3 with SMTP id lw3so46756728iec.2
        for <linux-nfs@vger.kernel.org>; Thu, 12 Mar 2015 08:59:45 -0700 (PDT)
Message-ID: <1426175970.15787.4.camel@primarydata.com>
Subject: Re: [PATCH 1/15] NFSv4.1: don't export static symbol
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, daniel@iogearbox.net
Date: Thu, 12 Mar 2015 11:59:30 -0400
In-Reply-To: <1426092997-30605-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1426092997-30605-1-git-send-email-Julia.Lawall@lip6.fr>
	 <1426092997-30605-2-git-send-email-Julia.Lawall@lip6.fr>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2015-03-11 at 17:56 +0100, Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> The semantic patch that fixes this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @r@
> type T;
> identifier f;
> @@
> 
> static T f (...) { ... }
> 
> @@
> identifier r.f;
> declarer name EXPORT_SYMBOL_GPL;
> @@
> 
> -EXPORT_SYMBOL_GPL(f);
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
>  fs/nfs/pnfs.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> diff -u -p a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1902,7 +1902,6 @@ static void pnfs_writehdr_free(struct nf
>  	pnfs_put_lseg(hdr->lseg);
>  	nfs_pgio_header_free(hdr);
>  }
> -EXPORT_SYMBOL_GPL(pnfs_writehdr_free);
>  
>  int
>  pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
> @@ -2032,7 +2031,6 @@ static void pnfs_readhdr_free(struct nfs
>  	pnfs_put_lseg(hdr->lseg);
>  	nfs_pgio_header_free(hdr);
>  }
> -EXPORT_SYMBOL_GPL(pnfs_readhdr_free);
>  
>  int
>  pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
> 

Thanks Julia! Applied....

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com




