Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:50299 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750803AbcEZHfS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 May 2016 03:35:18 -0400
Date: Thu, 26 May 2016 09:35:15 +0200
From: Christoph Hellwig <hch@lst.de>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [V2 2/2] nfsd: Add a super simple flex file server
Message-ID: <20160526073515.GA22814@lst.de>
References: <1464209035-84591-1-git-send-email-loghyr@primarydata.com> <1464209035-84591-3-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1464209035-84591-3-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  void nfsd4_setup_layout_type(struct svc_export *exp)
>  {
> +#if defined(CONFIG_NFSD_BLOCKLAYOUT) || defined(CONFIG_NFSD_SCSILAYOUT)
>  	struct super_block *sb = exp->ex_path.mnt->mnt_sb;
> +#endif
>  
>  	if (!(exp->ex_flags & NFSEXP_PNFS))
>  		return;
>  
>  	/*
> -	 * Check if the file system supports exporting a block-like layout.
> +	 * If flex file is configured, use it by default. Otherwise
> +	 * check if the file system supports exporting a block-like layout.
>  	 * If the block device supports reservations prefer the SCSI layout,
>  	 * otherwise advertise the block layout.
>  	 */
> +#ifdef CONFIG_NFSD_FLEXFILELAYOUT
> +	exp->ex_layout_type = LAYOUT_FLEX_FILES;
> +#endif
>  #ifdef CONFIG_NFSD_BLOCKLAYOUT
> +	/* overwrite flex file layout selection if needed */

So my evil attempt to let you take on the multi-layout support didn't
pan out :)

But given that we don't enable pnfs by defaul this should still be ok,
so:

Reviewed-by: Christoph Hellwig <hch@lst.de>
