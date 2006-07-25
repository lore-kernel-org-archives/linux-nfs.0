From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 010 of 11] knfsd: make pools numa aware
Date: Tue, 25 Jul 2006 08:43:13 -0400
Message-ID: <1153831393.5660.13.camel@localhost>
References: <1153804618.21040.25.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5MGN-0007dn-T4
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 05:43:52 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5MGM-0006zS-DG
	for nfs@lists.sourceforge.net; Tue, 25 Jul 2006 05:43:52 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1153804618.21040.25.camel@hole.melbourne.sgi.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2006-07-25 at 15:16 +1000, Greg Banks wrote:
> knfsd: Actually implement multiple pools.  On NUMA machines, allocate
> a svc_pool per NUMA node; on SMP a svc_pool per CPU; otherwise a single
> global pool.  Enqueue sockets on the svc_pool corresponding to the CPU
> on which the socket bh is run (i.e. the NIC interrupt CPU).  Threads
> have their cpu mask set to limit them to the CPUs in the svc_pool that
> owns them.
> 
> This is the patch that allows an Altix to scale NFS traffic linearly
> beyond 4 CPUs and 4 NICs.
> 
> Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
> ---
> 
>  include/linux/sunrpc/svc.h |   62 +++++++++++
>  net/sunrpc/svc.c           |  184 +++++++++++++++++++++++++++++++++-
>  net/sunrpc/svcsock.c       |    7 +
>  3 files changed, 251 insertions(+), 2 deletions(-)
> 
> Index: linus-git/net/sunrpc/svc.c
> ===================================================================
> --- linus-git.orig/net/sunrpc/svc.c	2006-07-24 22:16:36.157203063 +1000
> +++ linus-git/net/sunrpc/svc.c	2006-07-24 22:54:13.557820093 +1000
> @@ -4,6 +4,10 @@
>   * High-level RPC service routines
>   *
>   * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
> + *
> + * Multiple threads pools and NUMAisation
> + * Copyright (c) 2006 Silicon Graphics, Inc.
> + * by Greg Banks <gnb@melbourne.sgi.com>
>   */
>  
>  #include <linux/linkage.h>
> @@ -24,6 +28,161 @@
>  #define RPCDBG_FACILITY	RPCDBG_SVCDSP
>  #define RPC_PARANOIA 1
>  
> +
> +#if SVC_HAVE_MULTIPLE_POOLS
> +
> +struct svc_pool_map svc_pool_map = { .mode = -1, .init = 0 };
> +
> +/*
> + * Build the global map of cpus to pools and vice versa.
> + */
> +static unsigned int
> +svc_pool_map_init(void)
> +{
> +	struct svc_pool_map *m = &svc_pool_map;
> +	unsigned int node;
> +	unsigned int cpu;
> +	unsigned int pidx = 0;
> +	unsigned int maxpools;
> +
> +	if (m->init)
> +		return m->npools;
> +	m->init = 1;
> +
> +	if (m->mode < 0) {
> +		/*
> +		 * Detect best pool mapping mode heuristically.
> +		 */
> +		m->mode = 0;	/* default: one global pool */
> +#ifdef CONFIG_NUMA
   ^^^^^^^^^^^^^^^^^^ Growl...

Perhaps a helper function to hide the ifdef.

> +		if (num_online_nodes() > 1) {
> +			/*
> +			 * Actually have multiple NUMA nodes,
> +			 * so split pools on NUMA node boundaries
> +			 */
> +			m->mode = 2;
> +		} else {
> +			node = any_online_node(node_online_map);
> +			if (nr_cpus_node(node) > 2) {
> +				/*
> +				 * Apparently we're running with CONFIG_NUMA
> +				 * on non-NUMA hardware, e.g. with a generic
> +				 * x86_64 kernel on Xeons.  In this case we
> +				 * want to divide the pools on cpu boundaries.
> +				 */
> +				m->mode = 1;
> +			}
> +		}
> +#else
> +		if (num_online_cpus() > 1) {
> +			/*
> +			 * Plain SMP with multiple CPUs online.
> +			 */
> +			m->mode = 1;
> +		}
> +#endif
> +	}
> +
> +	switch (m->mode) {
> +	case 0:
> +fallback:
> +		m->mode = 0;
> +		m->npools = 1;
> +		printk("nfsd: initialising 1 global pool\n");
                          ^^^^ ho hum....

Please keep sunrpc and nfsd separate. Also, this should probably be a
dprintk() in order to avoid spamming the syslogs.

> +		break;
> +
> +	case 1:
> +		maxpools = num_possible_cpus();
> +		m->cpu_to_pool = kcalloc(maxpools, sizeof(unsigned int),
> +					       GFP_KERNEL);
> +		if (!m->cpu_to_pool)
> +			goto fallback;
> +		m->pool_to_cpu = kcalloc(maxpools, sizeof(unsigned int),
> +					       GFP_KERNEL);
> +		if (!m->pool_to_cpu) {
> +			kfree(m->cpu_to_pool);
> +			goto fallback;
> +		}
> +		for_each_online_cpu(cpu) {
> +			BUG_ON(pidx > maxpools);
> +			m->cpu_to_pool[cpu] = pidx;
> +			m->pool_to_cpu[pidx] = cpu;
> +			pidx++;
> +		}
> +		/* cpus brought online later all get mapped to pool0, sorry */
> +		m->npools = pidx;
> +
> +		printk("nfsd: initialising %u pools, one per cpu\n", m->npools);
                          ^^^^
> +		break;
> +
> +#ifdef CONFIG_NUMA
  ^^^^^^^^^^^^^^^^^^^ See above
> +	case 2:
> +		maxpools = num_possible_nodes();
> +		m->node_to_pool = kcalloc(maxpools, sizeof(unsigned int),
> +					       GFP_KERNEL);
> +		if (!m->node_to_pool)
> +			goto fallback;
> +		m->pool_to_node = kcalloc(maxpools, sizeof(unsigned int),
> +					       GFP_KERNEL);
> +		if (!m->pool_to_node) {
> +			kfree(m->node_to_pool);
> +			goto fallback;
> +		}
> +		for_each_node_with_cpus(node) {
> +			/* some architectures (e.g. SN2) have cpuless nodes */
> +			BUG_ON(pidx > maxpools);
> +			m->node_to_pool[node] = pidx;
> +			m->pool_to_node[pidx] = node;
> +			pidx++;
> +		}
> +		/* nodes brought online later all get mapped to pool0, sorry */
> +		m->npools = pidx;
> +
> +		printk("nfsd: initialising %u pools, one per numa node\n", m->npools);
                          ^^^^
> +		break;
> +#endif /* CONFIG_NUMA */
> +	}
> +
> +	return m->npools;
> +}
> +
> +/*
> + * Set the current thread's cpus_allowed mask so that it
> + * will only run on cpus in the given pool.
> + *
> + * Returns 1 and fills in oldmask iff a cpumask was applied.
> + */
> +static int
> +svc_pool_map_set_cpumask(unsigned int pidx, cpumask_t *oldmask)
> +{
> +	struct svc_pool_map *m = &svc_pool_map;
> +	unsigned int node;
> +	unsigned int cpu;
> +
> +	BUG_ON(!m->init);
> +
> +	switch (m->mode)
> +	{
> +	default:
> +	case 0:
> +		return 0;
> +	case 1:
> +		cpu = m->pool_to_cpu[pidx];
> +		*oldmask = current->cpus_allowed;
> +		set_cpus_allowed(current, cpumask_of_cpu(cpu));
> +		return 1;
> +#ifdef CONFIG_NUMA
    ^^^^^^^^^^^^^^^^^ See above
> +	case 2:
> +		node = m->pool_to_node[pidx];
> +		*oldmask = current->cpus_allowed;
> +		set_cpus_allowed(current, node_to_cpumask(node));
> +		return 1;
> +#endif /* CONFIG_NUMA */
> +	}
> +}
> +
> +#endif /* SVC_HAVE_MULTIPLE_POOLS */
> +
>  /*
>   * Create an RPC service
>   */
> @@ -101,8 +260,13 @@ svc_create_pooled(struct svc_program *pr
>  		  svc_thread_fn func, int sig, struct module *mod)
>  {
>  	struct svc_serv *serv;
> +	unsigned int npools = 1;
>  
> -	serv = __svc_create(prog, bufsize, /*npools*/1);
> +#if SVC_HAVE_MULTIPLE_POOLS

No...
#ifndef SVC_HAVE_MULTIPLE_POOLS
static inline svc_pool_map_init(void)
{
	return 0;
}
#else
.....
#endif

> +	npools = svc_pool_map_init();
> +#endif
> +
> +	serv = __svc_create(prog, bufsize, npools);
>  
>  	if (serv != NULL) {
>  		serv->sv_function = func;
> @@ -202,12 +366,18 @@ svc_release_buffer(struct svc_rqst *rqst
>  
>  /*
>   * Create a thread in the given pool.  Caller must hold BKL.
> + * On a NUMA or SMP machine, with a multi-pool serv, the thread
> + * will be restricted to run on the cpus belonging to the pool.
>   */
>  static int
>  __svc_create_thread(svc_thread_fn func, struct svc_serv *serv, struct svc_pool *pool)
>  {
>  	struct svc_rqst	*rqstp;
>  	int		error = -ENOMEM;
> +#if SVC_HAVE_MULTIPLE_POOLS
> +	int		have_oldmask = 0;
> +	cpumask_t	oldmask;
> +#endif
>  
>  	rqstp = kzalloc(sizeof(*rqstp), GFP_KERNEL);
>  	if (!rqstp)
> @@ -227,7 +397,19 @@ __svc_create_thread(svc_thread_fn func, 
>  	spin_unlock_bh(&pool->sp_lock);
>  	rqstp->rq_server = serv;
>  	rqstp->rq_pool = pool;
> +
> +#if SVC_HAVE_MULTIPLE_POOLS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
See above. Setting have_oldmask to zero in the case where
SVC_HAVE_MULTIPLE_POOLS should work fine, and will be optimised away by
the compiler.

> +	if (serv->sv_nrpools > 1)
> +		have_oldmask = svc_pool_map_set_cpumask(pool->sp_id, &oldmask);
> +#endif
> +
>  	error = kernel_thread((int (*)(void *)) func, rqstp, 0);
> +
> +#if SVC_HAVE_MULTIPLE_POOLS
> +	if (have_oldmask)
> +		set_cpus_allowed(current, oldmask);
> +#endif
> +
>  	if (error < 0)
>  		goto out_thread;
>  	svc_sock_update_bufs(serv);
> Index: linus-git/net/sunrpc/svcsock.c
> ===================================================================
> --- linus-git.orig/net/sunrpc/svcsock.c	2006-07-24 20:44:46.911435470 +1000
> +++ linus-git/net/sunrpc/svcsock.c	2006-07-24 22:45:23.263878219 +1000
> @@ -150,8 +150,9 @@ static void
>  svc_sock_enqueue(struct svc_sock *svsk)
>  {
>  	struct svc_serv	*serv = svsk->sk_server;
> -	struct svc_pool *pool = &serv->sv_pools[0];
> +	struct svc_pool *pool;
>  	struct svc_rqst	*rqstp;
> +	int cpu;
>  
>  	if (!(svsk->sk_flags &
>  	      ( (1<<SK_CONN)|(1<<SK_DATA)|(1<<SK_CLOSE)|(1<<SK_DEFERRED)) ))
> @@ -159,6 +160,10 @@ svc_sock_enqueue(struct svc_sock *svsk)
>  	if (test_bit(SK_DEAD, &svsk->sk_flags))
>  		return;
>  
> +	cpu = get_cpu();
> +	pool = svc_pool_for_cpu(svsk->sk_server, cpu);
> +	put_cpu();
> +
>  	spin_lock_bh(&pool->sp_lock);
>  
>  	if (!list_empty(&pool->sp_threads) &&
> Index: linus-git/include/linux/sunrpc/svc.h
> ===================================================================
> --- linus-git.orig/include/linux/sunrpc/svc.h	2006-07-24 22:16:36.041218126 +1000
> +++ linus-git/include/linux/sunrpc/svc.h	2006-07-24 22:45:23.347867112 +1000
> @@ -41,6 +41,39 @@ struct svc_pool {
>  	struct list_head	sp_all_threads;	/* all server threads */
>  } ____cacheline_aligned_in_smp;
>  
> +#if defined(CONFIG_NUMA) || defined(CONFIG_SMP)
> +#define SVC_HAVE_MULTIPLE_POOLS	1
> +#else
> +#define SVC_HAVE_MULTIPLE_POOLS	0
> +#endif
> +
> +#if SVC_HAVE_MULTIPLE_POOLS

^^^^^^^^^^^^ Any reason why you've done this? A definition shouldn't be
that worrying to us...

> +/*
> + * Global structure for mapping cpus to pools and vice versa.
> + * Setup once during sunrpc initialisation.
> + */
> +struct svc_pool_map {
> +	/*
> +	 * Mode for mapping cpus to pools.
> +	 *
> +	 * -1 = automatic, choose one of the other modes at boot
> +	 * 0 = no mapping, just a single global pool (legacy & UP mode)
> +	 * 1 = one pool per cpu
> +	 * 2 = one pool per numa node
> +	 */
> +	int mode;
> +	int init;
> +	unsigned int npools;
> +	unsigned int *pool_to_cpu;
> +	unsigned int *cpu_to_pool;
> +#ifdef CONFIG_NUMA
> +	unsigned int *node_to_pool;
> +	unsigned int *pool_to_node;
> +#endif /* CONFIG_NUMA */
> +};
> +#endif /* SVC_HAVE_MULTIPLE_POOLS */
> +
> +
>  /*
>   * RPC service.
>   *
> @@ -360,5 +393,34 @@ int		   svc_process(struct svc_serv *, s
>  int		   svc_register(struct svc_serv *, int, unsigned short);
>  void		   svc_wake_up(struct svc_serv *);
>  void		   svc_reserve(struct svc_rqst *rqstp, int space);
> +extern struct svc_pool_map svc_pool_map;
> +
> +
> +static inline struct svc_pool *svc_pool_for_cpu(struct svc_serv *serv, int cpu)
> +{
> +#if SVC_HAVE_MULTIPLE_POOLS
> +	struct svc_pool_map *m = &svc_pool_map;
> +	unsigned int pidx;
> +
> +	switch (m->mode) {
> +	default:
> +	case 0:
> +		pidx = 0;
> +		break;
> +	case 1:
> +		pidx = m->cpu_to_pool[cpu];
> +		break;
> +#ifdef CONFIG_NUMA
> +	case 2:
> +		pidx = m->node_to_pool[cpu_to_node(cpu)];
> +		break;
> +#endif /* CONFIG_NUMA */
> +	}
> +	return &serv->sv_pools[pidx % serv->sv_nrpools];
> +#else
> +	return &serv->sv_pools[0];
> +#endif
> +}
> +
>  
>  #endif /* SUNRPC_SVC_H */
> 

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
