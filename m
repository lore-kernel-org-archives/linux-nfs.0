Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:37919 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282AbaG3MGM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:06:12 -0400
Received: by mail-qa0-f48.google.com with SMTP id m5so1140631qaj.21
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:06:12 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 30 Jul 2014 08:06:10 -0400
To: Natanael Copa <natanael.copa@gmail.com>
Cc: linux-nfs@vger.kernel.org, Natanael Copa <ncopa@alpinelinux.org>
Subject: Re: [PATCH 11/11] exportfs: only do glibc specific hackery on glibc
Message-ID: <20140730080610.7655e15e@tlielax.poochiereds.net>
In-Reply-To: <1406719399-1735-12-git-send-email-ncopa@alpinelinux.org>
References: <1406719399-1735-1-git-send-email-ncopa@alpinelinux.org>
	<1406719399-1735-12-git-send-email-ncopa@alpinelinux.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 30 Jul 2014 13:23:19 +0200
Natanael Copa <natanael.copa@gmail.com> wrote:

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

As I mentioned on IRC, there's a typo above...

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


-- 
Jeff Layton <jlayton@primarydata.com>
