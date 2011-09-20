Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:19170 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243Ab1ITQZH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Sep 2011 12:25:07 -0400
Subject: Re: [PATCH 1/1] statd: Decouple statd's state directory from the NFS state directory
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@ORACLE.COM>
In-Reply-To: <1316531020-25071-1-git-send-email-steved@redhat.com>
Date: Tue, 20 Sep 2011 11:43:05 -0400
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <E962C83A-3848-4B5F-8E42-37099FFD146F@oracle.com>
References: <1316531020-25071-1-git-send-email-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 20, 2011, at 11:03 AM, Steve Dickson wrote:

> To allow greater flexibility to where statd's state is kept,
> statd's state path can now be decoupled from the normal
> NFS state directory.

statd has always allowed this via command line options.  What the patch does is allow distributions to specify a _default_ statd state directory that is not under /var/lib/nfs, via a convenient configure option instead of by patching.

This actually corrects a limitation introduced in January 2010 by me.  Previously the macro definitions allowed the default to be any directory, not just under /var/lib/nfs.  Introduced by commit f16fb1cd.

> In configure.ac, the NSM_STATD_PATH definition will now define
> the path to where the state information is kept. The default
> value, /var/lib/nfs, can be redefined with the --with-statdpath
> flag.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> configure.ac       |    9 +++++++++
> support/nsm/file.c |    7 ++-----
> 2 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/configure.ac b/configure.ac
> index b5934c4..7819d98 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -23,6 +23,14 @@ AC_ARG_WITH(statedir,
> 	statedir=$withval,
> 	statedir=/var/lib/nfs)
> 	AC_SUBST(statedir)
> +AC_ARG_WITH(statdpath,
> +	[AC_HELP_STRING([--with-statdpath=/foo @<:@default=/var/lib/nfs@:>@],
> +		[define statd's state dir as /foo instead of the NFS statedir]
> +	)],
> +	statdpath=$withval,
> +	statdpath=$statedir
> +	)
> +	AC_SUBST(statdpath)

Very clean!

> AC_ARG_WITH(statduser,
> 	[AC_HELP_STRING([--with-statduser=rpcuser],
>                         [statd to run under @<:@rpcuser or nobody@:>@]
> @@ -387,6 +395,7 @@ dnl *************************************************************
> dnl Export some path names to config.h
> dnl *************************************************************
> AC_DEFINE_UNQUOTED(NFS_STATEDIR, "$statedir", [This defines the location of the NFS state files. Warning: this must match definitions in config.mk!])
> +AC_DEFINE_UNQUOTED(NSM_STATD_PATH, "$statdpath", [Define this if you what statd file placed in somewhere other than NFS_STATEDIR])

The help text isn't quite accurate, since $statdpath is always defined now.  Something more like this:

  "Define this to the pathname where statd keeps its state files"

> if test "x$cross_compiling" = "xno"; then
> 	CFLAGS_FOR_BUILD=${CFLAGS_FOR_BUILD-"$CFLAGS"}
> diff --git a/support/nsm/file.c b/support/nsm/file.c
> index a12c753..d9da572 100644
> --- a/support/nsm/file.c
> +++ b/support/nsm/file.c
> @@ -95,12 +95,9 @@
> #define NSM_KERNEL_STATE_FILE	"/proc/sys/fs/nfs/nsm_local_state"
> 
> 
> - * Some distributions place statd's files in a subdirectory
> + * Defines where statd's state files live.
>  */
> -#define NSM_PATH_EXTENSION
> -/* #define NSM_PATH_EXTENSION	"/statd" */
> -
> -#define NSM_DEFAULT_STATEDIR		NFS_STATEDIR NSM_PATH_EXTENSION
> +#define NSM_DEFAULT_STATEDIR		NSM_STATD_PATH

IMO we don't need two macros that by definition always have the same value.  That will either get fixed or tripped on eventually, so I think it should be corrected now.

The cleanest approach would be to set up NSM_DEFAULT_STATEDIR in configure.ac, and drop the use of NSM_STATD_PATH.  Or you can replace the use of NSM_DEFAULT_STATEDIR everywhere in support/nsm/file.c.  Up to you.

> static char nsm_base_dirname[PATH_MAX] = NSM_DEFAULT_STATEDIR;
> 
> -- 
> 1.7.6.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




