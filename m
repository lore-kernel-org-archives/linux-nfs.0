From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH 6/6] pnfsd: fix compile errors when CONFIG_PNFSD
 is	not set
Date: Tue, 09 Feb 2010 20:00:28 +0200
Message-ID: <4B71A2BC.5060302@panasas.com>
References: <1265737357-9405-1-git-send-email-andros@netapp.com>	<1265737357-9405-2-git-send-email-andros@netapp.com>	<1265737357-9405-3-git-send-email-andros@netapp.com>	<1265737357-9405-4-git-send-email-andros@netapp.com>	<1265737357-9405-5-git-send-email-andros@netapp.com>	<1265737357-9405-6-git-send-email-andros@netapp.com> <1265737357-9405-7-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24250 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754995Ab0BISAh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Feb 2010 13:00:37 -0500
In-Reply-To: <1265737357-9405-7-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I don't see any problems with CONFIG_PNFSD=n
both fs/nfsd/nfs4pnfsd.c and fs/nfsd/nfs4pnfsdlm.c are built only conditionally
with PNFSD is configured.

fs/nfsd/Makefile:
nfsd-$(CONFIG_PNFSD)	+= nfs4pnfsd.o nfs4pnfsdlm.o nfs4pnfsds.o

Benny

On Feb. 09, 2010, 19:42 +0200, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4pnfsd.c   |    4 ++++
>  fs/nfsd/nfs4pnfsdlm.c |    4 ++++
>  2 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index 75bddd8..44a1edd 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -21,6 +21,8 @@
>   *
>   *****************************************************************************/
>  
> +#if defined(CONFIG_PNFSD)
> +
>  #include "pnfsd.h"
>  
>  #define NFSDDBG_FACILITY                NFSDDBG_PROC
> @@ -1676,3 +1678,5 @@ int nfsd_device_notify_cb(struct super_block *sb,
>  		__func__, status, notify_num);
>  	return status;
>  }
> +
> +#endif /* CONFIG_PNFSD */
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index 83c4698..8e8a5a8 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -21,6 +21,8 @@
>   *
>   ******************************************************************************/
>  
> +#if defined(CONFIG_PNFSD)
> +
>  #include <linux/nfs4.h>
>  #include <linux/nfsd/const.h>
>  #include <linux/nfsd/debug.h>
> @@ -402,3 +404,5 @@ const struct pnfs_export_operations pnfs_dlm_export_ops = {
>  	.layout_get = nfsd4_pnfs_dlm_layoutget,
>  };
>  EXPORT_SYMBOL(pnfs_dlm_export_ops);
> +
> +#endif /* CONFIG_PNFSD */
