Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbaLHSEe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2014 13:04:34 -0500
Message-ID: <5485E82C.7030809@RedHat.com>
Date: Mon, 08 Dec 2014 13:04:28 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?UTF-8?B?RGF2aWQgSMOkcmRlbWFu?= <david@hardeman.nu>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] [RFC] nfs-utils: include headers from srcdir
References: <20141202123805.13015.25151.stgit@zeus.muc.hardeman.nu> <20141202124004.13015.5604.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141202124004.13015.5604.stgit@zeus.muc.hardeman.nu>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/02/2014 07:40 AM, David Härdeman wrote:
> Some of the headers in ./support/include get generated as part of the
> build process (and end up in the build dir hierarchy) and some are
> not (so they stay in the srcdir hierarchy).
> 
> That means the build breaks when using a separate build dir. I'm not sure
> what the best way to make sure that -I$(top_srcdir)/support/include is
> defined everywhere is. Consider this a basis for discussion rather than
> a real patch. Someone with more autoconf-fu can surely come up with a better
> solution.
This one I didn't commit because it caused -I../../support/include to 
defined twice. That path gets define ing  Makefile.in file in the 
DEFAULT_INCLUDES macro. 

steved.

> ---
>  configure.ac |    3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/configure.ac b/configure.ac
> index e3af723..5d0ab2b 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -479,6 +479,9 @@ my_am_cflags="-Wall -Wextra -Wstrict-prototypes $ARCHFLAGS -pipe"
>  
>  AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
>  
> +AM_CPPFLAGS="$AM_CPPFLAGS -I\$(top_srcdir)/support/include"
> +AC_SUBST([AM_CPPFLAGS])
> +
>  # Make sure that $ACLOCAL_FLAGS are used during a rebuild
>  AC_SUBST([ACLOCAL_AMFLAGS], ["-I $ac_macro_dir \$(ACLOCAL_FLAGS)"])
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
