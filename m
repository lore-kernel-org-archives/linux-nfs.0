Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:44482 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755043AbbGTWnd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 18:43:33 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
Cc: "'Tom Talpey'" <tom@talpey.com>, "'Chuck Lever'" <chuck.lever@oracle.com>,
        <linux-rdma@vger.kernel.org>, <linux-nfs@vger.kernel.org>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net> <20150720190311.10997.12636.stgit@manet.1015granger.net> <55AD5B48.3010906@talpey.com> <20150720210544.GA9655@obsidianresearch.com> <015501d0c334$3f1c2830$bd547890$@opengridcomputing.com> <20150720221333.GA11356@obsidianresearch.com>
In-Reply-To: <20150720221333.GA11356@obsidianresearch.com>
Subject: RE: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
Date: Mon, 20 Jul 2015 17:43:34 -0500
Message-ID: <015e01d0c33d$82b44ce0$881ce6a0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Jason Gunthorpe [mailto:jgunthorpe@obsidianresearch.com]
> Sent: Monday, July 20, 2015 5:14 PM
> To: Steve Wise
> Cc: 'Tom Talpey'; 'Chuck Lever'; linux-rdma@vger.kernel.org; linux-nfs@vger.kernel.org
> Subject: Re: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
> 
> On Mon, Jul 20, 2015 at 04:37:15PM -0500, Steve Wise wrote:
> >
> >
> > > From: Steve Wise [mailto:swise@opengridcomputing.com]
> > > Sent: Monday, July 20, 2015 4:34 PM
> > > To: 'Jason Gunthorpe'; 'Tom Talpey'
> > > Cc: 'Chuck Lever'; 'linux-rdma@vger.kernel.org'; 'linux-nfs@vger.kernel.org'
> > > Subject: RE: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
> > >
> > >
> > > >
> > > > > Based on that, should we remove the cxgb3 driver as well? Or at least
> > > > > can you fix it up to at least fail get_dma_mr if there is too much
> > > > > ram?
> > > > >
> > > >
> > > > I would like to keep cxgb3 around.  I can add code to fail if the memory is > 32b.  Do you know how I get the amount of
> > available ram?
> > > >
> > >
> > > Something like this?
> > >
> > > @@ -736,6 +736,9 @@ static struct ib_mr *iwch_get_dma_mr(struct ib_pd *pd, int acc)
> > >         /*
> > >          * T3 only supports 32 bits of size.
> > >          */
> > > +       if ((totalram_pages << PAGE_SHIFT) > 0xffffffff)
> > > +               return -ENOTSUPP;
> >
> > oops: ERR_PTR(-ENOTSUPP);
> >
> > > +
> > >         bl.size = 0xffffffff;
> > >         bl.addr = 0;
> > >         kva = 0;
> 
> Yah, that seems much better.. With the patch set I am working on this
> will mean all ULPs will fail to create a kernel PD on cxgb3 if the
> above triggers. If our error handling works that should just make it
> unuable from kernel space which is what we need to see..
> 

What about user PDs?  We need that to work for cxgb3.


> To remove the amasso driver, move it to Staging. I don't know the
> exact details, sorry. Hopefully Doug will be able to help you do that.
>

ok thanks

 
> Maybe add some kind of one time print 'cxgb3 is not usuable on
> machines with >4G of RAM' as well?
>

Could do.

> Jason

