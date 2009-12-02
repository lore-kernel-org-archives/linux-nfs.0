From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NLM: add network test when host expire but hold lock at
 nlm_gc_hosts
Date: Wed, 2 Dec 2009 07:26:44 -0500
Message-ID: <20091202072644.31c5d17e@tlielax.poochiereds.net>
References: <4B163798.7010309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957AbZLBM0y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2009 07:26:54 -0500
In-Reply-To: <4B163798.7010309@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 02 Dec 2009 17:47:04 +0800
Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:

> After a client get lock, it's network partition for some reasons.
> other client cannot get lock success forever.
> 
> This patch can avoid this problem using rpc_ping to test client's
> network when host expired but hold lock.
> 
> If the client's network is partition, server will release client's 
> lock, other client will get lock success.
> 
> Signed-off-by: mijinlong@cn.fujitsu.com

Yikes! That sounds like it'll make locking subject to the reliability
of the network. I don't think that's a good idea.

What might be more reasonable is to consider implementing something
like the clear_locks command in Solaris. That is, a way for an admin to
remove server-side locks held by a client that he knows is never going
to come back. With that, this sort of thing at least becomes a willful
act...

> ---
>  fs/lockd/host.c             |   54 ++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/sunrpc/clnt.h |    1 +
>  net/sunrpc/clnt.c           |    4 +-
>  3 files changed, 56 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index 4600c20..73f6732 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -31,6 +31,7 @@ static int			nrhosts;
>  static DEFINE_MUTEX(nlm_host_mutex);
>  
>  static void			nlm_gc_hosts(void);
> +static int			nlm_test_host(struct nlm_host *);
>  
>  struct nlm_lookup_host_info {
>  	const int		server;		/* search for server|client */
> @@ -550,13 +551,24 @@ nlm_gc_hosts(void)
>  
>  	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
>  		hlist_for_each_entry_safe(host, pos, next, chain, h_hash) {
> -			if (atomic_read(&host->h_count) || host->h_inuse
> +			if (atomic_read(&host->h_count) 
>  			 || time_before(jiffies, host->h_expires)) {
>  				dprintk("nlm_gc_hosts skipping %s (cnt %d use %d exp %ld)\n",
>  					host->h_name, atomic_read(&host->h_count),
>  					host->h_inuse, host->h_expires);
>  				continue;
>  			}
> +
> +			if (host->h_inuse) {
> +				if (!nlm_test_host(host)) {
> +					dprintk("nlm_gc_hosts skipping %s (cnt %d use %d exp %ld)\n",
> +						host->h_name, atomic_read(&host->h_count),
> +						host->h_inuse, host->h_expires);
> +					continue;
> +				}
> +				nlmsvc_free_host_resources(host);
> +			}
> +
>  			dprintk("lockd: delete host %s\n", host->h_name);
>  			hlist_del_init(&host->h_hash);
>  
> @@ -567,3 +579,43 @@ nlm_gc_hosts(void)
>  
>  	next_gc = jiffies + NLM_HOST_COLLECT;
>  }
> +
> +static int
> +nlm_test_host(struct nlm_host *host)
> +{
> +	struct rpc_clnt *clnt;
> +
> +	dprintk("lockd: test host %s\n", host->h_name);
> +	clnt = host->h_rpcclnt;
> +	if (clnt == NULL) {
> +		unsigned long increment = HZ;
> +		struct rpc_timeout timeparms = {
> +			.to_initval	= increment,
> +			.to_increment	= increment,
> +			.to_maxval	= increment * 3UL,
> +			.to_retries	= 2U,
> +		};
> +
> +		struct rpc_create_args args = {
> +			.protocol	= host->h_proto,
> +			.address	= nlm_addr(host),
> +			.addrsize	= host->h_addrlen,
> +			.saddress	= nlm_srcaddr(host),
> +			.timeout	= &timeparms,
> +			.servername	= host->h_name,
> +			.program	= &nlm_program,
> +			.version	= host->h_version,
> +			.authflavor	= RPC_AUTH_UNIX,
> +			.flags		= RPC_CLNT_CREATE_AUTOBIND,
> +		};
> +
> +		clnt = rpc_create(&args);
> +		if (IS_ERR(clnt)) 
> +			return -EIO;
> +
> +		rpc_shutdown_client(clnt);
> +		return 0;
> +	}
> +
> +	return rpc_ping(clnt, RPC_TASK_SOFT);
> +}

Hmm...this runs in lockd's context too, right? While it's waiting for a
ping to come back, the server can't service any lock requests. That
could really slow down lockd in the event of a network partition. In
general, it's best to avoid blocking operations in lockd's context if
at all possible.

> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 8ed9642..b221f8f 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -162,6 +162,7 @@ size_t		rpc_pton(const char *, const size_t,
>  char *		rpc_sockaddr2uaddr(const struct sockaddr *);
>  size_t		rpc_uaddr2sockaddr(const char *, const size_t,
>  				   struct sockaddr *, const size_t);
> +int 		rpc_ping(struct rpc_clnt *clnt, int flags);
>  
>  static inline unsigned short rpc_get_port(const struct sockaddr *sap)
>  {
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 38829e2..53b9f34 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -79,7 +79,6 @@ static void	call_connect_status(struct rpc_task *task);
>  
>  static __be32	*rpc_encode_header(struct rpc_task *task);
>  static __be32	*rpc_verify_header(struct rpc_task *task);
> -static int	rpc_ping(struct rpc_clnt *clnt, int flags);
>  
>  static void rpc_register_client(struct rpc_clnt *clnt)
>  {
> @@ -1675,7 +1674,7 @@ static struct rpc_procinfo rpcproc_null = {
>  	.p_decode = rpcproc_decode_null,
>  };
>  
> -static int rpc_ping(struct rpc_clnt *clnt, int flags)
> +int rpc_ping(struct rpc_clnt *clnt, int flags)
>  {
>  	struct rpc_message msg = {
>  		.rpc_proc = &rpcproc_null,
> @@ -1686,6 +1685,7 @@ static int rpc_ping(struct rpc_clnt *clnt, int flags)
>  	put_rpccred(msg.rpc_cred);
>  	return err;
>  }
> +EXPORT_SYMBOL_GPL(rpc_ping);
>  
>  struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int flags)
>  {


-- 
Jeff Layton <jlayton@redhat.com>
