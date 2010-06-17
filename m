From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] SQUASHME: move objlayout to the PNFS_LD dprint channel
Date: Thu, 17 Jun 2010 11:59:17 -0400
Message-ID: <4C1A4655.3090008@panasas.com>
References: <4C1926EF.4020002@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:27484 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756453Ab0FQP7M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 11:59:12 -0400
In-Reply-To: <4C1926EF.4020002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Merged at pnfs-all-2.6.35-rc3-2010-06-17

Thanks!

Benny

On Jun. 16, 2010, 15:33 -0400, Boaz Harrosh <bharrosh@panasas.com> wrote:
> 
> Signed-off-by: Boaz Harrosh <bharrosh-xFkOKRQa54hHeCz7Ayp15r+LScJ5NNVl@public.gmane.org>
> ---
>  fs/nfs/objlayout/objio_osd.c  |    2 +-
>  fs/nfs/objlayout/objlayout.c  |    2 +-
>  fs/nfs/objlayout/panfs_shim.c |    2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index 9079b7b..5f0612f 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -48,7 +48,7 @@
>  
>  #include "objlayout.h"
>  
> -#define NFSDBG_FACILITY         NFSDBG_PNFS
> +#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
>  
>  #define _LLU(x) ((unsigned long long)x)
>  
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> index ad56ab8..c380bf6 100644
> --- a/fs/nfs/objlayout/objlayout.c
> +++ b/fs/nfs/objlayout/objlayout.c
> @@ -42,7 +42,7 @@
>  #include <scsi/osd_initiator.h>
>  #include "objlayout.h"
>  
> -#define NFSDBG_FACILITY         NFSDBG_PNFS
> +#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
>  
>  struct pnfs_client_operations *pnfs_client_ops;
>  
> diff --git a/fs/nfs/objlayout/panfs_shim.c b/fs/nfs/objlayout/panfs_shim.c
> index 3c5baba..3f76233 100644
> --- a/fs/nfs/objlayout/panfs_shim.c
> +++ b/fs/nfs/objlayout/panfs_shim.c
> @@ -46,7 +46,7 @@
>  
>  #include <linux/panfs_shim_api.h>
>  
> -#define NFSDBG_FACILITY         NFSDBG_PNFS
> +#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
>  
>  struct panfs_export_operations *panfs_export_ops;
>  
