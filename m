Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:34225 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbbIQO7N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 10:59:13 -0400
Received: by ykdg206 with SMTP id g206so19249657ykd.1
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 07:59:13 -0700 (PDT)
Date: Thu, 17 Sep 2015 10:59:09 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "Suzuki K. Poulose" <suzuki.poulose@arm.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Fix a race in xs_reset_transport
Message-ID: <20150917105909.14f06a6d@synchrony.poochiereds.net>
In-Reply-To: <1442501401.12852.1.camel@primarydata.com>
References: <1442332163-9230-1-git-send-email-suzuki.poulose@arm.com>
	<20150915145229.4e69d5f7@synchrony.poochiereds.net>
	<CAHQdGtTzHbuBQTdW7vfxpOzET8hOQrXV-AE1Px7rNwu1zBMKNw@mail.gmail.com>
	<20150917101847.74ee85ac@synchrony.poochiereds.net>
	<1442501401.12852.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 Sep 2015 10:50:01 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Thu, 2015-09-17 at 10:18 -0400, Jeff Layton wrote:
> > On Thu, 17 Sep 2015 09:38:33 -0400
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > 
> > > On Tue, Sep 15, 2015 at 2:52 PM, Jeff Layton <
> > > jlayton@poochiereds.net> wrote:
> > > > On Tue, 15 Sep 2015 16:49:23 +0100
> > > > "Suzuki K. Poulose" <suzuki.poulose@arm.com> wrote:
> > > > 
> > > > >  net/sunrpc/xprtsock.c |    9 ++++++++-
> > > > >  1 file changed, 8 insertions(+), 1 deletion(-)
> > > > > 
> > > > > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > > > > index 7be90bc..6f4789d 100644
> > > > > --- a/net/sunrpc/xprtsock.c
> > > > > +++ b/net/sunrpc/xprtsock.c
> > > > > @@ -822,9 +822,16 @@ static void xs_reset_transport(struct
> > > > > sock_xprt *transport)
> > > > >       if (atomic_read(&transport->xprt.swapper))
> > > > >               sk_clear_memalloc(sk);
> > > > > 
> > > > > -     kernel_sock_shutdown(sock, SHUT_RDWR);
> > > > > +     if (sock)
> > > > > +             kernel_sock_shutdown(sock, SHUT_RDWR);
> > > > > 
> > > > 
> > > > Good catch, but...isn't this still racy? What prevents transport
> > > > ->sock
> > > > being set to NULL after you assign it to "sock" but before
> > > > calling
> > > > kernel_sock_shutdown?
> > > 
> > > The XPRT_LOCKED state.
> > > 
> > 
> > IDGI -- if the XPRT_LOCKED bit was supposed to prevent that, then
> > how could you hit the original race? There should be no concurrent
> > callers to xs_reset_transport on the same xprt, right?
> 
> Correct. The only exception is xs_destroy.
> 
> > AFAICT, that bit is not set in the xprt_destroy codepath, which may
> > be
> > the root cause of the problem. How would we take it there anyway?
> > xprt_destroy is void return, and may not be called in the context of
> > a
> > rpc_task. If it's contended,  what do we do? Sleep until it's
> > cleared?
> > 
> 
> How about the following.
> 
> 8<-----------------------------------------------------------------
> From e2e68218e66c6b0715fd6b8f1b3092694a7c0e62 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Thu, 17 Sep 2015 10:42:27 -0400
> Subject: [PATCH] SUNRPC: Fix races between socket connection and destroy code
> 
> When we're destroying the socket transport, we need to ensure that
> we cancel any existing delayed connection attempts, and order them
> w.r.t. the call to xs_close().
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/xprtsock.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 7be90bc1a7c2..d2dfbd043bea 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -881,8 +881,11 @@ static void xs_xprt_free(struct rpc_xprt *xprt)
>   */
>  static void xs_destroy(struct rpc_xprt *xprt)
>  {
> +	struct sock_xprt *transport = container_of(xprt,
> +			struct sock_xprt, xprt);
>  	dprintk("RPC:       xs_destroy xprt %p\n", xprt);
>  
> +	cancel_delayed_work_sync(&transport->connect_worker);
>  	xs_close(xprt);
>  	xs_xprt_free(xprt);
>  	module_put(THIS_MODULE);

Yeah, that looks like it might do it. The only other xs_destroy callers
are in the connect codepath so canceling the work should prevent the
race. So...

Acked-by: Jeff Layton <jlayton@poochiereds.net>

It wouldn't hurt to update the comments over xs_close too for
posterity. They currently say:

 * The caller _must_ be holding XPRT_LOCKED in order to avoid issues with
 * xs_reset_transport() zeroing the socket from underneath a writer.

...but that rule is clearly broken here.
