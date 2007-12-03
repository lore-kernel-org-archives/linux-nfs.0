From: James Lentini <jlentini@netapp.com>
Subject: Re: [RFC,PATCH 7/8] rdma: makefile (second thread)
Date: Mon, 3 Dec 2007 15:29:25 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0712031524250.7142@jlentini-linux.nane.netapp.com>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int>
 <20071129224513.14887.8074.stgit@dell3.ogc.int> <2E823541-6441-4605-8F15-440954CED454@oracle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53004 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806AbXLCU3n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Dec 2007 15:29:43 -0500
In-Reply-To: <2E823541-6441-4605-8F15-440954CED454@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Mon, 3 Dec 2007, Chuck Lever wrote:

> On Nov 29, 2007, at 5:45 PM, Tom Tucker wrote:
> > Add the NFSD_RDMA module to the sunrpc makefile.
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> > net/sunrpc/Makefile |    4 ++++
> > 1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
> > index 92e1dbe..6d03dbf 100644
> > --- a/net/sunrpc/Makefile
> > +++ b/net/sunrpc/Makefile
> > @@ -15,3 +15,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
> > 	    svc_xprt.o
> > sunrpc-$(CONFIG_PROC_FS) += stats.o
> > sunrpc-$(CONFIG_SYSCTL) += sysctl.o
> > +
> > +obj-$(CONFIG_NFSD_RDMA) += svcrdma.o
> > +svcrdma-y := svc_rdma.o svc_rdma_transport.o \
> > +	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o
> 
> 
> Maybe it would be better to enable server-side RPC RDMA provider support with
> a separate config option, like the client side does it, then build the NFS
> server dependency on that, instead of adding it here in the RPC makefile.
> 
> If the client-side and server-side providers are merged, then they could both
> be enabled via CONFIG_SUNRPC_XPRT_RDMA.
> 
> Comments?

I vote for keeping the client and server sources and builds separate. 
I'd keep the sources separate because the interfaces defined in the 
xprtrdma files are only used by the client and the interfaces defined 
in svc_rdma_* files are only used by the server. I'd keep keep the 
build configuration separate because often someone will want to an NFS 
client but not an NFS server or vice versa.

james
