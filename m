Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:60796 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbbGMQ55 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 12:57:57 -0400
Date: Mon, 13 Jul 2015 10:57:48 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: "'Christoph Hellwig'" <hch@infradead.org>
Cc: Tom Talpey <tom@talpey.com>, Doug Ledford <dledford@redhat.com>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150713165748.GE23832@obsidianresearch.com>
References: <20150708203205.GA21847@infradead.org>
 <20150709000337.GE16812@obsidianresearch.com>
 <559EF332.7060103@redhat.com>
 <20150709225306.GA30741@obsidianresearch.com>
 <559FC710.1050307@talpey.com>
 <20150710161108.GA19042@obsidianresearch.com>
 <55A00754.4010009@redhat.com>
 <55A01225.9000000@talpey.com>
 <20150710195420.GA31500@obsidianresearch.com>
 <20150711101736.GA14741@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150711101736.GA14741@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 11, 2015 at 03:17:36AM -0700, 'Christoph Hellwig' wrote:
> On Fri, Jul 10, 2015 at 01:54:20PM -0600, Jason Gunthorpe wrote:
> > diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
> > index bac3fb406a74..6ed7e0f6c162 100644
> > +++ b/drivers/infiniband/core/verbs.c
> > @@ -1126,6 +1126,12 @@ struct ib_mr *ib_get_dma_mr(struct ib_pd *pd, int mr_access_flags)
> >         struct ib_mr *mr;
> >         int err;
> >  
> > +       /* Granting remote access to the physical MR is a security hole, don't
> > +          do it. */
> > +       WARN_ON_ONCE(mr_access_flags &
> > +               (IB_ACCESS_REMOTE_WRITE | IB_ACCESS_REMOTE_READ |
> > +                IB_ACCESS_REMOTE_ATOMIC));
> > +
> 
> How about providing a system-wide IB_ACCESS_LOCAL_READ |
> IB_ACCESS_LOCAL_WRITE MR that all drivers can use and get rid of
> ib_get_dma_mr in the long run?  That would help to nicely simplify
> drivers?

That is more or less what I was talking about when I suggested
removing the lkey from the API ULPs use.

Ultimately ib_get_dma_mr is just one call, and switching to
(eg) pd->local_memory_lkey is tidier, but not much simpler..

> Currently various drivers are using ib_get_dma_mr with remote flags
> unfortunately, e.g. the SRP initiator driver uses it to optimize away
> memory registrtions for single SGL entry requests.

Unconditionally? Ugh. Maybe we do need the warn_on :(

> That looks fixable realtively easily, but I don't understand the
> other consumers as good.

The ones I looked at used it as a fallback if FMR or FRMR are not
available.

Jason
