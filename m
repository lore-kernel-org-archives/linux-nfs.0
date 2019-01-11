Return-Path: <SRS0=ZJCY=PT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAE3AC43387
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Jan 2019 22:10:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7763520878
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Jan 2019 22:10:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725828AbfAKWKb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 11 Jan 2019 17:10:31 -0500
Received: from fieldses.org ([173.255.197.46]:50300 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725825AbfAKWKb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Jan 2019 17:10:31 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id A50FE1C5A; Fri, 11 Jan 2019 17:10:30 -0500 (EST)
Date:   Fri, 11 Jan 2019 17:10:30 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Message-ID: <20190111221030.GA28794@fieldses.org>
References: <20190104173912.GC11787@fieldses.org>
 <20190107213218.GD7753@fieldses.org>
 <e14e17167ef98c456e7648ad0536827b7870f0ff.camel@hammerspace.com>
 <20190108150107.GA15921@fieldses.org>
 <4077991d3d3acee4c37c7c8c6dc2b76930c9584e.camel@hammerspace.com>
 <20190109165142.GB32189@fieldses.org>
 <300445038b75d5efafe9391eb4b8e83d9d6e3633.camel@hammerspace.com>
 <20190111211235.GA27206@fieldses.org>
 <BB7240BE-3F20-43AD-B709-7F18CC33CC02@oracle.com>
 <6F5B73B7-E9F8-4FDB-8381-E5C02772C6A5@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6F5B73B7-E9F8-4FDB-8381-E5C02772C6A5@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 11, 2019 at 04:54:01PM -0500, Chuck Lever wrote:
> > On Jan 11, 2019, at 4:52 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> >> So, I think we need your patch plus something like this.
> >> 
> >> Chuck, maybe you could help me with the "XXX: Chuck:" parts?
> > 
> > I haven't been following. Why do you think those are necessary?

I'm worried something like this could happen:

	CPU 1				CPU 2
	-----				-----

	set XPT_DATA			dec xpt_nr_rqsts

	svc_xprt_enqueue		svc_xprt_enqueue

And both decide nothing should be done if neither sees the change that
the other made.

Maybe I'm still missing some reason that couldn't happen.

Even if it can happen, it's an unlikely race that will likely be fixed
when another event comes along a little later, which would explain why
we've never seen any reports.

> > We've had set_bit and atomic_{inc,dec} in this code for ages,
> > and I've never noticed a problem.
> > 
> > Rather than adding another CPU pipeline bubble in the RDMA code,
> > though, could you simply move the set_bit() call site inside the
> > critical sections?
> 
> er, inside the preceding critical section. Just reverse the order
> of the spin_unlock and the set_bit.

That'd do it, thanks!

--b.

> 
> 
> > 
> > 
> >> (This applies on top of your patch plus another that just renames the
> >> stupidly long svc_xprt_has_something_to_do() to svc_xprt_read().)
> >> 
> >> --b.
> >> 
> >> commit d7356c3250d4
> >> Author: J. Bruce Fields <bfields@redhat.com>
> >> Date:   Fri Jan 11 15:36:40 2019 -0500
> >> 
> >>   svcrpc: fix unlikely races preventing queueing of sockets
> >> 
> >>   In the rpc server, When something happens that might be reason to wake
> >>   up a thread to do something, what we do is
> >> 
> >>           - modify xpt_flags, sk_sock->flags, xpt_reserved, or
> >>             xpt_nr_rqsts to indicate the new situation
> >>           - call svc_xprt_enqueue() to decide whether to wake up a thread.
> >> 
> >>   svc_xprt_enqueue may require multiple conditions to be true before
> >>   queueing up a thread to handle the xprt.  In the SMP case, one of the
> >>   other CPU's may have set another required condition, and in that case,
> >>   although both CPUs run svc_xprt_enqueue(), it's possible that neither
> >>   call sees the writes done by the other CPU in time, and neither one
> >>   recognizes that all the required conditions have been set.  A socket
> >>   could therefore be ignored indefinitely.
> >> 
> >>   Add memory barries to ensure that any svc_xprt_enqueue() call will
> >>   always see the conditions changed by other CPUs before deciding to
> >>   ignore a socket.
> >> 
> >>   I've never seen this race reported.  In the unlikely event it happens,
> >>   another event will usually come along and the problem will fix itself.
> >>   So I don't think this is worth backporting to stable.
> >> 
> >>   Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> >> 
> >> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> >> index d410ae512b02..2af21b84b3b6 100644
> >> --- a/net/sunrpc/svc_xprt.c
> >> +++ b/net/sunrpc/svc_xprt.c
> >> @@ -357,6 +357,7 @@ static void svc_xprt_release_slot(struct svc_rqst *rqstp)
> >> 	struct svc_xprt	*xprt = rqstp->rq_xprt;
> >> 	if (test_and_clear_bit(RQ_DATA, &rqstp->rq_flags)) {
> >> 		atomic_dec(&xprt->xpt_nr_rqsts);
> >> +		smp_wmb(); /* See smp_rmb() in svc_xprt_ready() */
> >> 		svc_xprt_enqueue(xprt);
> >> 	}
> >> }
> >> @@ -365,6 +366,15 @@ static bool svc_xprt_ready(struct svc_xprt *xprt)
> >> {
> >> 	unsigned long xpt_flags;
> >> 
> >> +	/*
> >> +	 * If another cpu has recently updated xpt_flags,
> >> +	 * sk_sock->flags, xpt_reserved, or xpt_nr_rqsts, we need to
> >> +	 * know about it; otherwise it's possible that both that cpu and
> >> +	 * this one could call svc_xprt_enqueue() without either
> >> +	 * svc_xprt_enqueue() recognizing that the conditions below
> >> +	 * are satisfied, and we could stall indefinitely:
> >> +	 */
> >> +	smp_rmb();
> >> 	READ_ONCE(xprt->xpt_flags);
> >> 
> >> 	if (xpt_flags & (BIT(XPT_CONN) | BIT(XPT_CLOSE)))
> >> @@ -479,7 +489,7 @@ void svc_reserve(struct svc_rqst *rqstp, int space)
> >> 	if (xprt && space < rqstp->rq_reserved) {
> >> 		atomic_sub((rqstp->rq_reserved - space), &xprt->xpt_reserved);
> >> 		rqstp->rq_reserved = space;
> >> -
> >> +		smp_wmb(); /* See smp_rmb() in svc_xprt_ready() */
> >> 		svc_xprt_enqueue(xprt);
> >> 	}
> >> }
> >> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> >> index 828b149eaaef..377244992ae8 100644
> >> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> >> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> >> @@ -316,6 +316,7 @@ static void svc_rdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
> >> 	list_add_tail(&ctxt->rc_list, &rdma->sc_rq_dto_q);
> >> 	spin_unlock(&rdma->sc_rq_dto_lock);
> >> 	set_bit(XPT_DATA, &rdma->sc_xprt.xpt_flags);
> >> +	/* XXX: Chuck: do we need an smp_mb__after_atomic() here? */
> >> 	if (!test_bit(RDMAXPRT_CONN_PENDING, &rdma->sc_flags))
> >> 		svc_xprt_enqueue(&rdma->sc_xprt);
> >> 	goto out;
> >> diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
> >> index dc1951759a8e..e1a790487d69 100644
> >> --- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
> >> +++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
> >> @@ -290,6 +290,7 @@ static void svc_rdma_wc_read_done(struct ib_cq *cq, struct ib_wc *wc)
> >> 		spin_unlock(&rdma->sc_rq_dto_lock);
> >> 
> >> 		set_bit(XPT_DATA, &rdma->sc_xprt.xpt_flags);
> >> +		/* XXX: Chuck: do we need a smp_mb__after_atomic() here? */
> >> 		svc_xprt_enqueue(&rdma->sc_xprt);
> >> 	}
> >> 
> > 
> > --
> > Chuck Lever
> 
> --
> Chuck Lever
> 
> 
