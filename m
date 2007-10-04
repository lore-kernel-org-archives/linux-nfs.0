From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 05/35] svc: Move sk_sendto and sk_recvfrom to	svc_xprt_class
Date: Thu, 4 Oct 2007 11:34:46 +1000
Message-ID: <20071004013446.GR21388@sgi.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192740.3250.73564.stgit@dell3.ogc.int>
	<CBDFC3B7-FE67-4715-87CA-E828D76844BB@oracle.com>
	<1191342596.1565.11.camel@trinity.ogc.int>
	<4A775179-9659-41B6-999F-8316BA181152@oracle.com>
	<1191349462.1565.46.camel@trinity.ogc.int>
	<1191349842.1565.54.camel@trinity.ogc.int>
	<7FF82697-AB93-4339-AD46-CAE93E967242@oracle.com>
	<1191354906.1565.65.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdFX2-0001bw-BB
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 18:29:48 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+tik7FxSaS0PP7cWaeLW4egMGiYbmNQUw=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IdFX7-0002KR-9t
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 18:29:45 -0700
In-Reply-To: <1191354906.1565.65.camel@trinity.ogc.int>
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

On Tue, Oct 02, 2007 at 02:55:06PM -0500, Tom Tucker wrote:
> On Tue, 2007-10-02 at 14:47 -0400, Chuck Lever wrote:
> > On Oct 2, 2007, at 2:30 PM, Tom Tucker wrote:
> > 
> > > On Tue, 2007-10-02 at 13:24 -0500, Tom Tucker wrote:
> > >> On Tue, 2007-10-02 at 12:57 -0400, Chuck Lever wrote:
> > >>> On Oct 2, 2007, at 12:29 PM, Tom Tucker wrote:
> > >>
> > >> [...snip...]
> 
> [...snip...]
> 
> > >
> > > Actually, I'm having second thoughts. Since the svc_xprt structure is
> > > allocated on the rqstp thread in which the transport is going to be
> > > used, won't the memory be local to the allocating processor on a NUMA
> > > system?
> > 
> > The ops vector isn't in the svc_xprt.  It's a constant, so it's in  
> > memory allocated by the kernel loader at boot time.
> > 
> 
> I think one of us missing something. Here's how I think it works...
> 
> The svc_xprt_ops structure is a constant in kernel memory. The
> svc_xprt_class is also a constant and points to the svc_xprt_ops
> structure. The svc_xprt structure, however, is allocated via kmalloc and
> contains a _copy_ of the constant svc_xprt_ops structure and a copy of
> the xcl_max_payload value. See the svc_xprt_init function.
> 
> My original thinking (flawed I think) was that since the svc_xprt was
> allocated in the context of the current rqstp thread, that it would be
> allocated from processor local memory. While I think this is true,
> subsequent assignment of a rqstp thread to service a transport has no
> affinity to a particular transport.

Actually it does, on systems where these effects matter, thanks
to irq binding.  Altix hardware irq behaviour is that interrupts
from one device go to one CPU only (on other platforms you may
need to explicitly bind interrupts to achieve the same effect).
Given non-variable IP routing (i.e. assuming you tune ARP to behave
sensibly, and don't use mode=rr bonding) this means that network irqs
destined for a particular TCP socket have a very strong affinity to
a particular CPU.  In the steady state, NFS traffic from a single client
hits only a single CPU and inter-node NUMA traffic is very small.

The only part of this picture that doesn't work right in tot is
that svc_rqst structures are allocated at system boot and end up
on node0, and for really large systems doing a lot of IO this can
have a noticeable effect.  I have a patch which I need to get around
to posting.

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
