Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1495 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750847Ab0I0Lq3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 07:46:29 -0400
Message-ID: <4CA0840F.7000106@RedHat.com>
Date: Mon, 27 Sep 2010 07:46:23 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] Allow check_fqdn to compare IPv6 addresses
References: <20100804064553.16641.92857.stgit@localhost.localdomain> <20100804064945.16641.74397.stgit@localhost.localdomain>
In-Reply-To: <20100804064945.16641.74397.stgit@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/04/2010 02:49 AM, Neil Brown wrote:
> Simply use nfs_compare_sockaddr in place of addrs_match
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  support/export/client.c |   23 +----------------------
>  1 files changed, 1 insertions(+), 22 deletions(-)
> 
> diff --git a/support/export/client.c b/support/export/client.c
> index dc01067..286dcd6 100644
> --- a/support/export/client.c
> +++ b/support/export/client.c
> @@ -372,27 +372,6 @@ add_name(char *old, const char *add)
>  	return new;
>  }
>  
> -static _Bool
> -addrs_match4(const struct sockaddr *sa1, const struct sockaddr *sa2)
> -{
> -	const struct sockaddr_in *si1 = (const struct sockaddr_in *)sa1;
> -	const struct sockaddr_in *si2 = (const struct sockaddr_in *)sa2;
> -
> -	return si1->sin_addr.s_addr == si2->sin_addr.s_addr;
> -}
> -
> -static _Bool
> -addrs_match(const struct sockaddr *sa1, const struct sockaddr *sa2)
> -{
> -	if (sa1->sa_family == sa2->sa_family)
> -		switch (sa1->sa_family) {
> -		case AF_INET:
> -			return addrs_match4(sa1, sa2);
> -		}
> -
> -	return false;
> -}
> -
>  /*
>   * Check each address listed in @ai against each address
>   * stored in @clp.  Return 1 if a match is found, otherwise
> @@ -405,7 +384,7 @@ check_fqdn(const nfs_client *clp, const struct addrinfo *ai)
>  
>  	for (; ai; ai = ai->ai_next)
>  		for (i = 0; i < clp->m_naddr; i++)
> -			if (addrs_match(ai->ai_addr, get_addrlist(clp, i)))
> +			if (nfs_compare_sockaddr(ai->ai_addr, get_addrlist(clp, i)))
>  				return 1;
>  
>  	return 0;
> 
> 
This change already exists due to commit 60abb9

steved.
