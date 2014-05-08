Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:45847 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755131AbaEHXK0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 May 2014 19:10:26 -0400
Received: by mail-qc0-f170.google.com with SMTP id i8so3772555qcq.29
        for <linux-nfs@vger.kernel.org>; Thu, 08 May 2014 16:10:25 -0700 (PDT)
Date: Thu, 8 May 2014 19:10:23 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Thomas Haynes <thomas.haynes@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Push the file layout driver into a subdirectory
Message-ID: <20140508191023.070757f6@tlielax.poochiereds.net>
In-Reply-To: <1399584662-1913-1-git-send-email-Thomas.Haynes@primarydata.com>
References: <1399584662-1913-1-git-send-email-Thomas.Haynes@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu,  8 May 2014 14:31:02 -0700
Thomas Haynes <thomas.haynes@primarydata.com> wrote:

> From: Tom Haynes <Thomas.Haynes@primarydata.com>
> 
> The object and block layouts already exist in their own
> subdirectories. This patch completes the set!
> 
> Note that as a layout denotes nfs4 already, I stripped
> that prefix out of the file names.
> 
> Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>
> ---
>  fs/nfs/Makefile                                            |  4 +---
>  fs/nfs/filelayout/Kbuild                                   |  5 +++++
>  fs/nfs/{nfs4filelayout.c => filelayout/filelayout.c}       | 10 +++++-----
>  fs/nfs/{nfs4filelayout.h => filelayout/filelayout.h}       |  2 +-
>  fs/nfs/{nfs4filelayoutdev.c => filelayout/filelayoutdev.c} |  6 +++---
>  5 files changed, 15 insertions(+), 12 deletions(-)
>  create mode 100644 fs/nfs/filelayout/Kbuild
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
> diff --git a/fs/nfs/filelayout/Kbuild b/fs/nfs/filelayout/Kbuild

nit: supposedly the preferred name for these files is "Makefile",
though the objayout driver does seem to use "Kbuild". Probably best to
change that here since you're renaming files anyway...

> new file mode 100644
> index 0000000..8516cdf
> --- /dev/null
> +++ b/fs/nfs/filelayout/Kbuild
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

Looks good to me. Nice cleanup.

Acked-by: Jeff Layton <jlayton@poochiereds.net>
