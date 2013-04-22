Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18777 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752885Ab3DVRT3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Apr 2013 13:19:29 -0400
Message-ID: <5175711C.2090504@RedHat.com>
Date: Mon, 22 Apr 2013 13:19:24 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mike Frysinger <vapier@gentoo.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH [nfs-utils]] do not fail sqlite check when cross-compiling
References: <1365883476-5288-1-git-send-email-vapier@gentoo.org>
In-Reply-To: <1365883476-5288-1-git-send-email-vapier@gentoo.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 13/04/13 16:04, Mike Frysinger wrote:
> If we're cross-compiling, we can't do a runtime test of sqlite,
> so just assume that the user has a good enough version rather
> than falling over.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Committed...

steved.

> ---
>  configure.ac | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/configure.ac b/configure.ac
> index 3d7ab0a..a594a7b 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -274,9 +274,14 @@ if test "$enable_nfsv4" = yes; then
>  	AC_CHECK_HEADERS([libgen.h sys/inotify.h], ,
>  		AC_MSG_ERROR([Cannot find header needed for nfsdcltrack]))
>  
> -  	if test "$libsqlite3_cv_is_recent" != "yes" ; then
> -		AC_MSG_ERROR([nfsdcltrack requires sqlite-devel])
> -	fi
> +    case $libsqlite3_cv_is_recent in
> +    yes) ;;
> +    unknown)
> +      dnl do not fail when cross-compiling
> +      AC_MSG_WARN([assuming sqlite is at least v3.3]) ;;
> +    *)
> +      AC_MSG_ERROR([nfsdcltrack requires sqlite-devel]) ;;
> +    esac
>    fi
>  
>  else
> 
