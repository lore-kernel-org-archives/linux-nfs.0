Return-Path: <SRS0=GLKr=PR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93830C43387
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 16:51:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 690D0206BB
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 16:51:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725535AbfAIQvn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 9 Jan 2019 11:51:43 -0500
Received: from fieldses.org ([173.255.197.46]:47192 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725468AbfAIQvn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 Jan 2019 11:51:43 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id C068D1D27; Wed,  9 Jan 2019 11:51:42 -0500 (EST)
Date:   Wed, 9 Jan 2019 11:51:42 -0500
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Don't allow compiler optimisation of
 svc_xprt_release_slot()
Message-ID: <20190109165142.GB32189@fieldses.org>
References: <20190103141712.24381-1-trond.myklebust@hammerspace.com>
 <20190103224529.GA6907@fieldses.org>
 <a0493a5f022a666779d19fde5cdfbfdf9c7316c4.camel@hammerspace.com>
 <20190104173912.GC11787@fieldses.org>
 <20190107213218.GD7753@fieldses.org>
 <e14e17167ef98c456e7648ad0536827b7870f0ff.camel@hammerspace.com>
 <20190108150107.GA15921@fieldses.org>
 <4077991d3d3acee4c37c7c8c6dc2b76930c9584e.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4077991d3d3acee4c37c7c8c6dc2b76930c9584e.camel@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Jan 08, 2019 at 04:21:40PM +0000, Trond Myklebust wrote:
> On Tue, 2019-01-08 at 10:01 -0500, bfields@fieldses.org wrote:
> > On Mon, Jan 07, 2019 at 10:06:19PM +0000, Trond Myklebust wrote:
> > > On Mon, 2019-01-07 at 16:32 -0500, bfields@fieldses.org wrote:
> > > > So maybe we actually need
> > > > 
> > > >  static bool (struct svc_xprt *xprt)
> > > >  {
> > > > +	mb();
> > > 
> > > You would at best need a 'smp_rmb()'. There is nothing to gain from
> > > adding a write barrier here,
> > 
> > That's not my understanding.
> > 
> > What we have is basically:
> > 
> > 	1			2
> > 	----			----
> > 	WRITE to A		WRITE to B
> > 
> > 	READ from A and B	READ from A and B
> > 
> > and we want to guarantee that at least one of those two reads will
> > see
> > both of the writes.
> > 
> > A read barrier only orders reads with respect to the barrier, it
> > doesn't
> > do anything about writes, so doesn't guarantee anything here.
> 
> In this context 'WRITE to A' and/or 'WRITE to B' are presumably the
> operations of setting the flag bits in xprt->xpt_flags, no?

Right, or I guess sk_sock->flags, or an atomic operation on xpt_reserved
or xpt_nr_rqsts.

> That's not occurring here, it is occurring elsewhere.

Right.  And I hadn't tried to verify whether there were corresponding
(possibly implicit) write barriers in those places, thanks for doing
that work:

> The test_and_set_bit(XPT_DATA, &xprt->xpt_flags) in svc_data_ready()
> performs an explicit barrier, so we shouldn't really care.

OK.

> The other cases where we do set_bit(XPT_DATA) don't matter since the
> socket has its own locking, and so the XPT_DATA is really just a test
> for whether or not we need to enqueue the svc_xprt.

I'm not following, apologies.

In any case it's set only on initialization or in recvfrom, and in the
recvfrom case I think the

	smp_mb__before_atomic();
	clear_bit(XPT_BUSY, &xprt->xpt_flags);

in svc_xprt_received() provides the necessary write barrier.

But there are some exceptions in the rdma code, in svc_rdma_wc_receive
and svc_rdma_wc_done.

> In the only place where XPT_DEFERRED is set, you have an implicit write
> barrier (due to a spin_unlock) between the call to set_bit() and the
> call to svc_xprt_enqueue(), so all data writes are guaranteed to be
> complete before any attempt to enqueue the socket.

OK.

> I can't see that you really care for the case of XPT_CONN, since the
> just-created socket isn't going to be visible to other cpus until
> you've added it to &pool->sp_sockets (which also has implicit write
> barriers due to spin locks).
> 
> I don't think you really care for the case of XPT_CLOSE either since
> svc_delete_xprt() doesn't depend on any other data writes that aren't
> already protected by spinlocks.

OK.  Yes, I'm not worried about XPT_CONN or XPT_CLOSE.

> So the conclusion would be to add smp_rmb() in
> svc_xprt_has_something_to_do(). No extra write barriers are needed
> AFAICS.
> You may still need the READ_ONCE() in order to add a data dependency
> barrier (i.e. to ensure that alpha processors don't reorder reads of
> the xpt_flags with other speculative reads). That should reduce to a
> standard read on all non-alpha architectures.

That looks unnecessary; memory-barriers.txt say "Read memory barriers
imply data dependency barriers", and later "As of v4.15 of the Linux
kernel, an smp_read_barrier_depends() was added to READ_ONCE()".

I still wonder about:

	- the RDMA cases above.
	- svc_xprt_release_slot: no write barrier after writing to
	  xprt->xpt_nr_rqsts.
	- svc_reserve: no barrier after writing to xpt_reserved

Also svc_write_space is setting SOCK_NOSPACE and then calling
svc_xprt_enqueue.  I'm pretty sure the sk_write_space method has to have
a write barrier after that, though, so this is OK.

--b.

> 
> > 
> > --b.
> > 
> > 
> > 
> > > and you don't even need a read barrier in
> > > the non-smp case.
> > > 
> > > >  	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
> > > >  		return true;
> > > >  	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED))) {
> > > > 
> > > > Then whichever memory barrier executes second guarantees that the
> > > > following check sees the result of both the XPT_DATA and
> > > > xpt_nr_rqsts
> > > > changes.  I think....
> > > 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
> 
> 
