Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22792 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751774Ab1LVOjT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Dec 2011 09:39:19 -0500
Date: Thu, 22 Dec 2011 09:38:55 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Mike Frysinger <vapier@gentoo.org>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: [PATCH] nfsidmap: auto disable when keyutils is not found
Message-ID: <20111222093855.40112b8c@tlielax.poochiereds.net>
In-Reply-To: <1314991015-21484-1-git-send-email-vapier@gentoo.org>
References: <1314991015-21484-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri,  2 Sep 2011 15:16:55 -0400
Mike Frysinger <vapier@gentoo.org> wrote:

> Since we already auto-disable based on libnfsidmap capabilities, don't
> make keyutils a hard failure.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  aclocal/keyutils.m4    |    4 ++--
>  aclocal/libnfsidmap.m4 |    3 +--
>  configure.ac           |    2 +-
>  3 files changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/aclocal/keyutils.m4 b/aclocal/keyutils.m4
> index 84bc112..a392c0e 100644
> --- a/aclocal/keyutils.m4
> +++ b/aclocal/keyutils.m4
> @@ -6,6 +6,6 @@ AC_DEFUN([AC_KEYUTILS], [
>    AC_CHECK_LIB([keyutils], [keyctl_instantiate], [LIBKEYUTILS=-lkeyutils], ,)
>    AC_SUBST(LIBKEYUTILS)
>  
> -  AC_CHECK_HEADERS([keyutils.h], ,
> -  		   [AC_MSG_ERROR([keyutils.h header not found.])])
> +  AC_CHECK_HEADERS([keyutils.h])
> +
>  ])dnl
> diff --git a/aclocal/libnfsidmap.m4 b/aclocal/libnfsidmap.m4
> index 4faa923..484b1ec 100644
> --- a/aclocal/libnfsidmap.m4
> +++ b/aclocal/libnfsidmap.m4
> @@ -15,7 +15,6 @@ AC_DEFUN([AC_LIBNFSIDMAP], [
>                            [Define to 1 if you have the `nfs4_set_debug' function.])])
>  
>    dnl only enable nfsidmap when libnfsidmap supports it
> -  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid], [enable_nfsidmap=yes],
> -               [enable_nfsidmap=no])
> +  AC_CHECK_LIB([nfsidmap], [nfs4_owner_to_uid])
>  
>  ])dnl

The above delta in this patch has caused a build-time regression.

When you eliminated the 3rd argument to AC_CHECK_LIB, this started
adding -lnfsidmap to $LIBS. That means that that library gets linked
into every binary that's being built.

I haven't determined the right fix for this yet, but I think
libnfsidmap.m4 could use some cleanup.

Any thoughts on the proper fix?

> diff --git a/configure.ac b/configure.ac
> index c9fb27b..1a28f8a 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -266,7 +266,7 @@ if test "$enable_nfsv4" = yes; then
>    fi
>  fi
>  dnl enable nfsidmap when its support by libnfsidmap
> -AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$enable_nfsidmap" = "yes"])
> +AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$ac_cv_header_keyutils_h$ac_cv_lib_nfsidmap_nfs4_owner_to_uid" = "yesyes"])
>  
>  
>  if test "$knfsd_cv_glibc2" = no; then

Cheers
-- 
Jeff Layton <jlayton@redhat.com>
