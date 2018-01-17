Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58736 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753614AbeAQQLf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Jan 2018 11:11:35 -0500
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 228088B107
        for <linux-nfs@vger.kernel.org>; Wed, 17 Jan 2018 16:11:35 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-117-42.phx2.redhat.com [10.3.117.42])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C3710609B4
        for <linux-nfs@vger.kernel.org>; Wed, 17 Jan 2018 16:11:34 +0000 (UTC)
Subject: Re: [PATCH] libio.h: Has been deprecated
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20180111170838.3427-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <5c766fdf-fb1b-d281-addd-34164e52a186@RedHat.com>
Date: Wed, 17 Jan 2018 11:11:34 -0500
MIME-Version: 1.0
In-Reply-To: <20180111170838.3427-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/11/2018 12:08 PM, Steve Dickson wrote:
> In the latest glib-headers libio.h has been deprecated
> This patch removes this warning:
> 
> /usr/include/libio.h:21:2: warning: #warning "<libio.h> is deprecated; use <stdio.h> instead." [-Wcpp]
>  #warning "<libio.h> is deprecated; use <stdio.h> instead."
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  configure.ac               | 2 +-
>  support/include/sockaddr.h | 4 +---
>  2 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/configure.ac b/configure.ac
> index 672dd40..2d328db 100644
> --- a/configure.ac
> +++ b/configure.ac
> @@ -456,7 +456,7 @@ AC_CHECK_HEADERS([arpa/inet.h fcntl.h libintl.h limits.h \
>                   stdlib.h string.h sys/file.h sys/ioctl.h sys/mount.h \
>                   sys/param.h sys/socket.h sys/time.h sys/vfs.h \
>                   syslog.h unistd.h com_err.h et/com_err.h \
> -                 ifaddrs.h nfs-plugin.h libio.h])
> +                 ifaddrs.h nfs-plugin.h])
>  
>  dnl *************************************************************
>  dnl Checks for typedefs, structures, and compiler characteristics
> diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
> index 446b537..eeebcdf 100644
> --- a/support/include/sockaddr.h
> +++ b/support/include/sockaddr.h
> @@ -24,9 +24,7 @@
>  #include <config.h>
>  #endif
>  
> -#ifdef HAVE_LIBIO_H
> -#include <libio.h>
> -#endif
> +#include <stdio.h>
>  #include <stdlib.h>
>  #include <stdbool.h>
>  #include <sys/socket.h>
> 
