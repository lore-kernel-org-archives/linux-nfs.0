Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55270 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752757Ab1H3KFC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Aug 2011 06:05:02 -0400
Date: Tue, 30 Aug 2011 06:07:52 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] SUNRPC: compare scopeid for link-local addresses
Message-ID: <20110830060752.33e5de2d@corrin.poochiereds.net>
In-Reply-To: <4E5CABE9.5090401@cn.fujitsu.com>
References: <4E5CABE9.5090401@cn.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 30 Aug 2011 17:22:49 +0800
Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:

> For ipv6 link-local addresses, sunrpc do not compare those scope id.
> This patch let sunrpc compares scope id only on link-local addresses.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>

Reviewed-by: 
> ---
>  include/linux/sunrpc/clnt.h |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index db7bcaf..ee1bb67 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -218,7 +218,13 @@ static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
>  {
>  	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sap1;
>  	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
> -	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
> +
> +	if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
> +		return false;
> +	else if (ipv6_addr_type(&sin1->sin6_addr) & IPV6_ADDR_LINKLOCAL)
> +		return sin1->sin6_scope_id == sin2->sin6_scope_id;
> +
> +	return true;
>  }
>  
>  static inline bool __rpc_copy_addr6(struct sockaddr *dst,

Reviewed-by: Jeff Layton <jlayton@redhat.com>
