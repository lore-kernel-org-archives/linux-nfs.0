From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Wed, 23 May 2007 09:43:30 -0500
Message-ID: <1179931410.9389.144.camel@trinity.ogc.int>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
	<1179516988.23385.171.camel@trinity.ogc.int>
	<20070523140901.GG14076@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hqs3q-00061r-0o
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:43:34 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hqs3s-0005Be-Bu
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:43:37 -0700
In-Reply-To: <20070523140901.GG14076@sgi.com>
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


> Tom, just curious but in the November there was actually a difference
> between the sockets and RDMA versions, the latter didn't have this
> line:
> 
>         rqstp->rq_res.buflen = PAGE_SIZE;

I changed the defer logic quite a bit. In fact, I don't think it worked
last November when you got the code originally. The latest code is at
linux-nfs.org/~tomtucker/linux-nfs-2.6.git

> 
> > > > +static struct cache_deferred_req *
> > > > +svc_rdma_defer(struct cache_req *req)
> > > > +{
> > > > +	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
> > > > +	struct svcxprt_rdma *xprt;
> > > > +	struct svc_rdma_deferred_req *dr;
> > > > +
> > > > +	dprintk("svcrdma: deferring request on \n"
> > > > +		"  rqstp=%p\n"
> > > > +		"  rqstp->rq_arg.len=%d\n", 
> > > > +		rqstp, 
> > > > +		rqstp->rq_arg.len);
> > > > +
> > > > +	/* if more than a page, give up FIXME */
> > > > +	if (rqstp->rq_arg.page_len)
> > > > +		return NULL;
> > > > +	BUG_ON(rqstp->rq_deferred);
> > > > +	xprt = (struct svcxprt_rdma*)rqstp->rq_sock;
> > > > + retry:
> > > > +	dr = kmalloc(sizeof(struct svc_rdma_deferred_req), GFP_KERNEL);
> > > > +	if (!dr) {
> > > > +		printk(KERN_INFO "svcrdma: sleeping waiting for memory\n");
> > > > +		schedule_timeout_uninterruptible(msecs_to_jiffies(1000));
> > > > +		goto retry;
> > > > +	}
> > > 
> > > Why not return NULL, as svc_defer() does?
> > > 
> > 
> > I think you're right. I'll fix this.
> 
> Why have svc_rdma_defer() at all?  The generic code should be able
> to do call deferral and revisiting.  After all, it just needs to
> shuffle bits aside from the xdr_buf and put them back later; it's not
> a performance path; and the logic is convoluted and a pain to test.
> To illustrate how difficult this logic is, note that svc_rdma_revisit()
> leaks a page when called with too_many=1.
> 
> Like handling SK_CLOSE, it's logic that should be in the generic
> code rather than replicated in three svc_foo_recvfrom() routines.
> 
> Looking at the code, it seems to me that the reason for doing your
> own defer/revisit logic is to preserve the RDMA chunking header
> which lives before the RPC call header.  This header is skipped
> by svc_rdma_xdr_decode_req(), but a pointer to it is magically
> reconstructed by svc_rdma_sendto() so it can traverse the write chunks
> or reply chunks therein.  Am I correct?
> 

You are absolutely correct. 

> So the thing that RDMA is doing differently from the other transports
> is that it needs to go back and look at its transport-specific
> on-the-wire header again after having earlier skipped over it, and that
> this header needs to be preserved across a defer & revisit.  Right?
> 

Yes again.

> So perhaps a better approach would be to slightly tweak the existing
> generic defer & revisit logic to allow a transport to specify how
> many bytes of transport header need to be preserved.  Then the
> transport-specific code needs very little code to support defer &
> revisit, and doesn't duplicate multiple complex and subtle functions
> which mess with svc_sock internals.

The svcsock defer logic only supports a simple RPC without a page list.
The logic even has a comment that says "FIX ME". So I assumed that in
the fullness of time, any RPC could be deferred. If this is in fact the
case, then I believe it is better to have a separate method. If it is
not the case, then the defer logic can be made generic.  

> I have 4 untested patches which attempt to do this, I'll post them
> in a moment.

> Greg.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
