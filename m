Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11658 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751374Ab0I0Lox (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 07:44:53 -0400
Message-ID: <4CA083AD.2090306@RedHat.com>
Date: Mon, 27 Sep 2010 07:44:45 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/3] Give hostname.c more support for IPv6
References: <20100804064553.16641.92857.stgit@localhost.localdomain> <20100804064945.16641.71097.stgit@localhost.localdomain>
In-Reply-To: <20100804064945.16641.71097.stgit@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/04/2010 02:49 AM, Neil Brown wrote:
> Allow host_pton,  host_addrinfo, and all functions that use
> sockaddr_size to work correctly with IPv6 addresses.
> 
> This means host_addrinfo can now return IPv6 addresses, but I think
> all code is ready for that.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  support/export/hostname.c |   26 ++++++++++++++++++--------
>  1 files changed, 18 insertions(+), 8 deletions(-)
> 
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index f6a59f1..46ddfe2 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -38,9 +38,11 @@
>  static socklen_t
>  sockaddr_size(const struct sockaddr *sap)
>  {
> -	if (sap->sa_family != AF_INET)
> -		return 0;
> -	return (socklen_t)sizeof(struct sockaddr_in);
> +	if (sap->sa_family == AF_INET)
> +		return (socklen_t)sizeof(struct sockaddr_in);
> +	if (sap->sa_family == AF_INET6)
> +		return (socklen_t)sizeof(struct sockaddr_in6);
> +	return 0;
>  }
>  #endif	/* HAVE_GETNAMEINFO */
This routine was eliminated with commit 63afb9

>  
> @@ -126,10 +128,12 @@ host_pton(const char *paddr)
>  	 * addresses that end with a blank.
>  	 *
>  	 * inet_pton(3) is much stricter.  Use it to be certain we
> -	 * have a real AF_INET presentation address, before invoking
> -	 * getaddrinfo(3) to generate the full addrinfo list.
> +	 * have a real AF_INET or AF_INET6 presentation address,
> +	 * before invoking getaddrinfo(3) to generate the full
> +	 * addrinfo list.
>  	 */
> -	if (inet_pton(AF_INET, paddr, &sin.sin_addr) == 0)
> +	if (inet_pton(AF_INET, paddr, &sin.sin_addr) == 0 &&
> +	    inet_pton(AF_INET6, paddr, &sin.sin_addr) == 0)
>  		return NULL;
This error case is  already handled in the current version of
of host_pton, but I must say, the above approved is much clear
than the existing code... but I'm going to leave things as-is..

>  
>  	error = getaddrinfo(paddr, NULL, &hint, &ai);
> @@ -168,7 +172,7 @@ host_addrinfo(const char *hostname)
>  {
>  	struct addrinfo *ai = NULL;
>  	struct addrinfo hint = {
> -		.ai_family	= AF_INET,
> +		.ai_family	= AF_UNSPEC,
>  		/* don't return duplicates */
>  		.ai_protocol	= (int)IPPROTO_UDP,
>  		.ai_flags	= AI_ADDRCONFIG | AI_CANONNAME,
> @@ -178,7 +182,13 @@ host_addrinfo(const char *hostname)
>  	error = getaddrinfo(hostname, NULL, &hint, &ai);
>  	switch (error) {
>  	case 0:
> -		return ai;
> +		if (ai->ai_family == AF_INET ||
> +		    ai->ai_family == AF_INET6)
> +			return ai;
> +		freeaddrinfo(ai);
> +		xlog(D_GENERAL, "%s: resolved to neither IPv4 nor IPv6 address.",
> +				hostname);
> +		break;
I think I'm going to try and blend this in with Chuck's recent patches
since I do like the idea of logging unsupported address families...

steved.

>  	case EAI_SYSTEM:
>  		xlog(D_GENERAL, "%s: failed to resolve %s: (%d) %m",
>  				__func__, hostname, errno);
> 
> 
