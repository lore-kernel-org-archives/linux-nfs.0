Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55427 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750848Ab1GLOmM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2011 10:42:12 -0400
Message-ID: <4E1C5D41.6020403@RedHat.com>
Date: Tue, 12 Jul 2011 10:42:09 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Luk Claes <luk@debian.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Do not segfault because of kernel version
References: <20110704190003.GB12668@merit.edu> <1309844538-16008-1-git-send-email-luk@debian.org> <1309844538-16008-2-git-send-email-luk@debian.org>
In-Reply-To: <1309844538-16008-2-git-send-email-luk@debian.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 07/05/2011 01:42 AM, Luk Claes wrote:
> mount.nfs segfaults if kernel version number does not contain
> at least 3 components delimited with a dot.
> 
> Avoid this by matching up to three unsigned integers inialised
> to zero, separated by dots.
> 
> A version that does not start with an integer is probably a future
> version where the versioning evolved to another scheme.
> Return UINT_MAX which is guaranteed to be higher than existing
> versions. This would also make it possible to easily identify
> versions that do not start with an integer.
> 
> Signed-off-by: Luk Claes <luk@debian.org>
Committed....

steved.

> ---
>  utils/mount/version.h |   16 +++++++++-------
>  1 files changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/utils/mount/version.h b/utils/mount/version.h
> index af61a6f..531cf68 100644
> --- a/utils/mount/version.h
> +++ b/utils/mount/version.h
> @@ -23,8 +23,8 @@
>  #ifndef _NFS_UTILS_MOUNT_VERSION_H
>  #define _NFS_UTILS_MOUNT_VERSION_H
>  
> -#include <stdlib.h>
> -#include <string.h>
> +#include <stdio.h>
> +#include <limits.h>
>  
>  #include <sys/utsname.h>
>  
> @@ -37,14 +37,16 @@ static inline unsigned int MAKE_VERSION(unsigned int p, unsigned int q,
>  static inline unsigned int linux_version_code(void)
>  {
>  	struct utsname my_utsname;
> -	unsigned int p, q, r;
> +	unsigned int p, q = 0, r = 0;
>  
> +	/* UINT_MAX as backward compatibility code should not be run */
>  	if (uname(&my_utsname))
> -		return 0;
> +		return UINT_MAX;
>  
> -	p = (unsigned int)atoi(strtok(my_utsname.release, "."));
> -	q = (unsigned int)atoi(strtok(NULL, "."));
> -	r = (unsigned int)atoi(strtok(NULL, "."));
> +	/* UINT_MAX as future versions might not start with an integer */
> +	if (sscanf(my_utsname.release, "%u.%u.%u", &p, &q, &r) < 1)
> +		return UINT_MAX;
> +	
>  	return MAKE_VERSION(p, q, r);
>  }
>  
