Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44206 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842Ab1GCFE3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Jul 2011 01:04:29 -0400
Date: Sun, 3 Jul 2011 15:04:21 +1000
From: NeilBrown <neilb@suse.de>
To: Luk Claes <luk@debian.org>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Do not segfault because of kernel version
Message-ID: <20110703150421.2db09d94@notabene.brown>
In-Reply-To: <1309617149-3993-1-git-send-email-luk@debian.org>
References: <1309617149-3993-1-git-send-email-luk@debian.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat,  2 Jul 2011 16:32:29 +0200 Luk Claes <luk@debian.org> wrote:

> mount.nfs segfaults if kernel version number does not contain
> at least 3 components delimited with a dot.
> 
> Avoid this by matching up to three unsigned integers inialised
> to zero, separated by dots.
> 
> Signed-off-by: Luk Claes <luk@debian.org>
> ---
>  utils/mount/version.h |   11 +++++------
>  1 files changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/utils/mount/version.h b/utils/mount/version.h
> index af61a6f..2642eab 100644
> --- a/utils/mount/version.h
> +++ b/utils/mount/version.h
> @@ -23,8 +23,7 @@
>  #ifndef _NFS_UTILS_MOUNT_VERSION_H
>  #define _NFS_UTILS_MOUNT_VERSION_H
>  
> -#include <stdlib.h>
> -#include <string.h>
> +#include <stdio.h>
>  
>  #include <sys/utsname.h>
>  
> @@ -37,14 +36,14 @@ static inline unsigned int MAKE_VERSION(unsigned int p, unsigned int q,
>  static inline unsigned int linux_version_code(void)
>  {
>  	struct utsname my_utsname;
> -	unsigned int p, q, r;
> +	unsigned int p, q = 0, r = 0;
>  
>  	if (uname(&my_utsname))
>  		return 0;
>  
> -	p = (unsigned int)atoi(strtok(my_utsname.release, "."));
> -	q = (unsigned int)atoi(strtok(NULL, "."));
> -	r = (unsigned int)atoi(strtok(NULL, "."));
> +	if (sscanf(my_utsname.release, "%u.%u.%u", &p, &q, &r) < 1)
> +		return 0;
> +	

According to Linus, the error case should return a big number, not a small
number.
So if the version number is not recognised - e.g. it was written in Sanskrit
rather than arabic numberals, it is assumed to be a future version, not a
past version.

 https://lkml.org/lkml/2011/6/14/293


NeilBrown

>  	return MAKE_VERSION(p, q, r);
>  }
>  

