From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and remove
	signaling for shutdown
Date: Fri, 30 May 2008 16:59:13 -0400
Message-ID: <20080530165913.7025954a@tleilax.poochiereds.net>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>
	<18481.6416.571430.593722@notabene.brown>
	<4831F860.6050801@melbourne.sgi.com>
	<4833364A.4010803@melbourne.sgi.com>
	<20080520214823.576ad7a7@tleilax.poochiereds.net>
	<48339730.3060206@melbourne.sgi.com>
	<20080530122517.4f18c48e@tleilax.poochiereds.net>
	<20080530184653.GB18154@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Greg Banks <gnb@melbourne.sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080530184653.GB18154@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 30 May 2008 14:46:53 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, May 30, 2008 at 12:25:17PM -0400, Jeff Layton wrote:
> > On Tue, 20 May 2008 20:29:52 -0700
> > Greg Banks <gnb@melbourne.sgi.com> wrote:
> > 
> > > Jeff Layton wrote:
> > > >   
> > > > [...] Rather than delaying the allocation like this,
> > > > I wonder if we can just figure out the node from the cpumask and then
> > > > do a kmalloc_node()?
> > > >
> > > >   
> > > Sure.
> > > 
> > 
> > I started to do this patch as part of the kthread conversion, but it's
> > actually pretty independent. We can probably treat it separately.
> > This hasn't been tested on an actual NUMA machine yet, but any thoughts
> > on the following patch?
> > 
> > -----------------[snip]-------------------
> > 
> > >From 46432a021fe1931f4a44587124ac9442e83c4731 Mon Sep 17 00:00:00 2001
> > From: Jeff Layton <jlayton@redhat.com>
> > Date: Fri, 30 May 2008 11:57:18 -0400
> > Subject: [PATCH] sunrpc: have pooled services make NUMA-friendly allocations
> > 
> > Currently, svc_prepare_thread allocates memory using plain kmalloc()
> > and alloc_page() calls, even for threads that are destined to run on
> > different CPUs or NUMA nodes than the current one. Add a function to
> > translate a poolid into a NUMA node, and have svc_prepare_thread and
> > svc_init_buffer allocate memory on those nodes instead.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  net/sunrpc/svc.c |   46 ++++++++++++++++++++++++++++++++++++++++------
> >  1 files changed, 40 insertions(+), 6 deletions(-)
> > 
> > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> > index 01c7e31..3985fbc 100644
> > --- a/net/sunrpc/svc.c
> > +++ b/net/sunrpc/svc.c
> > @@ -332,6 +332,32 @@ svc_pool_map_set_cpumask(unsigned int pidx, cpumask_t *oldmask)
> >  }
> >  
> >  /*
> > + * for a given poolid, return the NUMA memory node. This allows us to
> > + * allocate memory close to the CPU's where the task will be running
> > + */
> > +static inline unsigned int
> > +svc_pool_to_node(unsigned int pidx)
> > +{
> > +	struct svc_pool_map *m = &svc_pool_map;
> > +	unsigned int poolnode = m->pool_to[pidx];
> > +
> > +	/*
> > +	 * The caller checks for sv_nrpools > 1, which
> > +	 * implies that we've been initialized.
> > +	 */
> > +	BUG_ON(m->count == 0);
> > +
> > +	switch (m->mode) {
> > +	case SVC_POOL_PERNODE:
> > +		return poolnode;
> > +	case SVC_POOL_PERCPU:
> > +		return cpu_to_node(poolnode);
> > +	}
> > +
> > +	return numa_node_id();
> > +}
> > +
> > +/*
> >   * Use the mapping mode to choose a pool for a given CPU.
> >   * Used when enqueueing an incoming RPC.  Always returns
> >   * a non-NULL pool pointer.
> > @@ -507,7 +533,7 @@ EXPORT_SYMBOL(svc_destroy);
> >   * We allocate pages and place them in rq_argpages.
> >   */
> >  static int
> > -svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
> > +svc_init_buffer(struct svc_rqst *rqstp, unsigned int size, unsigned int node)
> >  {
> >  	unsigned int pages, arghi;
> >  
> > @@ -517,7 +543,7 @@ svc_init_buffer(struct svc_rqst *rqstp, unsigned int size)
> >  	arghi = 0;
> >  	BUG_ON(pages > RPCSVC_MAXPAGES);
> >  	while (pages) {
> > -		struct page *p = alloc_page(GFP_KERNEL);
> > +		struct page *p = alloc_pages_node(node, GFP_KERNEL, 0);
> >  		if (!p)
> >  			break;
> >  		rqstp->rq_pages[arghi++] = p;
> > @@ -543,8 +569,14 @@ struct svc_rqst *
> >  svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool)
> >  {
> >  	struct svc_rqst	*rqstp;
> > +	unsigned int	node;
> > +
> > +	if (serv->sv_nrpools > 1)
> > +		node = svc_pool_to_node(pool->sp_id);
> > +	else
> > +		node = numa_node_id();
> >  
> > -	rqstp = kzalloc(sizeof(*rqstp), GFP_KERNEL);
> > +	rqstp = kmalloc_node(sizeof(*rqstp), GFP_KERNEL | __GFP_ZERO, node);
> >  	if (!rqstp)
> >  		goto out_enomem;
> >  
> > @@ -558,15 +590,17 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool)
> >  	rqstp->rq_server = serv;
> >  	rqstp->rq_pool = pool;
> >  
> > -	rqstp->rq_argp = kmalloc(serv->sv_xdrsize, GFP_KERNEL);
> > +	rqstp->rq_argp = kmalloc_node(serv->sv_xdrsize,
> > +					GFP_KERNEL | __GFP_ZERO, node);
> >  	if (!rqstp->rq_argp)
> >  		goto out_thread;
> >  
> > -	rqstp->rq_resp = kmalloc(serv->sv_xdrsize, GFP_KERNEL);
> > +	rqstp->rq_resp = kmalloc_node(serv->sv_xdrsize,
> > +					GFP_KERNEL | __GFP_ZERO, node);
> 
> Why the __GFP_ZERO's on these last two?
> 
> --b.
> 

Uhhh...because I worked on this just before going to bed? Good catch.
I think those flags can be removed...

> >  	if (!rqstp->rq_resp)
> >  		goto out_thread;
> >  
> > -	if (!svc_init_buffer(rqstp, serv->sv_max_mesg))
> > +	if (!svc_init_buffer(rqstp, serv->sv_max_mesg, node))
> >  		goto out_thread;
> >  
> >  	return rqstp;
> > -- 
> > 1.5.3.6
> > 
> > _______________________________________________
> > NFSv4 mailing list
> > NFSv4@linux-nfs.org
> > http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4


-- 
Jeff Layton <jlayton@redhat.com>
