Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:35832 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169Ab1H3O2d convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2011 10:28:33 -0400
Subject: Re: [PATCH 2/2] SUNRPC: compare scopeid for link-local addresses
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E5CABE9.5090401@cn.fujitsu.com>
Date: Tue, 30 Aug 2011 10:28:06 -0400
Cc: NFS <linux-nfs@vger.kernel.org>, "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>, Steve Dickson <SteveD@redhat.com>
Message-Id: <31E944A2-6DC2-4D71-92D9-E6521B1A23D3@oracle.com>
References: <4E5CABE9.5090401@cn.fujitsu.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 30, 2011, at 5:22 AM, Mi Jinlong wrote:

> For ipv6 link-local addresses, sunrpc do not compare those scope id.
> This patch let sunrpc compares scope id only on link-local addresses.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
> include/linux/sunrpc/clnt.h |    8 +++++++-
> 1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index db7bcaf..ee1bb67 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -218,7 +218,13 @@ static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
> {
> 	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sap1;
> 	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
> -	return ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr);
> +
> +	if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
> +		return false;
> +	else if (ipv6_addr_type(&sin1->sin6_addr) & IPV6_ADDR_LINKLOCAL)
> +		return sin1->sin6_scope_id == sin2->sin6_scope_id;

Thanks for splitting the patches.

The address comparators I've seen check that both addresses are link-local before comparing the scope IDs.  I don't think we can assume the kind of source-destination address relationship we have in parts of the RPC server code.

> +
> +	return true;
> }
> 
> static inline bool __rpc_copy_addr6(struct sockaddr *dst,
> -- 
> 1.7.6
> 
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




