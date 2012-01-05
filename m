Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54570 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754948Ab2AEVmd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jan 2012 16:42:33 -0500
Message-ID: <4F061943.1080403@RedHat.com>
Date: Thu, 05 Jan 2012 16:42:27 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mike Frysinger <vapier@gentoo.org>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsctl: fix building with newer arches
References: <1323323507-22609-1-git-send-email-vapier@gentoo.org>
In-Reply-To: <1323323507-22609-1-git-send-email-vapier@gentoo.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/08/2011 12:51 AM, Mike Frysinger wrote:
> Newer arches omitting both nfsctl and nfsservctl which breaks nfsctl.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Committed...

steved.
> ---
>  support/nfs/nfsctl.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/support/nfs/nfsctl.c b/support/nfs/nfsctl.c
> index 89fa1a4..fec775f 100644
> --- a/support/nfs/nfsctl.c
> +++ b/support/nfs/nfsctl.c
> @@ -11,16 +11,22 @@
>  #endif
>  
>  #include <unistd.h>
> +#include <errno.h>
>  #include <asm/unistd.h>
>  #include "nfslib.h"
>  
>  /* compatibility hack... */
> -#ifndef __NR_nfsctl
> +#if !defined(__NR_nfsctl) && defined(__NR_nfsservctl)
>  #define __NR_nfsctl	__NR_nfsservctl
>  #endif
>  
>  int
>  nfsctl (int cmd, struct nfsctl_arg * argp, union nfsctl_res * resp)
>  {
> +#ifdef __NR_nfsctl
>    return syscall (__NR_nfsctl, cmd, argp, resp);
> +#else
> +  errno = ENOSYS;
> +  return -1;
> +#endif
>  }
