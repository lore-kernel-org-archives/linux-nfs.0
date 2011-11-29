Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64811 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab1K2MVv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 07:21:51 -0500
Message-ID: <4ED4CE58.8090107@tonian.com>
Date: Tue, 29 Nov 2011 14:21:44 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Randy Dunlap <rdunlap@xenotime.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, Michal Marek <mmarek@suse.cz>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: ore: FIX breakage when MISC_FILESYSTEMS is not set
References: <20111124174358.d88f11c0ff700e5e6b3bf73b@canb.auug.org.au> <4ECE91F3.9010007@xenotime.net> <4ED422CC.60706@panasas.com> <4ED4238F.4090407@panasas.com>
In-Reply-To: <4ED4238F.4090407@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-29 02:13, Boaz Harrosh wrote:
> 
> As Reported by Randy Dunlap
> 
> When MISC_FILESYSTEMS is not enabled:
> 
> fs/built-in.o: In function `objio_alloc_io_state':
> objio_osd.c:(.text+0xcb525): undefined reference to `ore_get_rw_state'
> fs/built-in.o: In function `_write_done':
> objio_osd.c:(.text+0xcb58d): undefined reference to `ore_check_io'
> fs/built-in.o: In function `_read_done':
> ...
> 
> When MISC_FILESYSTEMS, which is more of a GUI thing then anything else,
> is not selected. exofs/Kconfig is never examined during Kconfig,
> and it can not do it's magic stuff to automatically select everything

nit: s/it's/its/

> needed.
> 
> The solution is to force all users of ORE (exofs, nfs) to manually
> select everything auto-magically selected before.

How about using "depend ORE" rather than "select ORE"?

> 
> (This is  why it is a bad idea to put libraries in random parts of
>  the tree)
> 
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/exofs/Kconfig |   17 +++++++++--------
>  fs/nfs/Kconfig   |    2 ++
>  2 files changed, 11 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/exofs/Kconfig b/fs/exofs/Kconfig
> index da42f32..6b05d99 100644
> --- a/fs/exofs/Kconfig
> +++ b/fs/exofs/Kconfig
> @@ -1,17 +1,18 @@
> -# Note ORE needs to "select ASYNC_XOR". So Not to force multiple selects
> -# for every ORE user we do it like this. Any user should add itself here
> -# at the "depends on EXOFS_FS || ..." with an ||. The dependencies are
> -# selected here, and we default to "ON". So in effect it is like been
> -# selected by any of the users.
> +# ORE - Objects Raid Engine (libore.ko)
> +# This library needs to be selected by it's users for example the below EXOFS
> +# filesystem.

nit:
This library needs to be selected by its users. For example, see
EXOFS_FS below.

Benny

> +# All users must do:
> +#	depends on SCSI_OSD_ULD
> +#	select ASYNC_XOR
> +#	select ORE
>  config ORE
>  	tristate
> -	depends on EXOFS_FS || PNFS_OBJLAYOUT
> -	select ASYNC_XOR
> -	default SCSI_OSD_ULD
>  
>  config EXOFS_FS
>  	tristate "exofs: OSD based file system support"
>  	depends on SCSI_OSD_ULD
> +	select ASYNC_XOR
> +	select ORE
>  	help
>  	  EXOFS is a file system that uses an OSD storage device,
>  	  as its backing storage.
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index dbcd821..3708d76 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -96,6 +96,8 @@ config PNFS_BLOCK
>  config PNFS_OBJLAYOUT
>  	tristate
>  	depends on NFS_FS && NFS_V4_1 && SCSI_OSD_ULD
> +	select ASYNC_XOR
> +	select ORE
>  	default m
>  
>  config ROOT_NFS
