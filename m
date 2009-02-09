From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Mon, 9 Feb 2009 16:11:42 -0500
Message-ID: <7ED0098B-1D71-4E43-A8E4-D5859F13DD38@oracle.com>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au> <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com> <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au> <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com> <1233698189.13862.16.camel@sibyl.beware.dropbear.id.au> <1233699391.7161.11.camel@heimdal.trondhjem.org> <91CE7AFB-2B15-4223-BE43-DF95ABC4B195@oracle.com> <1233771633.7161.35.camel@heimdal.trondhjem.org> <5552ED43-5E9C-4136-823D-DDDCF129DFAC@oracle.com> <1233773231.7161.51.camel@heimdal.trondhjem.org> <1234094116.13862.162.camel@sibyl.beware.dropbear.id.au>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:46553 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753696AbZBIVMC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2009 16:12:02 -0500
In-Reply-To: <1234094116.13862.162.camel-+Zt617Lp5ASbJVK1MCa92ZvzqaJJnU0YunOrhLTifxA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ian-

On Feb 8, 2009, at 6:55 AM, Ian Dall wrote:
> On Wed, 2009-02-04 at 13:47 -0500, Trond Myklebust wrote:
>> On Wed, 2009-02-04 at 13:44 -0500, Chuck Lever wrote:
>>> Right.  So, then, can nfs_match_client() use the same address
>>> comparison method as nfs_find_client()?  I'm inclined to think
>>> nfs_match_client() can use a more straightforward address comparison
>>> method.
>>
>> It could. We should certainly be checking that the sa_family field
>> matches...
>
> Based on this, here is a new version of the patch. I've dropped the
> contentious clean up of the conditional compilation. The match is done
> in a new function nfs_sockaddr_match(). Even though this function
> compares IPv4 and IPv6 addresses it compiles and runs OK even when  
> IPV6
> is not configured, because the necessary data structures and macros  
> are
> still defined.
>
> When IPV6 is not configured a few bytes (of executable) could be saved
> by making two versions of nfs_sockaddr_match() conditional on
> CONFIG_IPV6 but personally I don't think it is worth it.
>
> Log:
> ======================
> sockaddr structures can't be reliably compared using memcmp()
> because there are padding bytes in the structure which can't be
> guaranteed to be the same even when the sockaddr structures refer to
> the same socket.

It is also the case that IPv6 socket address structures contain other  
fields that don't have to match, like sin6_scope_id.  I think that is  
worth noting in the patch description.

I don't see anything immediately wrong with this approach, but I made  
a couple of additional minor comments below.

> Signed-off-by: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
> ======================
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index 9b728f3..04b11d9 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -272,6 +272,42 @@ static int nfs_sockaddr_match_ipaddr(const  
> struct sockaddr *sa1,
> }
> #endif
>
> +/* Test if two socket addresses are the same family, ipaddr and  
> port */

Instead of repeating what the function does, can this comment explain  
why the NFS client needs to match on the address and port, for example?

Explaining why it is different than the existing  
nfs_sockaddr_match_ipaddr() function would be helpful for future  
generations.

> +static int nfs_sockaddr_match(const struct sockaddr *sa1,
> +			      const struct sockaddr *sa2)
> +{
> +	if (sa1->sa_family != sa2->sa_family)
> +		return 0;
> +
> +	switch (sa1->sa_family) {
> +	case AF_INET:
> +		{
> +			const struct sockaddr_in * saddr1 =
> +				(const struct sockaddr_in *) sa1;
> +			const struct sockaddr_in * saddr2 =
> +				(const struct sockaddr_in *) sa2;
> +			if (likely(saddr1->sin_addr.s_addr !=
> +				   saddr2->sin_addr.s_addr)) {
> +				return 0;
> +			}
> +			return (saddr1->sin_port == saddr2->sin_port);
> +		}

As a stylistic point, these days we prefer to use a helper function  
instead of curly braces inside the arms of the switch.  It will also  
remove the need to fold those lines.

I have used this style in the past, but there is general consensus now  
that helper functions are easier to read, and are therefore preferred.

> +	case AF_INET6:
> +		{
> +			const struct sockaddr_in6 * saddr1 =
> +				(const struct sockaddr_in6 *) sa1;
> +			const struct sockaddr_in6 * saddr2 =
> +				(const struct sockaddr_in6 *) sa2;
> +			if (likely(!ipv6_addr_equal(&saddr1->sin6_addr,
> +						   &saddr1->sin6_addr))) {
> +				return 0;
> +			}
> +			return (saddr1->sin6_port == saddr2->sin6_port);
> +		}
> +	}
> +	return 0;
> +}
> +
> /*
>  * Find a client by IP address and protocol version
>  * - returns NULL if no such client
> @@ -344,8 +380,10 @@ struct nfs_client *nfs_find_client_next(struct  
> nfs_client *clp)
> static struct nfs_client *nfs_match_client(const struct  
> nfs_client_initdata *data)
> {
> 	struct nfs_client *clp;
> +	const struct sockaddr *sap = data->addr;
>
> 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
> +	        const struct sockaddr *clap = (struct sockaddr *)&clp- 
> >cl_addr;
> 		/* Don't match clients that failed to initialise properly */
> 		if (clp->cl_cons_state < 0)
> 			continue;
> @@ -358,7 +396,7 @@ static struct nfs_client *nfs_match_client(const  
> struct nfs_client_initdata *dat
> 			continue;
>
> 		/* Match the full socket address */
> -		if (memcmp(&clp->cl_addr, data->addr, sizeof(clp->cl_addr)) != 0)
> +		if (!nfs_sockaddr_match(sap, clap))
> 			continue;
>
> 		atomic_inc(&clp->cl_count);
>


--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
