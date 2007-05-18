From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Fri, 18 May 2007 14:36:28 -0500
Message-ID: <1179516988.23385.171.camel@trinity.ogc.int>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp8Fb-0004Lz-CN
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 12:36:32 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp8Fd-0007co-RB
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 12:36:34 -0700
In-Reply-To: <20070518192443.GD4843@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-05-18 at 15:24 -0400, J. Bruce Fields wrote:
> On Fri, May 18, 2007 at 12:45:52PM -0500, Tom Tucker wrote:
> > +	printk("svcrdma: new connection %p accepted with the following "
> > +		"attributes:\n"
> > +		"\tlocal_ip        : %d.%d.%d.%d\n"
> > +		"\tlocal_port	   : %d\n"
> > +		"\tremote_ip       : %d.%d.%d.%d\n"
> > +		"\tremote_port     : %d\n"
> > +		"\tmax_sge         : %d\n"
> > +		"\tsq_depth        : %d\n"
> > +		"\tmax_requests    : %d\n"
> > +		"\tread throttle   : %s\n"
> > +		"\tord             : %d\n",
> > +		newxprt,
> > +		NIPQUAD(((struct sockaddr_in*)&newxprt->sc_cm_id->
> > +			 route.addr.src_addr)->sin_addr.s_addr),
> > +		ntohs(((struct sockaddr_in*)&newxprt->sc_cm_id->
> > +		       route.addr.src_addr)->sin_port),
> > +		NIPQUAD(((struct sockaddr_in*)&newxprt->sc_cm_id->
> > +			 route.addr.dst_addr)->sin_addr.s_addr),
> > +		ntohs(((struct sockaddr_in*)&newxprt->sc_cm_id->
> > +		       route.addr.dst_addr)->sin_port),
> > +		newxprt->sc_max_sge,
> > +		newxprt->sc_sq_depth,
> > +		newxprt->sc_max_requests,
> > +		(svcrdma_read_throttle?"TRUE":"FALSE"),
> > +		newxprt->sc_ord);
> 
> I assume these massive printk's are meant to be dprintk's (if they're
> meant to be left in at all).

It shows up once per mount. I thought it was useful, but perhaps not...

> 
> > +/*
> > + * Setup the reply buffer for the svc_process function to write the
> > + * RPC into.
> > + */
> > +static int svc_rdma_prep_reply_buf(struct svc_rqst *rqstp)
> > +{
> > +	struct kvec *resv = &rqstp->rq_res.head[0];
> > +
> > +	/* setup response xdr_buf.
> > +	 * Initially it has just one page
> > +	 */
> > +	rqstp->rq_resused = 1;
> > +	resv->iov_base = page_address(rqstp->rq_respages[0]);
> > +	resv->iov_len = 0;
> > +	rqstp->rq_res.pages = rqstp->rq_respages+1;
> > +	rqstp->rq_res.len = 0;
> > +	rqstp->rq_res.page_base = 0;
> > +	rqstp->rq_res.page_len = 0;
> > +	rqstp->rq_res.buflen = PAGE_SIZE;
> > +	rqstp->rq_res.tail[0].iov_base = NULL;
> > +	rqstp->rq_res.tail[0].iov_len = 0;
> > +
> > +	return 0;
> > +}
> 
> I think this is a repeat of a question from yesterday--I'm not sure why
> we bothered to pull this out into  separate function when the
> implementations all end up being identical, except for the one line for
> the record length in the tcp case?
> 

Yeah, you're right. Maybe it shouldn't be prepare_buffer, but rather
"prepare_header". Then you'd keep the buffer code common and just have
the one line function for the TCP record len.


> > +
> > +/*
> > + * This request cannot be handled right now. Allocate a structure to
> > + * keep it's state pending completion processing. To accomplish this, the
> > + * function creates an svc_rdma_op_ctxt that looks like a receive completion and
> > + * enqueues it on the svc_sock's deferred request list.  When*
> > + * svc_rdma_recvfrom is subsequently called, it first checks if there is a
> > + * deferred RPC and if there is:
> > + * - Takes the deferred request off the deferred request queue
> > + * - Extracts the svc_rdma_op_ctxt from the deferred request structure
> > + * - Frees the deferred request structure
> > + * - Skips the ib_cq_poll call and processes the svc_rdma_op_ctxt as if it had
> > + *   just come out of an WR pulled from the CQ.
> > + */
> > +static struct cache_deferred_req *
> > +svc_rdma_defer(struct cache_req *req)
> > +{
> > +	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
> > +	struct svcxprt_rdma *xprt;
> > +	struct svc_rdma_deferred_req *dr;
> > +
> > +	dprintk("svcrdma: deferring request on \n"
> > +		"  rqstp=%p\n"
> > +		"  rqstp->rq_arg.len=%d\n", 
> > +		rqstp, 
> > +		rqstp->rq_arg.len);
> > +
> > +	/* if more than a page, give up FIXME */
> > +	if (rqstp->rq_arg.page_len)
> > +		return NULL;
> > +	BUG_ON(rqstp->rq_deferred);
> > +	xprt = (struct svcxprt_rdma*)rqstp->rq_sock;
> > + retry:
> > +	dr = kmalloc(sizeof(struct svc_rdma_deferred_req), GFP_KERNEL);
> > +	if (!dr) {
> > +		printk(KERN_INFO "svcrdma: sleeping waiting for memory\n");
> > +		schedule_timeout_uninterruptible(msecs_to_jiffies(1000));
> > +		goto retry;
> > +	}
> 
> Why not return NULL, as svc_defer() does?
> 

I think you're right. I'll fix this.


> --b.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
