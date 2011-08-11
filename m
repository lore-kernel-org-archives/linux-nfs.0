Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from oproxy7-pub.bluehost.com ([67.222.55.9]:36037 "HELO
	oproxy7-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751188Ab1HKQI1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 12:08:27 -0400
Date: Thu, 11 Aug 2011 08:41:45 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
To: <tao.peng@emc.com>
Cc: <torvalds@linux-foundation.org>, <bergwolf@gmail.com>,
        <Trond.Myklebust@netapp.com>, <linux-raid@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Subject: Re: Linux 3.1-rc1 (nfs/pnfs and drivers/md)
Message-Id: <20110811084145.3d4fada2.rdunlap@xenotime.net>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805BF0EAC8A@MX09A.corp.emc.com>
References: <CA+55aFwkJdyEpyNY64aAQ5ChrPZ8Kvx9iRUwy1J6_SRaxoN=zA@mail.gmail.com>
	<20110810122304.96b8be67.rdunlap@xenotime.net>
	<CA+a=Yy5izxiyvW5eYiWuute9E1vXwNTj4frdzNeEwsLDrszesg@mail.gmail.com>
	<20110810175829.a834d80f.rdunlap@xenotime.net>
	<CA+55aFzcSLrhkexEn=J7BN8F3P3Vy+EAjwgGwMQPdeoYoQG+Bw@mail.gmail.com>
	<F19688880B763E40B28B2B462677FBF805BF0EAC8A@MX09A.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 10 Aug 2011 23:26:47 -0400 tao.peng@emc.com wrote:

> Hi, Randy and Linus
> 
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org]
> > On Behalf Of Linus Torvalds
> > Sent: Thursday, August 11, 2011 9:10 AM
> > To: Randy Dunlap
> > Cc: Peng Tao; Trond Myklebust; linux-raid@vger.kernel.org; Linux Kernel Mailing List;
> > linux-nfs@vger.kernel.org
> > Subject: Re: Linux 3.1-rc1 (nfs/pnfs and drivers/md)
> > 
> > On Wed, Aug 10, 2011 at 5:58 PM, Randy Dunlap <rdunlap@xenotime.net> wrote:
> > >
> > > The blocklayout parts of NVS_V4_1 could depend on BLOCK.  or all of NVS_V4_1
> > > can depend on BLOCK.
> > 
> > Absolutely. Replace "could" by "should".
> > 
> > There's no way I'll take a patch to make NFS "select BLOCK". If the
> > block layer isn't enabled, then NFS obviously shouldn't be doing any
> > pnfs stuff.
> I see. How about the following patch? We used to do like following for PNFS_BLOCK but it was changed during code review.

Yes, that builds cleanly for me.  Thanks.

Acked-by: Randy Dunlap <rdunlap@xenotime.net>



> From 833b59c1d24b43a9a4d47f777abab2cd9d041c68 Mon Sep 17 00:00:00 2001
> From: Peng Tao <bergwolf@gmail.com>
> Date: Wed, 10 Aug 2011 18:29:21 -0400
> Subject: [PATCH] NFS41: make PNFS_BLOCK selectable
> 
> PNFS_BLOCK needs BLK_DEV_DM/MD, which is not a dependency for other
> pnfs layout drivers. Seperate it out so others can still build when
> BLK_DEV_DM/MD is not enabled.
> 
> Also change select to depends on to avoid build failures.
> 
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> Signed-off-by: Peng Tao <peng_tao@emc.com>
> ---
>  fs/nfs/Kconfig |   14 +++++++++-----
>  1 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index be02077..0d30613 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -79,12 +79,9 @@ config NFS_V4_1
>  	depends on NFS_FS && NFS_V4 && EXPERIMENTAL
>  	select SUNRPC_BACKCHANNEL
>  	select PNFS_FILE_LAYOUT
> -	select PNFS_BLOCK
> -	select MD
> -	select BLK_DEV_DM
>  	help
>  	  This option enables support for minor version 1 of the NFSv4 protocol
> -	  (RFC 5661 and RFC 5663) in the kernel's NFS client.
> +	  (RFC 5661) in the kernel's NFS client.
>  
>  	  If unsure, say N.
>  
> @@ -92,7 +89,14 @@ config PNFS_FILE_LAYOUT
>  	tristate
>  
>  config PNFS_BLOCK
> -	tristate
> +	tristate "Provide support for the pNFS Block Layout Driver for NFSv4.1 pNFS (EXPERIMENTAL)"
> +	depends on NFS_FS && NFS_V4_1 && BLK_DEV_DM
> +	help
> +	  Say M here if you want your pNFS client to support the Block Layout Driver
> +	  (RFC 5663). Requires Multiple devices driver support (DM) and Device mapper
> +	  support (BLK_DEV_DM).
> +
> +	  If unsure, say N.
>  
>  config PNFS_OBJLAYOUT
>  	tristate "Provide support for the pNFS Objects Layout Driver for NFSv4.1 pNFS (EXPERIMENTAL)"
> -- 
> 1.7.4.2
> 
> 
> 


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
