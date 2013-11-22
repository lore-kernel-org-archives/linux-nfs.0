Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756136Ab3KVQ1d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Nov 2013 11:27:33 -0500
Message-ID: <528F8631.2070604@RedHat.com>
Date: Fri, 22 Nov 2013 11:28:33 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Susant Sahani <ssahani@redhat.com>,
        Libtirpc-devel Mailing List
	<libtirpc-devel@lists.sourceforge.net>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] data race in bindresvport_sa
References: <1384966173-6229-1-git-send-email-ssahani@redhat.com>
In-Reply-To: <1384966173-6229-1-git-send-email-ssahani@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Would it be possible to get a little better description as 
to what this patch does and why its needed... 
"data race in bindresvport_sa" have very little 
meaning, at least to me... 

More comments below... 

On 20/11/13 11:49, Susant Sahani wrote:
> Signed-off-by: Susant Sahani <ssahani@redhat.com>
> ---
>  src/bindresvport.c | 16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/src/bindresvport.c b/src/bindresvport.c
> index 6ce3e81..d26d754 100644
> --- a/src/bindresvport.c
> +++ b/src/bindresvport.c
> @@ -46,6 +46,7 @@
>  #include <rpc/rpc.h>
>  
>  #include <string.h>
> +#include <reentrant.h>
>  
>  /*
>   * Bind a socket to a privileged IP port
> @@ -79,17 +80,23 @@ bindresvport_sa(sd, sa)
>  	u_int16_t *portp;
>  	static u_int16_t port;
>  	static short startport = STARTPORT;
> +	static pthread_mutex_t port_lock = PTHREAD_MUTEX_INITIALIZER;
How come you define this mutex statically instead in src/mt_misc.c
like the rest of the mutexes? 

Would you mind moving this (and the other two in the patches) 
to src/mt_misc.c and added a commit talking about what they
are protecting

tia!

steved.

>  	socklen_t salen;
> -	int nports = ENDPORT - startport + 1;
> +	int nports;
>  	int endport = ENDPORT;
>  	int i;
>  
> +	mutex_lock(&port_lock);
> +	nports = ENDPORT - startport + 1;
> +
>          if (sa == NULL) {
>                  salen = sizeof(myaddr);
>                  sa = (struct sockaddr *)&myaddr;
>  
> -                if (getsockname(sd, (struct sockaddr *)&myaddr, &salen) == -1)
> -                        return -1;      /* errno is correctly set */
> +                if (getsockname(sd, (struct sockaddr *)&myaddr, &salen) == -1) {
> +                    mutex_unlock(&port_lock);
> +                    return -1;      /* errno is correctly set */
> +                }
>  
>                  af = myaddr.ss_family;
>          } else
> @@ -112,6 +119,7 @@ bindresvport_sa(sd, sa)
>  #endif
>          default:
>                  errno = EPFNOSUPPORT;
> +                mutex_unlock(&port_lock);
>                  return (-1);
>          }
>          sa->sa_family = af;
> @@ -137,6 +145,8 @@ bindresvport_sa(sd, sa)
>  	    port = LOWPORT + port % (STARTPORT - LOWPORT);
>  	    goto again;
>  	}
> +	mutex_unlock(&port_lock);
> +
>          return (res);
>  }
>  #else
> 
