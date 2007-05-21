From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Mon, 21 May 2007 11:02:05 -0500
Message-ID: <1179763325.23385.244.camel@trinity.ogc.int>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<1179515255.6488.136.camel@heimdal.trondhjem.org>
	<1179518863.23385.195.camel@trinity.ogc.int>
	<18001.18232.387141.533217@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqAKn-0007Xn-G1
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 09:02:09 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqAKq-00044M-20
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 09:02:12 -0700
In-Reply-To: <18001.18232.387141.533217@notabene.brown>
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

On Mon, 2007-05-21 at 17:16 +1000, Neil Brown wrote:
> On Friday May 18, tom@opengridcomputing.com wrote:
> > On Fri, 2007-05-18 at 15:07 -0400, Trond Myklebust wrote:
> > 
> > > > +	while (xprt->sc_ctxt_cnt < target) {
> > > > +		xprt->sc_ctxt_cnt ++;
> > > > +		spin_unlock_irqrestore(&xprt->sc_ctxt_lock, flags);
> > > > +
> > > > +		ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
> > > > +
> > > > +		spin_lock_irqsave(&xprt->sc_ctxt_lock, flags);
> > > 
> > > You've now dropped the spinlock. How can you know that the condition
> > > xprt->sc_ctxt_cnt <= target is still valid?
> > > 
> > 
> > I increment the sc_ctxt_cnt with the lock held. If I'm at the limit, the
> > competing thread will find it equal -- correct? 
> > 
> 
> I'm having trouble figuring out who the competing thread is.
> As far as I can see (Well... "have seen"), this is always called from
> the context of an nfsd thread which has sole access to the xprt.  So
> there is no race.
> ??

The callback handler for SQ CQ (send queue completion queue) is called
on interrupt context. This function returns contexts to this queue when
cleaning up completed SQ WR (send queue work requests). See sq_cq_reap
in svc_rdma_transport.c, line #329.  

> 
> NeilBrown


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
