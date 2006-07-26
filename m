From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 010 of 11] knfsd: make pools numa aware (ifdefless)
Date: Wed, 26 Jul 2006 14:05:54 +0100
Message-ID: <20060726130553.GA25636@infradead.org>
References: <1153913457.21040.854.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5j5M-0007tO-C7
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 06:06:00 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5j5L-0007PJ-Ot
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 06:06:00 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <1153913457.21040.854.camel@hole.melbourne.sgi.com>
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

> +struct svc_pool_map svc_pool_map = { .mode = -1, .init = 0 };

No need to set .init to zero, that's done implicitly by C language semantics.
Also the initializatio nwould look more readable if it was split over multiple
lines (especially if it grows more fields later on):

struct svc_pool_map svc_pool_map = {
	.mode		= -1,
};

Any chance you could avoid having the global struct non-static and only
access it by well defined procedural interfaces?

> +static unsigned int
> +svc_pool_map_init(void)

This function really needs to be split into a few subroutines.  In addition
the modes should have symbolic names.

enum {
	SVC_MODE_NONE		= -1,
	SVC_MODE_GLOBAL		= 0,
	SVC_MODE_PERCPU		= 1,
	SVC_MODE_PERNODE	= 2,
};

/*
 * Detect best pool mapping mode heuristically.
 */
static int
svc_pool_choose_mode(void)
{
	/*
	 * If we actually have multiple NUMA nodes, split pools
	 * on NUMA node boundaries.
	 */
	if (num_online_nodes() > 1)
		return SVC_MODE_PERNODE;

	/*
	 * If we have an SMP machine with more than 2 CPUs, we want
	 * to divide the pools on cpu boundaries.
	 */
	if (nr_cpus_node(any_online_node(node_online_map)) > 2)
		return SVC_MODE_PERCPU;

	/*
	 * By default use one global pool.
	 */
	return SVC_MODE_GLOBAL;
}

static int
svc_pool_map_init_percpu(struct svc_pool_map *m)
{
	unsigned int maxpools = num_possible_cpus();
	unsigned int cpu, pidx = 0;

	m->to_pool = kcalloc(maxpools, sizeof(unsigned int), GFP_KERNEL);
	if (!m->to_pool)
		goto out;

	m->pool_to = kcalloc(maxpools, sizeof(unsigned int), GFP_KERNEL);
	if (!m->pool_to)
		goto out_free_to_pool;

	for_each_online_cpu(cpu) {
		BUG_ON(pidx > maxpools);
		m->to_pool[cpu] = pidx;
		m->pool_to[pidx] = cpu;
		pidx++;
	}

	/*
	 * CPUs brought online later all get mapped to pool0, sorry.
	 */
	m->npools = pidx;
	return 0;

 out_free_to_pool:
	kfree(m->to_pool);
 out:
	return -ENOMEM;
}

static int
svc_pool_map_init_pernode(struct svc_pool_map *m)
{
	unsigned int maxpools = num_possible_nodes();

	m->to_pool = kcalloc(maxpools, sizeof(unsigned int), GFP_KERNEL);
	if (!m->to_pool)
		goto out;

	m->pool_to = kcalloc(maxpools, sizeof(unsigned int), GFP_KERNEL);
	if (!m->pool_to)
		goto out_free_to_pool;

	for_each_node_with_cpus(node) {
		/* some architectures (e.g. SN2) have cpuless nodes */
		BUG_ON(pidx > maxpools);
		m->to_pool[node] = pidx;
		m->pool_to[pidx] = node;
		pidx++;
	}

	/*
	 * Nodes brought online later all get mapped to pool0, sorry.
	 */
	m->npools = pidx;
	return 0;

 out_free_to_pool:
	kfree(m->to_pool);
 out:
	return -ENOMEM;
}

static unsigned int
svc_pool_map_init(void)
{
	struct svc_pool_map *m = &svc_pool_map;
	int error;

	if (m->init)
		return m->npools;
	m->init = 1;
	m->npools = 1;

	if (m->mode == SVC_MODE_NONE)
		m->mode = svc_pool_choose_mode();

	switch (m->mode) {
	case SVC_MODE_PERCPU:
		error = svc_pool_map_init_percpu(m);
		if (error)
			m->node = SVC_MODE_GLOBAL;
		break;
	case SVC_MODE_PERNODE:
		error = svc_pool_map_init_pernode(m);
		if (error)
			m->node = SVC_MODE_GLOBAL;
		break;
	}

	return m->npools;
}

> +	switch (m->mode)
> +	{
> +	default:
> +	case 0:

	switch (m->mode) {

should also use the enum values.

> +static inline struct svc_pool *svc_pool_for_cpu(struct svc_serv *serv, int cpu)
> +{
> +	struct svc_pool_map *m = &svc_pool_map;
> +	unsigned int pidx;
> +
> +	switch (m->mode) {
> +	default:
> +	case 0:
> +		pidx = 0;
> +		break;
> +	case 1:
> +		pidx = m->to_pool[cpu];
> +		break;
> +	case 2:
> +		pidx = m->to_pool[cpu_to_node(cpu)];
> +		break;
> +	}
> +	return &serv->sv_pools[pidx % serv->sv_nrpools];
> +}

I think this is too large to be inlined.  Moving it out of line would
also make &svc_pool_map static scope, aswell as the struct definition for
it.  I think this would be a useful encapsulation even independent of
whether the de-inling is worth it from the performance/codesize improvement
perspective.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
