From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 0/11] svcrdma: WR context management bug fixes and
	cleanup
Date: Thu, 29 May 2008 17:25:37 -0500
Message-ID: <1212099937.22478.3.camel@trinity.ogc.int>
References: <12120836962076-git-send-email-tom@opengridcomputing.com>
	 <20080529221000.GE24018@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	swise@opengridcomputing.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:35931 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754367AbYE2WVQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2008 18:21:16 -0400
In-Reply-To: <20080529221000.GE24018@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-05-29 at 18:10 -0400, J. Bruce Fields wrote:
> On Thu, May 29, 2008 at 12:54:45PM -0500, Tom Tucker wrote:
> > Bruce:
> > 
> > This set of patches fixes bugs related to DMA mapping and unmapping and
> > in the process redesigns and cleans up the way that WR contexts are managed.
> > 
> > In addition to the bug fixes, there are three major changes:
> > 
> > - The data structure that maps client side memory to server side
> >   memory has been separated from the WR context. This makes for cleaner
> >   type checking and a smaller memory footprint for the RDMA transport.
> > 
> > - The mapping and unmapping of DMA is performed independently from the
> >   allocation and deallocation of the WR context. This is to allow the
> >   unmapping to occur early on recv where the unmapping of the DMA needs
> >   to be done prior to looking at the data and therefore before 
> >   deallocating the WR context.
> > 
> > - The WR context cache now uses a kmem_cache and is shared across
> >   all transport instances. This allows contexts to be shared between
> >   mounts and idle mounts don't consume context memory.
> > 
> > This patchset is intended for 2.6.27 and is based on 2.6.26-rc4. These patches
> > are also available at the following git url:
> 
> OK, thanks.  Bug me if I haven't commented or applied these by next
> week.
> 
> Is there anything else remaining for 2.6.26 (as opposed to .27)?

I'm inclined to say "no". But I'd like to hear if anyone out there is
dead in the water due to a bug in the 2.6.26 version.

Tom

> 
> --b.
> 
> > 
> > git://git.linux-nfs.org/projects/tomtucker/xprt-switch-2.6.git
> > 
> > [PATCH 01/11] svcrdma: Add a type for keeping NFS request mapping
> > 
> >  include/linux/sunrpc/svc_rdma.h          |   27 +++++++++++++++++++++++++++
> >  net/sunrpc/xprtrdma/svc_rdma.c           |   23 +++++++++++++++++++++++
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |   26 ++++++++++++++++++++++++++
> >  3 files changed, 76 insertions(+), 0 deletions(-)
> > 
> > [PATCH 02/11] svcrdma: Use rpc reply map for RDMA_WRITE processing
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  122 ++++++++++++++----------------
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +-
> >  2 files changed, 62 insertions(+), 65 deletions(-)
> > 
> > [PATCH 03/11] svcrdma: Use reply and chunk map for RDMA_READ processing
> > 
> >  include/linux/sunrpc/svc_rdma.h         |    1 +
> >  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   83 ++++++++++++++-----------------
> >  2 files changed, 39 insertions(+), 45 deletions(-)
> > 
> > [PATCH 04/11] svcrdma: Move the DMA unmap logic to the CQ handler
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |   20 ++++++++++++++------
> >  1 files changed, 14 insertions(+), 6 deletions(-)
> > 
> > [PATCH 05/11] svcrdma: Add dma map count and WARN_ON
> > 
> >  include/linux/sunrpc/svc_rdma.h          |    1 +
> >  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 +
> >  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    3 +++
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +++++
> >  4 files changed, 10 insertions(+), 0 deletions(-)
> > 
> > [PATCH 06/11] svcrdma: Remove unneeded spin locks from __svc_rdma_free
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 ----
> >  1 files changed, 0 insertions(+), 4 deletions(-)
> > 
> > [PATCH 07/11] svcrdma: Remove unused wait q from svcrdma_xprt structure
> > 
> >  include/linux/sunrpc/svc_rdma.h |    1 -
> >  1 files changed, 0 insertions(+), 1 deletions(-)
> > 
> > [PATCH 08/11] svcrdma: Limit ORD based on client's advertised IRD
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |   16 ++++++++++++----
> >  1 files changed, 12 insertions(+), 4 deletions(-)
> > 
> > [PATCH 09/11] svcrdma: Add flush_scheduled_work to module exit function
> > 
> >  net/sunrpc/xprtrdma/svc_rdma.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > [PATCH 10/11] svcrdma: Create a kmem cache for the WR contexts
> > 
> >  net/sunrpc/xprtrdma/svc_rdma.c |   24 ++++++++++++++++++++----
> >  1 files changed, 20 insertions(+), 4 deletions(-)
> > 
> > [PATCH 11/11] svcrdma: Change WR context get/put to use the kmem cache
> > 
> >  include/linux/sunrpc/svc_rdma.h          |    6 --
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |  121 +++---------------------------
> >  2 files changed, 12 insertions(+), 115 deletions(-)
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > 

