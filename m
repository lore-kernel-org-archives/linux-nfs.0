From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/3] SUNRPC: have svc_recv() check kthread_should_stop()
Date: Mon, 11 Feb 2008 11:24:01 -0500
Message-ID: <20080211162401.GL25742@fieldses.org>
References: <1202420095-5818-1-git-send-email-jlayton@redhat.com> <1202420095-5818-2-git-send-email-jlayton@redhat.com> <1202420095-5818-3-git-send-email-jlayton@redhat.com> <20080211004759.GD20829@fieldses.org> <20080211070606.635b57be@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57393 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756564AbYBKQYC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2008 11:24:02 -0500
In-Reply-To: <20080211070606.635b57be-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 11, 2008 at 07:06:06AM -0500, Jeff Layton wrote:
> On Sun, 10 Feb 2008 19:47:59 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > Another nit:
> > 
> > On Thu, Feb 07, 2008 at 04:34:54PM -0500, Jeff Layton wrote:
> > > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > > index ea377e0..a3165a2 100644
> > > --- a/net/sunrpc/svc_xprt.c
> > > +++ b/net/sunrpc/svc_xprt.c
> > > @@ -18,6 +18,7 @@
> > >  #include <linux/skbuff.h>
> > >  #include <linux/file.h>
> > >  #include <linux/freezer.h>
> > > +#include <linux/kthread.h>
> > >  #include <net/sock.h>
> > >  #include <net/checksum.h>
> > >  #include <net/ip.h>
> > > @@ -586,6 +587,8 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
> > >  		while (rqstp->rq_pages[i] == NULL) {
> > >  			struct page *p = alloc_page(GFP_KERNEL);
> > >  			if (!p) {
> > > +				if (kthread_should_stop())
> > > +					return -EINTR;
> > >  				int j = msecs_to_jiffies(500);
> > >  				schedule_timeout_uninterruptible(j);
> > >  			}
> > 
> > The compiler's whining about the mixed declarations and code, so I've
> > also done the following in my copy.
> > 
> > --b.
> > 
> > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > index a3165a2..53c8ea9 100644
> > --- a/net/sunrpc/svc_xprt.c
> > +++ b/net/sunrpc/svc_xprt.c
> > @@ -587,9 +587,9 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
> >  		while (rqstp->rq_pages[i] == NULL) {
> >  			struct page *p = alloc_page(GFP_KERNEL);
> >  			if (!p) {
> > +				int j = msecs_to_jiffies(500);
> >  				if (kthread_should_stop())
> >  					return -EINTR;
> > -				int j = msecs_to_jiffies(500);
> >  				schedule_timeout_uninterruptible(j);
> >  			}
> >  			rqstp->rq_pages[i] = p;
> 
> Thanks Bruce. This reminds me though that I had a question about the
> above. I'm assuming that it's ok to return -EINTR without allocating
> all of the pages that we'll need to actually do the recv. This seems to
> be OK for all of the in-kernel callers of svc_recv...
> 
> Given that, is there any reason we need an uninterruptible sleep there?

I can't think of any reason either.

> It looks like when under heavy memory pressure, svc_recv could loop there
> for a long time. Allowing it to exit from that loop when signalled seems
> like it would be a good thing...

Yes, I think you're right.

--b.
