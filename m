From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Bad extra hunk at pan_layout driver pathes
Date: Thu, 11 Aug 2011 15:26:46 -0700
Message-ID: <4E445726.1000702@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: Benny Halevy <benny@tonian.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:37522 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753606Ab1HKW0z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 18:26:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Benny

In your pNFS git tree at patch:
	99432a3 pnfs-obj: panlayout: panfs_shim objects IO engine

There is an extra hunk at Kconfig re-adding the PNFS_BLOCKS See below

> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index be02077..4f42384 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -104,6 +104,24 @@ config PNFS_OBJLAYOUT
>  
>  	  If unsure, say N.
>  
> +config PNFS_PANLAYOUT
> +	tristate "Provide support for the Panasas OSD Layout Driver for NFSv4.1 pNFS (EXPERIMENTAL)"
> +	depends on PNFS_OBJLAYOUT
> +	help
> +	  Say M or y here if you want your pNFS client to support the Panasas OSD Layout Driver.
> +
> +	  If unsure, say N.
> +

vvvvv Below is not needed

> +config PNFS_BLOCK
> +	tristate "Provide a pNFS block client (EXPERIMENTAL)"
> +	depends on NFS_FS && NFS_V4_1
> +	select MD
> +	select BLK_DEV_DM
> +	help
> +	  Say M or y here if you want your pNfs client to support the block protocol
> +
> +	  If unsure, say N.
> +

Please remove it below is a reverting diff

Thanks
>  config ROOT_NFS
>  	bool "Root file system on NFS"
>  	depends on NFS_FS=y && IP_PNP

---
