Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:34165 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629AbbIQOSv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 10:18:51 -0400
Received: by ykdg206 with SMTP id g206so17991697ykd.1
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 07:18:51 -0700 (PDT)
Date: Thu, 17 Sep 2015 10:18:47 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "Suzuki K. Poulose" <suzuki.poulose@arm.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Fix a race in xs_reset_transport
Message-ID: <20150917101847.74ee85ac@synchrony.poochiereds.net>
In-Reply-To: <CAHQdGtTzHbuBQTdW7vfxpOzET8hOQrXV-AE1Px7rNwu1zBMKNw@mail.gmail.com>
References: <1442332163-9230-1-git-send-email-suzuki.poulose@arm.com>
	<20150915145229.4e69d5f7@synchrony.poochiereds.net>
	<CAHQdGtTzHbuBQTdW7vfxpOzET8hOQrXV-AE1Px7rNwu1zBMKNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 Sep 2015 09:38:33 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Tue, Sep 15, 2015 at 2:52 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> > On Tue, 15 Sep 2015 16:49:23 +0100
> > "Suzuki K. Poulose" <suzuki.poulose@arm.com> wrote:
> >
> >>  net/sunrpc/xprtsock.c |    9 ++++++++-
> >>  1 file changed, 8 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> >> index 7be90bc..6f4789d 100644
> >> --- a/net/sunrpc/xprtsock.c
> >> +++ b/net/sunrpc/xprtsock.c
> >> @@ -822,9 +822,16 @@ static void xs_reset_transport(struct sock_xprt *transport)
> >>       if (atomic_read(&transport->xprt.swapper))
> >>               sk_clear_memalloc(sk);
> >>
> >> -     kernel_sock_shutdown(sock, SHUT_RDWR);
> >> +     if (sock)
> >> +             kernel_sock_shutdown(sock, SHUT_RDWR);
> >>
> >
> > Good catch, but...isn't this still racy? What prevents transport->sock
> > being set to NULL after you assign it to "sock" but before calling
> > kernel_sock_shutdown?
> 
> The XPRT_LOCKED state.
> 

IDGI -- if the XPRT_LOCKED bit was supposed to prevent that, then
how could you hit the original race? There should be no concurrent
callers to xs_reset_transport on the same xprt, right?

AFAICT, that bit is not set in the xprt_destroy codepath, which may be
the root cause of the problem. How would we take it there anyway?
xprt_destroy is void return, and may not be called in the context of a
rpc_task. If it's contended,  what do we do? Sleep until it's cleared?

-- 
Jeff Layton <jlayton@poochiereds.net>
