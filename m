Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50816 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932396AbdHWSeY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Aug 2017 14:34:24 -0400
Subject: Re: [PATCH v2] Replace bzero() calls with equivalent memset() calls
To: Joshua Kinard <kumba@gentoo.org>,
        libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
References: <796573dc-6d91-c04b-873b-92c7efbaa216@gentoo.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <ea5326ae-1f47-04ce-b855-b32553082e6d@RedHat.com>
Date: Wed, 23 Aug 2017 14:34:23 -0400
MIME-Version: 1.0
In-Reply-To: <796573dc-6d91-c04b-873b-92c7efbaa216@gentoo.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/31/2017 08:54 PM, Joshua Kinard wrote:
> As annotated in the bzero(3) man page, bzero() was marked as LEGACY in
> POSIX.1-2001 and removed in POSIX.1-2008, and should be replaced with
> memset() calls to write zeros to a memory region.  The attached patch
> replaces two bzero() calls and one __bzero() call in libtirpc with
> equivalent memset() calls.  The latter replacement fixes a compile error
> under uclibc-ng, which lacks a definition for __bzero()
> 
> Signed-off-by: Joshua Kinard <kumba@gentoo.org>
Committed... Sorry for taking so long... PTO got in the way.

steved.
> ---
> 
> Changes in v2:
> Removed the typecasts on the replacement memset() calls in
> src/auth_time.c and src/svc_auth_des.c
> 
> ---
> 
>  src/auth_time.c    |    2 +-
>  src/des_impl.c     |    2 +-
>  src/svc_auth_des.c |    2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/src/auth_time.c b/src/auth_time.c
> index 7f83ab4..69400bc 100644
> --- a/src/auth_time.c
> +++ b/src/auth_time.c
> @@ -317,7 +317,7 @@ __rpc_get_time_offset(td, srv, thost, uaddr, netid)
>  	sprintf(ipuaddr, "%d.%d.%d.%d.0.111", a1, a2, a3, a4);
>  	useua = &ipuaddr[0];
>  
> -	bzero((char *)&sin, sizeof(sin));
> +	memset(&sin, 0, sizeof(sin));
>  	if (uaddr_to_sockaddr(useua, &sin)) {
>  		msg("unable to translate uaddr to sockaddr.");
>  		if (needfree)
> diff --git a/src/des_impl.c b/src/des_impl.c
> index 9dbccaf..15bec2a 100644
> --- a/src/des_impl.c
> +++ b/src/des_impl.c
> @@ -588,7 +588,7 @@ _des_crypt (char *buf, unsigned len, struct desparams *desp)
>      }
>    tin0 = tin1 = tout0 = tout1 = xor0 = xor1 = 0;
>    tbuf[0] = tbuf[1] = 0;
> -  __bzero (schedule, sizeof (schedule));
> +  memset (schedule, 0, sizeof (schedule));
>  
>    return (1);
>  }
> diff --git a/src/svc_auth_des.c b/src/svc_auth_des.c
> index 2e90146..19a7c60 100644
> --- a/src/svc_auth_des.c
> +++ b/src/svc_auth_des.c
> @@ -356,7 +356,7 @@ cache_init()
>  
>  	authdes_cache = (struct cache_entry *)
>  		mem_alloc(sizeof(struct cache_entry) * AUTHDES_CACHESZ);	
> -	bzero((char *)authdes_cache, 
> +	memset(authdes_cache, 0,
>  		sizeof(struct cache_entry) * AUTHDES_CACHESZ);
>  
>  	authdes_lru = (short *)mem_alloc(sizeof(short) * AUTHDES_CACHESZ);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
