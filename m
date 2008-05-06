From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH  3/17] svcrdma: Fix return value in svc_rdma_send
Date: Tue, 6 May 2008 17:08:35 -0400
Message-ID: <20080506210835.GL13484@fieldses.org>
References: <20080505220817.GH12814@fieldses.org> <C4452686.4957E%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37188 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490AbYEFVIh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:08:37 -0400
In-Reply-To: <C4452686.4957E%tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 05, 2008 at 09:03:02PM -0500, Tom Tucker wrote:
> 
> 
> On 5/5/08 5:08 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Fri, May 02, 2008 at 11:28:35AM -0500, Tom Tucker wrote:
> >> Fix the return value on close to -ENOTCONN so caller knows to free context.
> >> Also if a thread is waiting for free SQ space, check for close when waking
> >> to avoid posting WR to a closing transport.
> > 
> > A random related question: svc_rdma_send_error() seems to have only one
> > caller, which ignores its return value.  Should its return value be
> > made void?
> 
> Honestly, I don't think this code path has ever been excercised. This is the
> "protocol error" path. Given my experience with the "random transport error"
> tests that resulted in the patchset your currently looking at, I'd be
> inclined to defer this kind of thing until I've built a "protocol error" set
> of tests and worked through the "evil client" scenarios.
> 
> Thoughts?

None, just the observation that it's ugly to have something defined as

	int svc_rdma_send_error(struct svcxprt_rdma *xprt, ...

whose only caller is

	(void)svc_rdma_send_error(rdma_xprt, rmsgp, ERR_VERS);

But it's not urgent--if you want to wait till you're fixing something
related, OK.

--b.

> > 
> > --b.
> > 
> >> 
> >> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> >> 
> >> ---
> >>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> >> 
> >> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> >> b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> >> index 14f83a1..8adb2f0 100644
> >> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> >> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> >> @@ -999,7 +999,7 @@ int svc_rdma_send(struct svcxprt_rdma *xprt, struct
> >> ib_send_wr *wr)
> >> int ret;
> >>  
> >> if (test_bit(XPT_CLOSE, &xprt->sc_xprt.xpt_flags))
> >> -  return 0;
> >> +  return -ENOTCONN;
> >>  
> >> BUG_ON(wr->send_flags != IB_SEND_SIGNALED);
> >> BUG_ON(((struct svc_rdma_op_ctxt *)(unsigned long)wr->wr_id)->wr_op !=
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
