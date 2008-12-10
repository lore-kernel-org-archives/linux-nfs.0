From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 07/27] NSM: Move nsm_find() to fs/lockd/mon.c
Date: Wed, 10 Dec 2008 16:08:29 -0500
Message-ID: <45CACC98-BE7E-4B66-B633-19716D523416@oracle.com>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net> <20081206000244.24075.75258.stgit@ingres.1015granger.net> <20081210205814.GF1212@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:28269 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753842AbYLJVIr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Dec 2008 16:08:47 -0500
In-Reply-To: <20081210205814.GF1212@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 10, 2008, at Dec 10, 2008, 3:58 PM, J. Bruce Fields wrote:
> On Fri, Dec 05, 2008 at 07:02:45PM -0500, Chuck Lever wrote:
>> The nsm_find() function sets up fresh nsm_handle entries.  This is
>> where we will store the "priv" cookie used to lookup nsm_handles  
>> during
>> reboot recovery.  The cookie will be constructed when nsm_find()
>> creates a new nsm_handle.
>>
>> As much as possible, I would like to keep everything that handles a
>> "priv" cookie in fs/lockd/mon.c so that all the smarts are in one
>> source file.  That organization should make it pretty simple to see  
>> how
>> all this works.
>>
>> To me, it makes more sense than the current arrangement to keep
>> nsm_find() with nsm_monitor() and nsm_unmonitor().
>>
>> So, start reorganizing by moving nsm_find() into fs/lockd/mon.c.  The
>> nsm_release() function comes along too, since it shares the nsm_lock
>> global variable.
>
> OK, haven't thought that organization through myself, but it sounds
> sensible, so I'll trust your judgement; applied.--b.

My thinking is that an nsm_handle is a different object than an  
nlm_host.  nlm_hosts are managed in fs/lockd/host.c, and nsm_handles  
will be managed in fs/lockd/mon.c.  The data structures and methods  
for each will be in their own separate source files.

It's possible that fs/lockd/mon.c should only care about the upcalls,  
as it does today.  However, if we leave nsm_find() (and later,  
nsm_reboot_lookup()) in fs/lockd/host.c, then both mon.c and host.c  
have to care about what's in nsm_private.  I would rather collect all  
of that local knowledge in a single source file.

We can talk about it more f2f tomorrow if you have questions, or have  
thought of better ways to organize this.

>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/lockd/host.c             |  129  
>> -----------------------------------------
>> fs/lockd/mon.c              |  134 +++++++++++++++++++++++++++++++++ 
>> ++++++++++
>> include/linux/lockd/lockd.h |    6 ++
>> 3 files changed, 140 insertions(+), 129 deletions(-)
>>
>> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
>> index 316241a..dbdeaa8 100644
>> --- a/fs/lockd/host.c
>> +++ b/fs/lockd/host.c
>> @@ -32,12 +32,6 @@ static int			nrhosts;
>> static DEFINE_MUTEX(nlm_host_mutex);
>>
>> static void			nlm_gc_hosts(void);
>> -static struct nsm_handle	*nsm_find(const struct sockaddr *sap,
>> -						const size_t salen,
>> -						const char *hostname,
>> -						const size_t hostname_len,
>> -						const int create);
>> -static void			nsm_release(struct nsm_handle *nsm);
>>
>> struct nlm_lookup_host_info {
>> 	const int		server;		/* search for server|client */
>> @@ -106,44 +100,6 @@ static void nlm_clear_port(struct sockaddr *sap)
>> 	}
>> }
>>
>> -static void nlm_display_ipv4_address(const struct sockaddr *sap,  
>> char *buf,
>> -				     const size_t len)
>> -{
>> -	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
>> -	snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
>> -}
>> -
>> -static void nlm_display_ipv6_address(const struct sockaddr *sap,  
>> char *buf,
>> -				     const size_t len)
>> -{
>> -	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
>> -
>> -	if (ipv6_addr_v4mapped(&sin6->sin6_addr))
>> -		snprintf(buf, len, NIPQUAD_FMT,
>> -				NIPQUAD(sin6->sin6_addr.s6_addr32[3]));
>> -	else if (sin6->sin6_scope_id != 0)
>> -		snprintf(buf, len, NIP6_FMT "%%%u", NIP6(sin6->sin6_addr),
>> -				sin6->sin6_scope_id);
>> -	else
>> -		snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
>> -}
>> -
>> -static void nlm_display_address(const struct sockaddr *sap,
>> -				char *buf, const size_t len)
>> -{
>> -	switch (sap->sa_family) {
>> -	case AF_INET:
>> -		nlm_display_ipv4_address(sap, buf, len);
>> -		break;
>> -	case AF_INET6:
>> -		nlm_display_ipv6_address(sap, buf, len);
>> -		break;
>> -	default:
>> -		snprintf(buf, len, "unsupported address family");
>> -		break;
>> -	}
>> -}
>> -
>> /*
>>  * Common host lookup routine for server & client
>>  */
>> @@ -636,88 +592,3 @@ nlm_gc_hosts(void)
>>
>> 	next_gc = jiffies + NLM_HOST_COLLECT;
>> }
>> -
>> -
>> -/*
>> - * Manage NSM handles
>> - */
>> -static LIST_HEAD(nsm_handles);
>> -static DEFINE_SPINLOCK(nsm_lock);
>> -
>> -static struct nsm_handle *nsm_find(const struct sockaddr *sap,
>> -				   const size_t salen,
>> -				   const char *hostname,
>> -				   const size_t hostname_len,
>> -				   const int create)
>> -{
>> -	struct nsm_handle *nsm = NULL;
>> -	struct nsm_handle *pos;
>> -
>> -	if (!sap)
>> -		return NULL;
>> -
>> -	if (hostname && memchr(hostname, '/', hostname_len) != NULL) {
>> -		if (printk_ratelimit()) {
>> -			printk(KERN_WARNING "Invalid hostname \"%.*s\" "
>> -					    "in NFS lock request\n",
>> -				(int)hostname_len, hostname);
>> -		}
>> -		return NULL;
>> -	}
>> -
>> -retry:
>> -	spin_lock(&nsm_lock);
>> -	list_for_each_entry(pos, &nsm_handles, sm_link) {
>> -
>> -		if (hostname && nsm_use_hostnames) {
>> -			if (strlen(pos->sm_name) != hostname_len
>> -			 || memcmp(pos->sm_name, hostname, hostname_len))
>> -				continue;
>> -		} else if (!nlm_cmp_addr(nsm_addr(pos), sap))
>> -			continue;
>> -		atomic_inc(&pos->sm_count);
>> -		kfree(nsm);
>> -		nsm = pos;
>> -		goto found;
>> -	}
>> -	if (nsm) {
>> -		list_add(&nsm->sm_link, &nsm_handles);
>> -		goto found;
>> -	}
>> -	spin_unlock(&nsm_lock);
>> -
>> -	if (!create)
>> -		return NULL;
>> -
>> -	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
>> -	if (nsm == NULL)
>> -		return NULL;
>> -
>> -	memcpy(nsm_addr(nsm), sap, salen);
>> -	nsm->sm_addrlen = salen;
>> -	nsm->sm_name = (char *) (nsm + 1);
>> -	memcpy(nsm->sm_name, hostname, hostname_len);
>> -	nsm->sm_name[hostname_len] = '\0';
>> -	nlm_display_address((struct sockaddr *)&nsm->sm_addr,
>> -				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
>> -	atomic_set(&nsm->sm_count, 1);
>> -	goto retry;
>> -
>> -found:
>> -	spin_unlock(&nsm_lock);
>> -	return nsm;
>> -}
>> -
>> -/*
>> - * Release an NSM handle
>> - */
>> -static void nsm_release(struct nsm_handle *nsm)
>> -{
>> -	if (!nsm)
>> -		return;
>> -	if (atomic_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
>> -		list_del(&nsm->sm_link);
>> -		spin_unlock(&nsm_lock);
>> -		kfree(nsm);
>> -	}
>> -}
>> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
>> index 81e1cc1..d5bd847 100644
>> --- a/fs/lockd/mon.c
>> +++ b/fs/lockd/mon.c
>> @@ -47,12 +47,52 @@ struct nsm_res {
>> static struct rpc_clnt *	nsm_create(void);
>>
>> static struct rpc_program	nsm_program;
>> +static				LIST_HEAD(nsm_handles);
>> +static				DEFINE_SPINLOCK(nsm_lock);
>>
>> /*
>>  * Local NSM state
>>  */
>> int				nsm_local_state;
>>
>> +static void nsm_display_ipv4_address(const struct sockaddr *sap,  
>> char *buf,
>> +				     const size_t len)
>> +{
>> +	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
>> +	snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
>> +}
>> +
>> +static void nsm_display_ipv6_address(const struct sockaddr *sap,  
>> char *buf,
>> +				     const size_t len)
>> +{
>> +	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
>> +
>> +	if (ipv6_addr_v4mapped(&sin6->sin6_addr))
>> +		snprintf(buf, len, NIPQUAD_FMT,
>> +				NIPQUAD(sin6->sin6_addr.s6_addr32[3]));
>> +	else if (sin6->sin6_scope_id != 0)
>> +		snprintf(buf, len, NIP6_FMT "%%%u", NIP6(sin6->sin6_addr),
>> +				sin6->sin6_scope_id);
>> +	else
>> +		snprintf(buf, len, NIP6_FMT, NIP6(sin6->sin6_addr));
>> +}
>> +
>> +static void nsm_display_address(const struct sockaddr *sap,
>> +				char *buf, const size_t len)
>> +{
>> +	switch (sap->sa_family) {
>> +	case AF_INET:
>> +		nsm_display_ipv4_address(sap, buf, len);
>> +		break;
>> +	case AF_INET6:
>> +		nsm_display_ipv6_address(sap, buf, len);
>> +		break;
>> +	default:
>> +		snprintf(buf, len, "unsupported address family");
>> +		break;
>> +	}
>> +}
>> +
>> /*
>>  * Common procedure for NSMPROC_MON/NSMPROC_UNMON calls
>>  */
>> @@ -162,6 +202,100 @@ void nsm_unmonitor(const struct nlm_host *host)
>> 	}
>> }
>>
>> +/**
>> + * nsm_find - Find or create a cached nsm_handle
>> + * @sap: pointer to socket address of handle to find
>> + * @salen: length of socket address
>> + * @hostname: pointer to C string containing hostname to find
>> + * @hostname_len: length of C string
>> + * @create: one means create new handle if not found in cache
>> + *
>> + * Behavior is modulated by the global nsm_use_hostnames variable
>> + * and by the @create argument.
>> + *
>> + * Returns a cached nsm_handle after bumping its ref count, or if
>> + * @create is set, returns a fresh nsm_handle if a handle that
>> + * matches @sap and/or @hostname cannot be found in the handle  
>> cache.
>> + * Returns NULL if an error occurs.
>> + */
>> +struct nsm_handle *nsm_find(const struct sockaddr *sap, const  
>> size_t salen,
>> +			    const char *hostname, const size_t hostname_len,
>> +			    const int create)
>> +{
>> +	struct nsm_handle *nsm = NULL;
>> +	struct nsm_handle *pos;
>> +
>> +	if (!sap)
>> +		return NULL;
>> +
>> +	if (hostname && memchr(hostname, '/', hostname_len) != NULL) {
>> +		if (printk_ratelimit()) {
>> +			printk(KERN_WARNING "Invalid hostname \"%.*s\" "
>> +					    "in NFS lock request\n",
>> +				(int)hostname_len, hostname);
>> +		}
>> +		return NULL;
>> +	}
>> +
>> +retry:
>> +	spin_lock(&nsm_lock);
>> +	list_for_each_entry(pos, &nsm_handles, sm_link) {
>> +
>> +		if (hostname && nsm_use_hostnames) {
>> +			if (strlen(pos->sm_name) != hostname_len
>> +			 || memcmp(pos->sm_name, hostname, hostname_len))
>> +				continue;
>> +		} else if (!nlm_cmp_addr(nsm_addr(pos), sap))
>> +			continue;
>> +		atomic_inc(&pos->sm_count);
>> +		kfree(nsm);
>> +		nsm = pos;
>> +		goto found;
>> +	}
>> +	if (nsm) {
>> +		list_add(&nsm->sm_link, &nsm_handles);
>> +		goto found;
>> +	}
>> +	spin_unlock(&nsm_lock);
>> +
>> +	if (!create)
>> +		return NULL;
>> +
>> +	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
>> +	if (nsm == NULL)
>> +		return NULL;
>> +
>> +	memcpy(nsm_addr(nsm), sap, salen);
>> +	nsm->sm_addrlen = salen;
>> +	nsm->sm_name = (char *) (nsm + 1);
>> +	memcpy(nsm->sm_name, hostname, hostname_len);
>> +	nsm->sm_name[hostname_len] = '\0';
>> +	nsm_display_address((struct sockaddr *)&nsm->sm_addr,
>> +				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
>> +	atomic_set(&nsm->sm_count, 1);
>> +	goto retry;
>> +
>> +found:
>> +	spin_unlock(&nsm_lock);
>> +	return nsm;
>> +}
>> +
>> +/**
>> + * nsm_release - Release an NSM handle
>> + * @nsm: pointer to handle to be released
>> + *
>> + */
>> +void nsm_release(struct nsm_handle *nsm)
>> +{
>> +	if (!nsm)
>> +		return;
>> +	if (atomic_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
>> +		list_del(&nsm->sm_link);
>> +		spin_unlock(&nsm_lock);
>> +		kfree(nsm);
>> +	}
>> +}
>> +
>> /*
>>  * Create NSM client for the local host
>>  */
>> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/ 
>> lockd.h
>> index 38344bf..8d71536 100644
>> --- a/include/linux/lockd/lockd.h
>> +++ b/include/linux/lockd/lockd.h
>> @@ -247,6 +247,12 @@ extern void	  nlm_host_rebooted(const struct  
>> sockaddr_in *, const char *,
>> int		  nsm_monitor(const struct nlm_host *host);
>> void		  nsm_unmonitor(const struct nlm_host *host);
>>
>> +struct nsm_handle *nsm_find(const struct sockaddr *sap, const  
>> size_t salen,
>> +					const char *hostname,
>> +					const size_t hostname_len,
>> +					const int create);
>> +void		  nsm_release(struct nsm_handle *nsm);
>> +
>> /*
>>  * This is used in garbage collection and resource reclaim
>>  * A return value != 0 means destroy the lock/block/share
>>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




