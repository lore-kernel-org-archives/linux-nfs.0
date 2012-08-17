Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52224 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754263Ab2HQUIK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Aug 2012 16:08:10 -0400
Date: Fri, 17 Aug 2012 16:08:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux-kernel <linux-kernel@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.0+ NFS issues (bisected)
Message-ID: <20120817200807.GB14620@fieldses.org>
References: <4FFC2573.8040804@msgid.tls.msk.ru>
 <20120712125303.GC16822@fieldses.org>
 <502DA4E8.9050800@msgid.tls.msk.ru>
 <20120817145616.GC11172@fieldses.org>
 <20120817160057.GE11172@fieldses.org>
 <502E7B86.3060702@msgid.tls.msk.ru>
 <20120817171854.GA14015@fieldses.org>
 <502E7EC3.5030006@msgid.tls.msk.ru>
 <502E7F84.3060003@msgid.tls.msk.ru>
 <20120817191800.GA14620@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120817191800.GA14620@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 17, 2012 at 03:18:00PM -0400, J. Bruce Fields wrote:
> On Fri, Aug 17, 2012 at 09:29:40PM +0400, Michael Tokarev wrote:
> > On 17.08.2012 21:26, Michael Tokarev wrote:
> > > On 17.08.2012 21:18, J. Bruce Fields wrote:
> > >> On Fri, Aug 17, 2012 at 09:12:38PM +0400, Michael Tokarev wrote:
> > > []
> > >>> So we're calling svc_recv in a tight loop, eating
> > >>> all available CPU.  (The above is with just 2 nfsd
> > >>> threads).
> > >>>
> > >>> Something is definitely wrong here.  And it happens mure more
> > >>> often after the mentioned commit (f03d78db65085).
> > >>
> > >> Oh, neat.  Hm.  That commit doesn't really sound like the cause, then.
> > >> Is that busy-looping reproduceable on kernels before that commit?
> > > 
> > > Note I bisected this issue to this commit.  I haven't seen it
> > > happening before this commit, and reverting it from 3.0 or 3.2
> > > kernel makes the problem to go away.
> > > 
> > > I guess it is looping there:
> > > 
> > > 
> > > net/sunrpc/svc_xprt.c:svc_recv()
> > > ...
> > >         len = 0;
> > > ...
> > >         if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
> > > ...
> > >         } else if (xprt->xpt_ops->xpo_has_wspace(xprt)) {  <=== here -- has no wspace due to memory...
> > > ...  len = <something>
> > >         }
> > > 
> > >         /* No data, incomplete (TCP) read, or accept() */
> > >         if (len == 0 || len == -EAGAIN)
> > >                 goto out;
> > > ...
> > > out:
> > >         rqstp->rq_res.len = 0;
> > >         svc_xprt_release(rqstp);
> > >         return -EAGAIN;
> > > }
> > > 
> > > I'm trying to verify this theory...
> > 
> > Yes.  I inserted a printk there, and all these million times while
> > we're waiting in this EAGAIN loop, this printk is triggering:
> > 
> > ....
> > [21052.533053]  svc_recv: !has_wspace
> > [21052.533070]  svc_recv: !has_wspace
> > [21052.533087]  svc_recv: !has_wspace
> > [21052.533105]  svc_recv: !has_wspace
> > [21052.533122]  svc_recv: !has_wspace
> > [21052.533139]  svc_recv: !has_wspace
> > [21052.533156]  svc_recv: !has_wspace
> > [21052.533174]  svc_recv: !has_wspace
> > [21052.533191]  svc_recv: !has_wspace
> > [21052.533208]  svc_recv: !has_wspace
> > [21052.533226]  svc_recv: !has_wspace
> > [21052.533244]  svc_recv: !has_wspace
> > [21052.533265] calling svc_recv: 1228163 times (err=-4)
> > [21052.533403] calling svc_recv: 1226616 times (err=-4)
> > [21052.534520] nfsd: last server has exited, flushing export cache
> > 
> > (I stopped nfsd since it was flooding the log).
> > 
> > I can only guess that before that commit, we always had space,
> > now we don't anymore, and are looping like crazy.
> 
> Thanks!  But, arrgh--that should be enough to go on at this point, but
> I'm not seeing it.  If has_wspace is returning false then it's likely
> also returning false to the call at the start of svc_xprt_enqueue()

Wait a minute, that assumption's a problem because that calculation
depends in part on xpt_reserved, which is changed here....

In particular, svc_xprt_release() calls svc_reserve(rqstp, 0), which
subtracts rqstp->rq_reserved and then calls svc_xprt_enqueue, now with a
lower xpt_reserved value.  That could well explain this.

--b.

> (see
> svc_xprt_has_something_to_do), which means the xprt shouldn't be getting
> requeued and the next svc_recv call should find no socket ready (so
> svc_xprt_dequeue() returns NULL), and goes to sleep.
> 
> But clearly it's not working that way....
> 
> --b.
