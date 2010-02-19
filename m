From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH] nfsd: default to kernel default for minorversion 1
Date: Thu, 18 Feb 2010 21:07:22 -0500
Message-ID: <20100219020722.GF8602@fieldses.org>
References: <20100201195821.GB19418@fieldses.org> <4B6B480C.1050307@RedHat.com> <20100205161001.GB24926@fieldses.org> <20100205192859.GE24926@fieldses.org> <20100205200501.GA28483@fieldses.org> <4B75B2DF.9060005@RedHat.com> <20100212200548.GB23361@fieldses.org> <4B75CBA3.8010001@RedHat.com> <20100212215524.GF24661@fieldses.org> <4B7C47A2.4010100@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753122Ab0BSCGh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Feb 2010 21:06:37 -0500
In-Reply-To: <4B7C47A2.4010100-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 17, 2010 at 02:46:42PM -0500, Steve Dickson wrote:
> The fact there needed to be yet another code change to
> re-enabled the 4.1 functionality bother me... So This
> patch basically does the same as your patch, does not
> write "+4.1" to the versions file. But it also introduces
> a configuration variable that will allow us to re-enabled
> the functionality w/out changing any code...

The correct way to enable 4.1 functionality is with a patch to the
kernel that changes 4.1 to default to on.  We'll do that once a minimal
4.1 implementation is finished.

What this patch does is allow a distribution to force 4.1 on by default
even for kernel which have not reached that level of maturity.  I
would strongly advise *against* any distribution building with such an
option.

In addition, this patch disables -N4 in the disable_nfsv4 case, which is
incorrect; a user that doesn't wish nfs-utils to override the kernel's
default should still be able to turn off 4.1 on kernels that do default
4.1 to on.

Please don't do this.

--b.

> 
> BTW, there was precedence with adding this type of 
> configuration variable since there has been
> NFS3_SUPPORTED and NFS4_SUPPORTED variables in the 
> past.
> 
> steved.
> 
> commit 6d5ac3fa75024be569b458f4d9b6ce05be47f601
> Author: Steve Dickson <steved@redhat.com>
> Date:   Wed Feb 17 14:38:19 2010 -0500
> 
>     nfsd: Disble NFS 4.1 functionality by default
>     
>     Due to the fact the current kernel code do not completely
>     conform to the NFS 4.1 RFC, this patch disable the 4.1 support
>     on the server.
>     
>     To control this 41 functionality, the NFS41_SUPPORTED
>     configuration variable now exist that will allow us to
>     re enable the functionality  without any code changes.
>     
>     Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> diff --git a/configure.ac b/configure.ac
> index 1dc4249..f6b1189 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -72,6 +72,20 @@ AC_ARG_ENABLE(nfsv4,
>  	AC_SUBST(IDMAPD)
>  	AC_SUBST(enable_nfsv4)
>  	AM_CONDITIONAL(CONFIG_NFSV4, [test "$enable_nfsv4" = "yes"])
> +
> +AC_ARG_ENABLE(nfsv41,
> +	[AC_HELP_STRING([--enable-nfsv41],
> +                        [enable support for NFSv41 @<:@default=no@:>@])],
> +	enable_nfsv41=$enableval,
> +	enable_nfsv41=no)
> +	if test "$enable_nfsv41" = yes; then
> +		AC_DEFINE(NFS41_SUPPORTED, 1, [Define this if you want NFSv41 support compiled in])
> +	else
> +		enable_nfsv4=
> +	fi
> +	AC_SUBST(enable_nfsv41)
> +	AM_CONDITIONAL(CONFIG_NFSV41, [test "$enable_nfsv41" = "yes"])
> +
>  AC_ARG_ENABLE(gss,
>  	[AC_HELP_STRING([--enable-gss],
>                          [enable support for rpcsec_gss @<:@default=yes@:>@])],
> diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
> index a64eb0a..c939d78 100644
> --- a/support/include/nfs/nfs.h
> +++ b/support/include/nfs/nfs.h
> @@ -1,6 +1,8 @@
>  #ifndef _NFS_NFS_H
>  #define _NFS_NFS_H
>  
> +#include <config.h>
> +
>  #include <linux/posix_types.h>
>  #include <sys/types.h>
>  #include <netinet/in.h>
> @@ -14,7 +16,11 @@
>  #define NFSD_MAXVERS 4
>  
>  #define NFSD_MINMINORVERS4 1
> +#ifdef  NFS41_SUPPORTED
>  #define NFSD_MAXMINORVERS4 1
> +#else
> +#define NFSD_MAXMINORVERS4 0
> +#endif
>  
>  struct nfs_fh_len {
>  	int		fh_size;
> 
