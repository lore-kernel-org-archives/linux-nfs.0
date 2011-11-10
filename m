Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34432 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835Ab1KJGzk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2011 01:55:40 -0500
Received: by fagn18 with SMTP id n18so185212fag.19
        for <linux-nfs@vger.kernel.org>; Wed, 09 Nov 2011 22:55:39 -0800 (PST)
Message-ID: <4EBB7568.5030706@tonian.com>
Date: Thu, 10 Nov 2011 08:55:36 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>
Subject: Re: Subject: [PATCH] SQUASHME: pnfsd: nfs4pnfsd.c should dprint under
 NFSDDBG_PNFS
References: <4EB9F8D6.1080302@panasas.com>
In-Reply-To: <4EB9F8D6.1080302@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-09 05:51, Boaz Harrosh wrote:
> 
> I've been squinting  at pnfsd dprints for ages and aching under the wait. So I headed
> up to the nfsd/debug.h to add a PNFS channel, and what do you know? there is one!
> It's used by nfs4pnfsds.c. Surly  nfs4pnfsd.c is more _PNFS than _PROC.
> 
> While at it I changed  nfs4pnfsdlm.c to, also already defined, NFSDDBG_FILELAYOUT
> which was unused before this patch.
> 
> CC: Steve Dickson <steved@redhat.com>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

Makes sense. Thanks!

Benny

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
