Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53436 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752288AbcCJWbA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Mar 2016 17:31:00 -0500
Date: Thu, 10 Mar 2016 17:30:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: block and scsi layout drivers need to depend on
 CONFIG_BLOCK
Message-ID: <20160310223059.GB4210@fieldses.org>
References: <1457534607-6925-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1457534607-6925-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks!--b.

On Wed, Mar 09, 2016 at 03:43:27PM +0100, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> ---
>  fs/nfsd/Kconfig | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
> index a30a313..c9f583d 100644
> --- a/fs/nfsd/Kconfig
> +++ b/fs/nfsd/Kconfig
> @@ -88,7 +88,7 @@ config NFSD_PNFS
>  
>  config NFSD_BLOCKLAYOUT
>  	bool "NFSv4.1 server support for pNFS block layouts"
> -	depends on NFSD_V4
> +	depends on NFSD_V4 && BLOCK
>  	select NFSD_PNFS
>  	help
>  	  This option enables support for the exporting pNFS block layouts
> @@ -100,7 +100,7 @@ config NFSD_BLOCKLAYOUT
>  
>  config NFSD_SCSILAYOUT
>  	bool "NFSv4.1 server support for pNFS SCSI layouts"
> -	depends on NFSD_V4
> +	depends on NFSD_V4 && BLOCK
>  	select NFSD_PNFS
>  	help
>  	  This option enables support for the exporting pNFS SCSI layouts
> -- 
> 2.1.4
