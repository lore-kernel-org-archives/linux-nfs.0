From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Thu, 24 May 2007 00:09:01 +1000
Message-ID: <20070523140901.GG14076@sgi.com>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<20070518192443.GD4843@fieldses.org>
	<1179516988.23385.171.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqrWg-0002WC-61
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:09:18 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX18YQNo25DCfE0olWxafMjYOglgAU3AIrnQ=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqrWi-0005F5-R3
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:09:21 -0700
In-Reply-To: <1179516988.23385.171.camel@trinity.ogc.int>
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

On Fri, May 18, 2007 at 02:36:28PM -0500, Tom Tucker wrote:
> On Fri, 2007-05-18 at 15:24 -0400, J. Bruce Fields wrote:
> > On Fri, May 18, 2007 at 12:45:52PM -0500, Tom Tucker wrote:
> > 
> > > +/*
> > > + * Setup the reply buffer for the svc_process function to write the
> > > + * RPC into.
> > > + */
> > > +static int svc_rdma_prep_reply_buf(struct svc_rqst *rqstp)
> > > +{
> > > +	struct kvec *resv = &rqstp->rq_res.head[0];
> > > +
> > > +	/* setup response xdr_buf.
> > > +	 * Initially it has just one page
> > > +	 */
> > > +	rqstp->rq_resused = 1;
> > > +	resv->iov_base = page_address(rqstp->rq_respages[0]);
> > > +	resv->iov_len = 0;
> > > +	rqstp->rq_res.pages = rqstp->rq_respages+1;
> > > +	rqstp->rq_res.len = 0;
> > > +	rqstp->rq_res.page_base = 0;
> > > +	rqstp->rq_res.page_len = 0;
> > > +	rqstp->rq_res.buflen = PAGE_SIZE;
> > > +	rqstp->rq_res.tail[0].iov_base = NULL;
> > > +	rqstp->rq_res.tail[0].iov_len = 0;
> > > +
> > > +	return 0;
> > > +}
> > 
> > I think this is a repeat of a question from yesterday--I'm not sure why
> > we bothered to pull this out into  separate function when the
> > implementations all end up being identical, except for the one line for
> > the record length in the tcp case?
> > 
> 
> Yeah, you're right. Maybe it shouldn't be prepare_buffer, but rather
> "prepare_header". Then you'd keep the buffer code common and just have
> the one line function for the TCP record len.

Ok, I'll change my patch to push all those initialisation lines back
into svc_process() where they came from, make svc_tcp_prepare_reply()
do just the 1 line it needs to, and have no method for UDP.

Tom, just curious but in the November there was actually a difference
between the sockets and RDMA versions, the latter didn't have this
line:

        rqstp->rq_res.buflen = PAGE_SIZE;

> > > +static struct cache_deferred_req *
> > > +svc_rdma_defer(struct cache_req *req)
> > > +{
> > > +	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
> > > +	struct svcxprt_rdma *xprt;
> > > +	struct svc_rdma_deferred_req *dr;
> > > +
> > > +	dprintk("svcrdma: deferring request on \n"
> > > +		"  rqstp=%p\n"
> > > +		"  rqstp->rq_arg.len=%d\n", 
> > > +		rqstp, 
> > > +		rqstp->rq_arg.len);
> > > +
> > > +	/* if more than a page, give up FIXME */
> > > +	if (rqstp->rq_arg.page_len)
> > > +		return NULL;
> > > +	BUG_ON(rqstp->rq_deferred);
> > > +	xprt = (struct svcxprt_rdma*)rqstp->rq_sock;
> > > + retry:
> > > +	dr = kmalloc(sizeof(struct svc_rdma_deferred_req), GFP_KERNEL);
> > > +	if (!dr) {
> > > +		printk(KERN_INFO "svcrdma: sleeping waiting for memory\n");
> > > +		schedule_timeout_uninterruptible(msecs_to_jiffies(1000));
> > > +		goto retry;
> > > +	}
> > 
> > Why not return NULL, as svc_defer() does?
> > 
> 
> I think you're right. I'll fix this.

Why have svc_rdma_defer() at all?  The generic code should be able
to do call deferral and revisiting.  After all, it just needs to
shuffle bits aside from the xdr_buf and put them back later; it's not
a performance path; and the logic is convoluted and a pain to test.
To illustrate how difficult this logic is, note that svc_rdma_revisit()
leaks a page when called with too_many=1.

Like handling SK_CLOSE, it's logic that should be in the generic
code rather than replicated in three svc_foo_recvfrom() routines.

Looking at the code, it seems to me that the reason for doing your
own defer/revisit logic is to preserve the RDMA chunking header
which lives before the RPC call header.  This header is skipped
by svc_rdma_xdr_decode_req(), but a pointer to it is magically
reconstructed by svc_rdma_sendto() so it can traverse the write chunks
or reply chunks therein.  Am I correct?

So the thing that RDMA is doing differently from the other transports
is that it needs to go back and look at its transport-specific
on-the-wire header again after having earlier skipped over it, and that
this header needs to be preserved across a defer & revisit.  Right?

So perhaps a better approach would be to slightly tweak the existing
generic defer & revisit logic to allow a transport to specify how
many bytes of transport header need to be preserved.  Then the
transport-specific code needs very little code to support defer &
revisit, and doesn't duplicate multiple complex and subtle functions
which mess with svc_sock internals.

I have 4 untested patches which attempt to do this, I'll post them
in a moment.


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
