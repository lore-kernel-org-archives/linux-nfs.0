Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39792 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754303AbaHGMPO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Aug 2014 08:15:14 -0400
Message-ID: <53E36DC5.7020200@RedHat.com>
Date: Thu, 07 Aug 2014 08:15:01 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Natanael Copa <natanael.copa@gmail.com>, linux-nfs@vger.kernel.org
CC: Natanael Copa <ncopa@alpinelinux.org>
Subject: Re: [PATCH 11/11] exportfs: only do glibc specific hackery on glibc
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org> <1406719399-1735-12-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1406719399-1735-12-git-send-email-ncopa@alpinelinux.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/30/2014 07:23 AM, Natanael Copa wrote:
> We should not depend on the libc do free(3) on ai_canonname as that is
> completely up to implementation and known o break things on uclibc and
> musl libc.
> 
> Signed-off-by: Natanael Copa <ncopa@alpinelinux.org>
> ---
>  support/export/hostname.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index d9153e1..30584b4 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -382,6 +382,7 @@ host_numeric_addrinfo(const struct sockaddr *sap)
>  
>  	ai = host_pton(buf);
>  
> +#if !definded(__UCLIBC__) && defined(__GLIBC__)
You still have this typo here... and the only reason
it compiled is HAVE_GETNAMEINFO is not defined 
in your world....

How well were these change tested against glibc? I'm 
concern about eliminating chunks of need code with
all these new  defines.... 

steved.

>  	/*
>  	 * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
>  	 */
> @@ -392,7 +393,9 @@ host_numeric_addrinfo(const struct sockaddr *sap)
>  			ai = NULL;
>  		}
>  	}
> +#endif
>  
>  	return ai;
>  }
> +
>  #endif	/* !HAVE_GETNAMEINFO */
> 
