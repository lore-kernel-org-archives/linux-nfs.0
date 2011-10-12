Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60153 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751548Ab1JLOjG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Oct 2011 10:39:06 -0400
Date: Wed, 12 Oct 2011 10:39:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: fix bug about IPv6 address scope checking
Message-ID: <20111012143904.GA21063@fieldses.org>
References: <4E953D2E.5080103@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E953D2E.5080103@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 12, 2011 at 03:09:34PM +0800, Mi Jinlong wrote:
> The result from ipv6_addr_scope() always not be a single SCOPE,
> so we can't use equal to compare the result with IPV6_ADDR_SCOPE_LINKLOCAL
> at nfs_sockaddr_match_ipaddr6.
> 
> This patch fixs the problem, and lets checking address before scope_id.

Looks right to me, thanks; committing unless someone else catches a
problem.

--b.

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/nfs/client.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 5833fbb..b4e41dd 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -336,11 +336,12 @@ static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
>  	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
>  	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
>  
> -	if (ipv6_addr_scope(&sin1->sin6_addr) == IPV6_ADDR_SCOPE_LINKLOCAL &&
> -	    sin1->sin6_scope_id != sin2->sin6_scope_id)
> +	if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
>  		return 0;
> +	else if (ipv6_addr_type(&sin1->sin6_addr) & IPV6_ADDR_LINKLOCAL)
> +		return sin1->sin6_scope_id == sin2->sin6_scope_id;
>  
> -	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
> +	return 1;
>  }
>  #else	/* !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE) */
>  static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
> -- 
> 1.7.6
> 
> 
> 
