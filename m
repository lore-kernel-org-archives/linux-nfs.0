Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51409 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965410AbbKDVsT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 16:48:19 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 3FCFC935D1
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2015 21:48:19 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] Allow gssd and svcgssd to set the libtirpc
 debug level
To: Scott Mayhew <smayhew@redhat.com>
References: <1443541003-28073-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <563A7D21.5090802@RedHat.com>
Date: Wed, 4 Nov 2015 16:48:17 -0500
MIME-Version: 1.0
In-Reply-To: <1443541003-28073-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/29/2015 11:36 AM, Scott Mayhew wrote:
> The interface for controlling the debug level in libtirpc was added
> over a year ago, but nothing's taking advantage of it.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed.. after fixing a warning...

steved.

> ---
>  aclocal/libtirpc.m4  | 6 ++++++
>  utils/gssd/gssd.c    | 7 +++++++
>  utils/gssd/svcgssd.c | 7 +++++++
>  3 files changed, 20 insertions(+)
> 
> diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
> index b7de636..27368ff 100644
> --- a/aclocal/libtirpc.m4
> +++ b/aclocal/libtirpc.m4
> @@ -20,6 +20,12 @@ AC_DEFUN([AC_LIBTIRPC], [
>                                      [Define to 1 if your rpcsec library provides authgss_free_private_data])],,
>                           [${LIBS}])])
>  
> +     AS_IF([test -n "${LIBTIRPC}"],
> +           [AC_CHECK_LIB([tirpc], [libtirpc_set_debug],
> +                         [AC_DEFINE([HAVE_LIBTIRPC_SET_DEBUG], [1],
> +                                    [Define to 1 if your tirpc library provides libtirpc_set_debug])],,
> +                         [${LIBS}])])
> +
>    AC_SUBST([AM_CPPFLAGS])
>    AC_SUBST(LIBTIRPC)
>  
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index e480349..078e558 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -869,6 +869,13 @@ main(int argc, char *argv[])
>  	if (verbosity && rpc_verbosity == 0)
>  		rpc_verbosity = verbosity;
>  	authgss_set_debug_level(rpc_verbosity);
> +#elif HAVE_LIBTIRPC_SET_DEBUG
> +	/*
> +	 * Only set the libtirpc debug level if explicitly requested via -r...
> +	 * gssd is chatty enough as it is.
> +	 */
> +	if (rpc_verbosity > 0)
> +		libtirpc_set_debug(progname, rpc_verbosity, fg);
>  #else
>          if (rpc_verbosity > 0)
>  		printerr(0, "Warning: rpcsec_gss library does not "
> diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
> index f1b4347..0fe7c6d 100644
> --- a/utils/gssd/svcgssd.c
> +++ b/utils/gssd/svcgssd.c
> @@ -135,6 +135,13 @@ main(int argc, char *argv[])
>  	if (verbosity && rpc_verbosity == 0)
>  		rpc_verbosity = verbosity;
>  	authgss_set_debug_level(rpc_verbosity);
> +#elif HAVE_LIBTIRPC_SET_DEBUG
> +        /*
> +	 * Only set the libtirpc debug level if explicitly requested via -r...
> +	 * svcgssd is chatty enough as it is.
> +	 */
> +        if (rpc_verbosity > 0)
> +                libtirpc_set_debug(progname, rpc_verbosity, fg);
>  #else
>  	if (rpc_verbosity > 0)
>  		printerr(0, "Warning: rpcsec_gss library does not "
> 
