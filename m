Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:40689 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757221Ab2ERAAb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 20:00:31 -0400
Subject: Re: [nfs-utils PATCH] build: avoid AM_CONDITIONAL in conditional execution.
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=iso-8859-1
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1337297671-9614-1-git-send-email-flameeyes@flameeyes.eu>
Date: Thu, 17 May 2012 20:00:26 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <F2544999-60EA-4192-90D5-44C79DEE82CC@oracle.com>
References: <1337297671-9614-1-git-send-email-flameeyes@flameeyes.eu>
To: =?iso-8859-1?Q?Diego_Elio_Petten=F2?= <flameeyes@flameeyes.eu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

On May 17, 2012, at 7:34 PM, Diego Elio Pettenò wrote:

> Automake does not support conditional AM_CONDITIONAL calls; what that
> means is that you always have to execute AM_CONDITIONAL one way or the
> other. Both the libsqlite3.m4 file and the nfsdcld conditionals are
> executed only when NFSv4 is enabled, which breaks building with
> --disable-nfsv4.
> 
> Remove the SQLite3 conditional altogether as it's never used, and move

Are we using sqlite3 at all at this point?

> the nfsdcld conditional outside of the conditional code.
> 
> Signed-off-by: Diego Elio Pettenò <flameeyes@flameeyes.eu>
> ---
> aclocal/libsqlite3.m4 |    1 -
> configure.ac          |    3 +--
> 2 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/aclocal/libsqlite3.m4 b/aclocal/libsqlite3.m4
> index 73d1e46..8c38993 100644
> --- a/aclocal/libsqlite3.m4
> +++ b/aclocal/libsqlite3.m4
> @@ -29,5 +29,4 @@ AC_DEFUN([AC_SQLITE3_VERS], [
>     LIBS="$saved_LIBS"])
> 
>   AC_MSG_RESULT($libsqlite3_cv_is_recent)
> -  AM_CONDITIONAL(CONFIG_SQLITE3, [test "$libsqlite3_cv_is_recent" = "yes"])
> ])dnl
> diff --git a/configure.ac b/configure.ac
> index 9ba53e2..b408f1b 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -278,8 +278,6 @@ if test "$enable_nfsv4" = yes; then
> 	fi
>   fi
> 
> -  AM_CONDITIONAL(CONFIG_NFSDCLD, [test "$enable_nfsdcld" = "yes" ])
> -
>   dnl librpcsecgss already has a dependency on libgssapi,
>   dnl but we need to make sure we get the right version
>   if test "$enable_gss" = yes; then
> @@ -293,6 +291,7 @@ if test "$enable_nfsv41" = yes; then
> fi
> 
> dnl enable nfsidmap when its support by libnfsidmap
> +AM_CONDITIONAL(CONFIG_NFSDCLD, [test "$enable_nfsdcld" = "yes" ])
> AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$ac_cv_header_keyutils_h$ac_cv_lib_nfsidmap_nfs4_owner_to_uid" = "yesyes"])
> 
> 
> -- 
> 1.7.8.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




