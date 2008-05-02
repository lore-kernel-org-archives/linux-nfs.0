From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 0/17] svcrdma: RDMA transport driver close path cleanup
Date: Fri, 02 May 2008 18:05:07 -0500
Message-ID: <1209769507.27628.36.camel@trinity.ogc.int>
References: <1209745721600-git-send-email-tom@opengridcomputing.com>
	 <20080502223755.GA29690@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:52860 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933428AbYEBXDE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 19:03:04 -0400
In-Reply-To: <20080502223755.GA29690@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-05-02 at 18:37 -0400, J. Bruce Fields wrote:
> Thanks.  I'm a little backlogged--bug me if I haven't gotten back to
> these by next week.

No problem. 
Tom

> 
> --b.
> 
> On Fri, May 02, 2008 at 11:28:24AM -0500, Tom Tucker wrote:
> > This patchset fixes a number of defects in the close path of the SVCRDMA
> > transport provider. The defects were found by injecting errors on the 
> > transport at random intervals while running concurrent iozone tests on
> > IB and iWARP mounts. With this set of patches applied I was able to run
> > the the above tests for several hours without causing a crash or leaking
> > resources. The transport recovers correctly on a client reconnect.
> > 
> > This patchset is based on 2.6 top of tree, however, I think these fixes are
> > good candidates for a 2.6.25 dot release as well. I have a set that is
> > already merged for that release if you would like them. They are available in
> > my git tree on linux-nfs.org in the '2.6.25' branch. Please let me know if you
> > would like me to post them here.
> > 
> > [PATCH 1/17] svcrdma: Simplify receive buffer posting
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   17 +----------------
> >  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   10 ++++++++++
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |   19 -------------------
> >  3 files changed, 11 insertions(+), 35 deletions(-)
> > 
> > [PATCH 2/17] svcrdma: Fix race with dto_tasklet in svc_rdma_send
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    8 ++++++--
> >  1 files changed, 6 insertions(+), 2 deletions(-)
> > 
> > [PATCH 3/17] svcrdma: Fix return value in svc_rdma_send
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > [PATCH 4/17] svcrdma: Add put of connection ESTABLISHED reference in rdma_cma_handler
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > [PATCH 5/17] svcrdma: Free context on ib_post_recv error
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > [PATCH 6/17] svcrdma: Free context on post_recv error in send_reply
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_sendto.c |    3 ++-
> >  1 files changed, 2 insertions(+), 1 deletions(-)
> > 
> > [PATCH 7/17] svcrdma: Fix error handling during listening endpoint creation
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    6 +++---
> >  1 files changed, 3 insertions(+), 3 deletions(-)
> > 
> > [PATCH 8/17] svcrdma: Return error from rdma_read_xdr so caller knows to free context
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   17 +++++++++++++----
> >  1 files changed, 13 insertions(+), 4 deletions(-)
> > 
> > [PATCH 9/17] svcrdma: Remove unused READ_DONE context flags bit
> > 
> >  include/linux/sunrpc/svc_rdma.h          |    1 -
> >  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 -
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 -
> >  3 files changed, 0 insertions(+), 3 deletions(-)
> > 
> > [PATCH 10/17] svcrdma: Simplify RDMA_READ deferral buffer management
> > 
> >  include/linux/sunrpc/svc_rdma.h          |    1 +
> >  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   58 ++++++------------------------
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 ++-
> >  3 files changed, 16 insertions(+), 48 deletions(-)
> > 
> > [PATCH 11/17] svcrdma: Use standard Linux lists for context cache
> > 
> >  include/linux/sunrpc/svc_rdma.h          |    5 ++-
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |   47 ++++++++++++++++-------------
> >  2 files changed, 29 insertions(+), 23 deletions(-)
> > 
> > [PATCH 12/17] svcrdma: Relaxing locking scope on RQ CQ
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > [PATCH 13/17] svcrdma: Move destroy to kernel thread
> > 
> >  include/linux/sunrpc/svc_rdma.h          |    1 +
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |   17 ++++++++++++++---
> >  2 files changed, 15 insertions(+), 3 deletions(-)
> > 
> > [PATCH 14/17] svcrdma: Add reference for each SQ/RQ WR
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |   18 ++++++++++++++++--
> >  1 files changed, 16 insertions(+), 2 deletions(-)
> > 
> > [PATCH 15/17] svcrdma: Move the QP and cm_id destruction to svc_rdma_free
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |   40 +++++++++++++++---------------
> >  1 files changed, 20 insertions(+), 20 deletions(-)
> > 
> > [PATCH 16/17] svcrdma: Cleanup queued, but unprocessed I/O in svc_rdma_free
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |   38 +++++++++++++++++++++++++++--
> >  1 files changed, 35 insertions(+), 3 deletions(-)
> > 
> > [PATCH 17/17] svcrdma: Use ib verbs version of dma_unmap
> > 
> >  net/sunrpc/xprtrdma/svc_rdma_transport.c |    8 ++++----
> >  1 files changed, 4 insertions(+), 4 deletions(-)
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

