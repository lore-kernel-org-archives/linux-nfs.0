Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52174 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759447Ab2JYM5S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Oct 2012 08:57:18 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q9PCvIll032616
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 25 Oct 2012 08:57:18 -0400
Message-ID: <5089372D.1050501@RedHat.com>
Date: Thu, 25 Oct 2012 08:57:17 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 10/10] nfsdcltrack: flip the default in autoconf to
 "yes" for it
References: <1351092359-25842-1-git-send-email-jlayton@redhat.com> <1351092359-25842-11-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351092359-25842-11-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 24/10/12 11:25, Jeff Layton wrote:
> Allow nfsdcltrack to be built by default if all of the requirements
> for it are in place. Set the initial state of $enable_nfsdcltrack
> to "maybe", and fix the appropriate tests to just disable building
> the binary unless someone explicitly requests it.
Hmm... I'm not sure I too keen on this "maybe" state... 

So if no flags are given to ./configuration, and not 
all the requirements to build nfsdcltrack exists, the configuration 
will succeed, but the command will not be build. Correct?

But if the  --enable_nfsdcltrack flag is given and not all
the requirements to build nfsdcltrack exist the configuration
will fail. 

I'm thinking we might want to make it a bit more binary. Either
on or off. Like it is with the other conditionally built 
commands... 

steved.
 
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  configure.ac | 24 +++++++++++++++++-------
>  1 file changed, 17 insertions(+), 7 deletions(-)
> 
> diff --git a/configure.ac b/configure.ac
> index 65d1bea..aa41e0a 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -187,9 +187,9 @@ fi
>  
>  AC_ARG_ENABLE(nfsdcltrack,
>  	[AC_HELP_STRING([--enable-nfsdcltrack],
> -			[enable NFSv4 clientid tracking programs @<:@default=no@:>@])],
> +			[enable NFSv4 clientid tracking programs @<:@default=yes@:>@])],
>  	enable_nfsdctrack=$enableval,
> -	enable_nfsdcltrack="no")
> +	enable_nfsdcltrack="maybe")
>  
>  dnl Check for TI-RPC library and headers
>  AC_LIBTIRPC
> @@ -269,12 +269,22 @@ if test "$enable_nfsv4" = yes; then
>    dnl Check for sqlite3
>    AC_SQLITE3_VERS
>  
> -  if test "$enable_nfsdcltrack" = "yes"; then
> +  if test "$enable_nfsdcltrack" != "no"; then
>  	AC_CHECK_HEADERS([libgen.h sys/inotify.h], ,
> -		AC_MSG_ERROR([Cannot find header needed for nfsdcltrack]))
> -
> -  	if test "$libsqlite3_cv_is_recent" != "yes" ; then
> +		if test "$enable_nfsdcltrack" = "yes"; then
> +			AC_MSG_ERROR([Cannot find header needed for nfsdcltrack])
> +		else
> +			AC_MSG_WARN([Cannot find header needed for nfsdcltrack. Disabling it.])
> +			enable_nfsdcltrack="no"
> +		fi
> +	)
> +  fi
> +  if test "$libsqlite3_cv_is_recent" != "yes" ; then
> +	if test "$enable_nfsdcltrack" = "yes"; then
>  		AC_MSG_ERROR([nfsdcltrack requires sqlite3])
> +	elif test "$enable_nfsdcltrack" != "no"; then
> +		AC_MSG_WARN([nfsdcltrack requires sqlite3. Disabling it.])
> +		enable_nfsdcltrack="no"
>  	fi
>    fi
>  
> @@ -292,7 +302,7 @@ if test "$enable_nfsv41" = yes; then
>  fi
>  
>  dnl enable nfsidmap when its support by libnfsidmap
> -AM_CONDITIONAL(CONFIG_NFSDCLTRACK, [test "$enable_nfsdcltrack" = "yes" ])
> +AM_CONDITIONAL(CONFIG_NFSDCLTRACK, [test "$enable_nfsdcltrack" != "no" ])
>  AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$ac_cv_header_keyutils_h$ac_cv_lib_nfsidmap_nfs4_owner_to_uid" = "yesyes"])
>  
>  
> 
