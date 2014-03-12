Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51512 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752077AbaCLNdI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2014 09:33:08 -0400
Date: Wed, 12 Mar 2014 09:33:00 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'J. Bruce Fields'" <bfields@fieldses.org>,
        Tom Tucker <tom@opengridcomputing.com>,
        "'Yan Burman'" <yanb@mellanox.com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org, "'Or Gerlitz'" <ogerlitz@mellanox.com>
Subject: Re: NFS over RDMA crashing
Message-ID: <20140312093300.7a434cbb@tlielax.poochiereds.net>
In-Reply-To: <531B79F8.2020008@opengridcomputing.com>
References: <51127B3F.2090200@mellanox.com>
	<20130206222435.GL16417@fieldses.org>
	<20130207164134.GK3222@fieldses.org>
	<003601cf3a26$94523ee0$bcf6bca0$@opengridcomputing.com>
	<005d01cf3a45$94ced0d0$be6c7270$@opengridcomputing.com>
	<531B47B3.1070503@opengridcomputing.com>
	<531B6D90.2090208@opengridcomputing.com>
	<531B79F8.2020008@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 08 Mar 2014 14:13:44 -0600
Steve Wise <swise@opengridcomputing.com> wrote:

> On 3/8/2014 1:20 PM, Steve Wise wrote:
> >
> >> I removed your change and started debugging original crash that 
> >> happens on top-o-tree.   Seems like rq_next_pages is screwed up.  It 
> >> should always be >= rq_respages, yes?  I added a BUG_ON() to assert 
> >> this in rdma_read_xdr() we hit the BUG_ON(). Look
> >>
> >> crash> svc_rqst.rq_next_page 0xffff8800b84e6000
> >>   rq_next_page = 0xffff8800b84e6228
> >> crash> svc_rqst.rq_respages 0xffff8800b84e6000
> >>   rq_respages = 0xffff8800b84e62a8
> >>
> >> Any ideas Bruce/Tom?
> >>
> >
> > Guys, the patch below seems to fix the problem.  Dunno if it is 
> > correct though.  What do you think?
> >
> > diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c 
> > b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > index 0ce7552..6d62411 100644
> > --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> > @@ -90,6 +90,7 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
> >                 sge_no++;
> >         }
> >         rqstp->rq_respages = &rqstp->rq_pages[sge_no];
> > +       rqstp->rq_next_page = rqstp->rq_respages;
> >
> >         /* We should never run out of SGE because the limit is defined to
> >          * support the max allowed RPC data length
> > @@ -276,6 +277,7 @@ static int fast_reg_read_chunks(struct 
> > svcxprt_rdma *xprt,
> >
> >         /* rq_respages points one past arg pages */
> >         rqstp->rq_respages = &rqstp->rq_arg.pages[page_no];
> > +       rqstp->rq_next_page = rqstp->rq_respages;
> >
> >         /* Create the reply and chunk maps */
> >         offset = 0;
> >
> >
> 
> While this patch avoids the crashing, it apparently isn't correct...I'm 
> getting IO errors reading files over the mount. :)
> 

I hit the same oops and tested your patch and it seems to have fixed
that particular panic, but I still see a bunch of other mem corruption
oopses even with it. I'll look more closely at that when I get some
time.

FWIW, I can easily reproduce that by simply doing something like:

    $ dd if=/dev/urandom of=/file/on/nfsordma/mount bs=4k count=1

I'm not sure why you're not seeing any panics with your patch in place.
Perhaps it's due to hw differences between our test rigs.

The EIO problem that you're seeing is likely the same client bug that
Chuck recently fixed in this patch:

    [PATCH 2/8] SUNRPC: Fix large reads on NFS/RDMA

AIUI, Trond is merging that set for 3.15, so I'd make sure your client
has those patches when testing.

Finally, I also have a forthcoming patch to fix non-page aligned NFS
READs as well. I'm hesitant to send that out though until I can at
least run the connectathon testsuite against this server. The WRITE
oopses sort of prevent that for now...

-- 
Jeff Layton <jlayton@redhat.com>
