Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40231 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863Ab2IYNd0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Sep 2012 09:33:26 -0400
Date: Tue, 25 Sep 2012 09:33:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org, Michael Tokarev <mjt@tls.msk.ru>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] svcrpc: fix svc_xprt_enqueue/svc_recv busy-looping
Message-ID: <20120925133322.GB18921@fieldses.org>
References: <20120820223746.GL5779@fieldses.org>
 <20120820224915.GM5779@fieldses.org>
 <20120925155457.44428c06@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120925155457.44428c06@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 25, 2012 at 03:54:57PM +1000, NeilBrown wrote:
> On Mon, 20 Aug 2012 18:49:15 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Mon, Aug 20, 2012 at 06:37:47PM -0400, bfields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > The rpc server tries to ensure that there will be room to send a reply
> > > before it receives a request.
> > > 
> > > It does this by tracking, in xpt_reserved, an upper bound on the total
> > > size of the replies that is has already committed to for the socket.
> > > 
> > > Currently it is adding in the estimate for a new reply *before* it
> > > checks whether there is space available.  If it finds that there is not
> > > space, it then subtracts the estimate back out.
> > > 
> > > This may lead the subsequent svc_xprt_enqueue to decide that there is
> > > space after all.
> > > 
> > > The results is a svc_recv() that will repeatedly return -EAGAIN, causing
> > > server threads to loop without doing any actual work.
> > > 
> > > Cc: stable@vger.kernel.org
> > > Reported-by: Michael Tokarev <mjt@tls.msk.ru>
> > > Tested-by: Michael Tokarev <mjt@tls.msk.ru>
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > ---
> > >  net/sunrpc/svc_xprt.c |    7 ++-----
> > >  1 file changed, 2 insertions(+), 5 deletions(-)
> > > 
> > > Queuing up for 3.6 absent any objections.--b.
> > 
> > By the way, one thing I'm still curious about is how this got
> > introduced.  mjt bisected it to f03d78db65085609938fdb686238867e65003181
> > "net: refine {udp|tcp|sctp}_mem limits", which looks like it just made
> > the problem a little more likely.
> > 
> > The last substantive change to has_wspace logic was Trond's
> > 47fcb03fefee2501e79176932a4184fc24d6f8ec, but I have a tough time
> > figuring out whether that would have affected it one way or the other.
> > 
> > As far as I can tell we've always added to xpt_reserved in this way, so
> > that svc_recv and svc_xprt_enqueue are comparing different things, and
> > surely this was always wrong even if the problem must have been harder
> > to trigger before.
> > 
> > But some of the wspace logic I don't understand, so cc'ing Neil and
> > Trond in case they see any other problem I missed.
> 
> Hi Bruce et al.
> 
> My guess is that 
> commit 9c335c0b8daf56b9f73479d00b1dd726e1fcca09
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Oct 26 11:32:03 2010 -0400
> 
>     svcrpc: fix wspace-checking race
> 
> introduced this problem.  It moved the test for 'do we have enough space'
> from before we add in the requirements of a new request, to after.
> 
> But I think your patch looks good.

Oops--thanks for spotting that!

All I wish I had now is an idea for a patch that would make that mistake
less likely in the future.  Slather on some comments, I guess....

--b.
