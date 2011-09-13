Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57545 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755038Ab1IMHlH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 03:41:07 -0400
Message-ID: <4E6F0A14.1050103@cn.fujitsu.com>
Date: Tue, 13 Sep 2011 15:45:24 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: NFS <linux-nfs@vger.kernel.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/2] SUNRPC: compare scopeid for link-local addresses
References: <4E5CABE9.5090401@cn.fujitsu.com>
In-Reply-To: <4E5CABE9.5090401@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi guys:

  What's the situation about those two paths?


thanks,
Mi Jinlong

Mi Jinlong:
> For ipv6 link-local addresses, sunrpc do not compare those scope id.
> This patch let sunrpc compares scope id only on link-local addresses.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
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

