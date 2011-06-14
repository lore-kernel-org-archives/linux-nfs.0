Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:33154 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484Ab1FNPNS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 11:13:18 -0400
Received: by iwn34 with SMTP id 34so4725087iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 08:13:17 -0700 (PDT)
Message-ID: <4DF77A8B.9020008@gmail.com>
Date: Tue, 14 Jun 2011 11:13:15 -0400
From: Benny Halevy <bhalevy.lists@gmail.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 07/34] pnfsblock: define PNFS_BLOCK Kconfig option
References: <cover.1307921137.git.rees@umich.edu> <f67f031ef845429a5e3b08d662e33113f631d51c.1307921138.git.rees@umich.edu>
In-Reply-To: <f67f031ef845429a5e3b08d662e33113f631d51c.1307921138.git.rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-12 19:44, Jim Rees wrote:
> From: Fred Isaman <iisaman@citi.umich.edu>
> 
> Define a configuration variable to enable/disable compilation of the
> block driver code.
> 
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> [pnfs-block: fix CONFIG_PNFS_BLOCK dependencies]
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/Kconfig              |    8 ++++++++
>  fs/nfs/Makefile             |    1 +
>  fs/nfs/blocklayout/Makefile |    5 +++++
>  3 files changed, 14 insertions(+), 0 deletions(-)
>  create mode 100644 fs/nfs/blocklayout/Makefile
> 
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index 8151554..3cebf1b 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -97,6 +97,14 @@ config PNFS_OBJLAYOUT
>  
>  	  If unsure, say N.
>  
> +config PNFS_BLOCK
> +	tristate "Provide a pNFS block client (EXPERIMENTAL)"
> +	depends on NFS_FS && PNFS

PNFS config option is obsolete.
Needs to be NFS_V4_1

Benny

> +	help
> +	  Say M or y here if you want your pNfs client to support the block protocol
> +
> +	  If unsure, say N.
> +
>  config ROOT_NFS
>  	bool "Root file system on NFS"
>  	depends on NFS_FS=y && IP_PNP
> diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
> index 6a34f7d..b58613d 100644
> --- a/fs/nfs/Makefile
> +++ b/fs/nfs/Makefile
> @@ -23,3 +23,4 @@ obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
>  nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
>  
>  obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
> +obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
> diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
> new file mode 100644
> index 0000000..f214c1c
> --- /dev/null
> +++ b/fs/nfs/blocklayout/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for the pNFS block layout driver kernel module
> +#
> +obj-$(CONFIG_PNFS_BLOCK) +=
> +blocklayoutdriver-objs :=
