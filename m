Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57212 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932401AbeCJQeH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 10 Mar 2018 11:34:07 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1D4884E918
        for <linux-nfs@vger.kernel.org>; Sat, 10 Mar 2018 16:34:07 +0000 (UTC)
Subject: Re: [PATCH] nfs-utils: Test if extra compiler warnings are available
To: Justin Mitchell <jumitche@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1520444246.7682.9.camel@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <8043f26d-c5e1-068e-5806-78381e8a77c6@RedHat.com>
Date: Sat, 10 Mar 2018 11:34:06 -0500
MIME-Version: 1.0
In-Reply-To: <1520444246.7682.9.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/07/2018 12:37 PM, Justin Mitchell wrote:
> Some of the latest compiler warnings flags are not available
> on older compilers so this adds macros to test they are supported
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
Committed... after a few changes... 

steved.
> ---
>  configure.ac | 21 +++++++++++++++++----
>  1 file changed, 17 insertions(+), 4 deletions(-)
> 
> diff --git a/configure.ac b/configure.ac
> index f4eba1f..e0c9039 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -550,7 +550,6 @@ my_am_cflags="\
>   -Werror=strict-prototypes \
>   -Werror=missing-prototypes \
>   -Werror=missing-declarations \
> - -Werror=format-overflow=2 \
>   -Werror=format=2 \
>   -Werror=undef \
>   -Werror=missing-include-dirs \
> @@ -560,15 +559,29 @@ my_am_cflags="\
>   -Werror=return-type \
>   -Werror=switch \
>   -Werror=overflow \
> - -Werror=int-conversion \
>   -Werror=parentheses \
> - -Werror=incompatible-pointer-types \
> - -Werror=misleading-indentation \
>   -Werror=aggregate-return \
>   -Werror=unused-result \
>   -fno-strict-aliasing \
>  "
>  
> +AC_DEFUN([CHECK_CCSUPPORT], [
> +  my_save_cflags="$CFLAGS"
> +  CFLAGS=$1
> +  AC_MSG_CHECKING([whether CC supports $1])
> +  AC_COMPILE_IFELSE([AC_LANG_PROGRAM([])],
> +    [AC_MSG_RESULT([yes])]
> +    [$2+=$1],
> +    [AC_MSG_RESULT([no])]
> +  )
> +  CFLAGS="$my_save_cflags"
> +])
> +
> +CHECK_CCSUPPORT([-Werror=format-overflow=2], [my_am_cflags])
> +CHECK_CCSUPPORT([-Werror=int-conversion], [my_am_cflags])
> +CHECK_CCSUPPORT([-Werror=incompatible-pointer-types], [my_am_cflags])
> +CHECK_CCSUPPORT([-Werror=misleading-indentation], [my_am_cflags])
> +
>  AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
>  
>  # Make sure that $ACLOCAL_FLAGS are used during a rebuild
> 
