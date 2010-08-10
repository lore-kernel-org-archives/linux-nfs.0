Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:56590 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872Ab0HJIkw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Aug 2010 04:40:52 -0400
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
References: <4c57cfe8.887b0e0a.2f79.4772@mx.google.com> <20100803.012144.267950450.davem@davemloft.net> <20100803021110.f0b3877b.akpm@linux-foundation.org> <4C57EE9A.7040308@gmail.com>  <4c5ad0d6.42ecd80a.47d7.0dfc@mx.google.com> <1281037822.2948.49.camel@heimdal.trondhjem.org> <4c5bd64a.4a2ae30a.0283.0551@mx.google.com> <4c5fc9f3.487e0e0a.2960.ffffe4ec@mx.google.com> <1281372927.8950.3.camel@heimdal.trondhjem.org>
In-Reply-To: <1281372927.8950.3.camel@heimdal.trondhjem.org>
Subject: RE: [PATCH] [Bug 16494] NFS client over TCP hangs due to packet loss
Date: Tue, 10 Aug 2010 09:40:46 +0100
Message-ID: <4c611091.487e0e0a.39f4.372b@mx.google.com>
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> On Mon, 2010-08-09 at 10:27 +0100, Andy Chittenden wrote:
> > A weekend run with that patch applied to 2.6.34.2 was successful. As
> nobody has objected, what's the next step to getting it applied to the
> official source trees?
> 
> Please resend me a version with a cleaned up changelog entry. I can
> then
> push it as a bugfix.
> 
> Cheers
>   Trond

Thanks. I think this sums it up:

SUNRPC: fix NFS client over TCP hangs due to packet loss (Bug 16494)

When reusing a TCP connection, ensure that it's aborted if a previous shutdown attempt has been made on that connection so that the RPC over TCP recovery mechanism succeeds.

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

