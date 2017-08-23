Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42034 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932459AbdHWSsc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Aug 2017 14:48:32 -0400
Subject: Re: [PATCH v2 1/1] autotools: install rpcbind to --sbindir.
To: Michael Orlitzky <michael@orlitzky.com>, linux-nfs@vger.kernel.org
References: <20170801185525.13063-1-michael@orlitzky.com>
 <20170801185525.13063-2-michael@orlitzky.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <29f23ec0-621c-354d-5739-0b909528a788@RedHat.com>
Date: Wed, 23 Aug 2017 14:48:31 -0400
MIME-Version: 1.0
In-Reply-To: <20170801185525.13063-2-michael@orlitzky.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/01/2017 02:55 PM, Michael Orlitzky wrote:
> According to its own man page, the rpcbind program "can only be
> started by the super-user." On systems where a distinction is made, it
> therefore makes sense to install rpcbind to the autotools sbindir
> rather than the regular bindir where it is currently installed. This
> is accomplished by three small changes:
> 
>   1. Move rpcbind from bin_PROGRAMS to sbin_PROGRAMS in Makefile.am.
>   2. Change @_bindir@ to @_sbindir@ in the rpcbind systemd service file.
>   3. Tell configure.ac that it should substitute the value of $sbindir
>      into @_sbindir@ instead of $bindir$ into @_bindir@.
> 
> The rpcinfo tool remains where it is, in bindir, since unprivileged
> users are able to usefully run it. This avoids forcing maintainers to
> choose between two bad options: hiding rpcinfo from unprivileged
> users, or installing a useless rpcbind for them.
> 
> Signed-off-by: Michael Orlitzky <michael@orlitzky.com>
Committed.... 

steved.

> ---
>  Makefile.am                | 3 ++-
>  configure.ac               | 6 +++---
>  systemd/rpcbind.service.in | 2 +-
>  3 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/Makefile.am b/Makefile.am
> index 43c2710..c160a95 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -29,7 +29,8 @@ if LIBWRAP
>  AM_CPPFLAGS +=	-DLIBWRAP
>  endif
>  
> -bin_PROGRAMS = rpcbind rpcinfo
> +bin_PROGRAMS = rpcinfo
> +sbin_PROGRAMS = rpcbind
>  
>  rpcbind_SOURCES = \
>  	src/check_bound.c \
> diff --git a/configure.ac b/configure.ac
> index 3790310..359a418 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -61,9 +61,9 @@ AC_SEARCH_LIBS([pthread_create], [pthread])
>  
>  AC_CHECK_HEADERS([nss.h rpcsvc/mount.h])
>  
> -# make bindir available for substitution in config file
> +# make sbindir available for substitution in config file
>  # 2 "evals" needed to expand variable names
> -AC_SUBST([_bindir])
> -AC_CONFIG_COMMANDS_PRE([eval eval _bindir=$bindir])
> +AC_SUBST([_sbindir])
> +AC_CONFIG_COMMANDS_PRE([eval eval _sbindir=$sbindir])
>  
>  AC_OUTPUT([Makefile systemd/rpcbind.service])
> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
> index 03a9e0b..f8cfa9f 100644
> --- a/systemd/rpcbind.service.in
> +++ b/systemd/rpcbind.service.in
> @@ -12,7 +12,7 @@ After=rpcbind.socket
>  [Service]
>  Type=notify
>  # distro can provide a drop-in adding EnvironmentFile=-/??? if needed.
> -ExecStart=@_bindir@/rpcbind $RPCBIND_OPTIONS -w -f
> +ExecStart=@_sbindir@/rpcbind $RPCBIND_OPTIONS -w -f
>  
>  [Install]
>  WantedBy=multi-user.target
> 
