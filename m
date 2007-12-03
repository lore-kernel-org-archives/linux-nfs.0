From: James Lentini <jlentini@netapp.com>
Subject: Re: [RFC,PATCH 7/8] rdma: makefile (second thread)
Date: Mon, 3 Dec 2007 17:29:54 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0712031656150.7142@jlentini-linux.nane.netapp.com>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int>
 <20071129224513.14887.8074.stgit@dell3.ogc.int> <2E823541-6441-4605-8F15-440954CED454@oracle.com>
 <Pine.LNX.4.64.0712031524250.7142@jlentini-linux.nane.netapp.com>
 <D770E4F7-53C3-4853-B3B5-9E5B3A1FF40D@oracle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49920 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750723AbXLCW35 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Dec 2007 17:29:57 -0500
In-Reply-To: <D770E4F7-53C3-4853-B3B5-9E5B3A1FF40D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Mon, 3 Dec 2007, Chuck Lever wrote:

> On Dec 3, 2007, at 3:29 PM, James Lentini wrote:
> > On Mon, 3 Dec 2007, Chuck Lever wrote:
> > 
> > > On Nov 29, 2007, at 5:45 PM, Tom Tucker wrote:
> > > > Add the NFSD_RDMA module to the sunrpc makefile.
> > > > 
> > > > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > > > ---
> > > > 
> > > > net/sunrpc/Makefile |    4 ++++
> > > > 1 files changed, 4 insertions(+), 0 deletions(-)
> > > > 
> > > > diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
> > > > index 92e1dbe..6d03dbf 100644
> > > > --- a/net/sunrpc/Makefile
> > > > +++ b/net/sunrpc/Makefile
> > > > @@ -15,3 +15,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o
> > > > \
> > > > 	    svc_xprt.o
> > > > sunrpc-$(CONFIG_PROC_FS) += stats.o
> > > > sunrpc-$(CONFIG_SYSCTL) += sysctl.o
> > > > +
> > > > +obj-$(CONFIG_NFSD_RDMA) += svcrdma.o
> > > > +svcrdma-y := svc_rdma.o svc_rdma_transport.o \
> > > > +	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o
> > > 
> > > 
> > > Maybe it would be better to enable server-side RPC RDMA provider support
> > > with
> > > a separate config option, like the client side does it, then build the NFS
> > > server dependency on that, instead of adding it here in the RPC makefile.
> > > 
> > > If the client-side and server-side providers are merged, then they could
> > > both
> > > be enabled via CONFIG_SUNRPC_XPRT_RDMA.
> > > 
> > > Comments?
> > 
> > I vote for keeping the client and server sources and builds separate.
> > I'd keep the sources separate because the interfaces defined in the
> > xprtrdma files are only used by the client and the interfaces defined
> > in svc_rdma_* files are only used by the server.
> 
> That's just a design choice.  There's no real reason the two can't be merged
> at some later point.
> 
> I understand that the two sides were developed separately... but it seems like
> poor software engineering practice that there is so little code reuse between
> the client and server-side RDMA transport providers.  It continues an
> unfortunate tradition in the Linux RPC implementation.

I believe the differences are the result of (1) the asymmetry in the 
NFS/RDMA protocol, only the RPC responder (NFS server) is allowed to 
launch RDMA operations which results in different memory managements, 
etc. and (2) the interfaces they plug into are different. Both 
implementations do share common definitions when possible (e.g. wire 
formats).

> > I'd keep keep the build configuration separate because often 
> > someone will want to an NFS client but not an NFS server or vice 
> > versa.
> 
> You need both server and client providers to support NFSv4 
> callbacks, right?

You're right. I should have been more precise above.

> I still think it's useful to not add "CONFIG_NFSD_RDMA" to the 
> sunrpc Makefile, and would like to see that changed.

I understand where you are coming from but when I look at the current 
config options (e.g. separate options for enabling the v3/v4 in the 
client and server) it seems natural to me to have these be separate as 
well. Regardless of whether one config option or two are exposed, I 
still believe that it makes sense to build the modules separately.
