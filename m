From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/7] NLM: Convert nlm_lookup_host() to use a single argument
Date: Fri, 3 Oct 2008 13:33:38 -0400
Message-ID: <51B54FBE-A322-4561-BCEC-AB805DE3BB06@oracle.com>
References: <20081003162856.10198.20451.stgit@ingres.1015granger.net> <20081003165006.10198.9012.stgit@ingres.1015granger.net> <1223054162.7346.1.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:56473 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798AbYJCReL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 13:34:11 -0400
In-Reply-To: <1223054162.7346.1.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 3, 2008, at Oct 3, 2008, 1:16 PM, Trond Myklebust wrote:
> On Fri, 2008-10-03 at 12:50 -0400, Chuck Lever wrote:
>> The nlm_lookup_host() function already has a large number of  
>> arguments,
>> and I'm about to add a few more.  As a clean up, convert the function
>> to use a single data structure argument.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/lockd/host.c |   89 +++++++++++++++++++++++++++++++++++ 
>> +-------------------
>> 1 files changed, 59 insertions(+), 30 deletions(-)
>>
>> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
>> index be8f19d..1630588 100644
>> --- a/fs/lockd/host.c
>> +++ b/fs/lockd/host.c
>> @@ -38,6 +38,20 @@ static struct nsm_handle	*nsm_find(const struct  
>> sockaddr *sap,
>> 						const size_t hostname_len,
>> 						const int create);
>>
>> +#define NLM_SERVER	(0)
>> +#define NLM_CLIENT	(1)
>> +
>
> Could we please get RID of this crap instead of 'documenting' it?  
> There
> is absolutely _no_ excuse for keeping a single list for both server  
> and
> client struct hosts...
>
> Strongly NACKED....

We haven't dropped that work item, but Bruce and I agreed months ago  
that he would handle the client/server list split *after* I had  
finished the IPv6 changes.  I think the IPv6 work is a much higher  
priority here.


>
>
>> +struct nlm_lookup_host_info {
>> +	const int		peer;		/* search for server|client */
>> +	const struct sockaddr_in *sin;		/* address to search for */
>> +	const unsigned short	protocol;	/* transport to search for*/
>> +	const u32		version;	/* NLM version to search for */
>> +	const char		*hostname;	/* remote's hostname */
>> +	const size_t		hostname_len;	/* it's length */
>> +	const struct sockaddr_in *src_sin;	/* our address (optional) */
>> +	const size_t		src_len;	/* it's length */
>> +};
>> +
>> /*
>>  * Hash function must work well on big- and little-endian platforms
>>  */
>> @@ -121,23 +135,13 @@ static void nlm_display_address(const struct  
>> sockaddr *sap,
>> /*
>>  * Common host lookup routine for server & client
>>  */
>> -static struct nlm_host *nlm_lookup_host(int server,
>> -					const struct sockaddr_in *sin,
>> -					int proto, u32 version,
>> -					const char *hostname,
>> -					unsigned int hostname_len,
>> -					const struct sockaddr_in *ssin)
>> +static struct nlm_host *nlm_lookup_host(struct  
>> nlm_lookup_host_info *ni)
>> {
>> 	struct hlist_head *chain;
>> 	struct hlist_node *pos;
>> 	struct nlm_host	*host;
>> 	struct nsm_handle *nsm = NULL;
>>
>> -	dprintk("lockd: nlm_lookup_host(proto=%d, vers=%u,"
>> -			" my role is %s, hostname=%.*s)\n",
>> -			proto, version, server ? "server" : "client",
>> -			hostname_len, hostname ? hostname : "<none>");
>> -
>> 	mutex_lock(&nlm_host_mutex);
>>
>> 	if (time_after_eq(jiffies, next_gc))
>> @@ -150,22 +154,23 @@ static struct nlm_host *nlm_lookup_host(int  
>> server,
>> 	 * different NLM rpc_clients into one single nlm_host object.
>> 	 * This would allow us to have one nlm_host per address.
>> 	 */
>> -	chain = &nlm_hosts[nlm_hash_address((struct sockaddr *)sin)];
>> +	chain = &nlm_hosts[nlm_hash_address((struct sockaddr *)ni->sin)];
>> 	hlist_for_each_entry(host, pos, chain, h_hash) {
>> -		if (!nlm_cmp_addr(nlm_addr(host), (struct sockaddr *)sin))
>> +		if (!nlm_cmp_addr(nlm_addr(host), (struct sockaddr *)ni->sin))
>> 			continue;
>>
>> 		/* See if we have an NSM handle for this client */
>> 		if (!nsm)
>> 			nsm = host->h_nsmhandle;
>>
>> -		if (host->h_proto != proto)
>> +		if (host->h_proto != ni->protocol)
>> 			continue;
>> -		if (host->h_version != version)
>> +		if (host->h_version != ni->version)
>> 			continue;
>> -		if (host->h_server != server)
>> +		if (host->h_server != ni->peer)
>> 			continue;
>> -		if (!nlm_cmp_addr(nlm_srcaddr(host), (struct sockaddr *)ssin))
>> +		if (!nlm_cmp_addr(nlm_srcaddr(host),
>> +					(struct sockaddr *)ni->src_sin))
>> 			continue;
>>
>> 		/* Move to head of hash chain. */
>> @@ -186,8 +191,9 @@ static struct nlm_host *nlm_lookup_host(int  
>> server,
>> 		atomic_inc(&nsm->sm_count);
>> 	else {
>> 		host = NULL;
>> -		nsm = nsm_find((struct sockaddr *)sin, sizeof(*sin),
>> -				hostname, hostname_len, 1);
>> +		nsm = nsm_find((struct sockaddr *)ni->sin,
>> +				sizeof(struct sockaddr_in),
>> +				ni->hostname, ni->hostname_len, 1);
>> 		if (!nsm) {
>> 			dprintk("lockd: nlm_lookup_host failed; "
>> 				"no nsm handle\n");
>> @@ -202,12 +208,12 @@ static struct nlm_host *nlm_lookup_host(int  
>> server,
>> 		goto out;
>> 	}
>> 	host->h_name	   = nsm->sm_name;
>> -	memcpy(nlm_addr(host), sin, sizeof(*sin));
>> -	host->h_addrlen = sizeof(*sin);
>> +	memcpy(nlm_addr(host), ni->sin, sizeof(struct sockaddr_in));
>> +	host->h_addrlen = sizeof(struct sockaddr_in);
>> 	nlm_clear_port(nlm_addr(host));
>> -	memcpy(nlm_srcaddr(host), ssin, sizeof(*ssin));
>> -	host->h_version    = version;
>> -	host->h_proto      = proto;
>> +	memcpy(nlm_srcaddr(host), ni->src_sin, sizeof(struct sockaddr_in));
>> +	host->h_version    = ni->version;
>> +	host->h_proto      = ni->protocol;
>> 	host->h_rpcclnt    = NULL;
>> 	mutex_init(&host->h_mutex);
>> 	host->h_nextrebind = jiffies + NLM_HOST_REBIND;
>> @@ -218,7 +224,7 @@ static struct nlm_host *nlm_lookup_host(int  
>> server,
>> 	host->h_state      = 0;			/* pseudo NSM state */
>> 	host->h_nsmstate   = 0;			/* real NSM state */
>> 	host->h_nsmhandle  = nsm;
>> -	host->h_server	   = server;
>> +	host->h_server	   = ni->peer;
>> 	hlist_add_head(&host->h_hash, chain);
>> 	INIT_LIST_HEAD(&host->h_lockowners);
>> 	spin_lock_init(&host->h_lock);
>> @@ -273,9 +279,21 @@ struct nlm_host *nlmclnt_lookup_host(const  
>> struct sockaddr_in *sin,
>> 	const struct sockaddr_in source = {
>> 		.sin_family	= AF_UNSPEC,
>> 	};
>> +	struct nlm_lookup_host_info ni = {
>> +		.peer		= NLM_SERVER,
>> +		.sin		= sin,
>> +		.protocol	= proto,
>> +		.version	= version,
>> +		.hostname	= hostname,
>> +		.hostname_len	= hostname_len,
>> +		.src_sin	= &source,
>> +	};
>>
>> -	return nlm_lookup_host(0, sin, proto, version,
>> -			       hostname, hostname_len, &source);
>> +	dprintk("lockd: %s(host='%s', vers=%u, proto=%s)\n", __func__,
>> +			(hostname ? hostname : "<none>"), version,
>> +			(proto == IPPROTO_UDP ? "udp" : "tcp"));
>> +
>> +	return nlm_lookup_host(&ni);
>> }
>>
>> /*
>> @@ -289,10 +307,21 @@ nlmsvc_lookup_host(struct svc_rqst *rqstp,
>> 		.sin_family	= AF_INET,
>> 		.sin_addr	= rqstp->rq_daddr.addr,
>> 	};
>> +	struct nlm_lookup_host_info ni = {
>> +		.peer		= NLM_CLIENT,
>> +		.sin		= svc_addr_in(rqstp),
>> +		.protocol	= rqstp->rq_prot,
>> +		.version	= rqstp->rq_vers,
>> +		.hostname	= hostname,
>> +		.hostname_len	= hostname_len,
>> +		.src_sin	= &source,
>> +	};
>> +
>> +	dprintk("lockd: %s(host='%*s', vers=%u, proto=%s)\n", __func__,
>> +			(int)hostname_len, hostname, rqstp->rq_vers,
>> +			(rqstp->rq_prot == IPPROTO_UDP ? "udp" : "tcp"));
>>
>> -	return nlm_lookup_host(1, svc_addr_in(rqstp),
>> -			       rqstp->rq_prot, rqstp->rq_vers,
>> -			       hostname, hostname_len, &source);
>> +	return nlm_lookup_host(&ni);
>> }
>>
>> /*
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




