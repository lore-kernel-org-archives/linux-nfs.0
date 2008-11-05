From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 05/12] lockd: encapsulate nlm_hosts table variables in one structure
Date: Wed, 5 Nov 2008 17:25:40 -0500
Message-ID: <5C259444-2EA3-489E-9FC9-5983DDE74950@oracle.com>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net> <1225915611-2401-1-git-send-email-bfields@citi.umich.edu> <1225915611-2401-2-git-send-email-bfields@citi.umich.edu> <1225915611-2401-3-git-send-email-bfields@citi.umich.edu> <1225915611-2401-4-git-send-email-bfields@citi.umich.edu> <1225915611-2401-5-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:19908 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753264AbYKEWZs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 17:25:48 -0500
In-Reply-To: <1225915611-2401-5-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 5, 2008, at 3:06 PM, J. Bruce Fields wrote:
> This will simplify splitting these variables into client and server
> sides.
>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
> fs/lockd/host.c |   46 ++++++++++++++++++++++++++--------------------
> 1 files changed, 26 insertions(+), 20 deletions(-)
>
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 1a1adb9..199ca8c 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -26,10 +26,16 @@
> #define NLM_HOST_EXPIRE		(300 * HZ)
> #define NLM_HOST_COLLECT	(120 * HZ)
>
> -static struct hlist_head	nlm_hosts[NLM_HOST_NRHASH];
> +struct host_table {
> +	struct hlist_head ht_chains[NLM_HOST_NRHASH];
> +	int ht_num;
> +	struct mutex ht_mutex;
> +};
> +
> +static struct host_table nlm_hosts = {
> +	.ht_mutex = __MUTEX_INITIALIZER(nlm_hosts.ht_mutex)
> +};
> static unsigned long		next_gc;

I also moved next_gc into the host_table struct in my version of these  
patches.  Do we want to garbage collect the client and server host  
caches separately?  I'm not sure.

>
> -static int			nrhosts;
> -static DEFINE_MUTEX(nlm_host_mutex);
>
> static void			nlm_gc_hosts(void);
> static struct nsm_handle	*nsm_find(const struct sockaddr *sap,
> @@ -140,7 +146,7 @@ static struct nlm_host *nlm_lookup_host(struct  
> nlm_lookup_host_info *ni)
> 	struct nlm_host	*host;
> 	struct nsm_handle *nsm;
>
> -	mutex_lock(&nlm_host_mutex);
> +	mutex_lock(&nlm_hosts.ht_mutex);
>
> 	if (time_after_eq(jiffies, next_gc))
> 		nlm_gc_hosts();
> @@ -152,7 +158,7 @@ static struct nlm_host *nlm_lookup_host(struct  
> nlm_lookup_host_info *ni)
> 	 * different NLM rpc_clients into one single nlm_host object.
> 	 * This would allow us to have one nlm_host per address.
> 	 */
> -	chain = &nlm_hosts[nlm_hash_address(ni->sap)];
> +	chain = &nlm_hosts.ht_chains[nlm_hash_address(ni->sap)];
> 	hlist_for_each_entry(host, pos, chain, h_hash) {
> 		if (!nlm_cmp_addr(nlm_addr(host), ni->sap))
> 			continue;
> @@ -218,7 +224,7 @@ static struct nlm_host *nlm_lookup_host(struct  
> nlm_lookup_host_info *ni)
> 	INIT_LIST_HEAD(&host->h_granted);
> 	INIT_LIST_HEAD(&host->h_reclaim);
>
> -	nrhosts++;
> +	nlm_hosts.ht_num++;
>
> 	nlm_display_address((struct sockaddr *)&host->h_addr,
> 				host->h_addrbuf, sizeof(host->h_addrbuf));
> @@ -229,7 +235,7 @@ static struct nlm_host *nlm_lookup_host(struct  
> nlm_lookup_host_info *ni)
> 			host->h_name);
>
> out:
> -	mutex_unlock(&nlm_host_mutex);
> +	mutex_unlock(&nlm_hosts.ht_mutex);
> 	return host;
> }
>
> @@ -498,8 +504,8 @@ void nlm_host_rebooted(const struct sockaddr_in  
> *sin,
> 	 * lock for this.
> 	 * To avoid processing a host several times, we match the nsmstate.
> 	 */
> -again:	mutex_lock(&nlm_host_mutex);
> -	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; + 
> +chain) {
> +again:	mutex_lock(&nlm_hosts.ht_mutex);
> +	for (chain = nlm_hosts.ht_chains; chain < nlm_hosts.ht_chains +  
> NLM_HOST_NRHASH; ++chain) {
> 		hlist_for_each_entry(host, pos, chain, h_hash) {
> 			if (host->h_nsmhandle == nsm
> 			 && host->h_nsmstate != new_state) {
> @@ -507,7 +513,7 @@ again:	mutex_lock(&nlm_host_mutex);
> 				host->h_state++;
>
> 				nlm_get_host(host);
> -				mutex_unlock(&nlm_host_mutex);
> +				mutex_unlock(&nlm_hosts.ht_mutex);
>
> 				if (host->h_server) {
> 					/* We're server for this guy, just ditch
> @@ -524,7 +530,7 @@ again:	mutex_lock(&nlm_host_mutex);
> 		}
> 	}
>
> -	mutex_unlock(&nlm_host_mutex);
> +	mutex_unlock(&nlm_hosts.ht_mutex);
> }
>
> /*
> @@ -539,11 +545,11 @@ nlm_shutdown_hosts(void)
> 	struct nlm_host	*host;
>
> 	dprintk("lockd: shutting down host module\n");
> -	mutex_lock(&nlm_host_mutex);
> +	mutex_lock(&nlm_hosts.ht_mutex);
>
> 	/* First, make all hosts eligible for gc */
> 	dprintk("lockd: nuking all hosts...\n");
> -	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; + 
> +chain) {
> +	for (chain = nlm_hosts.ht_chains; chain < nlm_hosts.ht_chains +  
> NLM_HOST_NRHASH; ++chain) {
> 		hlist_for_each_entry(host, pos, chain, h_hash) {
> 			host->h_expires = jiffies - 1;
> 			if (host->h_rpcclnt) {
> @@ -555,13 +561,13 @@ nlm_shutdown_hosts(void)
>
> 	/* Then, perform a garbage collection pass */
> 	nlm_gc_hosts();
> -	mutex_unlock(&nlm_host_mutex);
> +	mutex_unlock(&nlm_hosts.ht_mutex);
>
> 	/* complain if any hosts are left */
> -	if (nrhosts) {
> +	if (nlm_hosts.ht_num) {
> 		printk(KERN_WARNING "lockd: couldn't shutdown host module!\n");
> -		dprintk("lockd: %d hosts left:\n", nrhosts);
> -		for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; + 
> +chain) {
> +		dprintk("lockd: %d hosts left:\n", nlm_hosts.ht_num);
> +		for (chain = nlm_hosts.ht_chains; chain < nlm_hosts.ht_chains +  
> NLM_HOST_NRHASH; ++chain) {
> 			hlist_for_each_entry(host, pos, chain, h_hash) {
> 				dprintk("       %s (cnt %d use %d exp %ld)\n",
> 					host->h_name, atomic_read(&host->h_count),
> @@ -584,7 +590,7 @@ nlm_gc_hosts(void)
> 	struct nlm_host	*host;
>
> 	dprintk("lockd: host garbage collection\n");
> -	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; + 
> +chain) {
> +	for (chain = nlm_hosts.ht_chains; chain < nlm_hosts.ht_chains +  
> NLM_HOST_NRHASH; ++chain) {
> 		hlist_for_each_entry(host, pos, chain, h_hash)
> 			host->h_inuse = 0;
> 	}
> @@ -592,7 +598,7 @@ nlm_gc_hosts(void)
> 	/* Mark all hosts that hold locks, blocks or shares */
> 	nlmsvc_mark_resources();
>
> -	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; + 
> +chain) {
> +	for (chain = nlm_hosts.ht_chains; chain < nlm_hosts.ht_chains +  
> NLM_HOST_NRHASH; ++chain) {
> 		hlist_for_each_entry_safe(host, pos, next, chain, h_hash) {
> 			if (atomic_read(&host->h_count) || host->h_inuse
> 			 || time_before(jiffies, host->h_expires)) {
> @@ -605,7 +611,7 @@ nlm_gc_hosts(void)
> 			hlist_del_init(&host->h_hash);
>
> 			nlm_destroy_host(host);
> -			nrhosts--;
> +			nlm_hosts.ht_num--;
> 		}
> 	}
>
> -- 
> 1.5.5.rc1
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



