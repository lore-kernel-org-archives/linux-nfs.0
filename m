Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38266 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753266AbcKHUUy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Nov 2016 15:20:54 -0500
Date: Tue, 8 Nov 2016 15:20:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: svc_xprt_put is no longer BH-safe
Message-ID: <20161108202035.GC26589@fieldses.org>
References: <1934654A-78D7-4180-A0AA-4B144254BFC2@oracle.com>
 <20161108200339.GA26589@fieldses.org>
 <7AB623FA-C766-4A1B-8A70-C54F4C8C80ED@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7AB623FA-C766-4A1B-8A70-C54F4C8C80ED@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 08, 2016 at 03:13:13PM -0500, Chuck Lever wrote:
> 
> > On Nov 8, 2016, at 3:03 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Sat, Oct 29, 2016 at 12:21:03PM -0400, Chuck Lever wrote:
> >> Hi Bruce-
> > 
> > Sorry for the slow response!
> > 
> > ...
> >> In commit 39a9beab5acb83176e8b9a4f0778749a09341f1f ('rpc: share one xps between
> >> all backchannels') you added:
> >> 
> >> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> >> index f5572e3..4f01f63 100644
> >> --- a/net/sunrpc/svc_xprt.c
> >> +++ b/net/sunrpc/svc_xprt.c
> >> @@ -136,6 +136,8 @@ static void svc_xprt_free(struct kref *kref)
> >>        /* See comment on corresponding get in xs_setup_bc_tcp(): */
> >>        if (xprt->xpt_bc_xprt)
> >>                xprt_put(xprt->xpt_bc_xprt);
> >> +       if (xprt->xpt_bc_xps)
> >> +               xprt_switch_put(xprt->xpt_bc_xps);
> >>        xprt->xpt_ops->xpo_free(xprt);
> >>        module_put(owner);
> >> }
> >> 
> >> svc_xprt_free() is invoked by svc_xprt_put(). svc_xprt_put() is called
> >> from svc_rdma in soft IRQ context (eg. svc_rdma_wc_receive).
> > 
> > Is that necessary?  I wonder why the svcrdma code seems to be taking so
> > many of its own references on svc_xprts.
> 
> The idea is to keep the xprt around while Work Requests (I/O) are running,
> so that the xprt is guaranteed to be there during work completions. The
> completion handlers (where svc_xprt_put is often invoked) run in soft IRQ
> context.
> 
> It's simple to change completions to use a Work Queue instead, but testing
> so far shows that will result in a performance loss. I'm still studying it.
> 
> Is there another way to keep the xprt's ref count boosted while I/O is
> going on?

Why do you need the svc_xprt in the completion?

Can the xpo_detach method wait for any pending completions?

--b.

> 
> 
> >> However, xprt_switch_put() takes a spin lock (xps_lock) which is locked
> >> everywhere without disabling BHs.
> >> 
> >> It looks to me like 39a9beab5acb makes svc_xprt_put() no longer BH-safe?
> >> Not sure if svc_xprt_put() was intended to be BH-safe beforehand.
> >> 
> >> Maybe xprt_switch_put() could be invoked in ->xpo_free, but that seems
> >> like a temporary solution.
> > 
> > Since xpo_free is also called from svc_xprt_put that doesn't sound like
> > it would change anything.  Or do we not trunk over RDMA for some reason?
> 
> It's quite desirable to trunk NFS/RDMA on multiple connections, and it
> should work just like it does for TCP, but so far it's not been tested.
> 
> 
> --
> Chuck Lever
> 
> 
