Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:43985 "EHLO
        mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755847AbeFOIXN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jun 2018 04:23:13 -0400
MIME-Version: 1.0
References: <1528891298-26694-1-git-send-email-geert@linux-m68k.org> <675726D3-9273-4051-B38F-6377B8445A27@oracle.com>
In-Reply-To: <675726D3-9273-4051-B38F-6377B8445A27@oracle.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 15 Jun 2018 10:23:01 +0200
Message-ID: <CAMuHMdUBqxFw5VoNo1mNRuV_T-pMzRc63vMa3ckAjp5jE7cFvg@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Move inline xprt_alloc_xid() up to fix compiler warning
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Bruce Fields <bfields@fieldses.org>, jlayton@kernel.org,
        trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On Thu, Jun 14, 2018 at 7:20 PM Chuck Lever <chuck.lever@oracle.com> wrote:
> > On Jun 13, 2018, at 8:01 AM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> >
> > With gcc 4.1.2:
> >
> >    net/sunrpc/xprt.c:69: warning: ‘xprt_alloc_xid’ declared inline after being called
> >    net/sunrpc/xprt.c:69: warning: previous declaration of ‘xprt_alloc_xid’ was here
> >
> > To fix this, move the function up, before its caller, and remove the no
> > longer needed forward declaration.
> >
> > Fixes: 37ac86c3a76c1136 ("SUNRPC: Initialize rpc_rqst outside of xprt->reserve_lock")
> > Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> > ---
> > net/sunrpc/xprt.c | 11 +++++------
> > 1 file changed, 5 insertions(+), 6 deletions(-)
> >
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > index 3c85af058227d14b..60a8b9f91cf94b54 100644
> > --- a/net/sunrpc/xprt.c
> > +++ b/net/sunrpc/xprt.c
> > @@ -66,7 +66,6 @@
> >  * Local functions
> >  */
> > static void    xprt_init(struct rpc_xprt *xprt, struct net *net);
> > -static __be32        xprt_alloc_xid(struct rpc_xprt *xprt);
> > static void   xprt_connect_status(struct rpc_task *task);
> > static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
> > static void     __xprt_put_cong(struct rpc_xprt *, struct rpc_rqst *);
> > @@ -956,6 +955,11 @@ static void xprt_timer(struct rpc_task *task)
> >               task->tk_status = 0;
> > }
> >
> > +static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
> > +{
> > +     return (__force __be32)xprt->xid++;
> > +}
> > +
> > /**
> >  * xprt_prepare_transmit - reserve the transport before sending a request
> >  * @task: RPC task about to send a request
> > @@ -1296,11 +1300,6 @@ void xprt_retry_reserve(struct rpc_task *task)
> >       xprt->ops->alloc_slot(xprt, task);
> > }
> >
> > -static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
> > -{
> > -     return (__force __be32)xprt->xid++;
> > -}
> > -
>
> For code organization, we might want to keep xprt_alloc_xid
> together with xprt_init_xid. Would it be better to simply
> remove the "inline" directive from these two and let the
> compiler choose the best optimization?

That's an option, too.

> > static inline void xprt_init_xid(struct rpc_xprt *xprt)
> > {
> >       xprt->xid = prandom_u32();

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
