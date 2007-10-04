From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 05/35] svc: Move sk_sendto and sk_recvfrom to	svc_xprt_class
Date: Thu, 4 Oct 2007 11:21:00 +1000
Message-ID: <20071004012100.GQ21388@sgi.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192740.3250.73564.stgit@dell3.ogc.int>
	<CBDFC3B7-FE67-4715-87CA-E828D76844BB@oracle.com>
	<1191342596.1565.11.camel@trinity.ogc.int>
	<4A775179-9659-41B6-999F-8316BA181152@oracle.com>
	<1191349462.1565.46.camel@trinity.ogc.int>
	<1191349842.1565.54.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdFJk-00008b-O7
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 18:15:56 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IdFJp-0007dA-Eh
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 18:16:01 -0700
In-Reply-To: <1191349842.1565.54.camel@trinity.ogc.int>
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

On Tue, Oct 02, 2007 at 01:30:42PM -0500, Tom Tucker wrote:
> On Tue, 2007-10-02 at 13:24 -0500, Tom Tucker wrote:
> > On Tue, 2007-10-02 at 12:57 -0400, Chuck Lever wrote:
> > > On Oct 2, 2007, at 12:29 PM, Tom Tucker wrote:
> > 
> > [...snip...]
> > 
> > > >>
> > > >> It looks like on the client side, I didn't put the ops vector or the
> > > >> payload maximum in the class structure at all... 6 of one, half dozen
> > > >> of the other.  Using the class's value of the ops and payload maximum
> > > >> would save some space in the svc_xprt, though, come to think of it.
> > > >>
> > > >
> > > > cache thing again. let's see how Greg weighs in.
> > > 
> > > The ops vector itself will be in some other CPU's memory most of the  
> > > time on big systems. 
> > 
> > Well this is a good point. Unless we implement thread pools for svc_xprt
> > memory allocation, it won't likely buy you much.
> > 
> 
> Actually, I'm having second thoughts. Since the svc_xprt structure is
> allocated on the rqstp thread in which the transport is going to be
> used, won't the memory be local to the allocating processor on a NUMA
> system?

On NUMA systems this more or less just works out OK as long as you
don't do anything silly like round-robin bonding or enable cpuset
memory_spread_slab.  The incoming TCP SYN segment is processed on
the CPU which handles irqs from the NIC on which the segment arrives.
This means the svc_xprt is allocated from that CPU, and lives in that
node's memory, where it's nice and local for all the NFS processing
in response to subsequent TCP segments.

Achieving this effect was one of the unspoken goals of the knfsd
NUMAisation work.  It's the reason that the permanent sockets are
not per-pool, so that threads on any CPU can respond to connection
attempts.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
