Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:13380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759168Ab2DZUHV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 16:07:21 -0400
Message-ID: <4F99AAEB.6080509@RedHat.com>
Date: Thu, 26 Apr 2012 16:07:07 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Nick Alcock <nix@esperi.org.uk>
CC: linux-nfs@vger.kernel.org, Nick Alcock <nick.alcock@oracle.com>
Subject: Re: [PATCH 3/4] No longer require NIS.
References: <1328472138-25750-1-git-send-email-nix@esperi.org.uk> <1328472138-25750-3-git-send-email-nix@esperi.org.uk>
In-Reply-To: <1328472138-25750-3-git-send-email-nix@esperi.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/05/2012 03:02 PM, Nick Alcock wrote:
> From: Nick Alcock <nick.alcock@oracle.com>
> 
> NIS is deader than the proverbial dodo, and eglibc allows you to compile it out
> entirely.  Though libtirpc can work with NIS, it works perfectly well if NIS
> is not in the libc, thanks to nsswitch (acting as if NIS is there but empty).
> However, when NIS is not compiled into eglibc, libnsl is not present.  So
> check for it at configure time, and include it via LIBS if available.
> (I suspect this LIBS-inclusion will have no effect, and we don't even need
> to check for NIS at compile time, but I have no NIS-capable systems to
> test this on.)
> 
> Signed-off-by: Nick Alcock <nick.alcock@oracle.com>
> ---
>  configure.ac    |    1 +
>  src/Makefile.am |    2 +-
>  2 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/configure.ac b/configure.ac
> index 97c6f2c..7ff80a4 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -23,6 +23,7 @@ AC_HEADER_DIRENT
>  AC_PREFIX_DEFAULT(/usr)
>  AC_CHECK_HEADERS([arpa/inet.h fcntl.h libintl.h limits.h locale.h netdb.h netinet/in.h stddef.h stdint.h stdlib.h string.h sys/ioctl.h sys/param.h sys/socket.h sys/time.h syslog.h unistd.h])
>  AC_CHECK_LIB([pthread], [pthread_create])
> +AC_CHECK_LIB([nsl], [yp_get_default_domain])
>  
>  
>  AC_CONFIG_FILES([Makefile src/Makefile man/Makefile doc/Makefile])
> diff --git a/src/Makefile.am b/src/Makefile.am
> index 509cf61..66350f5 100644
> --- a/src/Makefile.am
> +++ b/src/Makefile.am
> @@ -40,7 +40,7 @@ lib_LTLIBRARIES = libtirpc.la
>  # release number of your package. This is an abuse that only fosters
>  # misunderstanding of the purpose of library versions."
>  #
> -libtirpc_la_LDFLAGS = -lnsl -lpthread -version-info 1:10:0
> +libtirpc_la_LDFLAGS = -lpthread -version-info 1:10:0
>  
>  libtirpc_la_SOURCES = auth_none.c auth_unix.c authunix_prot.c bindresvport.c clnt_bcast.c \
>          clnt_dg.c clnt_generic.c clnt_perror.c clnt_raw.c clnt_simple.c \

Committed...

steved.
