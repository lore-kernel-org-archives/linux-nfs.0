From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Fri, 18 May 2007 15:24:43 -0400
Message-ID: <20070518192443.GD4843@fieldses.org>
References: <1179510352.23385.123.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp84C-0003A7-AB
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 12:24:44 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hp84E-0000Y3-PF
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 12:24:47 -0700
In-Reply-To: <1179510352.23385.123.camel@trinity.ogc.int>
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

On Fri, May 18, 2007 at 12:45:52PM -0500, Tom Tucker wrote:
> +	printk("svcrdma: new connection %p accepted with the following "
> +		"attributes:\n"
> +		"\tlocal_ip        : %d.%d.%d.%d\n"
> +		"\tlocal_port	   : %d\n"
> +		"\tremote_ip       : %d.%d.%d.%d\n"
> +		"\tremote_port     : %d\n"
> +		"\tmax_sge         : %d\n"
> +		"\tsq_depth        : %d\n"
> +		"\tmax_requests    : %d\n"
> +		"\tread throttle   : %s\n"
> +		"\tord             : %d\n",
> +		newxprt,
> +		NIPQUAD(((struct sockaddr_in*)&newxprt->sc_cm_id->
> +			 route.addr.src_addr)->sin_addr.s_addr),
> +		ntohs(((struct sockaddr_in*)&newxprt->sc_cm_id->
> +		       route.addr.src_addr)->sin_port),
> +		NIPQUAD(((struct sockaddr_in*)&newxprt->sc_cm_id->
> +			 route.addr.dst_addr)->sin_addr.s_addr),
> +		ntohs(((struct sockaddr_in*)&newxprt->sc_cm_id->
> +		       route.addr.dst_addr)->sin_port),
> +		newxprt->sc_max_sge,
> +		newxprt->sc_sq_depth,
> +		newxprt->sc_max_requests,
> +		(svcrdma_read_throttle?"TRUE":"FALSE"),
> +		newxprt->sc_ord);

I assume these massive printk's are meant to be dprintk's (if they're
meant to be left in at all).

> +/*
> + * Setup the reply buffer for the svc_process function to write the
> + * RPC into.
> + */
> +static int svc_rdma_prep_reply_buf(struct svc_rqst *rqstp)
> +{
> +	struct kvec *resv = &rqstp->rq_res.head[0];
> +
> +	/* setup response xdr_buf.
> +	 * Initially it has just one page
> +	 */
> +	rqstp->rq_resused = 1;
> +	resv->iov_base = page_address(rqstp->rq_respages[0]);
> +	resv->iov_len = 0;
> +	rqstp->rq_res.pages = rqstp->rq_respages+1;
> +	rqstp->rq_res.len = 0;
> +	rqstp->rq_res.page_base = 0;
> +	rqstp->rq_res.page_len = 0;
> +	rqstp->rq_res.buflen = PAGE_SIZE;
> +	rqstp->rq_res.tail[0].iov_base = NULL;
> +	rqstp->rq_res.tail[0].iov_len = 0;
> +
> +	return 0;
> +}

I think this is a repeat of a question from yesterday--I'm not sure why
we bothered to pull this out into  separate function when the
implementations all end up being identical, except for the one line for
the record length in the tcp case?

> +
> +/*
> + * This request cannot be handled right now. Allocate a structure to
> + * keep it's state pending completion processing. To accomplish this, the
> + * function creates an svc_rdma_op_ctxt that looks like a receive completion and
> + * enqueues it on the svc_sock's deferred request list.  When*
> + * svc_rdma_recvfrom is subsequently called, it first checks if there is a
> + * deferred RPC and if there is:
> + * - Takes the deferred request off the deferred request queue
> + * - Extracts the svc_rdma_op_ctxt from the deferred request structure
> + * - Frees the deferred request structure
> + * - Skips the ib_cq_poll call and processes the svc_rdma_op_ctxt as if it had
> + *   just come out of an WR pulled from the CQ.
> + */
> +static struct cache_deferred_req *
> +svc_rdma_defer(struct cache_req *req)
> +{
> +	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
> +	struct svcxprt_rdma *xprt;
> +	struct svc_rdma_deferred_req *dr;
> +
> +	dprintk("svcrdma: deferring request on \n"
> +		"  rqstp=%p\n"
> +		"  rqstp->rq_arg.len=%d\n", 
> +		rqstp, 
> +		rqstp->rq_arg.len);
> +
> +	/* if more than a page, give up FIXME */
> +	if (rqstp->rq_arg.page_len)
> +		return NULL;
> +	BUG_ON(rqstp->rq_deferred);
> +	xprt = (struct svcxprt_rdma*)rqstp->rq_sock;
> + retry:
> +	dr = kmalloc(sizeof(struct svc_rdma_deferred_req), GFP_KERNEL);
> +	if (!dr) {
> +		printk(KERN_INFO "svcrdma: sleeping waiting for memory\n");
> +		schedule_timeout_uninterruptible(msecs_to_jiffies(1000));
> +		goto retry;
> +	}

Why not return NULL, as svc_defer() does?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
