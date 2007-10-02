From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 05/35] svc: Move sk_sendto and sk_recvfrom	to	svc_xprt_class
Date: Tue, 02 Oct 2007 14:55:06 -0500
Message-ID: <1191354906.1565.65.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192740.3250.73564.stgit@dell3.ogc.int>
	<CBDFC3B7-FE67-4715-87CA-E828D76844BB@oracle.com>
	<1191342596.1565.11.camel@trinity.ogc.int>
	<4A775179-9659-41B6-999F-8316BA181152@oracle.com>
	<1191349462.1565.46.camel@trinity.ogc.int>
	<1191349842.1565.54.camel@trinity.ogc.int>
	<7FF82697-AB93-4339-AD46-CAE93E967242@oracle.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Icnqv-0001tg-TZ
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 12:56:22 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Icnqz-0005P8-Qm
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 12:56:27 -0700
In-Reply-To: <7FF82697-AB93-4339-AD46-CAE93E967242@oracle.com>
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

On Tue, 2007-10-02 at 14:47 -0400, Chuck Lever wrote:
> On Oct 2, 2007, at 2:30 PM, Tom Tucker wrote:
> 
> > On Tue, 2007-10-02 at 13:24 -0500, Tom Tucker wrote:
> >> On Tue, 2007-10-02 at 12:57 -0400, Chuck Lever wrote:
> >>> On Oct 2, 2007, at 12:29 PM, Tom Tucker wrote:
> >>
> >> [...snip...]

[...snip...]

> >
> > Actually, I'm having second thoughts. Since the svc_xprt structure is
> > allocated on the rqstp thread in which the transport is going to be
> > used, won't the memory be local to the allocating processor on a NUMA
> > system?
> 
> The ops vector isn't in the svc_xprt.  It's a constant, so it's in  
> memory allocated by the kernel loader at boot time.
> 

I think one of us missing something. Here's how I think it works...

The svc_xprt_ops structure is a constant in kernel memory. The
svc_xprt_class is also a constant and points to the svc_xprt_ops
structure. The svc_xprt structure, however, is allocated via kmalloc and
contains a _copy_ of the constant svc_xprt_ops structure and a copy of
the xcl_max_payload value. See the svc_xprt_init function.

My original thinking (flawed I think) was that since the svc_xprt was
allocated in the context of the current rqstp thread, that it would be
allocated from processor local memory. While I think this is true,
subsequent assignment of a rqstp thread to service a transport has no
affinity to a particular transport. So as you say, it will likely be in
some other processors memory, so what does it matter?

So the question in my mind, is "is it worth it to create rqstp to
transport affinity when assigning a thread to service a transport. If
not, then I should remove all this copy nonsense and access the constant
in svc_xprt_class directly.

> In other words, on each request, you will need to get the address of  
> the vector from dynamically allocated memory, but the vector itself  
> (and therefore the addresses of the transport methods) will be fixed  
> and in the boot CPU's memory pool.
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
