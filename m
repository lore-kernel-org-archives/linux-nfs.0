From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/14] NLM: Beef up NLM address display function
Date: Wed, 29 Oct 2008 15:25:14 -0400
Message-ID: <20081029192514.GA1406@fieldses.org>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net> <20081024180954.23810.34150.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45818 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752435AbYJ2TZP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Oct 2008 15:25:15 -0400
In-Reply-To: <20081024180954.23810.34150.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 24, 2008 at 02:09:54PM -0400, Chuck Lever wrote:
> Add support for IPv6 addresses with a scope ID,

I remain a bit confused about scope ID's.  If you tell me they're
needed, I'll believe you.

> and enable calls from outside of fs/lockd/host.c

Some day of course it'd be nice to collect all the basic "display an
ipv6 address" code together in one place!

> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 9fd8889..c7516ae 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -104,29 +104,54 @@ static void nlm_clear_port(struct sockaddr *sap)
>  	}
>  }
>  
> -static void nlm_display_address(const struct sockaddr *sap,
...
> +int nlm_display_address(const struct sockaddr *sap, char *buf,

The return value is never used, even after your other patches.  Do you
have any plans to use it?

--b.

> +			const size_t len)
> +{
>  	switch (sap->sa_family) {
>  	case AF_UNSPEC:
> -		snprintf(buf, len, "unspecified");
> -		break;
> +		snprintf(buf, len, "unspecified address");
> +		return -EAFNOSUPPORT;
>  	case AF_INET:
> -		snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
> -		break;
> +		return nlm_display_ipv4_address(sap, buf, len);
>  	case AF_INET6:
> -		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
> -			snprintf(buf, len, NIPQUAD_FMT,
> -				 NIPQUAD(sin6->sin6_addr.s6_addr32[3]));
> -		else
> -			snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
> -		break;
> +		return nlm_display_ipv6_address(sap, buf, len);
>  	default:
>  		snprintf(buf, len, "unsupported address family");
> -		break;
> +		return -EAFNOSUPPORT;
>  	}
>  }
