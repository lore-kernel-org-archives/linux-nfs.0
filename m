From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Tue, 22 May 2007 15:36:29 +1000
Message-ID: <18002.33117.816973.42500@notabene.brown>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<1179515255.6488.136.camel@heimdal.trondhjem.org>
	<1179518863.23385.195.camel@trinity.ogc.int>
	<18001.18232.387141.533217@notabene.brown>
	<1179763325.23385.244.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqN3E-0002sK-Vz
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 22:36:55 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqN3H-0007eq-Dm
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 22:36:56 -0700
In-Reply-To: message from Tom Tucker on Monday May 21
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

On Monday May 21, tom@opengridcomputing.com wrote:
> On Mon, 2007-05-21 at 17:16 +1000, Neil Brown wrote:
> > On Friday May 18, tom@opengridcomputing.com wrote:
> > > On Fri, 2007-05-18 at 15:07 -0400, Trond Myklebust wrote:
> > > 
> > > > > +	while (xprt->sc_ctxt_cnt < target) {
> > > > > +		xprt->sc_ctxt_cnt ++;
> > > > > +		spin_unlock_irqrestore(&xprt->sc_ctxt_lock, flags);
> > > > > +
> > > > > +		ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
> > > > > +
> > > > > +		spin_lock_irqsave(&xprt->sc_ctxt_lock, flags);
> > > > 
> > > > You've now dropped the spinlock. How can you know that the condition
> > > > xprt->sc_ctxt_cnt <= target is still valid?
> > > > 
> > > 
> > > I increment the sc_ctxt_cnt with the lock held. If I'm at the limit, the
> > > competing thread will find it equal -- correct? 
> > > 
> > 
> > I'm having trouble figuring out who the competing thread is.
> > As far as I can see (Well... "have seen"), this is always called from
> > the context of an nfsd thread which has sole access to the xprt.  So
> > there is no race.
> > ??
> 
> The callback handler for SQ CQ (send queue completion queue) is called
> on interrupt context. This function returns contexts to this queue when
> cleaning up completed SQ WR (send queue work requests). See sq_cq_reap
> in svc_rdma_transport.c, line #329.  

OK....
So presumably svc_rdma_put_context should be incrementing sc_ctxt_cnt
when it puts the ctxt back on the list?

In which case you still get a race where you can put more ctxt's on
the list than you really want.  But that is hardly a big problem.

So the current locking around the "<, ++" seems a bit misleading.
Should sc_ctxt_cnt be made and atomic_t, and then bump_context_cache
can be:

  while (atomic_read(sc_ctxt_cnt) < target) {
	ctxt = kmalloc();
	if (ctxt) {
		spin_lock_irqsave()
		if (atomic_read() < target) {
			// add to list; ctxt = NULL;
			atomic_inc(sc_ctxt_cnt)
		}
		spin_unlock_irqrestore()
		free(ctxt);
	}
  }

??
That makes it clearer (to me) what is being locked.

I also think svc_rdma_get_context could be simplified a bit too.

  while (1) {
       lock;
       ctxt = head-of-list;
       unlock;
       if (ctxt)
		break;
       if (!bump_cache)
		msleep(500)
  }
  initialise ctxt


But I'm still not sold on the idea of allocating these contexts on
demand.  Can you provide a bit more data about that?
e.g. maximum number of contexts that might be required for one
request, vs typical number of contexts.  And how big is a context
anyway?

Also, what is the lifetime of these contexts?  Presumably they are
allocated to handle a single request, and then get passing into the
transport until the reply is fully sent?  That makes them a lot like
the rq_pages allocated as needed at the start of svc_recv.  Could the
contexts be handled in much the same way?

Elsewhere nfsd goes to some effort to pre-allocate any needed memory.
It would be nice if it were consistent.


NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
