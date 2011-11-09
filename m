Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37118 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752741Ab1KITzM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Nov 2011 14:55:12 -0500
Date: Wed, 9 Nov 2011 14:55:10 -0500
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <benny@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: Subject: [PATCH] SQUASHME: pnfsd: nfs4pnfsd.c should dprint
 under NFSDDBG_PNFS
Message-ID: <20111109195510.GA2227@fieldses.org>
References: <4EB9F8D6.1080302@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EB9F8D6.1080302@panasas.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 08, 2011 at 07:51:50PM -0800, Boaz Harrosh wrote:
> 
> I've been squinting  at pnfsd dprints for ages and aching under the wait. So I headed
> up to the nfsd/debug.h to add a PNFS channel, and what do you know? there is one!
> It's used by nfs4pnfsds.c. Surly  nfs4pnfsd.c is more _PNFS than _PROC.

Hey now, nfs4pnfsd.c has enough problems of its own without being
accused of surliness.

--b.

> 
> While at it I changed  nfs4pnfsdlm.c to, also already defined, NFSDDBG_FILELAYOUT
> which was unused before this patch.
> 
> CC: Steve Dickson <steved@redhat.com>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfsd/nfs4pnfsd.c   |    2 +-
>  fs/nfsd/nfs4pnfsdlm.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
> index 18b8fca..f514ebe 100644
> --- a/fs/nfsd/nfs4pnfsd.c
> +++ b/fs/nfsd/nfs4pnfsd.c
> @@ -23,7 +23,7 @@
>  
>  #include "pnfsd.h"
>  
> -#define NFSDDBG_FACILITY                NFSDDBG_PROC
> +#define NFSDDBG_FACILITY                NFSDDBG_PNFS
>  
>  /* Globals */
>  static u32 current_layoutid = 1;
> diff --git a/fs/nfsd/nfs4pnfsdlm.c b/fs/nfsd/nfs4pnfsdlm.c
> index abc4d83..0f0441a 100644
> --- a/fs/nfsd/nfs4pnfsdlm.c
> +++ b/fs/nfsd/nfs4pnfsdlm.c
> @@ -30,7 +30,7 @@
>  #include "nfsfh.h"
>  #include "nfsd.h"
>  
> -#define NFSDDBG_FACILITY                NFSDDBG_PROC
> +#define NFSDDBG_FACILITY                NFSDDBG_FILELAYOUT
>  
>  /* Just use a linked list. Do not expect more than 32 dlm_device_entries
>   * the first implementation will just use one device per cluster file system
> -- 
> 1.7.6.2
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
