Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27935 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965397AbbKDVwi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Nov 2015 16:52:38 -0500
Subject: Re: [PATCH] nfsd: Fix message when creating NFSD listener sockets
To: Juergen Daubert <jue@jue.li>, linux-nfs@vger.kernel.org
References: <20151031102905.GA2010@jue.netz>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <563A7E23.2030802@RedHat.com>
Date: Wed, 4 Nov 2015 16:52:35 -0500
MIME-Version: 1.0
In-Reply-To: <20151031102905.GA2010@jue.netz>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/31/2015 06:29 AM, Juergen Daubert wrote:
> When the kernel's IPv6 module isn't loaded:
> 
> #:~> /usr/sbin/rpc.nfsd --debug 8
> rpc.nfsd: knfsd is currently down
> rpc.nfsd: Writing version string to kernel: -2 +3 +4
> rpc.nfsd: Creating AF_INET TCP socket.
> rpc.nfsd: Creating AF_INET UDP socket.
> rpc.nfsd: Creating AF_INET6 TCP socket.
> rpc.nfsd: Creating AF_INET6 UDP socket.
> 
> The last two messages are misleading, since creation of AF_INET6
> sockets now fails silently without kernel IPv6 support.
> 
> Fixes: c31fef7f4beb ('nfsd: ignore unsupported address types')
> 
> Signed-off-by: Juergen Daubert <jue@jue.il>
Committed... 

steved.

> ---
> 
>  utils/nfsd/nfssvc.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index fc11d23..e8efd06 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -168,8 +168,6 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
>  			continue;
>  		}
>  
> -		xlog(D_GENERAL, "Creating %s %s socket.", family, proto);
> -
>  		/* open socket and prepare to hand it off to kernel */
>  		sockfd = socket(addr->ai_family, addr->ai_socktype,
>  				addr->ai_protocol);
> @@ -183,6 +181,9 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
>  			addr = addr->ai_next;
>  			continue;
>  		}
> +
> +		xlog(D_GENERAL, "Created %s %s socket.", family, proto);
> +
>  #ifdef IPV6_SUPPORTED
>  		if (addr->ai_family == AF_INET6 &&
>  		    setsockopt(sockfd, IPPROTO_IPV6, IPV6_V6ONLY, &on, sizeof(on))) {
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
