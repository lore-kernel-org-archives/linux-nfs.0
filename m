From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Mon, 2 Feb 2009 12:00:09 -0500
Message-ID: <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:57359 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbZBBRA0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Feb 2009 12:00:26 -0500
In-Reply-To: <1233459927.3112.54.camel-+Zt617Lp5ASbJVK1MCa92ZvzqaJJnU0YunOrhLTifxA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 31, 2009, at 10:45 PM, Ian Dall wrote:
> The following patch is relative to 2.6.29-rc3. The crux of the  
> matter is
> that sock_addr structures can't be reliably compared using memcmp()
> because there are padding bytes in the structure which can't be
> guaranteed to be the same even when the sock_addr structures refer to
> the same thing.
>
> There have been significant changes to the way address comparison is
> done in client.c since my original patch (Kernel Bug Tracker #11061,
> comment 19). In particular ipv4 addresses are now mapped to ipv6
> addresses for comparison (but only if the kernel is configured for
> IPV6). The conditional compilation blocks were quite big and contained
> duplication. Adding my changes in their original style would have only
> made matters worse. So I have taken to opportunity to clean up. By
> inverting the logic, I was able to reduce the depth of nested ifs,
> reduce the number of trivial helper functions and reduce the size of  
> the
> conditional compilation blocks. This is a mater of opinion of course,
> but I think the result is cleaner and easier to read and maintain.
>
> This has been tested with kernels configured with and without IPV6.

As far as I can tell, this is only an issue in nfs_match_client(), so  
there isn't any need to rewrite the other pieces.

Isn't it enough to replace the memcmp() with a call to  
nfs_sockaddr_match_ipaddr() in nfs_match_client(), and then add a  
little extra logic in nfs_match_client() to compare the port numbers  
too?

> Log:
> ======================
> Clean up address comparison code, replace nfs_sockaddr_match_ipaddr()
> with more generic nfs_sockaddr_match_addr(). Don't compare sock_addr
> structures using memcmp().
>
> Signed-off-by: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
> ======================
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 9b728f3..bc38e24 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -223,6 +223,8 @@ void nfs_put_client(struct nfs_client *clp)
> 	}
> }
>
> +enum nfs_sockaddr_match_flags { nfs_port_nomatch = 0,  
> nfs_port_match };
> +
> #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> static const struct in6_addr *nfs_map_ipv4_addr(const struct  
> sockaddr *sa, struct in6_addr *addr_mapped)
> {
> @@ -238,40 +240,56 @@ static const struct in6_addr  
> *nfs_map_ipv4_addr(const struct sockaddr *sa, struc
> 			return addr_mapped;
> 	}
> }
> +#endif
>
> -static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
> -		const struct sockaddr *sa2)
> +static int nfs_sockaddr_match_addr(const struct sockaddr *sa1,
> +				   const struct sockaddr *sa2,
> +				   enum nfs_sockaddr_match_flags flags)
> {
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> 	const struct in6_addr *addr1;
> 	const struct in6_addr *addr2;
> 	struct in6_addr addr1_mapped;
> 	struct in6_addr addr2_mapped;
> -
> +	
> 	addr1 = nfs_map_ipv4_addr(sa1, &addr1_mapped);
> -	if (likely(addr1 != NULL)) {
> -		addr2 = nfs_map_ipv4_addr(sa2, &addr2_mapped);
> -		if (likely(addr2 != NULL))
> -			return ipv6_addr_equal(addr1, addr2);
> -	}
> -	return 0;
> -}
> +	if (unlikely(addr1 == NULL))
> +		return 0;
> +	addr2 = nfs_map_ipv4_addr(sa2, &addr2_mapped);
> +	if (unlikely(addr2 == NULL))
> +		return 0;
> +	if (likely(!ipv6_addr_equal(addr1, addr2)))
> +		return 0;
> #else
> -static int nfs_sockaddr_match_ipaddr4(const struct sockaddr_in *sa1,
> -				 const struct sockaddr_in *sa2)
> -{
> -	return sa1->sin_addr.s_addr == sa2->sin_addr.s_addr;
> -}
> -
> -static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
> -				 const struct sockaddr *sa2)
> -{
> 	if (unlikely(sa1->sa_family != AF_INET || sa2->sa_family != AF_INET))
> 		return 0;
> -	return nfs_sockaddr_match_ipaddr4((const struct sockaddr_in *)sa1,
> -			(const struct sockaddr_in *)sa2);
> -}
> +	if (likely(((const struct sockaddr_in *)sa1)->sin_addr.s_addr !=
> +		   ((const struct sockaddr_in *)sa2)->sin_addr.s_addr))
> +		return 0;
> #endif
>
> +	if (flags != nfs_port_match)
> +		return 1;
> +
> +	/* match the port */
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +	switch (sa1->sa_family) {
> +	default:
> +		return 0;
> +	case AF_INET:
> +		return (((const struct sockaddr_in *)sa1)->sin_port ==
> +			((const struct sockaddr_in *)sa2)->sin_port);
> +	case AF_INET6:
> +		return (((const struct sockaddr_in6 *)sa1)->sin6_port ==
> +			((const struct sockaddr_in6 *)sa2)->sin6_port);
> +	}
> +#else
> +	return (((const struct sockaddr_in *)sa1)->sin_port ==
> +		((const struct sockaddr_in *)sa2)->sin_port);
> +#endif
> +
> +}
> +
> /*
>  * Find a client by IP address and protocol version
>  * - returns NULL if no such client
> @@ -293,7 +311,7 @@ struct nfs_client *nfs_find_client(const struct  
> sockaddr *addr, u32 nfsversion)
> 			continue;
>
> 		/* Match only the IP address, not the port number */
> -		if (!nfs_sockaddr_match_ipaddr(addr, clap))
> +		if (!nfs_sockaddr_match_addr(addr, clap, nfs_port_nomatch))
> 			continue;
>
> 		atomic_inc(&clp->cl_count);
> @@ -326,7 +344,7 @@ struct nfs_client *nfs_find_client_next(struct  
> nfs_client *clp)
> 			continue;
>
> 		/* Match only the IP address, not the port number */
> -		if (!nfs_sockaddr_match_ipaddr(sap, clap))
> +		if (!nfs_sockaddr_match_addr(sap, clap, nfs_port_nomatch))
> 			continue;
>
> 		atomic_inc(&clp->cl_count);
> @@ -344,8 +362,10 @@ struct nfs_client *nfs_find_client_next(struct  
> nfs_client *clp)
> static struct nfs_client *nfs_match_client(const struct  
> nfs_client_initdata *data)
> {
> 	struct nfs_client *clp;
> +	const struct sockaddr *sap = data->addr;
>
> 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
> +	        struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
> 		/* Don't match clients that failed to initialise properly */
> 		if (clp->cl_cons_state < 0)
> 			continue;
> @@ -358,9 +378,9 @@ static struct nfs_client *nfs_match_client(const  
> struct nfs_client_initdata *dat
> 			continue;
>
> 		/* Match the full socket address */
> -		if (memcmp(&clp->cl_addr, data->addr, sizeof(clp->cl_addr)) != 0)
> +		if (!nfs_sockaddr_match_addr(sap, clap, nfs_port_match))
> 			continue;
> -
> +		
> 		atomic_inc(&clp->cl_count);
> 		return clp;
> 	}
>
>
>
> -- 
> Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



