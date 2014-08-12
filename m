Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63858 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751648AbaHLLEG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 07:04:06 -0400
Message-ID: <53E9F49A.4070500@RedHat.com>
Date: Tue, 12 Aug 2014 07:03:54 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Natanael Copa <natanael.copa@gmail.com>, linux-nfs@vger.kernel.org
CC: Natanael Copa <ncopa@alpinelinux.org>
Subject: Re: [PATCH v2 11/11] exportfs: only do glibc specific hackery on
 glibc
References: <1407306306-29796-1-git-send-email-ncopa@alpinelinux.org> <1407306306-29796-12-git-send-email-ncopa@alpinelinux.org>
In-Reply-To: <1407306306-29796-12-git-send-email-ncopa@alpinelinux.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/06/2014 02:25 AM, Natanael Copa wrote:
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
        ^^^^^^^^
Are you kidding me???? How are you testing these patches? 

I'm all for this port but I'm a bit concern about the 
stability since things like this don't even compile... 

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
