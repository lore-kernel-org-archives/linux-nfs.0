Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:62236 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbaEIQf6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 May 2014 12:35:58 -0400
Received: by mail-qa0-f41.google.com with SMTP id dc16so4358174qab.14
        for <linux-nfs@vger.kernel.org>; Fri, 09 May 2014 09:35:57 -0700 (PDT)
Date: Fri, 9 May 2014 12:35:54 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Thomas Haynes <thomas.haynes@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Push the file layout driver into a subdirectory
Message-ID: <20140509123554.5219d4df@tlielax.poochiereds.net>
In-Reply-To: <1399651363-14482-1-git-send-email-Thomas.Haynes@primarydata.com>
References: <1399651363-14482-1-git-send-email-Thomas.Haynes@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri,  9 May 2014 09:02:43 -0700
Thomas Haynes <thomas.haynes@primarydata.com> wrote:

> From: Tom Haynes <Thomas.Haynes@primarydata.com>
> 
> Went to the Makefile as requested by Jeff.
> 
> Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
> ---
>  fs/nfs/Makefile                                            |  4 +---
>  fs/nfs/filelayout/Makefile                                 |  5 +++++
>  fs/nfs/{nfs4filelayout.c => filelayout/filelayout.c}       | 10 +++++-----
>  fs/nfs/{nfs4filelayout.h => filelayout/filelayout.h}       |  2 +-
>  fs/nfs/{nfs4filelayoutdev.c => filelayout/filelayoutdev.c} |  6 +++---
>  5 files changed, 15 insertions(+), 12 deletions(-)
>  create mode 100644 fs/nfs/filelayout/Makefile
>  rename fs/nfs/{nfs4filelayout.c => filelayout/filelayout.c} (99%)
>  rename fs/nfs/{nfs4filelayout.h => filelayout/filelayout.h} (99%)
>  rename fs/nfs/{nfs4filelayoutdev.c => filelayout/filelayoutdev.c} (99%)
> 
> diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
> index 551d82a..43058f7 100644
> --- a/fs/nfs/Makefile
> +++ b/fs/nfs/Makefile
> @@ -29,8 +29,6 @@ nfsv4-$(CONFIG_NFS_USE_LEGACY_DNS) += cache_lib.o
>  nfsv4-$(CONFIG_SYSCTL)	+= nfs4sysctl.o
>  nfsv4-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
>  
> -obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
> -nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
> -
> +obj-$(CONFIG_PNFS_FILE_LAYOUT) += filelayout/
>  obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
>  obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
> diff --git a/fs/nfs/filelayout/Makefile b/fs/nfs/filelayout/Makefile
> new file mode 100644
> index 0000000..8516cdf
> --- /dev/null
> +++ b/fs/nfs/filelayout/Makefile
> @@ -0,0 +1,5 @@
> +#
> +# Makefile for the pNFS Files Layout Driver kernel module
> +#
> +obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
> +nfs_layout_nfsv41_files-y := filelayout.o filelayoutdev.o
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/filelayout/filelayout.c
> similarity index 99%
> rename from fs/nfs/nfs4filelayout.c
> rename to fs/nfs/filelayout/filelayout.c
> index 7954e16..ffc2ed8 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/filelayout/filelayout.c
> @@ -35,11 +35,11 @@
>  
>  #include <linux/sunrpc/metrics.h>
>  
> -#include "nfs4session.h"
> -#include "internal.h"
> -#include "delegation.h"
> -#include "nfs4filelayout.h"
> -#include "nfs4trace.h"
> +#include "../nfs4session.h"
> +#include "../internal.h"
> +#include "../delegation.h"
> +#include "filelayout.h"
> +#include "../nfs4trace.h"
>  
>  #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
>  
> diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/filelayout/filelayout.h
> similarity index 99%
> rename from fs/nfs/nfs4filelayout.h
> rename to fs/nfs/filelayout/filelayout.h
> index cebd20e..ffbddf2 100644
> --- a/fs/nfs/nfs4filelayout.h
> +++ b/fs/nfs/filelayout/filelayout.h
> @@ -30,7 +30,7 @@
>  #ifndef FS_NFS_NFS4FILELAYOUT_H
>  #define FS_NFS_NFS4FILELAYOUT_H
>  
> -#include "pnfs.h"
> +#include "../pnfs.h"
>  
>  /*
>   * Default data server connection timeout and retrans vaules.
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/filelayout/filelayoutdev.c
> similarity index 99%
> rename from fs/nfs/nfs4filelayoutdev.c
> rename to fs/nfs/filelayout/filelayoutdev.c
> index efac602..7c85390 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/filelayout/filelayoutdev.c
> @@ -33,9 +33,9 @@
>  #include <linux/module.h>
>  #include <linux/sunrpc/addr.h>
>  
> -#include "internal.h"
> -#include "nfs4session.h"
> -#include "nfs4filelayout.h"
> +#include "../internal.h"
> +#include "../nfs4session.h"
> +#include "filelayout.h"
>  
>  #define NFSDBG_FACILITY		NFSDBG_PNFS_LD
>  

Looks good.

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
