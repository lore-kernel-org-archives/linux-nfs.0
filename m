Return-Path: linux-nfs-owner@vger.kernel.org
Received: from webmail.solarflare.com ([12.187.104.25]:43869 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648Ab3F0PiC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 11:38:02 -0400
Message-ID: <1372347477.2436.7.camel@bwh-desktop.uk.level5networks.com>
Subject: Re: [RFC Patch net-next 4/5] sunrpc: use generic union inet_addr
From: Ben Hutchings <bhutchings@solarflare.com>
To: Cong Wang <amwang@redhat.com>
CC: <netdev@vger.kernel.org>, Daniel Borkmann <dborkman@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Date: Thu, 27 Jun 2013 16:37:57 +0100
In-Reply-To: <1372315398-19683-5-git-send-email-amwang@redhat.com>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <1372315398-19683-5-git-send-email-amwang@redhat.com>
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-06-27 at 14:43 +0800, Cong Wang wrote:
[...]
> --- a/include/net/inet_addr.h
> +++ b/include/net/inet_addr.h
> @@ -60,6 +60,62 @@ static inline bool inet_addr_multicast(const union inet_addr *ipa)
>  }
>  #endif
>  
> +/**
> + * inet_addr_copy - copy the address portion of one sockaddr to another
> + * @dst: destination sockaddr
> + * @src: source sockaddr
> + *
> + * Just copies the address portion and family. Ignores port, scope, etc.
> + * Caller is responsible for making certain that dst is large enough to hold
> + * the address in src. Returns true if address family is supported. Returns
> + * false otherwise.
> + */
> +static inline bool inet_addr_copy(union inet_addr *dst,
> +				  const union inet_addr *src)
> +{
> +	dst->sa.sa_family = src->sa.sa_family;
> +
> +	switch (src->sa.sa_family) {
> +	case AF_INET:
> +		dst->sin.sin_addr.s_addr = src->sin.sin_addr.s_addr;
> +		return true;
> +#if IS_ENABLED(CONFIG_IPV6)
> +	case AF_INET6:
> +		dst->sin6.sin6_addr = src->sin6.sin6_addr;
> +		dst->sin6.sin6_scope_id = src->sin6.sin6_scope_id;
> +		return true;
> +#endif

Most of the other functions work on IPv6 addresses without CONFIG_IPV6;
why should this be different?

Ben.

> +	}
> +
> +	return false;
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

