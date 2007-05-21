From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 11/15] knfsd: RDMA transport core
Date: Mon, 21 May 2007 20:02:59 +1000
Message-ID: <20070521100259.GN7482@sgi.com>
References: <1179510352.23385.123.camel@trinity.ogc.int>
	<18001.17958.145762.704892@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hq4jM-0003Yd-Fa
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 03:03:08 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Hq4jO-0006FZ-5u
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 03:03:11 -0700
In-Reply-To: <18001.17958.145762.704892@notabene.brown>
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

On Mon, May 21, 2007 at 05:11:34PM +1000, Neil Brown wrote:
> On Friday May 18, tom@opengridcomputing.com wrote:
> > 
> > This file implements the core transport data management and I/O
> > path. The I/O path for RDMA involves receiving callbacks on interrupt 
> > context. Since all the svc transport locks are _bh locks we enqueue the 
> > transport on a list, schedule a tasklet to dequeue data indications from 
> > the RDMA completion queue. The tasklet in turn takes _bh locks to 
> > enqueue receive data indications on a list for the transport. The 
> > svc_rdma_recvfrom transport function dequeues data from this list in an 
> > NFSD thread context.
> 
> Cannot we simply change the usage of ->sp_lock to always disable
> interrupts?

We could, but the question then is what impact will locking out
interrupts more often have on throughout or latency over Ethernet?

> That would make this much simpler. 

Yes it would.

> How much would it cost?

???

> Alternatively, why can the network layer deliver these notification in
> "bh" context, but the ib layer wants to deliver them in irq context?
> Does doing it in irq context have lower latency or something?

The problem is wider than it appears.  The kernel verbs interface
reports a *lot* of stuff in irq context, not just incoming data.
Many of those events would be best handled by disconnecting the
svc_sock, which implies setting SK_CLOSE and causing svc_sock_enqueue()
to be called.  The former happens; the latter doesn't.  For example,
see qp_event_handler() in net/sunrpc/svc_rdma_transport.c.  This
means that error conditions are not notified until some other event
causes svc_sock_enqueue() to be called.

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
