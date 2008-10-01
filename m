From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/10] lockd: Support non-AF_INET addresses in
	nlm_lookup_host()
Date: Wed, 1 Oct 2008 14:21:25 -0400
Message-ID: <20081001182125.GG6001@fieldses.org>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net> <20080917161720.4963.42788.stgit@ellison.1015granger.net> <20080926215324.GC7138@fieldses.org> <C23C367A-ECD8-424C-A3AA-3DF6F5886CDF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52633 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753957AbYJASV1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Oct 2008 14:21:27 -0400
In-Reply-To: <C23C367A-ECD8-424C-A3AA-3DF6F5886CDF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 01, 2008 at 11:50:27AM -0400, Chuck Lever wrote:
> On Sep 26, 2008, at Sep 26, 2008, 5:53 PM, J. Bruce Fields wrote:
>> On Wed, Sep 17, 2008 at 11:17:21AM -0500, Chuck Lever wrote:
>>> Make nlm_lookup_host() agnostic to address families.  As a clean up, 
>>> convert
>>> nlm_lookup_host() to use a single structure instead of nearly a  
>>> dozen separate
>>> arguments.
>>
>> Could you do those two steps as two separate patches, and resend?
>
> I tried that before, but it didn't make sense as two patches.
>
> I can try it again.

It should be very straightforward; I'd do the cleanup first, so:

	1. Bundle up nlm_lookup_host arguments into a single structure.
	2. Fix the address fields in that structure.

And it'd make change #2 trivial to verify.

--b.

>
>>
>>
>> --b.
>>
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> fs/lockd/host.c |   88 ++++++++++++++++++++++++++++++++++ 
>>> +--------------------
>>> 1 files changed, 56 insertions(+), 32 deletions(-)
>>>
>>> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
>>> index be8f19d..c9d25d1 100644
>>> --- a/fs/lockd/host.c
>>> +++ b/fs/lockd/host.c
>>> @@ -38,6 +38,21 @@ static struct nsm_handle	*nsm_find(const struct  
>>> sockaddr *sap,
>>> 						const size_t hostname_len,
>>> 						const int create);
>>>
>>> +#define NLM_SERVER	(0)
>>> +#define NLM_CLIENT	(1)
>>> +
>>> +struct nlm_lookup_host_info {
>>> +	const int		peer;		/* search for server|client */
>>> +	const struct sockaddr	*sap;		/* address to search for */
>>> +	const size_t		salen;		/* it's length */
>>> +	const unsigned short	protocol;	/* transport to search for*/
>>> +	const u32		version;	/* NLM version to search for */
>>> +	const char		*hostname;	/* remote's hostname */
>>> +	const size_t		hostname_len;	/* it's length */
>>> +	const struct sockaddr	*src_sap;	/* our address (optional) */
>>> +	const size_t		src_len;	/* it's length */
>>> +};
>>> +
>>> /*
>>>  * Hash function must work well on big- and little-endian platforms
>>>  */
>>> @@ -121,23 +136,13 @@ static void nlm_display_address(const struct  
>>> sockaddr *sap,
>>> /*
>>>  * Common host lookup routine for server & client
>>>  */
>>> -static struct nlm_host *nlm_lookup_host(int server,
>>> -					const struct sockaddr_in *sin,
>>> -					int proto, u32 version,
>>> -					const char *hostname,
>>> -					unsigned int hostname_len,
>>> -					const struct sockaddr_in *ssin)
>>> +static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info 
>>> *ni)
>>> {
>>> 	struct hlist_head *chain;
>>> 	struct hlist_node *pos;
>>> 	struct nlm_host	*host;
>>> 	struct nsm_handle *nsm = NULL;
>>>
>>> -	dprintk("lockd: nlm_lookup_host(proto=%d, vers=%u,"
>>> -			" my role is %s, hostname=%.*s)\n",
>>> -			proto, version, server ? "server" : "client",
>>> -			hostname_len, hostname ? hostname : "<none>");
>>> -
>>> 	mutex_lock(&nlm_host_mutex);
>>>
>>> 	if (time_after_eq(jiffies, next_gc))
>>> @@ -150,22 +155,22 @@ static struct nlm_host *nlm_lookup_host(int  
>>> server,
>>> 	 * different NLM rpc_clients into one single nlm_host object.
>>> 	 * This would allow us to have one nlm_host per address.
>>> 	 */
>>> -	chain = &nlm_hosts[nlm_hash_address((struct sockaddr *)sin)];
>>> +	chain = &nlm_hosts[nlm_hash_address(ni->sap)];
>>> 	hlist_for_each_entry(host, pos, chain, h_hash) {
>>> -		if (!nlm_cmp_addr(nlm_addr(host), (struct sockaddr *)sin))
>>> +		if (!nlm_cmp_addr(nlm_addr(host), ni->sap))
>>> 			continue;
>>>
>>> 		/* See if we have an NSM handle for this client */
>>> 		if (!nsm)
>>> 			nsm = host->h_nsmhandle;
>>>
>>> -		if (host->h_proto != proto)
>>> +		if (host->h_proto != ni->protocol)
>>> 			continue;
>>> -		if (host->h_version != version)
>>> +		if (host->h_version != ni->version)
>>> 			continue;
>>> -		if (host->h_server != server)
>>> +		if (host->h_server != ni->peer)
>>> 			continue;
>>> -		if (!nlm_cmp_addr(nlm_srcaddr(host), (struct sockaddr *)ssin))
>>> +		if (!nlm_cmp_addr(nlm_srcaddr(host), ni->src_sap))
>>> 			continue;
>>>
>>> 		/* Move to head of hash chain. */
>>> @@ -186,8 +191,8 @@ static struct nlm_host *nlm_lookup_host(int  
>>> server,
>>> 		atomic_inc(&nsm->sm_count);
>>> 	else {
>>> 		host = NULL;
>>> -		nsm = nsm_find((struct sockaddr *)sin, sizeof(*sin),
>>> -				hostname, hostname_len, 1);
>>> +		nsm = nsm_find(ni->sap, ni->salen,
>>> +					ni->hostname, ni->hostname_len, 1);
>>> 		if (!nsm) {
>>> 			dprintk("lockd: nlm_lookup_host failed; "
>>> 				"no nsm handle\n");
>>> @@ -202,12 +207,12 @@ static struct nlm_host *nlm_lookup_host(int  
>>> server,
>>> 		goto out;
>>> 	}
>>> 	host->h_name	   = nsm->sm_name;
>>> -	memcpy(nlm_addr(host), sin, sizeof(*sin));
>>> -	host->h_addrlen = sizeof(*sin);
>>> +	memcpy(nlm_addr(host), ni->sap, ni->salen);
>>> +	host->h_addrlen = ni->salen;
>>> 	nlm_clear_port(nlm_addr(host));
>>> -	memcpy(nlm_srcaddr(host), ssin, sizeof(*ssin));
>>> -	host->h_version    = version;
>>> -	host->h_proto      = proto;
>>> +	memcpy(nlm_srcaddr(host), ni->src_sap, ni->src_len);
>>> +	host->h_version    = ni->version;
>>> +	host->h_proto      = ni->protocol;
>>> 	host->h_rpcclnt    = NULL;
>>> 	mutex_init(&host->h_mutex);
>>> 	host->h_nextrebind = jiffies + NLM_HOST_REBIND;
>>> @@ -218,7 +223,7 @@ static struct nlm_host *nlm_lookup_host(int  
>>> server,
>>> 	host->h_state      = 0;			/* pseudo NSM state */
>>> 	host->h_nsmstate   = 0;			/* real NSM state */
>>> 	host->h_nsmhandle  = nsm;
>>> -	host->h_server	   = server;
>>> +	host->h_server	   = ni->peer;
>>> 	hlist_add_head(&host->h_hash, chain);
>>> 	INIT_LIST_HEAD(&host->h_lockowners);
>>> 	spin_lock_init(&host->h_lock);
>>> @@ -270,12 +275,22 @@ struct nlm_host *nlmclnt_lookup_host(const  
>>> struct sockaddr_in *sin,
>>> 				     const char *hostname,
>>> 				     unsigned int hostname_len)
>>> {
>>> -	const struct sockaddr_in source = {
>>> -		.sin_family	= AF_UNSPEC,
>>> +	const struct sockaddr source = {
>>> +		.sa_family	= AF_UNSPEC,
>>> +	};
>>> +	struct nlm_lookup_host_info ni = {
>>> +		.peer		= NLM_SERVER,
>>> +		.sap		= (struct sockaddr *)sin,
>>> +		.salen		= sizeof(*sin),
>>> +		.protocol	= proto,
>>> +		.version	= version,
>>> +		.hostname	= hostname,
>>> +		.hostname_len	= hostname_len,
>>> +		.src_sap	= &source,
>>> +		.src_len	= sizeof(source),
>>> 	};
>>>
>>> -	return nlm_lookup_host(0, sin, proto, version,
>>> -			       hostname, hostname_len, &source);
>>> +	return nlm_lookup_host(&ni);
>>> }
>>>
>>> /*
>>> @@ -289,10 +304,19 @@ nlmsvc_lookup_host(struct svc_rqst *rqstp,
>>> 		.sin_family	= AF_INET,
>>> 		.sin_addr	= rqstp->rq_daddr.addr,
>>> 	};
>>> +	struct nlm_lookup_host_info ni = {
>>> +		.peer		= NLM_CLIENT,
>>> +		.sap		= svc_addr(rqstp),
>>> +		.salen		= rqstp->rq_addrlen,
>>> +		.protocol	= rqstp->rq_prot,
>>> +		.version	= rqstp->rq_vers,
>>> +		.hostname	= hostname,
>>> +		.hostname_len	= hostname_len,
>>> +		.src_sap	= (struct sockaddr *)&source,
>>> +		.src_len	= sizeof(source),
>>> +	};
>>>
>>> -	return nlm_lookup_host(1, svc_addr_in(rqstp),
>>> -			       rqstp->rq_prot, rqstp->rq_vers,
>>> -			       hostname, hostname_len, &source);
>>> +	return nlm_lookup_host(&ni);
>>> }
>>>
>>> /*
>>>
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
