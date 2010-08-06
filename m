Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43445 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933058Ab0HFJaw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Aug 2010 05:30:52 -0400
From: "Andy Chittenden" <andyc.bluearc@gmail.com>
To: "'Trond Myklebust'" <Trond.Myklebust@netapp.com>
Cc: "'Andrew Morton'" <akpm@linux-foundation.org>,
        "'David Miller'" <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
        <pekkas@netcore.fi>, <jmorris@namei.org>, <yoshfuji@linux-ipv6.org>,
        <kaber@trash.net>, <eric.dumazet@gmail.com>,
        <William.Allen.Simpson@gmail.com>, <gilad@codefidence.com>,
        <ilpo.jarvinen@helsinki.fi>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Neil Brown'" <neilb@suse.de>,
        "'Chuck Lever'" <chuck.lever@oracle.com>,
        "'Benny Halevy'" <bhalevy@panasas.com>,
        "'Alexandros Batsakis'" <batsakis@netapp.com>,
        "'Joe Perches'" <joe@perches.com>,
        "Andy Chittenden" <andyc@bluearc.com>
References: <4c57cfe8.887b0e0a.2f79.4772@mx.google.com> <20100803.012144.267950450.davem@davemloft.net> <20100803021110.f0b3877b.akpm@linux-foundation.org> <4C57EE9A.7040308@gmail.com>  <4c5ad0d6.42ecd80a.47d7.0dfc@mx.google.com> <1281037822.2948.49.camel@heimdal.trondhjem.org>
In-Reply-To: <1281037822.2948.49.camel@heimdal.trondhjem.org>
Subject: RE: [PATCH] [Bug 16494] NFS client over TCP hangs due to packet loss
Date: Fri, 6 Aug 2010 10:30:48 +0100
Message-ID: <4c5bd64a.4a2ae30a.0283.0551@mx.google.com>
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> On Thu, 2010-08-05 at 15:55 +0100, Andy Chittenden wrote:
> > > On 2010-08-03 10:11, Andrew Morton wrote:
> > > > (cc linux-nfs)
> > > >
> > > > On Tue, 03 Aug 2010 01:21:44 -0700 (PDT) David
> > > Miller<davem@davemloft.net>  wrote:
> > > >
> > > >> From: "Andy Chittenden"<andyc.bluearc@gmail.com>
> > > >> Date: Tue, 3 Aug 2010 09:14:31 +0100
> > > >>
> > > >>> I don't know whether this patch is the correct fix or not but
> it
> > > enables the
> > > >>> NFS client to recover.
> > > >>>
> > > >>> Kernel version: 2.6.34.1 and 2.6.32.
> > > >>>
> > > >>> Fixes<https://bugzilla.kernel.org/show_bug.cgi?id=16494>. It
> clears
> > > down
> > > >>> any previous shutdown attempts so that reconnects on a socket
> > > that's been
> > > >>> shutdown leave the socket in a usable state (otherwise
> > > tcp_sendmsg() returns
> > > >>> -EPIPE).
> > > >>
> > > >> If the SunRPC code wants to close a TCP socket then use it
> again,
> > > >> it should disconnect by doing a connect() with sa_family ==
> > > AF_UNSPEC
> > >
> > > There is code to do that in the SunRPC code in
> xs_abort_connection()
> > > but
> > > that's conditionally called from xs_tcp_reuse_connection():
> > >
> > > static void xs_tcp_reuse_connection(struct rpc_xprt *xprt, struct
> > > sock_xprt *transport)
> > > {
> > > 	unsigned int state = transport->inet->sk_state;
> > >
> > > 	if (state == TCP_CLOSE && transport->sock->state ==
> > > SS_UNCONNECTED)
> > > 		return;
> > > 	if ((1 << state) & (TCPF_ESTABLISHED|TCPF_SYN_SENT))
> > > 		return;
> > > 	xs_abort_connection(xprt, transport);
> > > }
> > >
> > > That's changed since 2.6.26 where it unconditionally did the
> connect()
> > > with sa_family == AF_UNSPEC. FWIW we cannot reproduce this problem
> with
> > > 2.6.26.
> >
> > The problem is fixed with this patch which also prints out that
> sk_shutdown
> > can be non-zero on entry to xs_tcp_reuse_connection:
> >
> > # diff -up /home/company/software/src/linux-
> 2.6.34.2/net/sunrpc/xprtsock.c
> > net/sunrpc/xprtsock.c
> > --- /home/company/software/src/linux-2.6.34.2/net/sunrpc/xprtsock.c
> > 2010-08-02 18:30:51.000000000 +0100
> > +++ net/sunrpc/xprtsock.c       2010-08-05 12:21:11.000000000 +0100
> > @@ -1322,10 +1322,11 @@ static void xs_tcp_state_change(struct s
> >         if (!(xprt = xprt_from_sock(sk)))
> >                 goto out;
> >         dprintk("RPC:       xs_tcp_state_change client %p...\n",
> xprt);
> > -       dprintk("RPC:       state %x conn %d dead %d zapped %d\n",
> > +       dprintk("RPC:       state %x conn %d dead %d zapped %d
> sk_shutdown
> > %d\n",
> >                         sk->sk_state, xprt_connected(xprt),
> >                         sock_flag(sk, SOCK_DEAD),
> > -                       sock_flag(sk, SOCK_ZAPPED));
> > +                       sock_flag(sk, SOCK_ZAPPED),
> > +                       sk->sk_shutdown);
> >
> >         switch (sk->sk_state) {
> >         case TCP_ESTABLISHED:
> > @@ -1796,10 +1797,18 @@ static void xs_tcp_reuse_connection(stru
> >  {
> >         unsigned int state = transport->inet->sk_state;
> >
> > -       if (state == TCP_CLOSE && transport->sock->state ==
> SS_UNCONNECTED)
> > -               return;
> > -       if ((1 << state) & (TCPF_ESTABLISHED|TCPF_SYN_SENT))
> > -               return;
> > +       if (state == TCP_CLOSE && transport->sock->state ==
> SS_UNCONNECTED)
> > {
> > +               if (transport->inet->sk_shutdown == 0)
> > +                       return;
> > +               printk("%s: TCP_CLOSEd and sk_shutdown set to %d\n",
> > +                       __func__, transport->inet->sk_shutdown);
> > +       }
> > +       if ((1 << state) & (TCPF_ESTABLISHED|TCPF_SYN_SENT)) {
> > +               if (transport->inet->sk_shutdown == 0)
> > +                       return;
> > +               printk("%s: sk_shutdown set to %d\n",
> > +                       __func__, transport->inet->sk_shutdown);
> > +       }
> >         xs_abort_connection(xprt, transport);
> >  }
> >
> > Signed-off-by: Andy Chittenden <andyc.bluearc@gmail.com>
> >
> > dmesg displays:
> >
> > [ 2840.896043] xs_tcp_reuse_connection: TCP_CLOSEd and sk_shutdown
> set to 2
> >
> > so previously the code was attempting to reuse the connection but
> wasn't
> > aborting it and thus didn't clear down sk_shutdown.
> 
> Hi Andy,
> 
> I note that you are adding in two new printk()s. Why should they be
> printk(), and not dprintk()? Are you trying to report an exception that
> the user needs to be aware of, or is this only debugging info that
> we'll
> want to turn off under normal operation?

Hi Trond

Thanks for replying. It was debugging info: the printk()s show what the problem is. I was half expecting someone to pipe up "that isn't the correct way to fix this" and suggest another avenue to look at, or even, hopefully, come up with an alternative appropriate patch as I'm not an expert in this code: I don't know whether the sk_shutdown field being left set has implications elsewhere in the sunrpc code. FWIW I left the test case running overnight and have had only 50 such messages logged so it's not a heavy printk() load.

> 
> Also, it might be useful to add a comment to the code here to remind us
> what the 'sk_shutdown == 0' case corresponds to as far as the socket
> state is concerned, so that the casual reader can see why we shouldn't
> reset the connection.

If I knew what sk_shutdown == 0 really corresponded to, I could well add a comment! :-). I just knew that in 2.6.26 we didn't see this problem and that in later kernels the connection abort sequence was being done conditionally and that the sk_shutdown flag being left set was making tcp_sendmsg return an error. So, putting two and two together, I've effectively just added another condition in which to abort the connection.

As nobody has objected to the essence of my patch, I'll attempt a new patch that changes those printk()s into dprintk() and drop in what I think are appropriate comments. So here's a revised patch:

# diff -up /home/company/software/src/linux-2.6.34.2/net/sunrpc/xprtsock.c net/sunrpc/xprtsock.c 
--- /home/company/software/src/linux-2.6.34.2/net/sunrpc/xprtsock.c     2010-08-02 18:30:51.000000000 +0100
+++ net/sunrpc/xprtsock.c       2010-08-06 08:09:08.000000000 +0100
@@ -1322,10 +1322,11 @@ static void xs_tcp_state_change(struct s
        if (!(xprt = xprt_from_sock(sk)))
                goto out;
        dprintk("RPC:       xs_tcp_state_change client %p...\n", xprt);
-       dprintk("RPC:       state %x conn %d dead %d zapped %d\n",
+       dprintk("RPC:       state %x conn %d dead %d zapped %d sk_shutdown %d\n",
                        sk->sk_state, xprt_connected(xprt),
                        sock_flag(sk, SOCK_DEAD),
-                       sock_flag(sk, SOCK_ZAPPED));
+                       sock_flag(sk, SOCK_ZAPPED),
+                       sk->sk_shutdown);
 
        switch (sk->sk_state) {
        case TCP_ESTABLISHED:
@@ -1796,10 +1797,25 @@ static void xs_tcp_reuse_connection(stru
 {
        unsigned int state = transport->inet->sk_state;
 
-       if (state == TCP_CLOSE && transport->sock->state == SS_UNCONNECTED)
-               return;
-       if ((1 << state) & (TCPF_ESTABLISHED|TCPF_SYN_SENT))
-               return;
+       if (state == TCP_CLOSE && transport->sock->state == SS_UNCONNECTED) {
+               /* we don't need to abort the connection if the socket
+                * hasn't undergone a shutdown
+                */
+               if (transport->inet->sk_shutdown == 0)
+                       return;
+               dprintk("RPC:       %s: TCP_CLOSEd and sk_shutdown set to %d\n",
+                       __func__, transport->inet->sk_shutdown);
+       }
+       if ((1 << state) & (TCPF_ESTABLISHED|TCPF_SYN_SENT)) {
+               /* we don't need to abort the connection if the socket
+                * hasn't undergone a shutdown
+                */
+               if (transport->inet->sk_shutdown == 0)
+                       return;
+               dprintk("RPC:       %s: ESTABLISHED/SYN_SENT "
+                               "sk_shutdown set to %d\n",
+                               __func__, transport->inet->sk_shutdown);
+       }
        xs_abort_connection(xprt, transport);
 }

Signed-off-by: Andy Chittenden <andyc.bluearc@gmail.com>


