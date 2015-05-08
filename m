Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34885 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751578AbbEHDd2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 23:33:28 -0400
Message-ID: <554C2E86.6020304@RedHat.com>
Date: Thu, 07 May 2015 23:33:26 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Thorsten Kukuk <kukuk@suse.de>
CC: Mike Frysinger <vapier@gentoo.org>, libtirpc-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH V2] Fix Build w/gssapi disabled
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org> <20150507115248.GA20243@suse.de> <554B86E2.8090908@RedHat.com> <20150507163326.GA6156@suse.de> <554B98E9.4040601@RedHat.com> <20150507181206.GA7810@suse.de> <554BC53C.5080807@RedHat.com> <554BC730.3000004@RedHat.com> <554BC9F3.6020005@RedHat.com>
In-Reply-To: <554BC9F3.6020005@RedHat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/07/2015 04:24 PM, Steve Dickson wrote:
> This version seems to work now.
> 
> I wonder if this warrants a 0.3.1 release...
> 
> How do other library deal with API breakage?   
> 
> steved.
> 
> From 6cc5a243f62fbe32fe5f24f4c549a42b1c2b4adc Mon Sep 17 00:00:00 2001
> From: Thorsten Kukuk <kukuk@suse.de>
> Date: Thu, 7 May 2015 16:14:04 -0400
> Subject: [PATCH] Fix Build w/gssapi disabled
> 
> A regression was introduced by commit d5259e75 that
> broke the --disable-gssapi configuration flag
> causing numerous compile errors.
> 
> This patch fixes those errors but then the config
> flag is used it breaks API with previous releases.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  .gitignore                |  2 ++
>  Makefile.am               |  4 +++-
>  configure.ac              |  3 ++-
>  src/svc_auth_gss.c        |  5 ++++-
>  tirpc/rpc/rpc.h           |  4 +++-
>  tirpc/rpc/svc_auth.h      |  8 ++++++++
>  tirpc/tirpc-features.h.in | 10 ++++++++++
>  7 files changed, 32 insertions(+), 4 deletions(-)
>  create mode 100644 tirpc/tirpc-features.h.in
> 
> diff --git a/.gitignore b/.gitignore
> index b7814a3..fad274f 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -34,6 +34,8 @@ libtirpc.pc
>  lib*.a
>  src/libtirpc.la
>  src/libtirpc_la-*.lo
> +tirpc/stamp-h2
> +tirpc/tirpc-features.h
>  # generic editor backup et al
>  *~
>  .stgitmail.txt
> diff --git a/Makefile.am b/Makefile.am
> index 2bf725c..2bce3b0 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -4,9 +4,11 @@ ACLOCAL_AMFLAGS = -I m4
>  noinst_HEADERS	       = tirpc/reentrant.h \
>  			 tirpc/getpeereid.h \
>  			 tirpc/libc_private.h \
> -			 tirpc/un-namespace.h
> +			 tirpc/un-namespace.h \
> +			 tirpc/tirpc-features.h.in
>  
>  nobase_include_HEADERS = tirpc/netconfig.h \
> +			 tirpc/tirpc-features.h \
>  			 tirpc/rpcsvc/crypt.x \
>  			 tirpc/rpcsvc/crypt.h \
>  			 tirpc/rpc/xdr.h \
> diff --git a/configure.ac b/configure.ac
> index 711b054..290c635 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -10,6 +10,7 @@ AC_ARG_ENABLE(gssapi,
>  AM_CONDITIONAL(GSS, test "x$enable_gssapi" = xyes)
>  
>  if test "x$enable_gssapi" = xyes; then
> +	AC_DEFINE([HAVE_GSSAPI], [1], [Define to 1 if GSSAPI is enabled])
>  	GSSAPI_CFLAGS=`krb5-config --cflags gssapi`
>  	GSSAPI_LIBS=`krb5-config --libs gssapi`
>  	AC_SUBST([GSSAPI_CFLAGS])
> @@ -41,7 +42,7 @@ AC_ARG_ENABLE(symvers,
>  AM_CONDITIONAL(SYMVERS, test "x$enable_symvers" = xyes)
>  
>  AC_PROG_CC
> -AC_CONFIG_HEADERS([config.h])
> +AC_CONFIG_HEADERS([config.h tirpc/tirpc-features.h])
>  AC_PROG_LIBTOOL
>  AC_HEADER_DIRENT
>  AC_PREFIX_DEFAULT(/usr)
> diff --git a/src/svc_auth_gss.c b/src/svc_auth_gss.c
> index d95eae1..e0a5c6a 100644
> --- a/src/svc_auth_gss.c
> +++ b/src/svc_auth_gss.c
> @@ -34,8 +34,11 @@
>  
>   */
>  
> -#include <sys/types.h>
> +#ifdef HAVE_CONFIG_H
> +#include "config.h"
> +#endif
>  
> +#include <sys/types.h>
>  #include <unistd.h>
>  #include <stdio.h>
>  #include <stdlib.h>
> diff --git a/tirpc/rpc/rpc.h b/tirpc/rpc/rpc.h
> index 1dbb391..8f37454 100644
> --- a/tirpc/rpc/rpc.h
> +++ b/tirpc/rpc/rpc.h
> @@ -35,6 +35,8 @@
>  #ifndef _TIRPC_RPC_H
>  #define _TIRPC_RPC_H
>  
> +#include <tirpc-features.h>
> +
>  #include <rpc/types.h>		/* some typedefs */
>  #include <sys/socket.h>
>  #include <netinet/in.h>
> @@ -60,7 +62,7 @@
>  #include <rpc/auth_des.h>	/* protocol for des style cred */
>  #endif /* HAVE_AUTHDES */
>  
> -#ifdef HAVE_RPCSEC_GSS
> +#ifdef HAVE_GSSAPI
>  #include <rpc/auth_gss.h>   /* RPCSEC_GSS */
>  #endif
>  
> diff --git a/tirpc/rpc/svc_auth.h b/tirpc/rpc/svc_auth.h
> index 44b38bf..dbd8cc9 100644
> --- a/tirpc/rpc/svc_auth.h
> +++ b/tirpc/rpc/svc_auth.h
> @@ -41,6 +41,10 @@
>  #ifndef _RPC_SVC_AUTH_H
>  #define _RPC_SVC_AUTH_H
>  
> +#include <tirpc-features.h>
> +
> +#ifdef HAVE_GSSAPI
> +
>  #include <rpc/rpcsec_gss.h>
>  
>  typedef struct {
> @@ -51,6 +55,8 @@ typedef struct {
>  	u_int			seq_num;
>  } svc_rpc_gss_parms_t;
>  
> +#endif /* HAVE_GSSAPI */
> +
>  /*
>   * Interface to server-side authentication flavors.
>   */
> @@ -63,8 +69,10 @@ typedef struct SVCAUTH {
>  		int     (*svc_ah_destroy)(struct SVCAUTH *);
>  		} *svc_ah_ops;
>  	caddr_t svc_ah_private;
> +#ifdef HAVE_GSSAPI
>  	svc_rpc_gss_parms_t svc_gss_params;
>  	rpc_gss_rawcred_t raw_cred;
> +#endif
>  } SVCAUTH;
>  
>  #define SVCAUTH_WRAP(auth, xdrs, xfunc, xwhere) \
> diff --git a/tirpc/tirpc-features.h.in b/tirpc/tirpc-features.h.in
> new file mode 100644
> index 0000000..72e18bc
> --- /dev/null
> +++ b/tirpc/tirpc-features.h.in
> @@ -0,0 +1,10 @@
> +#ifndef _TIRPC_FEATURES_H
> +#define _TIRPC_FEATURES_H
> +
> +/* Define to 1 if DES authentication is enabled */
> +#undef HAVE_AUTHDES
> +
> +/* Define to 1 if GSSAPI is enabled */
> +#undef HAVE_GSSAPI
> +
> +#endif /* _TIRPC_FEATURES_H */
> 
