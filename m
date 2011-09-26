Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348Ab1IZTWl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 15:22:41 -0400
Message-ID: <4E80D0FC.3070107@RedHat.com>
Date: Mon, 26 Sep 2011 15:22:36 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] add dependency on devmapper for blkmapd
References: <1316973011-6393-1-git-send-email-rees@umich.edu>
In-Reply-To: <1316973011-6393-1-git-send-email-rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/25/2011 01:50 PM, Jim Rees wrote:
> Signed-off-by: Jim Rees <rees@umich.edu>
Committed..

steved.

> ---
>  configure.ac |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/configure.ac b/configure.ac
> index 80fb39d..f101b86 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -265,6 +265,12 @@ if test "$enable_nfsv4" = yes; then
>      AC_RPCSEC_VERSION
>    fi
>  fi
> +
> +if test "$enable_nfsv41" = yes; then
> +  AC_CHECK_LIB([devmapper], [dm_task_create], [LIBDEVMAPPER="-ldevmapper"], AC_MSG_ERROR([libdevmapper needed]))
> +  AC_CHECK_HEADER(libdevmapper.h, , AC_MSG_ERROR([Cannot find devmapper header file libdevmapper.h]))
> +fi
> +
>  dnl enable nfsidmap when its support by libnfsidmap
>  AM_CONDITIONAL(CONFIG_NFSIDMAP, [test "$ac_cv_header_keyutils_h$ac_cv_lib_nfsidmap_nfs4_owner_to_uid" = "yesyes"])
>  
> -- 1.7.4.1
