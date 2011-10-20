Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:46711 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755839Ab1JTBdg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Oct 2011 21:33:36 -0400
Message-ID: <4E9F7A63.7050708@panasas.com>
Date: Wed, 19 Oct 2011 18:33:23 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] rpcdebug: Add missing debug flags
References: <1319057013-19015-1-git-send-email-steved@redhat.com>
In-Reply-To: <1319057013-19015-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/19/2011 01:43 PM, Steve Dickson wrote:
> This patch added the following debug flags:
> 
> fscache - enable FSCache debugging
> pnfs - enable general pNFS debugging
> pnfs_ld - enable file layout pNFS debugging

"Any layout-driver debugging", not only files. We all use the same bit

Boaz

> 

> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  support/include/nfs/debug.h |    3 +++
>  tools/rpcdebug/rpcdebug.c   |    3 +++
>  2 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/support/include/nfs/debug.h b/support/include/nfs/debug.h
> index d391e91..dbec5ba 100644
> --- a/support/include/nfs/debug.h
> +++ b/support/include/nfs/debug.h
> @@ -76,6 +76,9 @@ enum {
>  #define NFSDBG_CALLBACK		0x0100
>  #define NFSDBG_CLIENT		0x0200
>  #define NFSDBG_MOUNT		0x0400
> +#define NFSDBG_FSCACHE		0x0800
> +#define NFSDBG_PNFS			0x1000
> +#define NFSDBG_PNFS_LD		0x2000
>  #define NFSDBG_ALL		0xFFFF
>  
>  #endif /* _NFS_DEBUG_H */
> diff --git a/tools/rpcdebug/rpcdebug.c b/tools/rpcdebug/rpcdebug.c
> index 275a491..444616d 100644
> --- a/tools/rpcdebug/rpcdebug.c
> +++ b/tools/rpcdebug/rpcdebug.c
> @@ -167,6 +167,9 @@ static struct flagmap {
>  	FLAG(NFS,       CALLBACK),
>  	FLAG(NFS,       CLIENT),
>  	FLAG(NFS,       MOUNT),
> +	FLAG(NFS,       FSCACHE),
> +	FLAG(NFS,       PNFS),
> +	FLAG(NFS,       PNFS_LD),
>  	FLAG(NFS,	ALL),
>  
>  	/* nfsd */

