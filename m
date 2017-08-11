Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:39873 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752901AbdHKPOM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Aug 2017 11:14:12 -0400
Date: Fri, 11 Aug 2017 17:14:11 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        linux-nfs@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] pnfs/blocklayout: =?utf-8?Q?re?=
        =?utf-8?Q?quire_64-bit_=D1=95ector=5Ft?=
Message-ID: <20170811151411.GA4301@lst.de>
References: <20170805085914.3188-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170805085914.3188-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, Anna,

can you pick this up?  Maybe even for 3.13 given that it should
be pretty harmless for 98% of the configfs, and will prevent problems
for the others.

On Sat, Aug 05, 2017 at 10:59:14AM +0200, Christoph Hellwig wrote:
> The blocklayout code does not compile cleanly for a 32-bit sector_t,
> and also has no reliable checks for devices sizes, which makes it
> unsafe to use with a kernel that doesn't support large block devices.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 5c83746a0cf2 ("pnfs/blocklayout: in-kernel GETDEVICEINFO XDR parsing")
> ---
>  fs/nfs/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index 69d02cf8cf37..5f93cfacb3d1 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -121,6 +121,7 @@ config PNFS_FILE_LAYOUT
>  config PNFS_BLOCK
>  	tristate
>  	depends on NFS_V4_1 && BLK_DEV_DM
> +	depends on 64BIT || LBDAF
>  	default NFS_V4
>  
>  config PNFS_FLEXFILE_LAYOUT
> -- 
> 2.11.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---end quoted text---
