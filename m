Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754156Ab3BUPnV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2013 10:43:21 -0500
Message-ID: <51264088.8030501@RedHat.com>
Date: Thu, 21 Feb 2013 10:43:04 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mike Frysinger <vapier@gentoo.org>
CC: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH [rpcbind]] fix building one systems w/out nss.h
References: <1361299690-19402-1-git-send-email-vapier@gentoo.org>
In-Reply-To: <1361299690-19402-1-git-send-email-vapier@gentoo.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 19/02/13 13:48, Mike Frysinger wrote:
> The nss.h header is glibc-specific, so use the existing HAVE_NSS_H define
> to avoid including/using it when it is not available.
> 
> URL: http://bugs.gentoo.org/458024
> Reported-by: Mark Reiche <porphyr@gmx.de>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Committed...

steved.
> ---
>  src/rpcbind.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index 9a0504d..83dbe93 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -67,7 +67,11 @@
>  #include <pwd.h>
>  #include <string.h>
>  #include <errno.h>
> +#ifdef HAVE_NSS_H
>  #include <nss.h>
> +#else
> +static inline void __nss_configure_lookup(const char *db, const char *s) {}
> +#endif
>  #include "rpcbind.h"
>  
>  /*#define RPCBIND_DEBUG*/
> -- 1.8.1.2 -- To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at http://vger.kernel.org/majordomo-info.html
> 
