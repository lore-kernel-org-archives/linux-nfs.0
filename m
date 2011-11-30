Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51932 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757054Ab1K3BHV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 20:07:21 -0500
Message-ID: <4ED5803D.8030906@panasas.com>
Date: Tue, 29 Nov 2011 17:00:45 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Randy Dunlap <rdunlap@xenotime.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Michal Marek <mmarek@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>,
        NFS list <linux-nfs@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>,
        <linux-next@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [osd-dev] [PATCH v3] ore: FIX breakage when MISC_FILESYSTEMS
 is not set
References: <20111124174358.d88f11c0ff700e5e6b3bf73b@canb.auug.org.au> <4ECE91F3.9010007@xenotime.net> <4ED422CC.60706@panasas.com> <4ED4238F.4090407@panasas.com> <4ED56C59.208@panasas.com>
In-Reply-To: <4ED56C59.208@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/29/2011 03:35 PM, Boaz Harrosh wrote:
> 
> As Reported by Randy Dunlap
> 

Randy Hi

I think I prefer this simple solution for now, instead of
the complete move of the ore to lib/

It solves the warning problem you reported and let us
keep the convenience of selecting everything in one place. As
was said there are more dependencies on the way.

I will look into the additional ASYNC_CORE and XOR_BLOCKS selects
you mentioned. For some reason it works but I'll try to find a
way to break it or prove It is sound.

Please advise?

Thanks
Heart

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
> needed.
> 
> We must split exofs/Kconfig in two. The ore one is always included.
> And the exofs one is left in it's old place in the menu.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/Kconfig           |    2 ++
>  fs/exofs/Kconfig     |   11 -----------
>  fs/exofs/ore.Kconfig |   12 ++++++++++++
>  3 files changed, 14 insertions(+), 11 deletions(-)
>  create mode 100644 fs/exofs/ore.Kconfig
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 5f4c45d..fd7bfef 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -218,6 +218,8 @@ source "fs/exofs/Kconfig"
>  
>  endif # MISC_FILESYSTEMS
>  
> +source "fs/exofs/ore.Kconfig"
> +
>  menuconfig NETWORK_FILESYSTEMS
>  	bool "Network File Systems"
>  	default y
> diff --git a/fs/exofs/Kconfig b/fs/exofs/Kconfig
> index da42f32..86194b2 100644
> --- a/fs/exofs/Kconfig
> +++ b/fs/exofs/Kconfig
> @@ -1,14 +1,3 @@
> -# Note ORE needs to "select ASYNC_XOR". So Not to force multiple selects
> -# for every ORE user we do it like this. Any user should add itself here
> -# at the "depends on EXOFS_FS || ..." with an ||. The dependencies are
> -# selected here, and we default to "ON". So in effect it is like been
> -# selected by any of the users.
> -config ORE
> -	tristate
> -	depends on EXOFS_FS || PNFS_OBJLAYOUT
> -	select ASYNC_XOR
> -	default SCSI_OSD_ULD
> -
>  config EXOFS_FS
>  	tristate "exofs: OSD based file system support"
>  	depends on SCSI_OSD_ULD
> diff --git a/fs/exofs/ore.Kconfig b/fs/exofs/ore.Kconfig
> new file mode 100644
> index 0000000..1ca7fb7
> --- /dev/null
> +++ b/fs/exofs/ore.Kconfig
> @@ -0,0 +1,12 @@
> +# ORE - Objects Raid Engine (libore.ko)
> +#
> +# Note ORE needs to "select ASYNC_XOR". So Not to force multiple selects
> +# for every ORE user we do it like this. Any user should add itself here
> +# at the "depends on EXOFS_FS || ..." with an ||. The dependencies are
> +# selected here, and we default to "ON". So in effect it is like been
> +# selected by any of the users.
> +config ORE
> +	tristate
> +	depends on EXOFS_FS || PNFS_OBJLAYOUT
> +	select ASYNC_XOR
> +	default SCSI_OSD_ULD

