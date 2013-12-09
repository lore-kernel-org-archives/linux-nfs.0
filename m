Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932814Ab3LIU6w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Dec 2013 15:58:52 -0500
Message-ID: <52A62F52.7070901@RedHat.com>
Date: Mon, 09 Dec 2013 16:00:02 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] configure.ac: enable the GSSAPI by default
References: <1386613948-28789-1-git-send-email-steved@redhat.com>
In-Reply-To: <1386613948-28789-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/12/13 13:32, Steve Dickson wrote:
> This changes GSSAPI support to be enabled by default.
> To disable the support use --disable-gssapi
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  configure.ac | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/configure.ac b/configure.ac
> index c95df38..b9906dc 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -5,12 +5,11 @@ AM_MAINTAINER_MODE
>  AC_CONFIG_SRCDIR([src/auth_des.c])
>  AC_CONFIG_MACRO_DIR([m4])
>  
> -AC_ARG_ENABLE(gss,[  --enable-gss            Turn on gss api], [case "${enableval}" in
> -        yes) gss=true ;;
> -        no)  gss=false ;;
> -        *) AC_MSG_ERROR(bad value ${enableval} for --enable-gss) ;;
> -      esac],[gss=false])
> -AM_CONDITIONAL(GSS, test x$gss = xtrue)
> +AC_ARG_ENABLE(gssapi,
> +	[AC_HELP_STRING([--disable-gssapi], [Disable GSSAPI support @<:@default=no@:>@])],
> +      [],[enable_gssapi=yes])
> +AM_CONDITIONAL(GSS, test x$enable_gssapi = xyes)
> +
>  AC_ARG_WITH(gssglue,
>  		[  --with-gssglue        Use libgssglue],
>  		 [case "${enableval}" in
> @@ -20,7 +19,8 @@ AC_ARG_WITH(gssglue,
>  		  esac],
>  		[gssglue=false])
>  AM_CONDITIONAL(USEGSSGLUE, test x$gssglue = xtrue)
> -if test x$gss = xtrue; then
> +
> +if test x$enable_gssapi = xyes; then
>  	if test x$gssglue = xtrue; then
>  		PKG_CHECK_MODULES(GSSAPI, libgssglue, [],
>  		AC_MSG_ERROR([Unable to locate information required to use libgssglue.]))
> 
