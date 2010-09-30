From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] pnfs:  compile error in blocklayout code
Date: Thu, 30 Sep 2010 22:15:12 +0200
Message-ID: <4CA4EFD0.1040902@panasas.com>
References: <4CA4ED68.3090806@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36927 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751885Ab0I3UPO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Sep 2010 16:15:14 -0400
In-Reply-To: <4CA4ED68.3090806-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-09-30 22:04, Steve Dickson wrote:
> I needed to make the following change to get the
> block layout code to compile in a Fedora build 
> environment.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>

Merged. Thanks!

Benny

> 
> diff -up linux-2.6.35.x86_64/fs/nfs/blocklayout/blocklayout.h.orig linux-2.6.35.x86_64/fs/nfs/blocklayout/blocklayout.h
> --- linux-2.6.35.x86_64/fs/nfs/blocklayout/blocklayout.h.orig	2010-09-30 14:35:49.800480934 -0400
> +++ linux-2.6.35.x86_64/fs/nfs/blocklayout/blocklayout.h	2010-09-30 15:09:14.118105750 -0400
> @@ -34,7 +34,7 @@
>  
>  #include <linux/nfs_fs.h>
>  #include <linux/dm-ioctl.h> /* Needed for struct dm_ioctl*/
> -#include <../pnfs.h>
> +#include "../pnfs.h"
>  
>  #define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> 9)
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
