Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751127Ab1JTSzT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 14:55:19 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p9KItJGE021365
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 20 Oct 2011 14:55:19 -0400
Message-ID: <4EA06C3F.9010302@RedHat.com>
Date: Thu, 20 Oct 2011 14:45:19 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] rpcdebug: Add missing debug flags
References: <1319057013-19015-1-git-send-email-steved@redhat.com>
In-Reply-To: <1319057013-19015-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/19/2011 04:43 PM, Steve Dickson wrote:
> This patch added the following debug flags:
> 
> fscache - enable FSCache debugging
> pnfs - enable general pNFS debugging
> pnfs_ld - enable file layout pNFS debugging
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

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
