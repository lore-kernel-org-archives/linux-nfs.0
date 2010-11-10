From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] SQUASHME: pnfs-obj: bug in last conversion to embedded
 pnfs_layout_segment
Date: Wed, 10 Nov 2010 11:40:36 +0200
Message-ID: <4CDA6894.3040305@panasas.com>
References: <4CD2E7B4.8070805@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og113.obsmtp.com ([64.18.0.26]:54943 "HELO
	exprod5og113.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753944Ab0KJJki (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 04:40:38 -0500
In-Reply-To: <4CD2E7B4.8070805@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged. Thanks!

On 2010-11-04 19:04, Boaz Harrosh wrote:
> 
> The range field in pnfs_layout_segment is passed to io-engine's
> objio_alloc_lseg but was never set properly.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/objlayout/objlayout.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> index efe7984..332c832 100644
> --- a/fs/nfs/objlayout/objlayout.c
> +++ b/fs/nfs/objlayout/objlayout.c
> @@ -102,6 +102,7 @@ objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
>  	pnfs_osd_layout = (struct pnfs_osd_layout *)objlseg->pnfs_osd_layout;
>  	pnfs_osd_xdr_decode_layout(pnfs_osd_layout, layout);
>  
> +	objlseg->lseg.range = lgr->range;
>  	status = objio_alloc_lseg(&objlseg->internal, pnfslay, &objlseg->lseg,
>  				  pnfs_osd_layout);
>  	if (status)
