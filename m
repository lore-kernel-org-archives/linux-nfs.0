Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37139 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935496AbbI2Srq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Sep 2015 14:47:46 -0400
Date: Tue, 29 Sep 2015 14:47:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, skinsbursky@virtuozzo.com,
        stable@vger.kernel.org
Subject: Re: [PATCH] lockd: create NSM handles per net namespace
Message-ID: <20150929184745.GG3190@fieldses.org>
References: <1443012569-21623-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1443012569-21623-1-git-send-email-aryabinin@virtuozzo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 23, 2015 at 03:49:29PM +0300, Andrey Ryabinin wrote:
> Commit cb7323fffa85 ("lockd: create and use per-net NSM
>  RPC clients on MON/UNMON requests") introduced per-net
> NSM RPC clients. Unfortunately this doesn't make any sense
> without per-net nsm_handle.

Makes sense to me.  Is anyone doing testing to make sure we've got this
right now?

(For example, have you reproduced the below problem and verified that
it's fixed after this patch?)

--b.

> 
> E.g. the following scenario could happen
> Two hosts (X and Y) in different namespaces (A and B) share
> the same nsm struct.
> 
> 1. nsm_monitor(host_X) called => NSM rpc client created,
> 	nsm->sm_monitored bit set.
> 2. nsm_mointor(host-Y) called => nsm->sm_monitored already set,
> 	we just exit. Thus in namespace B ln->nsm_clnt == NULL.
> 3. host X destroyed => nsm->sm_count decremented to 1
> 4. host Y destroyed => nsm_unmonitor() => nsm_mon_unmon() => NULL-ptr
> 	dereference of *ln->nsm_clnt
> 
> So this could be fixed by making per-net nsm_handles list,
> instead of global. Thus different net namespaces will not be able
> share the same nsm_handle.
> 
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: <stable@vger.kernel.org>
> ---
>  fs/lockd/host.c             |  7 ++++---
>  fs/lockd/mon.c              | 36 ++++++++++++++++++++++--------------
>  fs/lockd/netns.h            |  1 +
>  fs/lockd/svc.c              |  1 +
>  fs/lockd/svc4proc.c         |  2 +-
>  fs/lockd/svcproc.c          |  2 +-
>  include/linux/lockd/lockd.h |  9 ++++++---
>  7 files changed, 36 insertions(+), 22 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 969d589..b5f3c3a 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -116,7 +116,7 @@ static struct nlm_host *nlm_alloc_host(struct nlm_lookup_host_info *ni,
>  		atomic_inc(&nsm->sm_count);
>  	else {
>  		host = NULL;
> -		nsm = nsm_get_handle(ni->sap, ni->salen,
> +		nsm = nsm_get_handle(ni->net, ni->sap, ni->salen,
>  					ni->hostname, ni->hostname_len);
>  		if (unlikely(nsm == NULL)) {
>  			dprintk("lockd: %s failed; no nsm handle\n",
> @@ -534,17 +534,18 @@ static struct nlm_host *next_host_state(struct hlist_head *cache,
>  
>  /**
>   * nlm_host_rebooted - Release all resources held by rebooted host
> + * @net:  network namespace
>   * @info: pointer to decoded results of NLM_SM_NOTIFY call
>   *
>   * We were notified that the specified host has rebooted.  Release
>   * all resources held by that peer.
>   */
> -void nlm_host_rebooted(const struct nlm_reboot *info)
> +void nlm_host_rebooted(const struct net *net, const struct nlm_reboot *info)
>  {
>  	struct nsm_handle *nsm;
>  	struct nlm_host	*host;
>  
> -	nsm = nsm_reboot_lookup(info);
> +	nsm = nsm_reboot_lookup(net, info);
>  	if (unlikely(nsm == NULL))
>  		return;
>  
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 47a32b6..6c05cd1 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -51,7 +51,6 @@ struct nsm_res {
>  };
>  
>  static const struct rpc_program	nsm_program;
> -static				LIST_HEAD(nsm_handles);
>  static				DEFINE_SPINLOCK(nsm_lock);
>  
>  /*
> @@ -264,33 +263,35 @@ void nsm_unmonitor(const struct nlm_host *host)
>  	}
>  }
>  
> -static struct nsm_handle *nsm_lookup_hostname(const char *hostname,
> -					      const size_t len)
> +static struct nsm_handle *nsm_lookup_hostname(const struct list_head *nsm_handles,
> +					const char *hostname, const size_t len)
>  {
>  	struct nsm_handle *nsm;
>  
> -	list_for_each_entry(nsm, &nsm_handles, sm_link)
> +	list_for_each_entry(nsm, nsm_handles, sm_link)
>  		if (strlen(nsm->sm_name) == len &&
>  		    memcmp(nsm->sm_name, hostname, len) == 0)
>  			return nsm;
>  	return NULL;
>  }
>  
> -static struct nsm_handle *nsm_lookup_addr(const struct sockaddr *sap)
> +static struct nsm_handle *nsm_lookup_addr(const struct list_head *nsm_handles,
> +					const struct sockaddr *sap)
>  {
>  	struct nsm_handle *nsm;
>  
> -	list_for_each_entry(nsm, &nsm_handles, sm_link)
> +	list_for_each_entry(nsm, nsm_handles, sm_link)
>  		if (rpc_cmp_addr(nsm_addr(nsm), sap))
>  			return nsm;
>  	return NULL;
>  }
>  
> -static struct nsm_handle *nsm_lookup_priv(const struct nsm_private *priv)
> +static struct nsm_handle *nsm_lookup_priv(const struct list_head *nsm_handles,
> +					const struct nsm_private *priv)
>  {
>  	struct nsm_handle *nsm;
>  
> -	list_for_each_entry(nsm, &nsm_handles, sm_link)
> +	list_for_each_entry(nsm, nsm_handles, sm_link)
>  		if (memcmp(nsm->sm_priv.data, priv->data,
>  					sizeof(priv->data)) == 0)
>  			return nsm;
> @@ -353,6 +354,7 @@ static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
>  
>  /**
>   * nsm_get_handle - Find or create a cached nsm_handle
> + * @net: network namespace
>   * @sap: pointer to socket address of handle to find
>   * @salen: length of socket address
>   * @hostname: pointer to C string containing hostname to find
> @@ -365,11 +367,13 @@ static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
>   * @hostname cannot be found in the handle cache.  Returns NULL if
>   * an error occurs.
>   */
> -struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
> +struct nsm_handle *nsm_get_handle(const struct net *net,
> +				  const struct sockaddr *sap,
>  				  const size_t salen, const char *hostname,
>  				  const size_t hostname_len)
>  {
>  	struct nsm_handle *cached, *new = NULL;
> +	struct lockd_net *ln = net_generic(net, lockd_net_id);
>  
>  	if (hostname && memchr(hostname, '/', hostname_len) != NULL) {
>  		if (printk_ratelimit()) {
> @@ -384,9 +388,10 @@ retry:
>  	spin_lock(&nsm_lock);
>  
>  	if (nsm_use_hostnames && hostname != NULL)
> -		cached = nsm_lookup_hostname(hostname, hostname_len);
> +		cached = nsm_lookup_hostname(&ln->nsm_handles,
> +					hostname, hostname_len);
>  	else
> -		cached = nsm_lookup_addr(sap);
> +		cached = nsm_lookup_addr(&ln->nsm_handles, sap);
>  
>  	if (cached != NULL) {
>  		atomic_inc(&cached->sm_count);
> @@ -400,7 +405,7 @@ retry:
>  	}
>  
>  	if (new != NULL) {
> -		list_add(&new->sm_link, &nsm_handles);
> +		list_add(&new->sm_link, &ln->nsm_handles);
>  		spin_unlock(&nsm_lock);
>  		dprintk("lockd: created nsm_handle for %s (%s)\n",
>  				new->sm_name, new->sm_addrbuf);
> @@ -417,19 +422,22 @@ retry:
>  
>  /**
>   * nsm_reboot_lookup - match NLMPROC_SM_NOTIFY arguments to an nsm_handle
> + * @net:  network namespace
>   * @info: pointer to NLMPROC_SM_NOTIFY arguments
>   *
>   * Returns a matching nsm_handle if found in the nsm cache. The returned
>   * nsm_handle's reference count is bumped. Otherwise returns NULL if some
>   * error occurred.
>   */
> -struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info)
> +struct nsm_handle *nsm_reboot_lookup(const struct net *net,
> +				const struct nlm_reboot *info)
>  {
>  	struct nsm_handle *cached;
> +	struct lockd_net *ln = net_generic(net, lockd_net_id);
>  
>  	spin_lock(&nsm_lock);
>  
> -	cached = nsm_lookup_priv(&info->priv);
> +	cached = nsm_lookup_priv(&ln->nsm_handles, &info->priv);
>  	if (unlikely(cached == NULL)) {
>  		spin_unlock(&nsm_lock);
>  		dprintk("lockd: never saw rebooted peer '%.*s' before\n",
> diff --git a/fs/lockd/netns.h b/fs/lockd/netns.h
> index 097bfa3..89fe011 100644
> --- a/fs/lockd/netns.h
> +++ b/fs/lockd/netns.h
> @@ -15,6 +15,7 @@ struct lockd_net {
>  	spinlock_t nsm_clnt_lock;
>  	unsigned int nsm_users;
>  	struct rpc_clnt *nsm_clnt;
> +	struct list_head nsm_handles;
>  };
>  
>  extern int lockd_net_id;
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index d678bcc..0dff13f 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -593,6 +593,7 @@ static int lockd_init_net(struct net *net)
>  	INIT_LIST_HEAD(&ln->lockd_manager.list);
>  	ln->lockd_manager.block_opens = false;
>  	spin_lock_init(&ln->nsm_clnt_lock);
> +	INIT_LIST_HEAD(&ln->nsm_handles);
>  	return 0;
>  }
>  
> diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
> index b147d1a..09c576f 100644
> --- a/fs/lockd/svc4proc.c
> +++ b/fs/lockd/svc4proc.c
> @@ -421,7 +421,7 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
>  		return rpc_system_err;
>  	}
>  
> -	nlm_host_rebooted(argp);
> +	nlm_host_rebooted(SVC_NET(rqstp), argp);
>  	return rpc_success;
>  }
>  
> diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
> index 21171f0..fb26b9f 100644
> --- a/fs/lockd/svcproc.c
> +++ b/fs/lockd/svcproc.c
> @@ -464,7 +464,7 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
>  		return rpc_system_err;
>  	}
>  
> -	nlm_host_rebooted(argp);
> +	nlm_host_rebooted(SVC_NET(rqstp), argp);
>  	return rpc_success;
>  }
>  
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index ff82a32..fd3b65b 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -235,7 +235,8 @@ void		  nlm_rebind_host(struct nlm_host *);
>  struct nlm_host * nlm_get_host(struct nlm_host *);
>  void		  nlm_shutdown_hosts(void);
>  void		  nlm_shutdown_hosts_net(struct net *net);
> -void		  nlm_host_rebooted(const struct nlm_reboot *);
> +void		  nlm_host_rebooted(const struct net *net,
> +					const struct nlm_reboot *);
>  
>  /*
>   * Host monitoring
> @@ -243,11 +244,13 @@ void		  nlm_host_rebooted(const struct nlm_reboot *);
>  int		  nsm_monitor(const struct nlm_host *host);
>  void		  nsm_unmonitor(const struct nlm_host *host);
>  
> -struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
> +struct nsm_handle *nsm_get_handle(const struct net *net,
> +					const struct sockaddr *sap,
>  					const size_t salen,
>  					const char *hostname,
>  					const size_t hostname_len);
> -struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info);
> +struct nsm_handle *nsm_reboot_lookup(const struct net *net,
> +					const struct nlm_reboot *info);
>  void		  nsm_release(struct nsm_handle *nsm);
>  
>  /*
> -- 
> 2.4.9
