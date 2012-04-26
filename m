Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30809 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753848Ab2DZUGp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 16:06:45 -0400
Message-ID: <4F99AAC7.3060709@RedHat.com>
Date: Thu, 26 Apr 2012 16:06:31 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Nick Alcock <nix@esperi.org.uk>
CC: linux-nfs@vger.kernel.org, Nick Alcock <nick.alcock@oracle.com>
Subject: Re: [PATCH 1/4] Fix debugging reference from non-GSS to optional
 GSS code.
References: <1328472138-25750-1-git-send-email-nix@esperi.org.uk>
In-Reply-To: <1328472138-25750-1-git-send-email-nix@esperi.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/05/2012 03:02 PM, Nick Alcock wrote:
> From: Nick Alcock <nick.alcock@oracle.com>
> 
> AUTH_DESTROY() and auth_destroy() are pulling in log_debug() from
> authgss_prot.c, but are used from outside the GSS code, thus preventing libtirpc
> from being used if compiled without GSS support.
> 
> The (somewhat ugly) fix here defines a new macro to do the job. Because we're
> not compiling as C99, I use the GNU C variadic macro extension: if we mean to
> be compiled with other compilers, this needs to change.
> 
> Signed-off-by: Nick Alcock <nick.alcock@oracle.com>
> ---
>  tirpc/rpc/auth.h |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/tirpc/rpc/auth.h b/tirpc/rpc/auth.h
> index 5f66e67..e7bbe36 100644
> --- a/tirpc/rpc/auth.h
> +++ b/tirpc/rpc/auth.h
> @@ -51,6 +51,7 @@
>  #include <sys/cdefs.h>
>  #include <sys/socket.h>
>  #include <sys/types.h>
> +#include <stdio.h>
>  
>  
>  #define MAX_AUTH_BYTES	400
> @@ -248,12 +249,18 @@ auth_put(AUTH *auth)
>  #define auth_refresh(auth, msg)		\
>  		((*((auth)->ah_ops->ah_refresh))(auth, msg))
>  
> +#if defined(__GNUC__) && defined(DEBUG)
> +#define auth_log_debug(fmt,args...) printf(stderr, fmt, args)
> +#else
> +#define auth_log_debug(fmt,args...)
> +#endif
> +
>  #define AUTH_DESTROY(auth)						\
>  		do {							\
>  			int refs;					\
>  			if ((refs = auth_put((auth))) == 0)		\
>  				((*((auth)->ah_ops->ah_destroy))(auth));\
> -			log_debug("%s: auth_put(), refs %d\n",		\
> +			auth_log_debug("%s: auth_put(), refs %d\n",	\
>  				__func__, refs);			\
>  		} while (0)
>  
> @@ -262,7 +269,7 @@ auth_put(AUTH *auth)
>  			int refs;					\
>  			if ((refs = auth_put((auth))) == 0)		\
>  				((*((auth)->ah_ops->ah_destroy))(auth));\
> -			log_debug("%s: auth_put(), refs %d\n",		\
> +			auth_log_debug("%s: auth_put(), refs %d\n",	\
>  				__func__, refs);			\
>  		} while (0)
>  
Committed...

steved.
