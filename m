Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59498 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950Ab1LTTSK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Dec 2011 14:18:10 -0500
Date: Tue, 20 Dec 2011 14:17:49 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/7] nfsdcld: add autoconf goop for sqlite
Message-ID: <20111220141749.583ce3d0@tlielax.poochiereds.net>
In-Reply-To: <1323974641-16515-4-git-send-email-jlayton@redhat.com>
References: <1323974641-16515-1-git-send-email-jlayton@redhat.com>
	<1323974641-16515-4-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 15 Dec 2011 13:43:57 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> Mostly cribbed from Chuck Lever's new-statd rewrite a few years ago...
> 

Sending this to Bruce and Steve, but cc'ing the list in case other
people have thoughts...

I have a couple of questions about configure/build behavior when the
dependencies aren't present on the build system. The patch below
autodisables the building of nfsdcld when sqlite isn't there or isn't
functional, etc.

This is probably fine initially, but eventually I'd like to see the
old state tracking code go away. At that point, this daemon will be
required for NFSv4 serving.

Some questions:

1) does anyone have a problem with deprecating the old state tracking
code? I'd prefer we not maintain it in perpetuity, but maybe there's an
argument for keeping it around?

2) assuming we do want to eventually deprecate the old code. When
should we plan to do this. Assuming that this goes into 3.3 and we add
sufficient printk warnings when the old tracker is used, the earliest
we could remove it is 3.5. Is that too aggressive?

3) again, assuming that we want to deprecate the old code eventually,
does it make sense to autodisable the daemon when the build deps aren't
sufficient for it? With it be better to make the build error out when
--enable-nfsv4 is "yes" and not bother with a new --enable option for
this daemon?

I probably will also need to add a autoconf test for inotify too.
Having an answer to these questions may save me from a lot of complex
autoconf hacking....

Thanks,

> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  aclocal/libsqlite3.m4 |   33 +++++++++++++++++++++++++++++++++
>  configure.ac          |   22 ++++++++++++++++++++++
>  utils/Makefile.am     |    5 ++++-
>  3 files changed, 59 insertions(+), 1 deletions(-)
>  create mode 100644 aclocal/libsqlite3.m4
> 
> diff --git a/aclocal/libsqlite3.m4 b/aclocal/libsqlite3.m4
> new file mode 100644
> index 0000000..73d1e46
> --- /dev/null
> +++ b/aclocal/libsqlite3.m4
> @@ -0,0 +1,33 @@
> +dnl Checks for matching sqlite3 header and library, and
> +dnl sufficient sqlite3 version.
> +dnl
> +AC_DEFUN([AC_SQLITE3_VERS], [
> +  AC_CHECK_HEADERS([sqlite3.h], ,)
> +
> +  dnl look for the library; do not add to LIBS if found
> +  AC_CHECK_LIB([sqlite3], [sqlite3_libversion_number], [LIBSQLITE=-lsqlite3], ,)
> +  AC_SUBST(LIBSQLITE)
> +
> +  AC_MSG_CHECKING(for suitable sqlite3 version)
> +
> +  AC_CACHE_VAL([libsqlite3_cv_is_recent],
> +   [
> +    saved_LIBS="$LIBS"
> +    LIBS=-lsqlite3
> +    AC_TRY_RUN([
> +	#include <stdio.h>
> +	#include <sqlite3.h>
> +	int main()
> +	{
> +		int vers = sqlite3_libversion_number();
> +
> +		return vers != SQLITE_VERSION_NUMBER ||
> +			vers < 3003000;
> +	}
> +       ], [libsqlite3_cv_is_recent=yes], [libsqlite3_cv_is_recent=no],
> +       [libsqlite3_cv_is_recent=unknown])
> +    LIBS="$saved_LIBS"])
> +
> +  AC_MSG_RESULT($libsqlite3_cv_is_recent)
> +  AM_CONDITIONAL(CONFIG_SQLITE3, [test "$libsqlite3_cv_is_recent" = "yes"])
> +])dnl
> diff --git a/configure.ac b/configure.ac
> index c5b6a0f..bf018a2 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -186,6 +186,12 @@ else
>  	AM_CONDITIONAL(MOUNT_CONFIG, [test "$enable_mount" = "yes"])
>  fi
>  
> +AC_ARG_ENABLE(nfsdcld,
> +	[AC_HELP_STRING([--enable-nfsdcld],
> +			[Create nfsdcld NFSv4 clientid tracking daemon. <:@default=yes@:>@])],
> +	enable_nfsdcld=$enableval,
> +	enable_nfsdcld="maybe")
> +
>  dnl Check for TI-RPC library and headers
>  AC_LIBTIRPC
>  
> @@ -259,6 +265,9 @@ if test "$enable_nfsv4" = yes; then
>    dnl check for the keyutils libraries and headers
>    AC_KEYUTILS
>  
> +  dnl Check for sqlite3
> +  AC_SQLITE3_VERS
> +
>    dnl librpcsecgss already has a dependency on libgssapi,
>    dnl but we need to make sure we get the right version
>    if test "$enable_gss" = yes; then
> @@ -328,6 +337,19 @@ fi
>  dnl Check for IPv6 support
>  AC_IPV6
>  
> +dnl Decide what to do with nfsdcld based on sqlite3 test result
> +if test "$enable_nfsv4" = "yes" -a "$libsqlite3_cv_is_recent" != "yes" ; then
> +	if test "$enable_nfsdcld" = "yes"; then
> +		AC_MSG_ERROR([nfsdcld requires sqlite3])
> +	elif test "$enable_nfsdcld" != "no"; then
> +		AC_MSG_WARN([nfsdcld requires sqlite3, autodisabling it])
> +		enable_nfsdcld="no"
> +	fi
> +fi
> +
> +dnl Now set CONFIG_NFSDCLD properly
> +AM_CONDITIONAL(CONFIG_NFSDCLD, [test "$enable_nfsdcld" != "no" ])
> +
>  dnl *************************************************************
>  dnl Check for headers
>  dnl *************************************************************
> diff --git a/utils/Makefile.am b/utils/Makefile.am
> index f42c7ee..5df7ca7 100644
> --- a/utils/Makefile.am
> +++ b/utils/Makefile.am
> @@ -21,8 +21,11 @@ if CONFIG_MOUNT
>  OPTDIRS += mount
>  endif
>  
> +if CONFIG_NFSDCLD
> +OPTDIRS += nfsdcld
> +endif
> +
>  SUBDIRS = \
> -	nfsdcld \
>  	exportfs \
>  	mountd \
>  	nfsd \


-- 
Jeff Layton <jlayton@redhat.com>
