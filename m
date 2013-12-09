Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932835Ab3LIU6i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Dec 2013 15:58:38 -0500
Message-ID: <52A62F43.5050505@RedHat.com>
Date: Mon, 09 Dec 2013 15:59:47 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] configure.ac: Remove gssglue configuration knobs
References: <1386619559-31330-1-git-send-email-steved@redhat.com>
In-Reply-To: <1386619559-31330-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/12/13 15:05, Steve Dickson wrote:
> Its really not a good idea for libtirpc to link with
> libgssglue so this patch remove the ability to do that.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  configure.ac | 23 ++++-------------------
>  1 file changed, 4 insertions(+), 19 deletions(-)
Committed...

steved.

> 
> diff --git a/configure.ac b/configure.ac
> index b9906dc..6b0cf27 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -10,26 +10,11 @@ AC_ARG_ENABLE(gssapi,
>        [],[enable_gssapi=yes])
>  AM_CONDITIONAL(GSS, test x$enable_gssapi = xyes)
>  
> -AC_ARG_WITH(gssglue,
> -		[  --with-gssglue        Use libgssglue],
> -		 [case "${enableval}" in
> -		  yes) gssglue=true ;;
> -		  no)  gssglue=false ;;
> -		  *) AC_MSG_ERROR(bad value ${enableval} for --with-gssglue) ;;
> -		  esac],
> -		[gssglue=false])
> -AM_CONDITIONAL(USEGSSGLUE, test x$gssglue = xtrue)
> -
>  if test x$enable_gssapi = xyes; then
> -	if test x$gssglue = xtrue; then
> -		PKG_CHECK_MODULES(GSSAPI, libgssglue, [],
> -		AC_MSG_ERROR([Unable to locate information required to use libgssglue.]))
> -	else
> -		GSSAPI_CFLAGS=`krb5-config --cflags gssapi`
> -		GSSAPI_LIBS=`krb5-config --libs gssapi`
> -		AC_SUBST([GSSAPI_CFLAGS])
> -		AC_SUBST([GSSAPI_LIBS])
> -	fi
> +	GSSAPI_CFLAGS=`krb5-config --cflags gssapi`
> +	GSSAPI_LIBS=`krb5-config --libs gssapi`
> +	AC_SUBST([GSSAPI_CFLAGS])
> +	AC_SUBST([GSSAPI_LIBS])
>  fi
>  AC_ARG_ENABLE(ipv6,
>  	[AC_HELP_STRING([--disable-ipv6], [Disable IPv6 support @<:@default=no@:>@])],
> 
