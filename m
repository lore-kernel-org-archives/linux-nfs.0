Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39440 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750776AbbEGOPU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 10:15:20 -0400
Message-ID: <554B736D.90608@RedHat.com>
Date: Thu, 07 May 2015 10:15:09 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Kinglong Mee <kinglongmee@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Eino Juhani Oltedal <e.j.oltedal@fys.uio.no>
Subject: Re: [PATCH 2/3] configure.ac: fix configure fail with --disable-mount
References: <552E8FDF.8020104@gmail.com>
In-Reply-To: <552E8FDF.8020104@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/15/2015 12:20 PM, Kinglong Mee wrote:
> Configure fail as,
> # ./configure --disable-mount
> ... ...
> checking for suitable libblkid version... yes
> checking for mnt_context_do_mount in -lmount... no
> configure: error: libmount needed
> 
> It is caused by $enable_libmount is "" (not "yes" and "no")
> with --disable-mount.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  configure.ac | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
Committed...

steved.

> 
> diff --git a/configure.ac b/configure.ac
> index 21be2bd..d4301a2 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -346,7 +346,7 @@ AC_SUBST(LIBBSD)
>  AC_SUBST(LIBBLKID)
>  AC_SUBST(LIBDL)
>  
> -if test "$enable_libmount" != no; then
> +if test "$enable_libmount" == yes; then
>     AC_CHECK_LIB(mount, mnt_context_do_mount, [LIBMOUNT="-lmount"], AC_MSG_ERROR([libmount needed]))
>     AC_CHECK_HEADER(libmount/libmount.h, , AC_MSG_ERROR([Cannot find libmount header file libmount/libmount.h]))
>  fi
> 
