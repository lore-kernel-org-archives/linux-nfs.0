Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail06.adl6.internode.on.net ([150.101.137.145]:9165 "EHLO
	ipmail06.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753575AbcGGWip (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2016 18:38:45 -0400
Date: Fri, 8 Jul 2016 08:38:09 +1000
From: Dave Chinner <david@fromorbit.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, bfields@fieldses.org
Subject: Re: [PATCH 2/2] xfs: abstract block export operations from nfsd
 layouts
Message-ID: <20160707223809.GH12670@dastard>
References: <5ff05b585226b689866f4604adddffc94910f63f.1467889001.git.bcodding@redhat.com>
 <073be10a55e5e952adbfd320abcce075fb3958ae.1467889001.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <073be10a55e5e952adbfd320abcce075fb3958ae.1467889001.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 07, 2016 at 07:02:32AM -0400, Benjamin Coddington wrote:
> Instead of creeping pnfs layout configuration into filesystems, move the
> definition of block-based export operations under a more abstract
> configuration.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/Kconfig          | 3 +++
>  fs/nfsd/Kconfig     | 2 ++
>  fs/xfs/Makefile     | 3 +--
>  fs/xfs/xfs_export.c | 2 +-
>  fs/xfs/xfs_pnfs.h   | 4 ++--
>  5 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 6725f59c18e6..6e57b4237d72 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -66,6 +66,9 @@ config FS_POSIX_ACL
>  config EXPORTFS
>  	tristate
>  
> +config BLOCK_EXPORT_OPS
> +	bool
> +

default n, help text?

Also, BLOCK_* prefix config options are for block layer
functionality, hence I suspect this will confuse people because it's
a filesystem config option. EXPORTFS_BLOCK_OPS seems more obvious
and correct to me, as the block mapping ops are part of the exportfs
operations interface....

>  xfs-$(CONFIG_SYSCTL)		+= xfs_sysctl.o
>  xfs-$(CONFIG_COMPAT)		+= xfs_ioctl32.o
> -xfs-$(CONFIG_NFSD_BLOCKLAYOUT)	+= xfs_pnfs.o
> -xfs-$(CONFIG_NFSD_SCSILAYOUT)	+= xfs_pnfs.o
> +xfs-$(CONFIG_BLOCK_EXPORT_OPS)	+= xfs_pnfs.o

Why do we need the first patch to XFS anymore? Just convert it
straight to using CONFIG_EXPORTFS_BLOCK_OPS....


Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
